// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// 
// Copyright (c) 2016 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the 
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
// 
// File:    HVACState.m
// Project: HVACDemo
// 
// Created by Lilli Szafranski on 2/11/16.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import "HVACState.h"


@implementation HVACState
{

}

- (id)initWithAirDirection:(NSInteger)airDirection fanSpeed:(NSInteger)fanSpeed ac:(BOOL)ac circ:(BOOL)circ defrostMax:(BOOL)defrostMax
{
    if ((self = [super init]))
    {
        _airDirection = airDirection;
        _fanSpeed = fanSpeed;
        _ac = ac;
        _circ = circ;
        _defrostMax = defrostMax;
    }

    return self;
}

+ (id)hvacStateWithAirDirection:(NSInteger)airDirection fanSpeed:(NSInteger)fanSpeed ac:(BOOL)ac circ:(BOOL)circ defrostMax:(BOOL)defrostMax
{
    return  [[HVACState alloc] initWithAirDirection:airDirection fanSpeed:fanSpeed ac:ac circ:circ defrostMax:defrostMax];
}
@end
