// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// 
// Copyright (c) 2016 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the 
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
// 
// File:    RVIServiceBundle.m
// Project: HVACDemo
// 
// Created by Lilli Szafranski on 1/28/16.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import "RVIServiceBundle.h"
#import "RVINode.h"
#import "RVIService.h"

@interface RVIService (BundleStuff)
- (BOOL)hasNodeIdentifier;
- (NSString *)getFullyQualifiedServiceName;
@end

@interface RVINode (BundleStuff)
- (void)announceServices;
- (void)invokeService:(RVIService *)service;
@end

@interface RVIServiceBundle ()
@property (nonatomic, strong) NSMutableDictionary *localServices;
@property (nonatomic, strong) NSMutableDictionary *remoteServices;
@property (nonatomic, strong) NSMutableDictionary *pendingServiceInvocations;
@property (nonatomic, strong) RVINode  *node;
@property (nonatomic, strong) NSString *bundleIdentifier;
@property (nonatomic, strong) NSString *domain;
@property (nonatomic, strong) NSString *localNodeIdentifier;
@end

@implementation RVIServiceBundle
{

}

- (NSString *)validated:(NSString *)identifier
{
    // TODO: PORT_COMPLETE
//    if (identifier == nil) throw new IllegalArgumentException("Input parameter can't be null.");
//    if (identifier.equals("")) throw new IllegalArgumentException("Input parameter can't be an empty string.");
//
//    String regex = "^[a-zA-Z0-9_\\.]*$";
//    boolean hasSpecialChar = !identifier.matches(regex);
//
//    if (hasSpecialChar)
//        throw new IllegalArgumentException("Input parameter contains a non-alphanumeric/underscore character.");

    return identifier;
}

/**
 * Instantiates a new Service bundle.
 *
 * @param context          the Application context. This value cannot be null.
 * @param domain           the domain portion of the RVI node's prefix (e.g., "jlr.com"). The domain must only contain
 *                         alphanumeric characters, underscores, and/or periods. No other characters or whitespace are
 *                         allowed. This value cannot be an empty string or null.
 * @param bundleIdentifier the bundle identifier (e.g., "hvac") The bundle identifier must only contain
 *                         alphanumeric characters, underscores, and/or periods. No other characters or whitespace
 *                         are allowed.  This value cannot be an empty string or null.
 * @param servicesIdentifiers a list of the identifiers for all the local services. The service identifiers must only contain
 *                            alphanumeric characters, underscores, and/or periods. No other characters or whitespace are allowed.
 *                            This value cannot be an empty string or null.
 */
- (id)initWithDomain:(NSString *)domain bundleIdentifier:(NSString *)bundleIdentifier serviceIdentifiers:(NSArray *)serviceIdentifiers
{
    if ((domain == nil) || (bundleIdentifier == nil) || (serviceIdentifiers == nil))
        return nil;

    if ((self = [super init]))
    {
        _domain = [self validated:[domain copy]];
        _bundleIdentifier = [self validated:[bundleIdentifier copy]];
        _localNodeIdentifier = [RVINode getLocalNodeIdentifier];

        _localServices = [self makeServices:serviceIdentifiers];

        _remoteServices = [NSMutableDictionary dictionary];
        _pendingServiceInvocations = [NSMutableDictionary dictionary];

    }

    return self;
}

+ (id)serviceBundleWithDomain:(NSString *)domain bundleIdentifier:(NSString *)bundleIdentifier serviceIdentifiers:(NSArray *)serviceIdentifiers
{
    return [[RVIServiceBundle alloc] initWithDomain:domain bundleIdentifier:bundleIdentifier serviceIdentifiers:serviceIdentifiers];
}

- (NSMutableDictionary *)makeServices:(NSArray *)serviceIdentifiers
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[serviceIdentifiers count]];

    if (serviceIdentifiers == nil) return dict;

    for (NSString *serviceIdentifier in serviceIdentifiers)
        dict[[self validated:serviceIdentifier]] = [RVIService serviceWithServiceIdentifier:serviceIdentifier
                                                                                         domain:self.domain
                                                                               bundleIdentifier:self.bundleIdentifier
                                                                                         prefix:self.localNodeIdentifier];

    return dict;
}

/**
 * Gets the service object, given the service identifier. If one does not exist with that identifier, it is created.
 *
 * @param serviceIdentifier the service identifier
 * @return the service
 */
