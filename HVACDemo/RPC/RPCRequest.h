// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
// Copyright (c) 2015 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
//
// File:    RPCRequest.h
// Project: HVACDemo
//
// Created by Lilli Szafranski on 5/41/15.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import <Foundation/Foundation.h>
#import "RPCResponse.h"

typedef void (^RPCRequestCallback)(RPCResponse *response);

@interface RPCRequest : NSObject

/**
 * The RPC Version.
 * This client only supports version 2.0 at the moment.
 *
 * @param NSString
 */
@property (nonatomic, strong) NSString *version;

/**
 * The id that was used in the request. If id is nil the request is treated like a notification.
 *
 * @param NSString
 */
@property (nonatomic, strong) NSString *id;

/**
 * Method to call on the RPC Server.
 *
 * @param NSString
 */
@property (nonatomic, strong) NSString *method;

/**
 * Request params. Either named, un-named, or nil
 *
 * @param id
 */
@property (nonatomic, strong) id params;

/**
 * Callback to call whenever request is finished
 *
 * @param RPCRequestCallback
 */
@property (nonatomic, copy) RPCRequestCallback callback;

#pragma mark - methods

/**
 * Serialized requests object for json encoding
 *
 */
- (NSMutableDictionary *)serialize;

/**
 * Helper method to get a request object
 *
 * @param NSString method The method that this request is for
 * @return RPCRequest
 */
+ (id)requestWithMethod:(NSString *)method;

/**
 * Helper method to get a request object
 *
 * @param NSString method The method that this request is for
 * @param id params Some parameters to send along with the request, either named, un-named, or nil
 * @return RPCRequest
 */
+ (id)requestWithMethod:(NSString *)method params:(id)params;

/**
 * Helper method to get a request object
 *
 * @param NSString method The method that this request is for
 * @param id params Some parameters to send along with the request, either named, un-named, or nil
 * @param RPCRequestCallback The callback to call once the request is finished
 * @return RPCRequest
 */
+ (id)requestWithMethod:(NSString*)method params:(id)params callback:(RPCRequestCallback)callback;
@end
