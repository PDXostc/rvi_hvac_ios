//
// Created by Lilli Szafranski on 1/30/16.
// Copyright (c) 2016 Lilli Szafranski. All rights reserved.
//

#import "RVIBluetoothConnection.h"
#import "RVIDlinkPacket.h"


@implementation RVIBluetoothConnection
{

}
- (id)init
{
    if ((self = [super init]))
    {

    }

    return self;
}

+ (id)bluetoothConnection
{
    return [[RVIBluetoothConnection alloc] init];
}

- (void)sendRviRequest:(RVIDlinkPacket *)dlinkPacket
{
//    if (!isConnected() || !isConfigured()) { // TODO: Call error on listener
//
//        mRemoteConnectionListener.onDidFailToSendDataToRemoteConnection(new Throwable("RVI node is not connected")); // TODO: Provide better feedback mechanism for when service invocations fail because node isn't connected!
//        return;
//    }
//
//    new SendDataTask(dlinkPacket).executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);//, dlinkPacket.toJsonString());
}

- (BOOL)isConnected
{
    //return mSocket != null && mSocket.isConnected();
    return NO;
}

- (BOOL)isConfigured
{
    //return !(mServerUrl == null || mServerUrl.isEmpty() || mServerPort == 0 || mClientKeyStore == null || mServerKeyStore == null);
    return NO;
}

- (void)connect
{
//    if (isConnected()) disconnect(null);
//
//    connectSocket();
}

- (void)disconnect:(NSError *)trigger
{
//
//    try {
//        if (mSocket != null)
//            mSocket.close();
//
//        mSocket = null;
//    } catch (Exception e) {
//        e.printStackTrace();
//    }
//
//    if (mRemoteConnectionListener != null && trigger != null) mRemoteConnectionListener.onRemoteConnectionDidDisconnect(trigger);
}

@end