- (RVIService *)getRemoteService:(NSString *)serviceIdentifier
{
    id service;
    if (nil != (service = self.remoteServices[serviceIdentifier]))
        return service;

    return [RVIService serviceWithServiceIdentifier:serviceIdentifier domain:self.domain bundleIdentifier:self.bundleIdentifier prefix:nil];
}

- (void)addLocalService:(NSString *)serviceIdentifier
{
    if (!self.localServices[serviceIdentifier])
        self.localServices[serviceIdentifier] = [RVIService serviceWithServiceIdentifier:serviceIdentifier domain:self.domain bundleIdentifier:self.bundleIdentifier prefix:self.localNodeIdentifier];


    if (self.node != nil) [self.node announceServices];
}

- (void)addLocalServices:(NSArray *)serviceIdentifiers
{
    for (NSString *serviceIdentifier in serviceIdentifiers)
        self.localServices[serviceIdentifier] = [RVIService serviceWithServiceIdentifier:serviceIdentifier domain:self.domain bundleIdentifier:self.bundleIdentifier prefix:self.localNodeIdentifier];

    if (self.node != nil) [self.node announceServices];
}

- (void)removeLocalService:(NSString *)serviceIdentifier
{
    [self.localServices removeObjectForKey:serviceIdentifier];

    if (self.node != nil) [self.node announceServices];
}

- (void)removeAllLocalServices
{
    [self.localServices removeAllObjects];

    if (self.node != nil) [self.node announceServices];
}

/**
 * Add a remote service to the service bundle. If there is a pending service invocation with a matching service
 * identifier, this invocation is sent to the remote node.
 *
 * @param serviceIdentifier the identifier of the service
 */
- (void)addRemoteService:(NSString *)serviceIdentifier withNodeIdentifier:(NSString *)remoteNodeIdentifier
{
    if (!self.remoteServices[serviceIdentifier])
        self.remoteServices[serviceIdentifier] = [RVIService serviceWithServiceIdentifier:serviceIdentifier domain:self.domain bundleIdentifier:self.bundleIdentifier prefix:remoteNodeIdentifier];

    RVIService *pendingServiceInvocation = self.pendingServiceInvocations[serviceIdentifier];
    if (pendingServiceInvocation != nil) {
        if (pendingServiceInvocation.timeout >= [[NSDate date] timeIntervalSince1970] * 1000) {
            pendingServiceInvocation.nodeIdentifier = remoteNodeIdentifier;
            [self.node invokeService:pendingServiceInvocation];
        }

        [self.pendingServiceInvocations removeObjectForKey:serviceIdentifier];
    }
}

/**
 * Remote a remote service from the service bundle.
 * @param serviceIdentifier the identifier of the service
 */
- (void)removeRemoteService:(NSString *)serviceIdentifier
{
    [self.remoteServices removeObjectForKey:serviceIdentifier];
}

/**
 * Remove all remote services from the service bundle.
 */
- (void)removeAllRemoteServices
{
    [self.remoteServices removeAllObjects];
}

- (void)invokeService:(NSString *)serviceIdentifier withParams:(NSObject *)parameters timeout:(NSInteger)timeout
{
    RVIService *service = [self getRemoteService:serviceIdentifier];

    service.parameters = parameters;
    service.timeout = ([[NSDate date] timeIntervalSince1970] * 1000) + timeout;

    if ([service hasNodeIdentifier] && self.node != nil) // TODO: Check the logic here
        [self.node invokeService:service];
    else
        self.pendingServiceInvocations[serviceIdentifier] = service;
}

/**
 * Service invoked.
 *
 * @param service the service
 */
- (void)serviceInvoked:(RVIService *)service
{
    [self.delegate onServiceInvoked:self withIdentifier:service.bundleIdentifier params:service.parameters];
}

/**
 * Gets a list of fully-qualified services names of all the local services.
 *
 * @return the local services
 */
- (NSArray *)getFullyQualifiedLocalServiceNames
{
    NSMutableArray *fullyQualifiedLocalServiceNames = [NSMutableArray arrayWithCapacity:[self.localServices count]];
    for (RVIService *service in [self.localServices allValues])
        if ([service getFullyQualifiedServiceName] != nil)
            [fullyQualifiedLocalServiceNames addObject:[service getFullyQualifiedServiceName]];

    return fullyQualifiedLocalServiceNames;
}

- (NSString *)getBundleIdentifier
{
    return self.bundleIdentifier;
}

/**
 * Gets the domain.
 *
 * @return the domain
 */
- (NSString *)getDomain
{
    return self.domain;
}
@end
