// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
// Copyright (c) 2015 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
//
// File:    RPCRequest.m
// Project: HVACDemo
//
// Created by Lilli Szafranski on 5/1/15.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import "RPCRequest.h"


@implementation RPCRequest
{

}

- (id)init
{
    if ((self = [super init]))
    {
        _version  = @"2.0";
        _method   = nil;
        _params   = nil;
        _callback = nil;

        self.id = [@(arc4random()) stringValue];
    }

    return self;
}

+ (id)requestWithMethod:(NSString *)method
{
    RPCRequest *request = [[RPCRequest alloc] init];
    request.method = method;

    return request;
}

+ (id)requestWithMethod:(NSString *)method params:(id)params
{
    RPCRequest *request = [self requestWithMethod:method];
    request.params = params;

    return request;
}

+ (id)requestWithMethod:(NSString *)method params:(id)params callback:(RPCRequestCallback)callback
{
    RPCRequest *request = [self requestWithMethod:method params:params];
    request.callback = callback;

    return request;
}

- (NSMutableDictionary *)serialize
{
    NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];

    if (self.version)
        payload[@"jsonrpc"] = self.version;

    if (self.method)
        payload[@"method"] = self.method;

    if (self.params)
        payload[@"params"] = self.params;

    if (self.id)
        payload[@"id"] = self.id;

    return payload;
}

@end
