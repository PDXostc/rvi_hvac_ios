// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// 
// Copyright (c) 2016 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the 
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
// 
// File:    RVIServerConnection.h
// Project: HVACDemo
// 
// Created by Lilli Szafranski on 1/28/16.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import <Foundation/Foundation.h>
#import "RVIRemoteConnectionDelegate.h"

@interface RVIServerConnection : NSObject <RVIRemoteConnectionInterface>
/**
 * The server url.
 */
@property (nonatomic, strong) NSString *serverUrl;

/**
 * The server port.
 */
@property (nonatomic)         UInt32 serverPort;

/**
 * The key store of the server certs
 */
@property (nonatomic, strong) id serverKeyStore;

/**
 * The key store of the client certs
 */
@property (nonatomic, strong) id clientKeyStore;

/**
 * The key store password of the client certs
 */
@property (nonatomic, strong) NSString *clientKeyStorePassword;

@property (nonatomic, readonly) BOOL isConnected;

@property (nonatomic, weak) id<RVIRemoteConnectionDelegate> delegate;

+ (id)serverConnection;

//- (void)sendRviRequest:(RVIDlinkPacket *)dlinkPacket;
//
//- (BOOL)isConnected;
//- (BOOL)isConfigured;
//
//- (void)connect;
//- (void)disconnect:(NSError *)trigger;
@end
