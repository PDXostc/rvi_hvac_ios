// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
// Copyright (c) 2015 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
//
// File:    RPCResponse.h
// Project: HVACDemo
//
// Created by Lilli Szafranski on 5/14/15.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import <Foundation/Foundation.h>


/**
 * RPC Response object
 *
 * This object is created when the server responds.
 */
@interface RPCResponse : NSObject

/**
 * The RPC Version.
 *
 * @param NSString
 */
@property (nonatomic, strong) NSString *version;

/**
 * The id that was used in the request.
 *
 * @param NSString
 */
@property (nonatomic, strong) NSString *id;

/**
 * RPC Error. If nil, no error occurred
 *
 * @return RPCError
 */
@property (nonatomic, strong) NSError *error;

/**
 * An object representation the result from the method on the server
 *
 * @param id
 */
@property (nonatomic, strong) id result;


#pragma mark - Methods

- (id)initWithError:(NSError *)error;

/**
 * Helper method to get an RPCResponse object with an error set
 *
 * @param NSError error The error for the response
 * @return RPCRequest
 */
+ (id)responseWithError:(NSError *)error;

@end
