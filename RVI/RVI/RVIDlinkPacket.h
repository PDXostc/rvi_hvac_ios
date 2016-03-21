// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// 
// Copyright (c) 2016 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the 
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
// 
// File:    RVIDlinkPacket.h
// Project: HVACDemo
// 
// Created by Lilli Szafranski on 1/28/16.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import <Foundation/Foundation.h>


/**
 * The Command enumeration, used to enumerate the different commands, or dlink packet types
 */
typedef enum
{
    NONE,
    /**
     * The AUTHORIZE dlink packet type ("cmd":"au").
     */
    AUTHORIZE,
    /**
     * The SERVICE_ANNOUNCE dlink packet type ("cmd":"sa").
     */
    SERVICE_ANNOUNCE,
    /**
     * The RECEIVE dlink packet type ("cmd":"rcv").
     */
    RECEIVE,
    /**
     * The PING dlink packet type ("cmd":"ping").
     */
    PING,
} DlinkCommand;


@interface RVIDlinkPacket : NSObject
/**
 * The transaction id.
 */
@property (nonatomic) NSInteger tid;

/**
 * The cmd that was used in the request ("au", "sa", "rcv", or "ping").
 */
@property (nonatomic) DlinkCommand command;

/**
 * The log id string used by rvi_core
 */
@property (nonatomic, strong) NSString *logId;

/**
 * Serializes the object into a json string
 * @return the serialized json string
 */
- (NSDictionary *)toDictionary;

/**
 * Base constructor of the DlinkPacket
 * @param command the command ("au", "sa", "rcv", or "ping")
 */
- (id)initWithCommand:(DlinkCommand)command;
+ (id)dlinkPacketWithCommand:(DlinkCommand)command;

/**
 * Instantiates a new Dlink packet.
 *
 * @param command the command
 * @param json an NSDictionary representing the json object
 */
- (id)initFromDictionary:(NSDictionary *)dict;
+ (id)dlinkPacketFromDictionary:(NSDictionary *)dict;
@end
