// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// 
// Copyright (c) 2016 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the 
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
// 
// File:    RVIService.m
// Project: HVACDemo
// 
// Created by Lilli Szafranski on 1/28/16.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import "RVIService.h"


@implementation RVIService
{

}

- (id)initWithServiceIdentifier:(NSString *)serviceIdentifier domain:(NSString *)domain bundleIdentifier:(NSString *)bundleIdentifier prefix:(NSString *)prefix
{
    if ((serviceIdentifier == nil) || (domain == nil) || (bundleIdentifier == nil))
        return nil;

    if ((self = [super init]))
    {
        _serviceIdentifier = [serviceIdentifier copy];
        _domain = [domain copy];
        _bundleIdentifier = [bundleIdentifier copy];
        _nodeIdentifier = [prefix copy];

    }

    return self;
}

+ (id)serviceWithServiceIdentifier:(NSString *)serviceIdentifier domain:(NSString *)domain bundleIdentifier:(NSString *)bundleIdentifier prefix:(NSString *)prefix
{
    return [[RVIService alloc] initWithServiceIdentifier:serviceIdentifier domain:domain bundleIdentifier:bundleIdentifier prefix:prefix];
}

- (NSDictionary *)unwrap:(NSArray *)parameters
{
    NSMutableDictionary *unwrapped = [NSMutableDictionary dictionary];

    for (NSDictionary *element in parameters)
        for (NSString *key in [element allKeys])
            unwrapped[key] = element[key];

    return [NSDictionary dictionaryWithDictionary:unwrapped];
}

- (id)initFromDictionary:(NSDictionary *)dict
{
    if (dict == nil)
        return nil;

    NSString *fqsn = dict[@"service"];
    NSArray *serviceParts = [fqsn componentsSeparatedByString:@"/"];

    if ([serviceParts count] != 5) return nil;

    if ((self = [super init]))
    {
        _domain = serviceParts[0];
        _nodeIdentifier = [NSString stringWithFormat:@"%@%@%@", serviceParts[1], @"/", serviceParts[2]];
        _bundleIdentifier = serviceParts[3];
        _serviceIdentifier = serviceParts[4];

        // TODO: Why are parameters arrays of object, not just an object? This should probably get fixed everywhere.
        if ([[dict[@"parameters"] class] isEqual:[NSArray class]] && [((NSArray *)dict[@"parameters"]) count] == 1)
            self.parameters = ((NSArray *)dict[@"parameters"])[0];
        else if ([[dict[@"parameters"] class] isEqual:[NSArray class]] && [((NSArray *)dict[@"parameters"]) count] > 1)
            self.parameters = [self unwrap:((NSArray *)dict[@"parameters"])];
        else
            self.parameters = dict[@"parameters"];
    }

    return self;
}

/**
 * Instantiates a new Vehicle service.
 *
 * @param jsonString the json string
 */
+ (id)serviceFromDictionary:(NSDictionary *)dict
{
    return [[RVIService alloc] initFromDictionary:dict];
}

/**
 * Gets fully qualified service name.
 *
 * @return the fully qualified service name
 */
- (NSString *)getFullyQualifiedServiceName
{
    return [NSString stringWithFormat:@"%@%@%@%@%@%@%@", self.domain, @"/", self.nodeIdentifier, @"/", self.bundleIdentifier, @"/", self.serviceIdentifier];
}

/**
 * Has the node identifier portion of the fully-qualified service name. This happens if the remote node is
 * connected and has announced this service.
 *
 * @return the boolean
 */
- (BOOL)hasNodeIdentifier
{
    return self.nodeIdentifier != nil;
}

/**
 * Generate request params.
 *
 * @return the object
 */
- (NSDictionary *)toDictionary
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    params[@"service"] = [self getFullyQualifiedServiceName];
    params[@"parameters"] = self.parameters;
    params[@"timeout"] = @(self.timeout);
    params[@"tid"] = @(1); // TODO: Please tell me we can not have this here

    return [NSDictionary dictionaryWithDictionary:params];
}
@end
