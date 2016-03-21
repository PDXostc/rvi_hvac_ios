// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// 
// Copyright (c) 2016 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the 
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
// 
// File:    RVINode.m
// Project: HVACDemo
// 
// Created by Lilli Szafranski on 1/28/16.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import "RVINode.h"
#import "RVIRemoteConnectionManager.h"
#import "RVIServiceBundle.h"
#import "RVIDlinkServiceAnnouncePacket.h"
#import "RVIService.h"
#import "RVIDlinkReceivePacket.h"
#import "RVIDlinkAuthPacket.h"
#import "RVIUtil.h"

@protocol RVIBundleInterface <NSObject>
@property (nonatomic, strong) NSString *bundleIdentifier;
@property (nonatomic, strong) NSString *domain;

@end

@interface RVIServiceBundle (NodeStuff)
@property (nonatomic, strong) RVINode  *node;

- (void)serviceInvoked:(RVIService *)service;
- (NSArray *)getFullyQualifiedLocalServiceNames;
- (void)addRemoteService:(NSString *)serviceIdentifier withNodeIdentifier:(NSString *)remoteNodeIdentifier;
@end


@interface RVINode () <RVIRemoteConnectionManagerDelegate>
@property (nonatomic, strong) NSMutableDictionary        *allServiceBundles;
@property (nonatomic, strong) RVIRemoteConnectionManager *remoteConnectionManager;
@property (nonatomic, readwrite) bool                    isConnected;
@end

@implementation RVINode
{

}

- (id)init
{
    if ((self = [super init]))
    {
        _allServiceBundles = [NSMutableDictionary dictionary];
        _remoteConnectionManager = [RVIRemoteConnectionManager remoteConnectionManager];

        [_remoteConnectionManager setDelegate:self];
    }

    return self;
}

+ (id)node
{
    return [[RVINode alloc] init];
}

- (void)setServerUrl:(NSString *)serverUrl
{
    [self.remoteConnectionManager setServerUrl:serverUrl];
}

- (void)setServerPort:(UInt32)serverPort
{
    [self.remoteConnectionManager setServerPort:serverPort];
}

- (void)setServerCertificate:(NSString *)serverCertificate serverDomain:(NSString *)serverDomain clientCertificate:(NSString *)clientCertificate clientCertificatePassword:(NSString *)clientCertificatePassword
{
    [self.remoteConnectionManager setServerCertificate:serverCertificate serverDomain:serverDomain clientCertificate:clientCertificate clientCertificatePassword:clientCertificatePassword];
}

- (void)setBluetoothDeviceAddress:(NSString *)deviceAddress
{
    [self.remoteConnectionManager setBluetoothDeviceAddress:deviceAddress];
}

- (void)setBluetoothServiceRecord:(NSUUID *)serviceRecord
{
    [self.remoteConnectionManager setBluetoothServiceRecord:serviceRecord];
}

- (void)setBluetoothChannel:(NSInteger)channel
{
    [self.remoteConnectionManager setBluetoothChannel:channel];
}

- (void)connect:(RemoteConnectionType)type
{
    [self.remoteConnectionManager connect:type];
}

- (void)disconnect:(RemoteConnectionType)type
{
    [self.remoteConnectionManager disconnect:type];
}

- (void)connectServer
{
    [self connect:SERVER];
}

- (void)disconnectServer
{
    [self disconnect:SERVER];
}

- (void)connectBluetooth
{
   [self connect:BLUETOOTH];
}

- (void)disconnectBluetooth
{
    [self connect:BLUETOOTH];
}

- (void)connect
{
    [self connect:GLOBAL];
}

- (void)disconnect
{
    [self disconnect:GLOBAL];
}

- (NSString *)bundleKey:(id<RVIBundleInterface>)bundle
{
    return [NSString stringWithFormat:@"%@:%@", bundle.domain, bundle.bundleIdentifier];
}

- (void)addBundle:(RVIServiceBundle *)bundle
{
    bundle.node = self;
    self.allServiceBundles[[self bundleKey:(id <RVIBundleInterface>)bundle]] = bundle;
    [self announceServices];
}

- (void)removeBundle:(RVIServiceBundle *)bundle
{
    bundle.node = nil;
    [self.allServiceBundles removeObjectForKey:[self bundleKey:(id <RVIBundleInterface>)bundle]];
    [self announceServices];
}

/**
 * Have the local node announce all it's available services.
 */
