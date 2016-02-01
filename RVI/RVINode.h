// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// 
// Copyright :(c) 2016 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the 
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
// 
// File:    RVINode.h
// Project: HVACDemo
// 
// Created by Lilli Szafranski on 1/28/16.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import <Foundation/Foundation.h>


@class RVIServiceBundle;
/**
 * The RVI node delegate interface.
 */
@protocol RVINodeDelegate <NSObject>
/**
 * Called when the local RVI node successfully connects to a remote RVI node.
 */
- (void)nodeDidConnect;

/**
 * Called when the local RVI node failed to connect to a remote RVI node.
 */
- (void)nodeDidFailToConnect:(NSError *)trigger;

/**
 * Called when the local RVI node disconnects from a remote RVI node.
 */
- (void)nodeDidDisconnect:(NSError *)trigger;
@end

@interface RVINode : NSObject
@property (nonatomic, weak) id<RVINodeDelegate>delegate;
@property (nonatomic, readonly) bool isConnected;

+ (id)node;

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
 * Sets the server port of the remote RVI node, when using a TCP/IP link to interface with a remote node.
 *
 * @param serverKeyStore the KeyStore object that contains your server's self-signed certificate that the TLS connection should accept.
 *                 To make this KeyStore object, use BouncyCastle :(http://www.bouncycastle.org/download/bcprov-jdk15on-146.jar), and
 *                 this command-line command:
 *                 $ keytool -import -v -trustcacerts -alias 0 \
 *                 -file [PATH_TO_SELF_CERT.PEM] \
 *                 -keystore [PATH_TO_KEYSTORE] \
 *                 -storetype BKS \
 *                 -provider org.bouncycastle.jce.provider.BouncyCastleProvider \
 *                 -providerpath [PATH_TO_bcprov-jdk15on-146.jar] \
 *                 -storepass [STOREPASS]
 * @param clientKeyStore the KeyStore object that contains your client's self-signed certificate that the TLS connection sends to the server.
 *                       // TODO: openssl pkcs12 -export -in insecure_device_cert.crt -inkey insecure_device_key.pem -out client.p12 -name "client-certs"
 * @param clientKeyStorePassword the password of the client key store
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
- (void)setBluetoothServiceRecord:(NSUUID *)serviceRecord;

/**
 * Sets the Bluetooth channel of the remote RVI node, when using a Bluetooth link to interface with a remote node.
 *
 * @param channel the channel
 */
- (void)setBluetoothChannel:(NSInteger)channel;

/**
 * Tells the local RVI node to connect to the remote RVI node using a TCP/IP connection.
 */
- (void)connectServer;

/**
 * Tells the local RVI node to disconnect the TCP/IP connection to the remote RVI node.
 */
- (void)disconnectServer;

/**
 * Tells the local RVI node to connect to the remote RVI node using a Bluetooth connection.
 */
- (void)connectBluetooth;

/**
 * Tells the local RVI node to disconnect the Bluetooth to the remote RVI node.
 */
- (void)disconnectBluetooth;

/**
 * Tells the local RVI node to connect to the remote RVI node, letting the RVINode choose the best connection.
 */
- (void)connect;

/**
 * Tells the local RVI node to disconnect all connections to the remote RVI node.
 */
- (void)disconnect;

/**
 * Add a service bundle to the local RVI node. Adding a service bundle triggers a service announce over the
 * network to the remote RVI node.
 *
 * @param bundle the bundle
 */
- (void)addBundle:(RVIServiceBundle *)bundle;

/**
 * Remove a service bundle from the local RVI node. Removing a service bundle triggers a service announce over the
 * network to the remote RVI node.
 *
 * @param bundle the bundle
 */
- (void)removeBundle:(RVIServiceBundle *)bundle;

/**
 * Gets the prefix of the local RVI node
 *
 * @param context the application context
 * @return the local prefix
 */
+ (NSString *)getLocalNodeIdentifier;
@end
