// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// 
// Copyright (c) 2016 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the 
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
// 
// File:    RVINode.m
// Project: HVACDemo
// 
// Created by Lilli Szafranski on 1/28/16.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import "RVINode.h"
#import "RVIRemoteConnectionManager.h"


@interface RVINode () <RVIRemoteConnectionManagerDelegate>
@property (nonatomic, strong) NSDictionary *allServiceBundles;
@property (nonatomic, strong) RVIRemoteConnectionManager *remoteConnectionManager;
@end

@implementation RVINode
{

}

- (id)initRVINode
{
    _remoteConnectionManager = [RVIRemoteConnectionManager remoteConnectionManager];

    [_remoteConnectionManager setDelegate:self];
}


/**
 * Sets the server url to the remote RVI node, when using a TCP/IP link to interface with a remote node.
 *
 * @param serverUrl the server url
 */
- (void)setServerUrl:(NSInteger *) serverUrl {
    mRemoteConnectionManager.setServerUrl(serverUrl);
}

/**
 * Sets the server port of the remote RVI node, when using a TCP/IP link to interface with a remote node.
 *
 * @param serverPort the server port
 */
- (void)setServerPort:(NSInteger *) serverPort {
    mRemoteConnectionManager.setServerPort(serverPort);
}


/**
 * Sets the server port of the remote RVI node, when using a TCP/IP link to interface with a remote node.
 *
 * @param serverKeyStore the KeyStore object that contains your server's self-signed certificate that the TLS connection should accept.
 *                 To make this KeyStore object, use BouncyCastle (http://www.bouncycastle.org/download/bcprov-jdk15on-146.jar), and
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
- (void)setKeyStores(KeyStore serverKeyStore, KeyStore clientKeyStore, String clientKeyStorePassword {
    mRemoteConnectionManager.setKeyStores(serverKeyStore, clientKeyStore, clientKeyStorePassword);
}

/**
 * Sets the device address of the remote Bluetooth receiver on the remote RVI node, when using a Bluetooth link to interface with a remote node.
 *
 * @param deviceAddress the Bluetooth device address
 */
- (void)setBluetoothDeviceAddress:(NSInteger *) deviceAddress {
    mRemoteConnectionManager.setBluetoothDeviceAddress(deviceAddress);
}

/**
 * Sets the Bluetooth service record identifier of the remote RVI node, when using a Bluetooth link to interface with a remote node.
 *
 * @param serviceRecord the service record identifier
 */
