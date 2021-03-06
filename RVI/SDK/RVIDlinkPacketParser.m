// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// 
// Copyright (c) 2016 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the 
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
// 
// File:    RVIDlinkPacketParser.m
// Project: HVACDemo
// 
// Created by Lilli Szafranski on 1/28/16.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import "RVIDlinkPacketParser.h"
#import "RVIUtil.h"
#import "RVIDlinkPacket.h"
#import "RVIDlinkAuthPacket.h"
#import "RVIDlinkServiceAnnouncePacket.h"
#import "RVIDlinkReceivePacket.h"

@interface RVIDlinkPacketParser ()
@property (nonatomic, strong) NSString *buffer;
@end

@implementation RVIDlinkPacketParser
{

}

- (id)init
{
    if ((self = [super init]))
    {

    }

    return self;
}

+ (id)dlinkPacketParser
{
    return [[RVIDlinkPacketParser alloc] init];
}


/**
 *
 * @param  buffer String to parse out JSON objects from
 * @return The length of the first JSON object found, 0 if it is an incomplete object,
 *                -1 if the string does not start with a '{' or an '['
 */
- (NSInteger)getLengthOfJsonObject:(NSString *)buffer
{
    if ([buffer characterAtIndex:0] != '{' && [buffer characterAtIndex:0] != '[') return -1;

    int numberOfOpens  = 0;
    int numberOfCloses = 0;

    unichar open  = [buffer characterAtIndex:0] == '{' ? '{' : '[';
    unichar close = [buffer characterAtIndex:0] == '{' ? '}' : ']';

    for (NSUInteger i = 0; i < [buffer length]; i++) {
        if ([buffer characterAtIndex:i] == open) numberOfOpens++;
        else if ([buffer characterAtIndex:i] == close) numberOfCloses++;

        if (numberOfOpens == numberOfCloses) return i + 1;
    }

    return 0;
}

- (RVIDlinkPacket *)stringToPacket:(NSString *)string
{
    DLog(@"Received packet: %@", string);

    if ([self.delegate respondsToSelector:@selector(onJsonStringParsed:)])
        [self.delegate onJsonStringParsed:string];

    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
    RVIDlinkPacket *packet = [RVIDlinkPacket dlinkPacketFromDictionary:jsonDict];

    if ([self.delegate respondsToSelector:@selector(onJsonObjectParsed:)])
        [self.delegate onJsonObjectParsed:jsonDict];

    DlinkCommand command = packet.command;

    if (command == NONE)
        return nil;

    if (command == AUTHORIZE) {
        return [RVIDlinkAuthPacket authPacketWithDictionary:jsonDict];
    } else if (command == SERVICE_ANNOUNCE) {
        return [RVIDlinkServiceAnnouncePacket serviceAnnouncePacketWithDictionary:jsonDict];
    } else if (command == RECEIVE) {
        return [RVIDlinkReceivePacket receivePacketWithDictionary:jsonDict];
    } else {
        return nil;
    }
}

- (NSString *)recurse:(NSString *)buffer
{
    DLog(@"");

    NSInteger lengthOfString     = [buffer length];
    NSInteger lengthOfJsonObject = [self getLengthOfJsonObject:buffer];

    RVIDlinkPacket *packet;

    if (lengthOfJsonObject == lengthOfString) { /* Current data is 1 json object */
        if ((packet = [self stringToPacket:buffer]) != nil)
            [self.delegate onPacketParsed:packet];

        return @"";

    } else if (lengthOfJsonObject < lengthOfString && lengthOfJsonObject > 0) { /* Current data is more than 1 json object */
        if ((packet = [self stringToPacket:[buffer substringToIndex:(NSUInteger)lengthOfJsonObject]]) != nil)
            [self.delegate onPacketParsed:packet];

        return [self recurse:[buffer substringFromIndex:(NSUInteger)lengthOfJsonObject]];

    } else if (lengthOfJsonObject == 0) { /* Current data is less than 1 json object */
        return buffer;

    } else { /* There was an error */
        return nil;

    }
}

/**
 * Parse the data (consisting of 0-n partial or complete json objects) that was received over the network
 * from an rvi node. Method parses the string, recursively chomping off json objects as they come in,
 * deserializing them into dlink packets. Remaining string (thereby assumed to be only a partial json object)
 * is saved until rest of the json object is received over the networked and appended to the buffer.
 *
 * @param data a json string, consisting of 0-n partial or complete json objects.
 */
- (void)parseData:(NSString *)data
{
    DLog(@"");
    if (self.buffer == nil) self.buffer = [NSMutableString string];

    self.buffer = [self recurse:[NSString stringWithFormat:@"%@%@", self.buffer, data]];
}

/**
 * Clears the saved (unparsed) buffer of data.
 */
- (void)clear
{
    self.buffer = nil;
}

- (NSString *)description
{
    return self.buffer.description;
}

@end