- (void)announceServices
{
    NSMutableArray *allServices = [NSMutableArray arrayWithCapacity:self.allServiceBundles.count];
    for (RVIServiceBundle *bundle in [self.allServiceBundles allValues])
        [allServices addObjectsFromArray:[bundle getFullyQualifiedLocalServiceNames]];

    [self.remoteConnectionManager sendPacket:[RVIDlinkServiceAnnouncePacket serviceAnnouncePacketWithServices:allServices]];
}

/**
 * Invoke service.
 *
 * @param service the service
 */
- (void)invokeService:(RVIService *)service
{
    [self.remoteConnectionManager sendPacket:[RVIDlinkReceivePacket receivePacketWithService:service]];
}

- (void)handleReceivePacket:(RVIDlinkReceivePacket *)packet
{
    RVIService *service = packet.service;

    RVIServiceBundle *bundle = self.allServiceBundles[[self bundleKey:(id <RVIBundleInterface>)service]];

    if (bundle != nil)
        [bundle serviceInvoked:service];
}

- (void)handleServiceAnnouncePacket:(RVIDlinkServiceAnnouncePacket *)packet
{
    for (NSString * fullyQualifiedRemoteServiceName in packet.services)
    {
        NSArray * serviceParts = [fullyQualifiedRemoteServiceName componentsSeparatedByString:@"/"];

        if ([serviceParts count] != 5) return;

        NSString *domain = serviceParts[0];
        NSString *nodeIdentifier = [NSString stringWithFormat:@"%@/%@",  serviceParts[1], serviceParts[2]];
        NSString *bundleIdentifier = serviceParts[3];
        NSString *serviceIdentifier = serviceParts[4];

        RVIServiceBundle *bundle = self.allServiceBundles[[NSString stringWithFormat:@"%@:%@", domain, bundleIdentifier]];

        if (bundle != nil)
            [bundle addRemoteService:serviceIdentifier withNodeIdentifier:nodeIdentifier];
    }
}

- (void)handleAuthPacket:(RVIDlinkAuthPacket *)packet
{
    [self announceServices];
}

//private final static String SHARED_PREFS_STRING         = "com.rvisdk.settings";
//private final static String LOCAL_SERVICE_PREFIX_STRING = "localServicePrefix";
//
//// TODO: Test and verify this function
//private static String uuidB58String( {
//    UUID uuid = UUID.randomUUID();
//    String b64Str;
//
//    ByteBuffer bb = ByteBuffer.wrap(new byte[16]);
//    bb.putLong(uuid.getMostSignificantBits());
//    bb.putLong(uuid.getLeastSignificantBits());
//
//    b64Str = Base64.encodeToString(bb.array(), Base64.DEFAULT);
//    b64Str = b64Str.split("=")[0];
//
//    b64Str = b64Str.replace('+', 'P');
//    b64Str = b64Str.replace('/', 'S'); /* Reduces likelihood of uniqueness but stops non-alphanumeric characters from screwing up any urls or anything */
//
//    return b64Str;
//}

/**
 * Gets the prefix of the local RVI node
 *
 * @param context the application context
 * @return the local prefix
 */
#define LOCAL_SERVICE_PREFIX_STRING_KEY @"org.genivi.rvi.local_service_prefix_string_key"
+ (NSString *)getLocalNodeIdentifier
{
    NSString *savedIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:LOCAL_SERVICE_PREFIX_STRING_KEY];

    if (!savedIdentifier)
    {
        savedIdentifier = [NSString stringWithFormat:@"ios/%@", [[NSUUID UUID] UUIDString]];
        [[NSUserDefaults standardUserDefaults] setObject:savedIdentifier forKey:LOCAL_SERVICE_PREFIX_STRING_KEY];
    }

    return savedIdentifier;
}

