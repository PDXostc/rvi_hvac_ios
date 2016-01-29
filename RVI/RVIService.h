// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// 
// Copyright (c) 2016 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the 
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
// 
// File:    RVIService.h
// Project: HVACDemo
// 
// Created by Lilli Szafranski on 1/28/16.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import <Foundation/Foundation.h>


@interface RVIService : NSObject
@property (nonatomic, copy) NSString *serviceIdentifier;

@property (nonatomic, copy) NSString *bundleIdentifier;

@property (nonatomic, copy) NSString *domain;

@property (nonatomic, copy) NSString *nodeIdentifier;

@property (nonatomic, copy) NSObject *parameters;

@property (nonatomic) long timeout;

/**
 * Instantiates a new Vehicle service.
 *
 * @param serviceIdentifier the service identifier
 * @param domain the domain
 * @param bundleIdentifier the bundle identifier
 * @param prefix the service's prefix
 */
- (id)initWithServiceIdentifier:(NSString *)serviceIdentifier domain:(NSString *)domain bundleIdentifier:(NSString *)bundleIdentifier prefix:(NSString *)prefix;
+ (id)serviceWithServiceIdentifier:(NSString *)serviceIdentifier domain:(NSString *)domain bundleIdentifier:(NSString *)bundleIdentifier prefix:(NSString *)prefix;

@end
