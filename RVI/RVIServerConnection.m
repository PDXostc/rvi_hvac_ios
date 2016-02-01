// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// 
// Copyright (c) 2016 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the 
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
// 
// File:    RVIServerConnection.m
// Project: HVACDemo
// 
// Created by Lilli Szafranski on 1/28/16.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import "RVIServerConnection.h"
#import "RVIUtil.h"
#import "RVIDlinkAuthPacket.h"
#import "RVIDlinkServiceAnnouncePacket.h"
#import "RVIDlinkReceivePacket.h"

@interface RVIServerConnection () <NSStreamDelegate>
@property (nonatomic) SecCertificateRef certificate;
@property (nonatomic) CFReadStreamRef readStream;
@property (nonatomic) CFWriteStreamRef writeStream;
@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic) BOOL isConnected;
@end

@implementation RVIServerConnection
{

}

- (id)init 
{
    if ((self = [super init])) 
    {
        
    }
    
    return self;
}
  
+ (id)serverConnection
{
    return [[RVIServerConnection alloc] init];
}

- (void)sendRviRequest:(RVIDlinkPacket *)dlinkPacket
{
    if (![self isConnected] || ![self isConfigured])
    { // TODO: Call error on listener

        [self.delegate onDidFailToSendDataToRemoteConnection:[NSError errorWithDomain:@"TODO" code:000 userInfo:@{NSLocalizedDescriptionKey : @"RVI node is not connected"}]];    // TODO: PORT_COMPLETE
        return;
    }

    //new SendDataTask(dlinkPacket).executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);//, dlinkPacket.toJsonString());

    NSError *jsonError;
    NSData  *payload = [NSJSONSerialization dataWithJSONObject:[dlinkPacket toDictionary]
                                                       options:nil
                                                         error:&jsonError];

    DLog(@"Sending data: %@", [NSString stringWithUTF8String:[payload bytes]]);

    if ([dlinkPacket isKindOfClass:[RVIDlinkAuthPacket class]])
    {
        [self.delegate onRemoteConnectionDidReceiveData:@"{\"cmd\":\"au\",\"ver\":\"1.0\",\"addr\":\"127.0.0.1\",\"port\":8810,\"creds\":[\"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJyaWdodF90b19pbnZva2UiOlsiZ2VuaXZpLm9yZy8iXSwiaXNzIjoiZ2VuaXZpLm9yZyIsImRldmljZV9jZXJ0IjoiTUlJQjh6Q0NBVndDQVFFd0RRWUpLb1pJaHZjTkFRRUxCUUF3UWpFTE1Ba0dBMVVFQmhNQ1ZWTXhEekFOQmdOVkJBZ01Cazl5WldkdmJqRVJNQThHQTFVRUJ3d0lVRzl5ZEd4aGJtUXhEekFOQmdOVkJBb01Ca2RGVGtsV1NUQWVGdzB4TlRFeE1qY3lNekUwTlRKYUZ3MHhOakV4TWpZeU16RTBOVEphTUVJeEN6QUpCZ05WQkFZVEFsVlRNUTh3RFFZRFZRUUlEQVpQY21WbmIyNHhFVEFQQmdOVkJBY01DRkJ2Y25Sc1lXNWtNUTh3RFFZRFZRUUtEQVpIUlU1SlZra3dnWjh3RFFZSktvWklodmNOQVFFQkJRQURnWTBBTUlHSkFvR0JBSnR2aU04QVJJckZxdVBjMG15QjlCdUY5TWRrQS8yU2F0cWJaTVdlVE9VSkhHcmpCREVFTUxRN3prOEF5Qm1pN1JxdVlZWnM2N1N5TGh5bFZHS2g2c0pBbGVjeGJIVXdqN2NaU1MxYm1LTWplNkw2MWdLd3hCbTJOSUZVMWNWbDJqSmxUYVU5VlloTTR4azU3eWoyOG5rTnhTWVdQMXZiRlgyTkRYMmlIN2I1QWdNQkFBRXdEUVlKS29aSWh2Y05BUUVMQlFBRGdZRUFoYnFWcjlFLzBNNzI5bmM2REkrcWdxc1JTTWZveXZBM0Ntbi9FQ3hsMXliR2t1ek83c0I4ZkdqZ01ROXp6Y2I2cTF1UDN3R2pQaW9xTXltaVlZalVtQ1R2emR2UkJaKzZTRGpyWmZ3VXVZZXhpS3FJOUFQNlhLYUhsQUwxNCtySys2SE40dUlrWmNJelB3U01IaWgxYnNUUnB5WTVaM0NVRGNESmtZdFZiWXM9IiwidmFsaWRpdHkiOnsic3RhcnQiOjE0NDg2ODM3NDIsInN0b3AiOjE0ODAyMTk3NDJ9LCJyaWdodF90b19yZWdpc3RlciI6WyJnZW5pdmkub3JnLyJdLCJjcmVhdGVfdGltZXN0YW1wIjoxNDQ4NjgzNzQyLCJpZCI6Inh4eCJ9.OPRklok0vZDNMHwwpOVx7lq8lDU0ukXFOAZsYBqUbD6ydy4yq-EZoFl9unTm4yQzZ9z-s31sCZyC5-qnQgpZl85oloqJA4gD0E1c4JDMRf0-arRUlCsMW74SWMRj3zTDTItc2D-R4Nhk-D_f1ZqkadhYiYFyKRcw_vhJ03OZowQ\"]}"];
    }
    else if ([dlinkPacket isKindOfClass:[RVIDlinkServiceAnnouncePacket class]])
    {
        [self.delegate onRemoteConnectionDidReceiveData:@"{\"cmd\":\"sa\",\"stat\":\"av\",\"svcs\":[\"genivi.org/vin/lilli/hvac/seat_heat_right\"]}"];
    }
    else if ([dlinkPacket isKindOfClass:[RVIDlinkReceivePacket class]])
    {
        [self.delegate onRemoteConnectionDidReceiveData:@"{\"tid\":4,\"cmd\":\"rcv\",\"mod\":\"proto_json_rpc\",\"data\":\"{\\\"tid\\\":4,\\\"service\\\":\\\"genivi.org/android/mN2XDXuzT3K4TEZkLwB2Lg/hvac/seat_heat_right\\\",\\\"timeout\\\":1454362937000,\\\"parameters\\\":{\\\"value\\\":\\\"0\\\"}}\"}"];
    }
}

