//
// Created by Lilli Szafranski on 1/30/16.
// Copyright (c) 2016 Lilli Szafranski. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol RVIRemoteConnectionInterface;
@protocol RVIRemoteConnectionDelegate;

@interface RVIBluetoothConnection : NSObject <RVIRemoteConnectionInterface>

@property (nonatomic, strong) NSString *deviceAddress;
@property (nonatomic)         NSInteger channel;
@property (nonatomic, strong) id serviceRecord;
@property (nonatomic, weak)   id<RVIRemoteConnectionDelegate> delegate;

+ (id)bluetoothConnection;

@end
