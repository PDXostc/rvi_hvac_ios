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

@protocol RVIRemoteConnectionDelegate;
@protocol RVIRemoteConnectionInterface;

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
 * The name of the of the server cert .der file
 */
@property (nonatomic, strong) id serverCertificate;

/**
 * The domain used as the "subjectAltName=DNS:<domain>" when creating the server certificate signing request
 */
@property (nonatomic, copy) NSString *serverDomain;

/**
 * The name of the client cert .p12 file
 */
@property (nonatomic, strong) id clientCertificate;

/**
 * The password of the client cert
 */
@property (nonatomic, strong) NSString *clientCertificatePassword;

@property (nonatomic, readonly) BOOL isConnected;

@property (nonatomic, weak) id<RVIRemoteConnectionDelegate> delegate;

+ (id)serverConnection;
@end
