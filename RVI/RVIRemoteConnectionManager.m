// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// 
// Copyright (c) 2016 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the 
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
// 
// File:    RVIRemoteConnectionManager.m
// Project: HVACDemo
// 
// Created by Lilli Szafranski on 1/28/16.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import "RVIRemoteConnectionManager.h"
#import "RVIRemoteConnectionDelegate.h"
#import "RVIServerConnection.h"
#import "RVIDlinkPacketParser.h"
#import "RVIBluetoothConnection.h"
#import "RVIUtil.h"
#import "RVIDlinkPacket.h"

@interface RVIRemoteConnectionManager () <RVIRemoteConnectionDelegate, RVIDlinkPacketParserDelegate>
@property (nonatomic, strong) RVIBluetoothConnection          *bluetoothConnection;
@property (nonatomic, strong) id<RVIRemoteConnectionInterface> remoteConnection;
@property (nonatomic, strong) RVIDlinkPacketParser            *dataParser;
@property (nonatomic, strong) RVIServerConnection             *directServerConnection;

@end

@implementation RVIRemoteConnectionManager
{

}

- (id)init
{
    if ((self = [super init]))
    {
        _dataParser = [RVIDlinkPacketParser dlinkPacketParser];
        _dataParser.delegate = self;

        _bluetoothConnection = [RVIBluetoothConnection bluetoothConnection];
        _directServerConnection = [RVIServerConnection serverConnection];

        _bluetoothConnection.delegate = self;
        _directServerConnection.delegate = self;
    }

    return self;
}

+ (id)remoteConnectionManager
{
    return [[RVIRemoteConnectionManager alloc] init];
}

- (void)connect:(RemoteConnectionType)type
{
    DLog(@"");

    self.remoteConnection = [self selectConfiguredRemoteConnection:type];

    if (self.remoteConnection != nil) [self.remoteConnection connect];
}

- (void)disconnect:(RemoteConnectionType)type
{
    if (self.remoteConnection != nil) [self.remoteConnection disconnect:nil];

    [self.dataParser clear];
}

- (void)sendPacket:(RVIDlinkPacket *)dlinkPacket
{
    if (dlinkPacket == nil) return;

    DLog(@"%@", [[dlinkPacket class] description]);

    if (self.remoteConnection == nil) {
        [self.delegate onRVIDidFailToSendPacket:[NSError errorWithDomain:@"TODO" code:000 userInfo:@{NSLocalizedDescriptionKey : @"Interface not selected"}]];    // TODO: PORT_COMPLETE
    } else if (![self.remoteConnection isConfigured]) {
        [self.delegate onRVIDidFailToSendPacket:[NSError errorWithDomain:@"TODO" code:000 userInfo:@{NSLocalizedDescriptionKey : @"Interface not configured"}]];  // TODO: PORT_COMPLETE
    } else if (![self.remoteConnection isConnected]) {
        [self.delegate onRVIDidFailToSendPacket:[NSError errorWithDomain:@"TODO" code:000 userInfo:@{NSLocalizedDescriptionKey : @"Interface not connected"}]];    // TODO: PORT_COMPLETE
    } else {
        [self.remoteConnection sendRviRequest:dlinkPacket];
    }
}

- (id<RVIRemoteConnectionInterface>)selectConfiguredRemoteConnection:(RemoteConnectionType)type // TODO: This is going to be buggy if a connection is enabled but not connected; the other connections won't have connected
{                                                                                               // TODO: Rewrite better 'choosing' code
    id<RVIRemoteConnectionInterface> remoteConnectionInterface;

    if (type == SERVER)
        remoteConnectionInterface = (id <RVIRemoteConnectionInterface>)self.directServerConnection;
    else if (type == BLUETOOTH)
        remoteConnectionInterface = (id <RVIRemoteConnectionInterface>)self.bluetoothConnection;
    else if (type == GLOBAL && [(id <RVIRemoteConnectionInterface>)self.directServerConnection isConfigured])
        remoteConnectionInterface = (id <RVIRemoteConnectionInterface>)self.directServerConnection;
    else
        remoteConnectionInterface = (id <RVIRemoteConnectionInterface>)self.bluetoothConnection;

    if (![remoteConnectionInterface isConfigured]) {
        [self.delegate onRVIDidFailToConnect:[NSError errorWithDomain:@"TODO" code:000 userInfo:@{NSLocalizedDescriptionKey : @"Interface not configured"}]];    // TODO: PORT_COMPLETE
        return nil;
    }

    return remoteConnectionInterface;
}

- (void)setServerUrl:(NSString *)serverUrl
{
    self.directServerConnection.serverUrl = serverUrl;
}

- (void)setServerPort:(UInt32)serverPort
{
    self.directServerConnection.serverPort = serverPort;
}

- (void)setServerKeyStores:(id)serverKeyStore clientKeyStore:(id)clientKeyStore clientKeyStorePassword:(NSString *)clientKeyStorePassword
{
    self.directServerConnection.serverKeyStore = serverKeyStore;
    self.directServerConnection.clientKeyStore = clientKeyStore;
    self.directServerConnection.clientKeyStorePassword = clientKeyStorePassword;
}

- (void)setBluetoothDeviceAddress:(NSString *)deviceAddress
{
    self.bluetoothConnection.deviceAddress = deviceAddress;
}

- (void)setBluetoothServiceRecord:(id)serviceRecord
{
    self.bluetoothConnection.serviceRecord = serviceRecord;
}

- (void)setBluetoothChannel:(NSInteger)channel
{
    self.bluetoothConnection.channel = channel;
}

- (void)onRemoteConnectionDidConnect
{
    [self.delegate onRVIDidConnect];
}

- (void)onRemoteConnectionDidDisconnect:(NSError *)error
{
    [self.delegate onRVIDidDisconnect:error];
}

- (void)onRemoteConnectionDidFailToConnect:(NSError *)error
{
    [self.delegate onRVIDidFailToConnect:error];
}

- (void)onRemoteConnectionDidReceiveData:(NSString *)data
{
    DLog(@"%@", data);
    [self.dataParser parseData:data];
}

- (void)onDidSendDataToRemoteConnection:(RVIDlinkPacket *)packet
{
    [self.delegate onRVIDidSendPacket:packet];
}

- (void)onDidFailToSendDataToRemoteConnection:(NSError *)error
{
    [self.delegate onRVIDidFailToSendPacket:error];
}

- (void)onPacketParsed:(RVIDlinkPacket *)packet
{
    DLog(@"");
    [self.delegate onRVIDidReceivePacket:packet];
}

@end
