// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// 
// Copyright (c) 2016 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the 
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
// 
// File:    RVIDlinkAuthPacket.m
// Project: HVACDemo
// 
// Created by Lilli Szafranski on 1/28/16.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import "RVIDlinkAuthPacket.h"
#import "RVIDlinkServiceAnnouncePacket.h"


@implementation RVIDlinkAuthPacket
{

}

- (id)initWithCredentials:(NSObject *)creds
{
    if (creds == nil)
        return nil;

    if ((self = [super initWithCommand:SERVICE_ANNOUNCE]))
    {
        _creds = creds;
        _addr = @"0.0.0.0";
        _port = 0;
        _version = @"1.0";
    }

    return self;
}

+ (id)dlinkAuthPacketWithCredentials:(NSObject *)creds
{
    return [[RVIDlinkAuthPacket alloc] initWithCredentials:creds];
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    if (dict == nil)
        return nil;

    if ((self = [super initFromDictionary:dict]))
    {
        _creds = dict[@"creds"];
        _addr = dict[@"addr"];
        _port = [dict[@"port"] integerValue];
        _version = dict[@"ver"];
    }

    return self;
}

+ (id)dlinkAuthPacketWithDictionary:(NSDictionary *)dict
{
    return [[RVIDlinkServiceAnnouncePacket alloc] initWithDictionary:dict];
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dict = (NSMutableDictionary *)[super toDictionary];

    dict[@"creds"] = self.creds; // TODO - jsonify
    dict[@"addr"] = self.addr;
    dict[@"ver"] = self.version;
    dict[@"port"] = @(self.port);

    return [NSDictionary dictionaryWithDictionary:dict];
}
@end
