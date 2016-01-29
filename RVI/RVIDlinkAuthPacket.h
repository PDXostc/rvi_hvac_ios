// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// 
// Copyright (c) 2016 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the 
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
// 
// File:    RVIDlinkAuthPacket.h
// Project: HVACDemo
// 
// Created by Lilli Szafranski on 1/28/16.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import <Foundation/Foundation.h>
#import "RVIDlinkPacket.h"


@interface RVIDlinkAuthPacket : RVIDlinkPacket
@property (nonatomic, strong) NSString *addr;

@property (nonatomic) NSInteger port;

@property (nonatomic, strong) NSString *version;

@property (nonatomic, strong) NSObject *creds;


/**
 * Constructor
 *
 * @param creds The credentials
 */
- (id)initWithCredentials:(NSObject *)creds;
+ (id)dlinkAuthPacketWithCredentials:(NSObject *)creds;

- (id)initWithDictionary:(NSDictionary *)dict;
+ (id)dlinkAuthPacketWithDictionary:(NSDictionary *)dict;
@end
