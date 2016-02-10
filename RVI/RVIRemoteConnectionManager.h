// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// 
// Copyright (c) 2016 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the 
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
// 
// File:    RVIRemoteConnectionManager.h
// Project: HVACDemo
// 
// Created by Lilli Szafranski on 1/28/16.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import <Foundation/Foundation.h>

@class RVIDlinkPacket;

typedef enum
{
    UNKNOWN,
    SERVER,
    BLUETOOTH,
    GLOBAL,
}RemoteConnectionType;

@protocol RVIRemoteConnectionManagerDelegate <NSObject>
/**
 * On RVI did connect.
 */
- (void)onRVIDidConnect;

/**
 * On RVI did disconnect.
 */
- (void)onRVIDidDisconnect:(NSError *)error;

/**
 * On RVI did fail to connect.
 *
 * @param error the error
 */
- (void)onRVIDidFailToConnect:(NSError *)error;

/**
 * On RVI did receive packet.
 *
 * @param packet the packet
 */
- (void)onRVIDidReceivePacket:(RVIDlinkPacket *)packet;

/**
 * On RVI did send packet.
 */
- (void)onRVIDidSendPacket:(RVIDlinkPacket *)packet;

/**
 * On RVI did fail to send packet.
 *
 * @param error the error
 */
- (void)onRVIDidFailToSendPacket:(NSError *)error;
@end

@interface RVIRemoteConnectionManager : NSObject
@property (nonatomic, weak) id<RVIRemoteConnectionManagerDelegate> delegate;

- (id)init;
+ (id)remoteConnectionManager;

/**
 * Connect the local RVI node to the remote RVI node.
 */
- (void)connect:(RemoteConnectionType)type;

/**
 * Disconnect the local RVI node from the remote RVI node
 */
- (void)disconnect:(RemoteConnectionType)type;

/**
 * Send an RVI request packet.
 *
 * @param dlinkPacket the dlink packet
 */
- (void)sendPacket:(RVIDlinkPacket *)dlinkPacket;

/**
 * Sets the server url to the remote RVI node, when using a TCP/IP link to interface with a remote node.
 *
 * @param serverUrl the server url
 */
- (void)setServerUrl:(NSString *)serverUrl;

/**
 * Sets the server port of the remote RVI node, when using a TCP/IP link to interface with a remote node.
 *
 * @param serverPort the server port
 */
- (void)setServerPort:(UInt32)serverPort;

/**
 * Sets the trusted server certificate of the remote RVI node, when using a TCP/IP link to interface with a remote node.
 *
 * @param clientKeyStore the server certificate key store
 * @param serverKeyStore the server certificate key store
 */
- (void)setServerKeyStores:(id)serverKeyStore clientKeyStore:(id)clientKeyStore clientKeyStorePassword:(NSString *)clientKeyStorePassword;

/**
 * Sets the device address of the remote Bluetooth receiver on the remote RVI node, when using a Bluetooth link to interface with a remote node.
 *
 * @param deviceAddress the Bluetooth device address
 */
- (void)setBluetoothDeviceAddress:(NSString *)deviceAddress;

/**
 * Sets the Bluetooth service record identifier of the remote RVI node, when using a Bluetooth link to interface with a remote node.
 *
 * @param serviceRecord the service record identifier
 */
- (void)setBluetoothServiceRecord:(id)serviceRecord;

/**
 * Sets the Bluetooth channel of the remote RVI node, when using a Bluetooth link to interface with a remote node.
 *
 * @param channel the channel
 */
- (void)setBluetoothChannel:(NSInteger)channel;
@end
