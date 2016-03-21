// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// 
// Copyright (c) 2016 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the 
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
// 
// File:    RVIDlinkReceivePacket.m
// Project: HVACDemo
// 
// Created by Lilli Szafranski on 1/28/16.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import "RVIDlinkPacket.h"
#import "RVIDlinkReceivePacket.h"
#import "RVIService.h"

@interface RVIService (Serialization)
- (NSDictionary *)toDictionary;
+ (id)serviceFromDictionary:(NSDictionary *)dict;
@end

@implementation RVIDlinkReceivePacket

- (id)initWithService:(RVIService *)service
{
    if (service == nil)
        return nil;

    if ((self = [super initWithCommand:RECEIVE]))
    {
        _service = service;
        _mod = @"proto_json_rpc";
    }

    return self;
}

+ (id)receivePacketWithService:(RVIService *)service
{
    return [[RVIDlinkReceivePacket alloc] initWithService:service];
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    if (dict == nil)
        return nil;

    if ((self = [super initFromDictionary:dict]))
    {

//        NSError *error = nil;
//        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[dict[@"data"] dataUsingEncoding:NSUTF8StringEncoding]
//                                                                 options:NSJSONReadingMutableContainers
//                                                                   error:&error];

        _service = [RVIService serviceFromDictionary:dict[@"data"]];//jsonDict];
        _mod = dict[@"mod"];
    }

    return self;
}

+ (id)receivePacketWithDictionary:(NSDictionary *)dictionary
{
    return [[RVIDlinkReceivePacket alloc] initWithDictionary:dictionary];
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dict = (NSMutableDictionary *)[super toDictionary];

//    NSError *error;
//    NSData *serviceData = [NSJSONSerialization dataWithJSONObject:[self.service toDictionary]
//                                                          options:nil
//                                                            error:&error];
//
//    if (error) {;} // TODO: Process error

    dict[@"data"] = [self.service toDictionary];

//    [[NSString alloc] initWithData:serviceData
//                          encoding:NSUTF8StringEncoding];

    dict[@"mod"] = self.mod;

    return [NSDictionary dictionaryWithDictionary:dict];
}
@end
