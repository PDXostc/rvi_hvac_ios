// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// 
// Copyright (c) 2016 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the 
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
// 
// File:    RVIServiceBundle.h
// Project: HVACDemo
// 
// Created by Lilli Szafranski on 1/28/16.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import <Foundation/Foundation.h>

@class RVIServiceBundle;

/**
 * The Service bundle delegate protocol.
 */
@protocol RVIServiceBundleDelegate

/**
 * Callback for when a local service belonging to the bundle was invoked.
 *
 * @param serviceBundle
 * @param serviceIdentifier the service identifier
 * @param parameters the parameters received in the invocation
 */
- (void)onServiceInvoked:(RVIServiceBundle *)serviceBundle withIdentifier:(NSString *)serviceIdentifier params:(NSObject *)parameters;
@end

@interface RVIServiceBundle : NSObject
@property (nonatomic, weak) id<RVIServiceBundleDelegate> delegate;

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
- (id)initWithDomain:(NSString *)domain bundleIdentifier:(NSString *)bundleIdentifier serviceIdentifiers:(NSArray *)serviceIdentifiers;
+ (id)serviceBundleWithDomain:(NSString *)domain bundleIdentifier:(NSString *)bundleIdentifier serviceIdentifiers:(NSArray *)serviceIdentifiers;

/**
 * Add a local service to the service bundle. Adding services triggers a service-announce by the local RVI node.
 * @param serviceIdentifier the identifier of the service
 */
- (void)addLocalService:(NSString *)serviceIdentifier;

/**
 * Add several local services to the service bundle. Adding services triggers a service-announce by the local RVI node.
 * @param serviceIdentifiers a list of service identifiers
 */
- (void)addLocalServices:(NSArray *)serviceIdentifiers;

/**
 * Remote a local service from the service bundle. Removing services triggers a service-announce by the local RVI node.
 * @param serviceIdentifier the identifier of the service
 */
- (void)removeLocalService:(NSString *)serviceIdentifier;

/**
 * Removes all the local services from the service bundle. Removing services triggers a service-announce by the local RVI node.
 */
- (void)removeAllLocalServices;

/**
 * Invoke/update a remote service on the remote RVI node
 *
 * @param serviceIdentifier the service identifier
 * @param parameters the parameters
 * @param timeout the timeout, in milliseconds. This is added to the current system time.
 */
- (void)invokeService:(NSString *)serviceIdentifier withParams:(NSObject *)parameters timeout:(NSInteger)timeout;

/**
 * Gets bundle identifier.
 *
 * @return the bundle identifier
 */
- (NSString *)getBundleIdentifier;
@end