//- (BOOL)isConnected
//{
//    //return mSocket != null && mSocket.isConnected();
//    return self.isConnected;
//}

- (BOOL)isConfigured
{
    //return !(mServerUrl == null || mServerUrl.isEmpty() || mServerPort == 0 || mClientKeyStore == null || mServerKeyStore == null);
    return YES;
}

- (void)connect
{
    DLog(@"");
    if ([self isConnected]) [self disconnect:nil];

    [self connectSocket];
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

- (void)connectSocket
{
    self.isConnected = YES;

    [self.delegate onRemoteConnectionDidConnect];

    //[self setup];
}

- (void)setup
{
    CFReadStreamRef  readStream;
    CFWriteStreamRef writeStream;
	NSURL *url = [NSURL URLWithString:self.serverUrl];
	
	NSLog(@"Setting up connection to %@ : %i", [url absoluteString], (int)self.serverPort);
	
	CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)[url host], self.serverPort, &readStream, &writeStream);
	
	if(!CFWriteStreamOpen(writeStream)) {
		NSLog(@"Error, writeStream not open");
		
		return;
	}

    self.inputStream = (__bridge NSInputStream *)readStream;
   	self.outputStream = (__bridge NSOutputStream *)writeStream;

	[self open];
	
	NSLog(@"Status of self.outputStream: %i", [self.outputStream streamStatus]);


	return;
}

- (void)open
{
	NSLog(@"Opening streams.");
	
//	self.inputStream = (NSInputStream *)self.readStream;
//	self.outputStream = (NSOutputStream *)self.writeStream;
	
	[self.inputStream setDelegate:self];
	[self.outputStream setDelegate:self];
	
	[self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	
	[self.inputStream open];
	[self.outputStream open];
}

- (void)close
{
	NSLog(@"Closing streams.");
	
	[self.inputStream close];
	[self.outputStream close];
	
	[self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	
	[self.inputStream setDelegate:nil];
	[self.outputStream setDelegate:nil];
	
	self.inputStream = nil;
	self.outputStream = nil;
}

- (void)connectSocket2
{
    DLog(@"");

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSData   *iosTrustedCertDerData = [NSData dataWithContentsOfFile:[bundle pathForResource:@"server-certs"
                                                                                      ofType:@"der"]];

    SecCertificateRef certificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef) iosTrustedCertDerData);

    self.certificate = certificate;

    [self verifiesManually:certificate];
}

