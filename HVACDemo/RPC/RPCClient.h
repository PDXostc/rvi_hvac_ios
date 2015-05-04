// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
// Copyright (c) 2015 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
//
// File:    RPCClient.h
// Project: HVACDemo
//
// Created by Lilli Szafranski on 5/1/15.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import <Foundation/Foundation.h>
#import "RPCRequest.h"

@interface RPCClient : NSObject

/**
 * Initialized an RPC Client with a specific end point.
 *
 * @param NSString endpoint The URL to the RPC Server
 * @return RPCClient
 */
- (id)initWithServiceEndpoint:(NSString *)endpoint;

/**
 * Posts a single single RPC request
 *
 */
- (void)postRequest:(RPCRequest*)request;

@end
