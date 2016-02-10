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

@interface HVACManager () <RVINodeDelegate, RVIServiceBundleDelegate>

@property (nonatomic, strong) RVINode   *node;
@property (nonatomic, strong) RVIServiceBundle *hvacBundle;
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


        _sharedManager.node       = [RVINode node];
        _sharedManager.hvacBundle = [RVIServiceBundle serviceBundleWithDomain:RVI_DOMAIN bundleIdentifier:HVAC_BUNDLE_IDENTIFER serviceIdentifiers:@[@"seat_heat_right"]];

        [_sharedManager.hvacBundle setDelegate:_sharedManager];
        [_sharedManager.node setDelegate:_sharedManager];

        //[_sharedManager.node setServerUrl:@"192.168.16.197"];
        [_sharedManager.node setServerUrl:@"192.168.16.132"];
        [_sharedManager.node setServerPort:8820];
        [_sharedManager.node setServerCertificate:@"lilli_ios_cert" serverDomain:RVI_DOMAIN clientCertificate:@"client" clientCertificatePassword:@"password"];
        [_sharedManager.node addBundle:_sharedManager.hvacBundle];
    });

    return _sharedManager;
}

- (void)sendService:(NSString *)service value:(NSString *)value
{
    [self.hvacBundle invokeService:service
                        withParams:@{@"sending_node" : [NSString stringWithFormat:@"%@/%@/",RVI_DOMAIN, [RVINode getLocalNodeIdentifier]],
                                   @"value" : value }
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