- (void)setBluetoothServiceRecord(UUID serviceRecord {
    /*RemoteConnectionManager.ourInstance.*/mRemoteConnectionManager.setBluetoothServiceRecord(serviceRecord);
}

/**
 * Sets the Bluetooth channel of the remote RVI node, when using a Bluetooth link to interface with a remote node.
 *
 * @param channel the channel
 */
- (void)setBluetoothChannel:(NSInteger *) channel {
    /*RemoteConnectionManager.ourInstance.*/mRemoteConnectionManager.setBluetoothChannel(channel);
}

public boolean isConnected( {
    return mIsConnected;
}

- (void)connect(RemoteConnectionManager.ConnectionType type {
    mRemoteConnectionManager.connect(type);//, RemoteConnection.Status.NA, RemoteConnection.Descriptor.NONE));
}

- (void)disconnect(RemoteConnectionManager.ConnectionType type {
    mRemoteConnectionManager.disconnect(type);//, RemoteConnection.Status.NA, RemoteConnection.Descriptor.DISCONNECTED_APP_INITIATED));
}

/**
 * Tells the local RVI node to connect to the remote RVI node using a TCP/IP connection.
 */
- (void)connectServer( {
    this.connect(RemoteConnectionManager.ConnectionType.SERVER);
}

/**
 * Tells the local RVI node to disconnect the TCP/IP connection to the remote RVI node.
 */
- (void)disconnectServer( {
    this.disconnect(RemoteConnectionManager.ConnectionType.SERVER);
}

/**
 * Tells the local RVI node to connect to the remote RVI node using a Bluetooth connection.
 */
- (void)connectBluetooth( {
   connect(RemoteConnectionManager.ConnectionType.BLUETOOTH);
}

/**
 * Tells the local RVI node to disconnect the Bluetooth to the remote RVI node.
 */
- (void)disconnectBluetooth( {
    connect(RemoteConnectionManager.ConnectionType.BLUETOOTH);
}

/**
 * Tells the local RVI node to connect to the remote RVI node, letting the RVINode choose the best connection.
 */
- (void)connect( {
    connect(RemoteConnectionManager.ConnectionType.GLOBAL);
}

/**
 * Tells the local RVI node to disconnect all connections to the remote RVI node.
 */
- (void)disconnect( {
    disconnect(RemoteConnectionManager.ConnectionType.GLOBAL);
}

/**
 * Add a service bundle to the local RVI node. Adding a service bundle triggers a service announce over the
 * network to the remote RVI node.
 *
 * @param bundle the bundle
 */
- (void)addBundle(ServiceBundle bundle {
    bundle.setNode(this);
    mAllServiceBundles.put(bundle.getDomain() + ":" + bundle.getBundleIdentifier(), bundle);
    announceServices();
}

/**
 * Remove a service bundle from the local RVI node. Removing a service bundle triggers a service announce over the
 * network to the remote RVI node.
 *
 * @param bundle the bundle
 */
- (void)removeBundle(ServiceBundle bundle {
    bundle.setNode(null);
    mAllServiceBundles.remove(bundle.getDomain() + ":" + bundle.getBundleIdentifier());
    announceServices();
}

/**
 * Have the local node announce all it's available services.
 */
void announceServices( {
    ArrayList<String> allServices = new ArrayList<>();
    for (ServiceBundle bundle : mAllServiceBundles.values())
        allServices.addAll(bundle.getFullyQualifiedLocalServiceNames());

    mRemoteConnectionManager.sendPacket(new DlinkServiceAnnouncePacket(allServices));
}

/**
 * Invoke service.
 *
 * @param service the service
 */
void invokeService(Service service {
    mRemoteConnectionManager.sendPacket(new DlinkReceivePacket(service));
}

- (void)handleReceivePacket(DlinkReceivePacket packet {
    Service service = packet.getService();

    ServiceBundle bundle = mAllServiceBundles.get(service.getDomain() + ":" + service.getBundleIdentifier());
    if (bundle != null)
        bundle.serviceInvoked(service);
}

- (void)handleServiceAnnouncePacket(DlinkServiceAnnouncePacket packet {
    for :(NSInteger *) fullyQualifiedRemoteServiceName : packet.getServices() {

        String[] serviceParts = fullyQualifiedRemoteServiceName.split("/");

        if (serviceParts.length != 5) return;

        String domain = serviceParts[0];
        String nodeIdentifier = serviceParts[1] + "/" + serviceParts[2];
        String bundleIdentifier = serviceParts[3];
        String serviceIdentifier = serviceParts[4];

        ServiceBundle bundle = mAllServiceBundles.get(domain + ":" + bundleIdentifier);

        if (bundle != null)
            bundle.addRemoteService(serviceIdentifier, nodeIdentifier);
    }
}

- (void)handleAuthPacket(DlinkAuthPacket packet {

}

private final static String SHARED_PREFS_STRING         = "com.rvisdk.settings";
private final static String LOCAL_SERVICE_PREFIX_STRING = "localServicePrefix";

// TODO: Test and verify this function
private static String uuidB58String( {
    UUID uuid = UUID.randomUUID();
    String b64Str;

    ByteBuffer bb = ByteBuffer.wrap(new byte[16]);
    bb.putLong(uuid.getMostSignificantBits());
    bb.putLong(uuid.getLeastSignificantBits());

    b64Str = Base64.encodeToString(bb.array(), Base64.DEFAULT);
    b64Str = b64Str.split("=")[0];

    b64Str = b64Str.replace('+', 'P');
    b64Str = b64Str.replace('/', 'S'); /* Reduces likelihood of uniqueness but stops non-alphanumeric characters from screwing up any urls or anything */

    return b64Str;
}

/**
 * Gets the prefix of the local RVI node
 *
 * @param context the application context
 * @return the local prefix
 */
+ (NSString *)getLocalNodeIdentifier
{
    SharedPreferences sharedPrefs = context.getSharedPreferences(SHARED_PREFS_STRING, MODE_PRIVATE);
    String localServicePrefix;

    if ((localServicePrefix = sharedPrefs.getString(LOCAL_SERVICE_PREFIX_STRING, null)) == null)
        localServicePrefix = "android/" + uuidB58String();

    SharedPreferences.Editor editor = sharedPrefs.edit();
    editor.putString(LOCAL_SERVICE_PREFIX_STRING, localServicePrefix);
    editor.apply();

    return localServicePrefix;
}
@end
