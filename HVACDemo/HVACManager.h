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
    HSI_HAZARD = 0,
    HSI_TEMP_LEFT,
    HSI_TEMP_RIGHT,
    HSI_SEAT_HEAT_LEFT,
    HSI_SEAT_HEAT_RIGHT,
    HSI_FAN_SPEED,
    HSI_AIRFLOW_DIRECTION,
    HSI_DEFROST_REAR,
    HSI_DEFROST_FRONT,
    HSI_DEFROST_MAX,
    HSI_AIR_CIRC,
    HSI_AC,
    HSI_AUTO,
    HSI_END_LOCAL,
    HSI_UNSUBSCRIBE = HSI_END_LOCAL,
    HSI_SUBSCRIBE,
    HSI_NONE,
} HVACServiceIdentifier;

@protocol HVACManagerDelegate <NSObject>
- (void)onNodeConnected;
- (void)onNodeDisconnected;
- (void)onServiceInvoked:(HVACServiceIdentifier)serviceIdentifier withValue:(id)value   ;
@end

@interface HVACManager : NSObject
+ (void)setDelegate:(id<HVACManagerDelegate>)delegate;
+ (void)invokeService:(HVACServiceIdentifier)service value:(NSObject *)value;
+ (void)start;
+ (void)restart;
@end
