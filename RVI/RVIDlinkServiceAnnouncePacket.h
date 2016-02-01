// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// 
// Copyright (c) 2016 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the 
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
// 
// File:    RVIDlinkServiceAnnouncePacket.h
// Project: HVACDemo
// 
// Created by Lilli Szafranski on 1/28/16.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import <Foundation/Foundation.h>
#import "RVIDlinkPacket.h"


@interface RVIDlinkServiceAnnouncePacket : RVIDlinkPacket
/**
 * The status.
 */
@property (nonatomic, strong) NSString *status;

/**
 * The list of fully-qualified service names that are being announced.
 */
@property (nonatomic, strong) NSArray *services;


/**
 * Constructor
 *
 * @param services The array of services to announce
 */
- (id)initWithServices:(NSArray *)services;
+ (id)serviceAnnouncePacketWithServices:(NSArray *)services;

- (id)initWithDictionary:(NSDictionary *)dict;
+ (id)serviceAnnouncePacketWithDictionary:(NSDictionary *)dict;
@end
