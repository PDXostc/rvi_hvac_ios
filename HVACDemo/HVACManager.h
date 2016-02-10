// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// 
// Copyright (c) 2015 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the 
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
// 
// File:    HVACManager.h
// Project: HVACDemo
// 
// Created by Lilli Szafranski on 5/4/15.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import <Foundation/Foundation.h>

typedef enum
{
    HVACServiceIdentifier_HAZARD = 0,
    HVACServiceIdentifier_TEMP_LEFT,
    HVACServiceIdentifier_TEMP_RIGHT,
    HVACServiceIdentifier_SEAT_HEAT_LEFT,
    HVACServiceIdentifier_SEAT_HEAT_RIGHT,
    HVACServiceIdentifier_FAN_SPEED,
    HVACServiceIdentifier_AIRFLOW_DIRECTION,
    HVACServiceIdentifier_DEFROST_REAR,
    HVACServiceIdentifier_DEFROST_FRONT,
    HVACServiceIdentifier_DEFROST_MAX,
    HVACServiceIdentifier_AIR_CIRC,
    HVACServiceIdentifier_AC,
    HVACServiceIdentifier_AUTO,
    HVACServiceIdentifier_END_LOCAL,
    HVACServiceIdentifier_UNSUBSCRIBE = HVACServiceIdentifier_END_LOCAL,
    HVACServiceIdentifier_SUBSCRIBE,
} HVACServiceIdentifier;

@protocol HVACManagerDelegate <NSObject>
- (void)onNodeConnected;
- (void)onNodeDisconnected;
- (void)onServiceInvoked:(HVACServiceIdentifier)serviceIdentifier withParameters:(id)parameters;
@end

@interface HVACManager : NSObject
+ (void)setDelegate:(id<HVACManagerDelegate>)delegate;
+ (void)invokeService:(HVACServiceIdentifier)service value:(NSString *)value;
+ (void)start;
+ (void)restart;
@end
