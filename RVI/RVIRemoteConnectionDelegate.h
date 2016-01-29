// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// 
// Copyright (c) 2016 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the 
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
// 
// File:    RVIRemoteConnectionDelegate.h
// Project: HVACDemo
// 
// Created by Lilli Szafranski on 1/28/16.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import <Foundation/Foundation.h>

@class RVIDlinkPacket;
@protocol RVIRemoteConnectionDelegate <NSObject>

/**
 * On RVI did connect.
 */
- (void)onRVIDidConnect;

/**
 * On RVI did disconnect.
 */
- (void)onRVIDidDisconnect:(NSError *)error;

/**
 * On RVI did fail to connect.
 *
 * @param error the error
 */
- (void)onRVIDidFailToConnect:(NSError *)error;

/**
 * On RVI did receive packet.
 *
 * @param packet the packet
 */
- (void)onRVIDidReceivePacket:(RVIDlinkPacket *)packet;

/**
 * On RVI did send packet.
 */
- (void)onRVIDidSendPacket:(RVIDlinkPacket *)packet;

/**
 * On RVI did fail to send packet.
 *
 * @param error the error
 */
- (void)onRVIDidFailToSendPacket:(NSError *)error;
@end