//- (void)useKeychain:(SecCertificateRef)certificate
//{
//    OSStatus err =SecItemAdd((__bridge CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
//                                                                                                   (id)kSecClassCertificate, kSecClass,
//                                                                                                   certificate, kSecValueRef, nil],
//                             NULL);
//    if ((err == noErr) || // success!
//            (err == errSecDuplicateItem))
//    { // the cert was already added.  Success!
//        // create your socket normally.
//        // This is oversimplified.  Refer to the CFNetwork Guide for more details.
//        CFReadStreamRef  readStream;
//        CFWriteStreamRef writeStream;
//        CFStreamCreatePairWithSocketToHost(NULL,
//                                            (CFStringRef)@"localhost",
//                                            8443,
//                                            &readStream,
//                                            &writeStream);
//        CFReadStreamSetProperty(readStream,
//                                kCFStreamPropertySocketSecurityLevel,
//                                kCFStreamSocketSecurityLevelTLSv1);
//        CFReadStreamOpen(readStream);
//        CFWriteStreamOpen(writeStream);
//    } else
//    {
//        // handle the error.  There is probably something wrong with your cert.
//    }
//}

- (void)verifiesManually:(SecCertificateRef)certificate
{
    DLog(@"");

    CFReadStreamRef  readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL,
                                        (__bridge CFStringRef)self.serverUrl,
                                        self.serverPort,
                                        &readStream,
                                        &writeStream);

    // Set this kCFStreamPropertySocketSecurityLevel before
    // setting kCFStreamPropertySSLSettings.
    // Setting kCFStreamPropertySocketSecurityLevel
    // appears to override previous settings in kCFStreamPropertySSLSettings
    CFReadStreamSetProperty(readStream,
                            kCFStreamPropertySocketSecurityLevel,
                            kCFStreamSocketSecurityLevelTLSv1);

    // this disables certificate chain validation in ssl settings.
    NSDictionary *sslSettings =
                         [NSDictionary dictionaryWithObjectsAndKeys:
                                               (id)kCFBooleanFalse, (id)kCFStreamSSLValidatesCertificateChain, nil];

    CFReadStreamSetProperty(readStream,
                            kCFStreamPropertySSLSettings,
                            (__bridge CFDictionaryRef)sslSettings);

    NSInputStream  *inputStream  = (__bridge NSInputStream *)readStream;
    NSOutputStream *outputStream = (__bridge NSOutputStream *)writeStream;

    [inputStream setDelegate:self];
    [outputStream setDelegate:self];

    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                           forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                            forMode:NSDefaultRunLoopMode];

    CFReadStreamOpen(readStream);
    CFWriteStreamOpen(writeStream);
}

#pragma mark -
#pragma mark NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    DLog(@"");

    // #1
    // NO for client, YES for server.  In this example, we are a client
    // replace "localhost" with the name of the server to which you are connecting
    //SecPolicyRef policy             = SecPolicyCreateSSL(NO, CFSTR("localhost"));
    SecPolicyRef policy             = SecPolicyCreateSSL(NO, (__bridge CFStringRef)self.serverUrl);
    SecTrustRef  trust              = NULL;

    // #2
    CFArrayRef   streamCertificates = (__bridge CFArrayRef)[aStream propertyForKey:(NSString *)kCFStreamPropertySSLPeerCertificates];

    switch (eventCode)
    {
        case NSStreamEventNone:
            DLog(@"NSStreamEventNone");
            break;
        case NSStreamEventOpenCompleted:
            DLog(@"NSStreamEventOpenCompleted");
            break;
        case NSStreamEventHasBytesAvailable:
            DLog(@"NSStreamEventHasBytesAvailable");
            break;
        case NSStreamEventHasSpaceAvailable:
            DLog(@"NSStreamEventHasSpaceAvailable");

            // #3
//            SecTrustCreateWithCertificates(streamCertificates, policy, &trust);
//
//            // #4
//            SecTrustSetAnchorCertificates(trust, (__bridge CFArrayRef)[NSArray arrayWithObject:(id)self.certificate]);
//
//            // #5
//            SecTrustResultType trustResultType = kSecTrustResultInvalid;
//            OSStatus           status          = SecTrustEvaluate(trust, &trustResultType);
//            if (status == errSecSuccess)
//            {
//                // expect trustResultType == kSecTrustResultUnspecified
//                // until my cert exists in the keychain see technote for more detail.
//                if (trustResultType == kSecTrustResultUnspecified)
//                {
//                    NSLog(@"We can trust this certificate! TrustResultType: %d", trustResultType);
//                }
//                else
//                {
//                    NSLog(@"Cannot trust certificate. TrustResultType: %d", trustResultType);
//                }
//            }
//            else
//            {
//                NSLog(@"Creating trust failed: %d", status);
//                [aStream close];
//            }
//            if (trust)
//            {
//                CFRelease(trust);
//            }
//            if (policy)
//            {
//                CFRelease(policy);
//            }
            break;
        case NSStreamEventErrorOccurred:
            NSLog(@"unexpected NSStreamEventErrorOccurred: %@", [aStream streamError]);
            break;
        case NSStreamEventEndEncountered:
            DLog(@"NSStreamEventEndEncountered");
            break;
        default:
            break;
    }
}
@end