- (void)onRVIDidConnect
{
    DLog(@"");

    self.isConnected = YES;
    [self.delegate nodeDidConnect];

    [self.remoteConnectionManager sendPacket:[RVIDlinkAuthPacket authPacketWithCredentials:@[@"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJyaWdodF90b19pbnZva2UiOlsiZ2VuaXZpLm9yZyJdLCJpc3MiOiJqbHIuY29tIiwiZGV2aWNlX2NlcnQiOiJNSUlCOHpDQ0FWd0NBUUV3RFFZSktvWklodmNOQVFFTEJRQXdRakVMTUFrR0ExVUVCaE1DVlZNeER6QU5CZ05WQkFnTUJrOXlaV2R2YmpFUk1BOEdBMVVFQnd3SVVHOXlkR3hoYm1ReER6QU5CZ05WQkFvTUJrZEZUa2xXU1RBZUZ3MHhOVEV4TWpjeU16RTBOVEphRncweE5qRXhNall5TXpFME5USmFNRUl4Q3pBSkJnTlZCQVlUQWxWVE1ROHdEUVlEVlFRSURBWlBjbVZuYjI0eEVUQVBCZ05WQkFjTUNGQnZjblJzWVc1a01ROHdEUVlEVlFRS0RBWkhSVTVKVmtrd2daOHdEUVlKS29aSWh2Y05BUUVCQlFBRGdZMEFNSUdKQW9HQkFKdHZpTThBUklyRnF1UGMwbXlCOUJ1RjlNZGtBLzJTYXRxYlpNV2VUT1VKSEdyakJERUVNTFE3ems4QXlCbWk3UnF1WVlaczY3U3lMaHlsVkdLaDZzSkFsZWN4YkhVd2o3Y1pTUzFibUtNamU2TDYxZ0t3eEJtMk5JRlUxY1ZsMmpKbFRhVTlWWWhNNHhrNTd5ajI4bmtOeFNZV1AxdmJGWDJORFgyaUg3YjVBZ01CQUFFd0RRWUpLb1pJaHZjTkFRRUxCUUFEZ1lFQWhicVZyOUUvME03MjluYzZESStxZ3FzUlNNZm95dkEzQ21uL0VDeGwxeWJHa3V6TzdzQjhmR2pnTVE5enpjYjZxMXVQM3dHalBpb3FNeW1pWVlqVW1DVHZ6ZHZSQlorNlNEanJaZndVdVlleGlLcUk5QVA2WEthSGxBTDE0K3JLKzZITjR1SWtaY0l6UHdTTUhpaDFic1RScHlZNVozQ1VEY0RKa1l0VmJZcz0iLCJ2YWxpZGl0eSI6eyJzdGFydCI6MTQ1MjE5Mjc3Nywic3RvcCI6MTQ4MzcyODc3N30sInJpZ2h0X3RvX3JlZ2lzdGVyIjpbImdlbml2aS5vcmciXSwiY3JlYXRlX3RpbWVzdGFtcCI6MTQ1MjE5Mjc3NywiaWQiOiJpbnNlY3VyZV9jcmVkZW50aWFscyJ9.TBDUJFL1IQ039Lz7SIkcblhz62jO35STJ8OiclL_xlxEE_L_EjnELrDOGvkIh7zhhl8RMHkUJcTFQKF7P6WDJ5rUJejXJlkTRf-aVmHqEhpspRw6xD2u_2A9wmTWLJF94_wsEb7M7xWCXVrbexu_oik85zmuxRQgRE5wrTC7DDQ"]]];
}

- (void)onRVIDidDisconnect:(NSError *)error
{
    DLog(@"%@", [error localizedDescription]);

    self.isConnected = NO;
    [self.delegate nodeDidDisconnect:error];
}

- (void)onRVIDidFailToConnect:(NSError *)error
{
    DLog(@"%@", [error localizedDescription]);

    self.isConnected = NO;
    [self.delegate nodeDidFailToConnect:error];
}

- (void)onRVIDidReceivePacket:(RVIDlinkPacket *)packet
{
    if (packet == nil) return;

    DLog(@"%@", [[packet class] description]);

    if ([packet isMemberOfClass:[RVIDlinkReceivePacket class]]) {
        [self handleReceivePacket:((RVIDlinkReceivePacket *)packet)];

    } else if ([packet isMemberOfClass:[RVIDlinkServiceAnnouncePacket class]]) {
        [self handleServiceAnnouncePacket:((RVIDlinkServiceAnnouncePacket *)packet)];

    } else if ([packet isMemberOfClass:[RVIDlinkAuthPacket class]]) {
        [self handleAuthPacket:((RVIDlinkAuthPacket *)packet)];

    }
}

- (void)onRVIDidSendPacket:(RVIDlinkPacket *)packet
{
    if (packet == nil) return;

    DLog(@"%@", [[packet class] description]);

    if ([packet isMemberOfClass:[RVIDlinkAuthPacket class]])
        [self announceServices];
}

- (void)onRVIDidFailToSendPacket:(NSError *)error
{
    DLog(@"%@", [error localizedDescription]);
}
@end
