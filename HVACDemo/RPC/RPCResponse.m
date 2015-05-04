// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
// Copyright (c) 2015 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
//
// File:    RPCResponse.m
// Project: HVACDemo
//
// Created by Lilli Szafranski on 5/1/15.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import "RPCResponse.h"


@implementation RPCResponse
{

}

- (id)initWithError:(NSError *)error
{
    if ((self = [super init]))
    {
        _error   = error;

        _version = nil;
        _result  = nil;
        _id      = nil;
    }

    return self;
}

+ (id)responseWithError:(NSError *)error
{
    return  [[RPCResponse alloc] initWithError:error];
}
@end
