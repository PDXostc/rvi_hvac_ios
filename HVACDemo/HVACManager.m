// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// 
// Copyright (c) 2015 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the 
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
// 
// File:    HVACManager.m
// Project: HVACDemo
// 
// Created by Lilli Szafranski on 5/4/15.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import "HVACManager.h"
#import "RVINode.h"

#define SERVICE_IDENTIFIERS @[@"hazard", @"temp_left", @"temp_right", @"seat_heat_left", @"seat_heat_right", @"fan_speed", @"airflow_direction", @"defrost_rear", @"defrost_front", @"defrost_max", @"air_circ", @"fan", @"control_auto", @"unsubscribe", @"subscribe", @"none"]

@interface HVACManager () <RVINodeDelegate, RVIServiceBundleDelegate>

@property (nonatomic, strong) RVINode          *node;
@property (nonatomic, strong) RVIServiceBundle *hvacBundle;
@property (nonatomic, weak)   id<HVACManagerDelegate> delegate;
@end

#define RVI_DOMAIN              @"genivi.org"
#define HVAC_BUNDLE_IDENTIFER   @"hvac"

@implementation HVACManager
{

}

+ (id)sharedManager
{
    static HVACManager *_sharedManager = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _sharedManager = [[HVACManager alloc] init];

        [_sharedManager setNode:[RVINode node]];
        [_sharedManager.node setDelegate:_sharedManager];
    });

    return _sharedManager;
}

+ (void)setDelegate:(id <HVACManagerDelegate>)delegate
{
    [[HVACManager sharedManager] setDelegate:delegate];
}

- (void)invokeService:(HVACServiceIdentifier)service value:(NSObject *)value
{
    [self.hvacBundle invokeService:SERVICE_IDENTIFIERS[service]
                        withParams:@{ @"sending_node" : [NSString stringWithFormat:@"%@/%@/",RVI_DOMAIN, [RVINode getLocalNodeIdentifier]],
                                      @"value"        : value }
                           timeout:10000];
}


+ (void)invokeService:(HVACServiceIdentifier)service value:(NSObject *)value
{
    [[HVACManager sharedManager] invokeService:service value:value];
}

- (void)start
{
    //[self.node setServerUrl:@"192.168.16.197"];
    [self.node setServerUrl:@"192.168.16.132"];
    [self.node setServerPort:8820];
    [self.node setServerCertificate:@"lilli_ios_cert" serverDomain:RVI_DOMAIN clientCertificate:@"client" clientCertificatePassword:@"password"];

    if (self.hvacBundle != NULL)
        [self.node removeBundle:self.hvacBundle];

    self.hvacBundle = [RVIServiceBundle serviceBundleWithDomain:RVI_DOMAIN
                                               bundleIdentifier:HVAC_BUNDLE_IDENTIFER
                                             serviceIdentifiers:[SERVICE_IDENTIFIERS subarrayWithRange:NSMakeRange(0, HSI_END_LOCAL)]];
    [self.hvacBundle setDelegate:self];

    [self.node addBundle:self.hvacBundle];
    [self.node connect];
}

+ (void)start
{
    [[HVACManager sharedManager] start];
}

- (void)restart
{
    [self.node disconnect];
    [self.node connect];
}

+ (void)restart
{
    [[HVACManager sharedManager] restart];
}

- (void)subscribeToHvac
{
    [self invokeService:HSI_SUBSCRIBE
                  value:[NSString stringWithFormat:@"{\"node\":\"%@/%@/\"}", RVI_DOMAIN, [RVINode getLocalNodeIdentifier]]];
}

- (void)nodeDidConnect
{
    [self subscribeToHvac];
    [self.delegate onNodeConnected];
}

- (void)nodeDidFailToConnect:(NSError *)trigger
{
    [self.delegate onNodeDisconnected];
}

- (void)nodeDidDisconnect:(NSError *)trigger
{
    [self.delegate onNodeDisconnected];
}

- (void)onServiceInvoked:(RVIServiceBundle *)serviceBundle withIdentifier:(NSString *)serviceIdentifier params:(NSObject *)parameters
{
    NSLog(@"onServiceInvoked...");

    [self.delegate onServiceInvoked:(HVACServiceIdentifier)[SERVICE_IDENTIFIERS indexOfObject:serviceIdentifier]
                          withValue:((NSDictionary *)parameters)[@"value"]];
}

@end
