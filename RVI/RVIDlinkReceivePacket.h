// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// 
// Copyright (c) 2016 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the 
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
// 
// File:    RVIDlinkReceivePacket.h
// Project: HVACDemo
// 
// Created by Lilli Szafranski on 1/28/16.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import <Foundation/Foundation.h>
#import "RVIDlinkPacket.h"

@class RVIService;

@interface RVIDlinkReceivePacket : RVIDlinkPacket
{

}
/**
 * The mod parameter.
 * This client is only using 'proto_json_rpc' at the moment.
 */
@property (nonatomic, strong) NSString *mod;

/**
 * The Service used to create the request params.
 */
@property (nonatomic, strong) RVIService *service;

/**
 * Constructor
 *
 * @param service The service that is getting invoked
 */
- (id)initWithService:(RVIService *)service;
+ (id)receivePacketWithService:(RVIService *)service;

- (id)initWithDictionary:(NSDictionary *)dict;
+ (id)receivePacketWithDictionary:(NSDictionary *)dict;
@end
