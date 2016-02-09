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
#import "RPCClient.h"
#import "RVINode.h"
#import "RVIServiceBundle.h"

@interface HVACManager () <RVINodeDelegate, RVIServiceBundleDelegate>
@property (nonatomic, strong) NSString  *vin;
@property (nonatomic, strong) NSString  *domain;
@property (nonatomic, strong) NSString  *app;
@property (nonatomic, strong) NSString  *backend;
@property (nonatomic, strong) NSString  *endpoint;
@property (nonatomic, strong) RPCClient *client;
@property (nonatomic, strong) RVINode   *node;
@property (nonatomic, strong) RVIServiceBundle *hvacBundle;


@end

@implementation HVACManager
{

}

+ (id)sharedManager
{
    static HVACManager *_sharedManager = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _sharedManager = [[HVACManager alloc] init];
        _sharedManager.domain   = @"jlr.com";
        _sharedManager.vin      = @"/vin/lilli";
        _sharedManager.app      = @"/hvac";
        _sharedManager.backend  = @"/backend/123456789";
        _sharedManager.endpoint = @"http://192.168.6.86:8811";//@"http://rvi1.nginfotpdx.net:8801";

        _sharedManager.client   = [[RPCClient alloc] initWithServiceEndpoint:_sharedManager.endpoint];


        _sharedManager.node       = [RVINode node];
        _sharedManager.hvacBundle = [RVIServiceBundle serviceBundleWithDomain:@"genivi.org" bundleIdentifier:@"hvac" serviceIdentifiers:@[@"seat_heat_right"]];

        [_sharedManager.hvacBundle setDelegate:_sharedManager];
        [_sharedManager.node setDelegate:_sharedManager];

        //[_sharedManager.node setServerUrl:@"192.168.16.197"];
        [_sharedManager.node setServerUrl:@"192.168.16.132"];
        [_sharedManager.node setServerPort:8820];
        [_sharedManager.node addBundle:_sharedManager.hvacBundle];
    });

    return _sharedManager;
}

- (void)sendService:(NSString *)service value:(NSString *)value
{
//    [self.client postRequest:[RPCRequest requestWithMethod:@"message"
//                                            params:@{
//                                               @"service_name": [NSString stringWithFormat:@"%@%@%@%@", self.domain, self.vin, self.app, service],
//                                               @"timeout": @((NSInteger)([[NSDate date] timeIntervalSince1970] + 5)),
//                                               @"parameters": @[
//                                                   @{
//                                                           @"sending_node" : [NSString stringWithFormat:@"%@%@", self.domain, self.backend],
//                                                           @"value" : value
//                                                   }
//                                               ]
//                                           }
//                                          callback:^(RPCResponse *response) {
//                                              NSLog(@"Sync response: %@", response);
//                                              NSLog(@"Sync response error: %@", response.error);
//                                          }]];

    [self.hvacBundle invokeService:@"seat_heat_right"
                        withParams:@{@"sending_node" : [NSString stringWithFormat:@"%@/%@/", @"genivi.org", [RVINode getLocalNodeIdentifier]],
                                   @"value" : @(5)}
                           timeout:10000];
}


+ (void)sendService:(NSString *)service value:(NSString *)value
{
    [[HVACManager sharedManager] sendService:service value:value];
}

- (void)start
{
    [self.node connect];
}

+ (void)start
{
    [[HVACManager sharedManager] start];
}

- (void)nodeDidConnect
{

}

- (void)nodeDidFailToConnect:(NSError *)trigger
{

}

- (void)nodeDidDisconnect:(NSError *)trigger
{

}

- (void)onServiceInvoked:(RVIServiceBundle *)serviceBundle withIdentifier:(NSString *)serviceIdentifier params:(NSObject *)parameters
{
    NSLog(@"onServiceInvoked...");
}

@end
