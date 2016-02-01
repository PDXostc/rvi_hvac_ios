// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// 
// Copyright (c) 2016 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the 
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
// 
// File:    RVIDlinkPacket.m
// Project: HVACDemo
// 
// Created by Lilli Szafranski on 1/28/16.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import "RVIDlinkPacket.h"
#import "RVIDlinkPacketParser.h"


@implementation RVIDlinkPacket
{

}
NSString * stringForCommand(DlinkCommand command)
{
    switch (command)
    {
        case AUTHORIZE:         return @"au";
        case SERVICE_ANNOUNCE:  return @"sa";
        case RECEIVE:           return @"rcv";
        case PING:              return @"ping";
        default:                return @"";
    }
}

DlinkCommand commandForString(NSString * string)
{
    if ([string isEqualToString:@"au"])   return AUTHORIZE;
    if ([string isEqualToString:@"sa"])   return SERVICE_ANNOUNCE;
    if ([string isEqualToString:@"rcv"])  return RECEIVE;
    if ([string isEqualToString:@"ping"]) return PING;

    return NONE;
}

- (NSDictionary *)toDictionary
{
    return [@{@"cmd" : stringForCommand(self.command), @"tid" : @(self.tid), @"rvi_log_id" : (self.logId ? self.logId : @"")} mutableCopy];
}

- (id)initWithCommand:(DlinkCommand)command
{
    static NSInteger tidCounter = 0;

    if (command == NONE)
        return nil;

    if ((self = [super init]))
    {
        _command = command;
        _tid     = tidCounter++;
    }

    return self;
}

+ (id)dlinkPacketWithCommand:(DlinkCommand)command
{
    return [[RVIDlinkPacket alloc] initWithCommand:command];
}

- (id)initFromDictionary:(NSDictionary *)dict
{
    if (dict == nil)
        return nil;

    if ((self = [super init]))
    {
        _command = commandForString(dict[@"cmd"]);
        _tid     = [dict[@"tid"] integerValue];
        _logId   = dict[@"rvi_log_id"];
    }

    return self;
}

+ (id)dlinkPacketFromDictionary:(NSDictionary *)dict
{
    return [[RVIDlinkPacket alloc] initFromDictionary:dict];
}
@end
