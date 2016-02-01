// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// 
// Copyright (c) 2016 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the 
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
// 
// File:    RVIDlinkPacketParser.h
// Project: HVACDemo
// 
// Created by Lilli Szafranski on 1/28/16.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import <Foundation/Foundation.h>
#import "RVIDlinkPacket.h"


/**
 * The interface Dlink packet parser listener. The object that's notified when complete dlink packets are parsed.
 */
@protocol RVIDlinkPacketParserDelegate <NSObject>

/**
 * On packet parsed. Callback method that notifies listener when a complete dlink packet was parsed out of the
 * input stream coming from an rvi node over the network.
 *
 * @param packet the dlink packet
 */
- (void)onPacketParsed:(RVIDlinkPacket *)packet;

@optional
/**
 * On json string parsed. Callback method that notifies listener when a complete json string was parsed out of
 * the input stream coming from an rvi node over the network.
 *
 * @param jsonString the json string
 */
- (void)onJsonStringParsed:(NSString *)jsonString;

/**
 * On json object parsed. Callback method that notifies listener when a complete json object was parsed out of
 * the input stream coming from an rvi node over the network.
 *
 * @param jsonObject the json object
 */
- (void)onJsonObjectParsed:(NSObject *)jsonObject;
@end

@interface RVIDlinkPacketParser : NSObject
@property (nonatomic, weak) id <RVIDlinkPacketParserDelegate> delegate;

+ (id)dlinkPacketParser;
- (void)parseData:(NSString *)data;
- (void)clear;
@end
