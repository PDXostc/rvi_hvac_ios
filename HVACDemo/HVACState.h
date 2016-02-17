// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// 
// Copyright (c) 2016 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the 
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
// 
// File:    HVACState.h
// Project: HVACDemo
// 
// Created by Lilli Szafranski on 2/11/16.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import <Foundation/Foundation.h>


@interface HVACState : NSObject
@property (readonly) NSInteger airDirection;
@property (readonly) NSInteger fanSpeed;
@property (readonly) BOOL      ac;
@property (readonly) BOOL      circ;
@property (readonly) BOOL      defrostMax;

+ (id)hvacStateWithAirDirection:(NSInteger)airDirection fanSpeed:(NSInteger)fanSpeed ac:(BOOL)ac circ:(BOOL)circ defrostMax:(BOOL)defrostMax;
@end
