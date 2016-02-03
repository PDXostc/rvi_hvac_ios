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
@property (nonatomic) SecCertificateRef       certificate;
@property (nonatomic, strong) NSInputStream  *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic) BOOL                    isConnected;
@property (nonatomic) BOOL                    isConnecting;
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
        [self.delegate onDidFailToSendDataToRemoteConnection:[NSError errorWithDomain:@"TODO" code:000 userInfo:@{NSLocalizedDescriptionKey : @"RVI node is not connected"}]]; // TODO: PORT_COMPLETE
        return;
    }

    NSError *jsonError;
    NSData  *payload = [NSJSONSerialization dataWithJSONObject:[dlinkPacket toDictionary]
                                                       options:nil
                                                         error:&jsonError];

    NSString *payloadString = [[NSString alloc] initWithData:payload encoding:NSUTF8StringEncoding];

    DLog(@"Sending data: %@", payloadString);

    [self writeString:payloadString];
}

- (BOOL)isConfigured
{
    return ([self.serverUrl length] && self.serverPort);
}

- (void)connect
{
    DLog(@"");

    if ([self isConnected])
        [self disconnect:nil];

    [self connectSocket];
}

- (void)disconnect:(NSError *)trigger
{
    self.isConnected = NO;

    [self close];

    if (trigger != nil)
        [self.delegate onRemoteConnectionDidDisconnect:trigger];
}

- (void)connectSocket
{
    self.isConnecting = YES;

    [self setup];
    [self open];
}

- (void)setup
{
    CFReadStreamRef  readStream;
    CFWriteStreamRef writeStream;
    NSURL            *url = [NSURL URLWithString:self.serverUrl];

    NSLog(@"Setting up connection to %@ : %i", [url absoluteString], (int)self.serverPort);

    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)[url absoluteString], self.serverPort, &readStream, &writeStream);

    self.inputStream  = (__bridge_transfer NSInputStream *)readStream;
    self.outputStream = (__bridge_transfer NSOutputStream *)writeStream;
}

- (void)open
{
    NSLog(@"Opening streams.");

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

    self.inputStream  = nil;
    self.outputStream = nil;
}

- (void)setup2
{
    DLog(@"");

    NSBundle *bundle                = [NSBundle bundleForClass:[self class]];
    NSData   *iosTrustedCertDerData = [NSData dataWithContentsOfFile:[bundle pathForResource:@"server-certs"
                                                                                      ofType:@"der"]];

    SecCertificateRef certificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)iosTrustedCertDerData);

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
    NSDictionary *sslSettings = @{(id)kCFStreamSSLValidatesCertificateChain : (id)kCFBooleanFalse};

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

- (void)readString:(NSString *)string
{
    NSLog(@"Reading in the following:");
    NSLog(@"%@", string);

    [self.delegate onRemoteConnectionDidReceiveData:string];
}

- (void)writeString:(NSString *)string
{
    uint8_t *buf = (uint8_t *)[string UTF8String];

    [self.outputStream write:buf maxLength:strlen((char *)buf)];

    NSLog(@"Writing out the following:");
    NSLog(@"%@", string);
}

#pragma mark -
#pragma mark NSStreamDelegate


#define BUFFER_LEN 1024
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    DLog(@"");

    // #1
    // NO for client, YES for server.  In this example, we are a client
    // replace "localhost" with the name of the server to which you are connecting
    //SecPolicyRef policy             = SecPolicyCreateSSL(NO, CFSTR("localhost"));
    SecPolicyRef policy = SecPolicyCreateSSL(NO, (__bridge CFStringRef)self.serverUrl);
    SecTrustRef  trust  = NULL;

    // #2
    CFArrayRef streamCertificates = (__bridge CFArrayRef)[stream propertyForKey:(NSString *)kCFStreamPropertySSLPeerCertificates];

    switch (eventCode)
    {
        case NSStreamEventNone:
            DLog(@"NSStreamEventNone");
            break;
        case NSStreamEventOpenCompleted:
            DLog(@"NSStreamEventOpenCompleted: %@", [[stream class] description]);
            break;
        case NSStreamEventHasBytesAvailable:
            DLog(@"NSStreamEventHasBytesAvailable");

            if (stream == self.inputStream)
            {
                NSLog(@"inputStream is ready.");

                uint8_t   buf[BUFFER_LEN];
                NSInteger len = [self.inputStream read:buf maxLength:BUFFER_LEN];
                NSMutableData *data = [[NSMutableData alloc] initWithLength:0];

                if (len > 0)
                {
                    [data appendBytes:(const void *)buf length:(NSUInteger)len];
                    [self readString:[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]];
                }
            }
            else
            {
                NSLog(@"stream != self.inputStream");
            }

            break;
        case NSStreamEventHasSpaceAvailable:
            DLog(@"NSStreamEventHasSpaceAvailable");

            if (stream == self.outputStream)
            {
                NSLog(@"outputStream is ready.");

                if (self.isConnecting)
                    [self finishConnecting];
            }
            else
            {
                NSLog(@"stream != self.outputStream");
            }

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
//                [stream close];
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
            NSLog(@"unexpected NSStreamEventErrorOccurred: %@", [stream streamError]);
            break;
        case NSStreamEventEndEncountered:
            DLog(@"NSStreamEventEndEncountered: %@", [[stream class] description]);
            break;
        default:
            break;
    }
}

- (void)finishConnecting
{
    self.isConnecting = NO;
    self.isConnected = YES;

    [self.delegate onRemoteConnectionDidConnect];
}
@end
