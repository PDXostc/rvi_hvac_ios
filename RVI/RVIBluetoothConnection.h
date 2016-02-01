//
// Created by Lilli Szafranski on 1/30/16.
// Copyright (c) 2016 Lilli Szafranski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RVIRemoteConnectionDelegate.h"


@interface RVIBluetoothConnection : NSObject <RVIRemoteConnectionInterface>

@property (nonatomic, strong) NSString *deviceAddress;
@property (nonatomic)         NSInteger channel;
@property (nonatomic, strong) id serviceRecord;
@property (nonatomic, weak)   id<RVIRemoteConnectionDelegate> delegate;

+ (id)bluetoothConnection;

//- (void)sendRviRequest:(RVIDlinkPacket *)dlinkPacket;
//
//- (BOOL)isConnected;
//- (BOOL)isConfigured;
//
//- (void)connect;
//- (void)disconnect:(NSError *)trigger;
@end
