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

#import "RVIRemoteConnectionDelegate.h"
#import "RVIServerConnection.h"
#import "RVIUtil.h"
#import "RVIDlinkAuthPacket.h"

@interface RVIServerConnection () <NSStreamDelegate>
@property (nonatomic) SecCertificateRef      certificate;
@property (nonatomic) SecCertificateRef      certificate2;
@property (nonatomic, strong) NSInputStream  *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic) BOOL                   isConnected;
@property (nonatomic) BOOL                   isConnecting;
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
    NSBundle *bundle                = [NSBundle bundleForClass:[self class]];
    NSData   *iosTrustedCertDerData = [NSData dataWithContentsOfFile:[bundle pathForResource:@"lilli_ios_cert"
                                                                                      ofType:@"der"]];

    SecCertificateRef certificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)iosTrustedCertDerData);

    // TODO: If cert is null, error

    self.certificate = certificate;


    NSString *password = @"password";
    NSString *path = [[NSBundle mainBundle] pathForResource:@"client" ofType:@"p12"];

    // prepare password
    CFStringRef cfPassword = CFStringCreateWithCString(NULL,
                                                       password.UTF8String,
                                                       kCFStringEncodingUTF8);

    const void *keys[]   = { kSecImportExportPassphrase };
    const void *values[] = { cfPassword };

    CFDictionaryRef optionsDictionary = CFDictionaryCreate(kCFAllocatorDefault, keys, values, 1, NULL, NULL);

    // prepare p12 file content
    NSData *fileContent = [[NSData alloc] initWithContentsOfFile:path];
    CFDataRef cfDataOfFileContent = (__bridge CFDataRef)fileContent;

    // extract p12 file content into items (array)
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    OSStatus status = errSecSuccess;
    status = SecPKCS12Import(cfDataOfFileContent,
                             optionsDictionary,
                             &items);
    // TODO: error handling on status

    // extract identity
    CFDictionaryRef yourIdentityAndTrust = CFArrayGetValueAtIndex(items, 0);
    const void *tempIdentity = NULL;
    tempIdentity = CFDictionaryGetValue(yourIdentityAndTrust,
                                        kSecImportItemIdentity);

    SecIdentityRef yourIdentity = (SecIdentityRef)tempIdentity;


    // get certificate from identity
    SecCertificateRef yourCertificate = NULL;
    status = SecIdentityCopyCertificate(yourIdentity, &yourCertificate);

    // at last, install certificate into keychain
    const void *keys2[]   = {    kSecValueRef,             kSecClass };
    const void *values2[] = { yourCertificate,  kSecClassCertificate };
    CFDictionaryRef dict  = CFDictionaryCreate(kCFAllocatorDefault, keys2, values2, 2, NULL, NULL);
    status = SecItemAdd(dict, NULL);


    // TODO: error handling on status


    self.certificate2 = yourCertificate;


    NSArray *myCerts = [[NSArray alloc] initWithObjects:(__bridge id)yourIdentity, /*(__bridge id)yourCertificate, (__bridge id)certificate,*/ nil];


    CFReadStreamRef  readStream;
    CFWriteStreamRef writeStream;
    NSURL            *url = [NSURL URLWithString:self.serverUrl];

    NSLog(@"Setting up connection to %@ : %i", [url absoluteString], (int)self.serverPort);

    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)[url absoluteString], self.serverPort, &readStream, &writeStream);

    self.inputStream  = (__bridge_transfer NSInputStream *)readStream;
    self.outputStream = (__bridge_transfer NSOutputStream *)writeStream;

    // this disables certificate chain validation in ssl settings.
    NSDictionary *sslSettings = @{  (id)kCFStreamSSLValidatesCertificateChain : (id)kCFBooleanFalse,
                                    (id)kCFStreamSSLPeerName                  : self.serverUrl,
                                    (id)kCFStreamSSLLevel                     : (id)kCFStreamSocketSecurityLevelSSLv3,
                                    (id)kCFStreamPropertySocketSecurityLevel  : (id)kCFStreamSocketSecurityLevelSSLv3,
                                    (id)kCFStreamSSLCertificates              : myCerts,
                                    (id)kCFStreamSSLIsServer                  : (id)kCFBooleanFalse };

    [self.inputStream setProperty:sslSettings
                           forKey:(__bridge NSString *)kCFStreamPropertySSLSettings];

    [self.outputStream setProperty:sslSettings
                            forKey:(__bridge NSString *)kCFStreamPropertySSLSettings];
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
NSString *kAnchorAlreadyAdded = @"AnchorAlreadyAdded";

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    DLog(@"");

    BOOL isGood = NO;

    // #1
    // NO for client, YES for server.  In this example, we are a client
    // replace "localhost" with the name of the server to which you are connecting
    //SecPolicyRef policy             = SecPolicyCreateSSL(NO, CFSTR("localhost"));
    SecPolicyRef policy = SecPolicyCreateSSL(NO, CFSTR("genivi.org"));//(__bridge CFStringRef)self.serverUrl);
    //SecTrustRef  trust  = NULL;

    // #2
    CFArrayRef streamCertificates = (__bridge CFArrayRef)[stream propertyForKey:(NSString *)kCFStreamPropertySSLPeerCertificates];

    SecTrustRef serverTrust;
    OSStatus status;
    // noErr == status?

    if (eventCode == NSStreamEventHasBytesAvailable || eventCode == NSStreamEventHasSpaceAvailable)
    {

        status = SecTrustCreateWithCertificates(streamCertificates, policy, &serverTrust);

        /* Because you don't want the array of certificates to keep
           growing, you should add the anchor to the trust list only
           upon the initial receipt of data (rather than every time).
         */
        NSNumber *alreadyAdded = [stream propertyForKey:kAnchorAlreadyAdded];
        if (!alreadyAdded || ![alreadyAdded boolValue])
        {
            NSLog(@"Not already added for stream");

            status = SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)@[(id)self.certificate]);
            // noErr == status?

            [stream setProperty:@YES forKey:kAnchorAlreadyAdded];
        }
        SecTrustResultType res = kSecTrustResultInvalid;

        if (SecTrustEvaluate(serverTrust, &res))
        {
            /* The trust evaluation failed for some reason.
               This probably means your certificate was broken
               in some way or your code is otherwise wrong. */

            DLog(@"SecTrustEvaluate(trust, &res) failed");

            // TODO: Handle correctly
            [self close];

            return;

        }

        if (res != kSecTrustResultProceed && res != kSecTrustResultUnspecified)
        {

            DLog(@"(res != kSecTrustResultProceed && res != kSecTrustResultUnspecified) res = %d", res);

            // TODO: Handle correctly
            [self close];

            return;

        }
        else
        {
            // Host is trusted. Handle the data callback normally.
            isGood = YES;
        }
    }
    
    
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

            if (!isGood)
                break;

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

            if (!isGood)
                break;

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
