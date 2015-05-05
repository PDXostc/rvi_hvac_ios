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

@interface HVACManager ()
@property (nonatomic, strong) NSString  *vin;
@property (nonatomic, strong) NSString  *domain;
@property (nonatomic, strong) NSString  *app;
@property (nonatomic, strong) NSString  *backend;
@property (nonatomic, strong) NSString  *endpoint;
@property (nonatomic, strong) RPCClient *client;

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
        _sharedManager.domain   = @"jlr.com/";
        _sharedManager.vin      = @"vin/lilli";
        _sharedManager.app      = @"/hvac/";
        _sharedManager.backend  = @"/backend/123456789";
        _sharedManager.endpoint = @"http://rvi1.nginfotpdx.net:8801";

        _sharedManager.client   = [[RPCClient alloc] initWithServiceEndpoint:_sharedManager.endpoint];
    });

    return _sharedManager;
}

- (void)sendMethod:(NSString *)method value:(NSString *)value
{
    [self.client postRequest:[RPCRequest requestWithMethod:@"message"
                                            params:@{
                                               @"service_name": [NSString stringWithFormat:@"%@%@%@%@", self.domain, self.vin, self.app, method],
                                               @"timeout": @((NSInteger)([[NSDate date] timeIntervalSince1970] + 5000)),
                                               @"parameters": @[
                                                   @{
                                                           @"sending_node" : [NSString stringWithFormat:@"%@%@", self.domain, self.backend],
                                                           @"value" : value
                                                   }
                                               ]
                                           }
                                          callback:^(RPCResponse *response) {
                                              NSLog(@"Sync request: %@", response);
                                              NSLog(@"Sync request error: %@", response.error);
                                          }]];


}


+ (void)sendMethod:(NSString *)method value:(NSString *)value
{
    [[HVACManager sharedManager] sendMethod:method value:value];
}
@end
