// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// 
// Copyright (c) 2016 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the 
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
// 
// File:    RVIDlinkServiceAnnouncePacket.m
// Project: HVACDemo
// 
// Created by Lilli Szafranski on 1/28/16.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import "RVIDlinkServiceAnnouncePacket.h"


@implementation RVIDlinkServiceAnnouncePacket
{

}

- (id)initWithServices:(NSArray *)services
{
    if (services == nil)
        return nil;

    if ((self = [super initWithCommand:SERVICE_ANNOUNCE]))
    {
        _services = [services copy];
        _status = @"av";
    }

    return self;
}

+ (id)dlinkServiceAnnoucePacketWithServices:(NSArray *)services
{
    return [[RVIDlinkServiceAnnouncePacket alloc] initWithServices:services];
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    if (dict == nil)
        return nil;

    if ((self = [super initFromDictionary:dict]))
    {
        _services = dict[@"svcs"];
        _status = dict[@"stat"];
    }

    return self;
}

+ (id)dlinkServiceAnnouncePacketWithDictionary:(id)dictionary
{
    return [[RVIDlinkServiceAnnouncePacket alloc] initWithDictionary:dictionary];
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dict = (NSMutableDictionary *)[super toDictionary];

    dict[@"svcs"] = self.services; // TODO - jsonify
    dict[@"stat"] = self.status;

    return [NSDictionary dictionaryWithDictionary:dict];
}
@end
