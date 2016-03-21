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
#import "RVINode.h"

@interface RVIServerConnection () <NSStreamDelegate>
@property (nonatomic) SecCertificateRef       certificate;
@property (nonatomic, strong) NSInputStream  *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic) BOOL                    isConnected;
@property (nonatomic) BOOL                    isConnecting;
@property (nonatomic) BOOL                    verifiedInputCerts;
@property (nonatomic) BOOL                    verifiedOutputCerts;
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
    {
        [self.delegate onDidFailToSendDataToRemoteConnection:[NSError errorWithDomain:GENIVI_ERROR_DOMAIN
                                                                                 code:kRVINodeNotConfigured
                                                                             userInfo:@{NSLocalizedDescriptionKey : @"Sending data to node has failed: RVI node is not configured or connected"}]];
        return;
    }

    NSError *jsonError;
    NSData  *payload = [NSJSONSerialization dataWithJSONObject:[dlinkPacket toDictionary]
                                                       options:nil
                                                         error:&jsonError];

    if (jsonError)
    {
        [self.delegate onDidFailToSendDataToRemoteConnection:[NSError errorWithDomain:GENIVI_ERROR_DOMAIN
                                                                                 code:kRVINodeJsonError
                                                                             userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Sending data to node has failed: %@", jsonError.localizedDescription],
                                                                                        NSUnderlyingErrorKey      : jsonError }]];
        return;

    }

    NSString *payloadString = [[NSString alloc] initWithData:payload encoding:NSUTF8StringEncoding];
    [self writeString:payloadString];

    DLog(@"Sending packet: %@", payloadString);
}

- (BOOL)isConfigured
{
    return ([self.serverUrl length] && self.serverPort && [self.serverCertificate length] && [self.serverDomain length] && [self.clientCertificate length] && [self.clientCertificatePassword length]);
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

- (void)errorConnecting:(NSInteger)code underlyingError:(NSError *)underlyingError
{
    NSString *localizedDescription;

    switch (code)
    {
        case errSecUnimplemented                    : localizedDescription = @"Connection to RVI node has failed due to TLS error: Function or operation not implemented.";                           break; // -4
        case errSecIO                               : localizedDescription = @"Connection to RVI node has failed due to TLS error: I/O error (bummers)";                                              break; // -36
        case errSecOpWr                             : localizedDescription = @"Connection to RVI node has failed due to TLS error: File already open with with write permission";                     break; // -49
        case errSecParam                            : localizedDescription = @"Connection to RVI node has failed due to TLS error: One or more parameters passed to a function where not valid.";     break; // -50
        case errSecAllocate                         : localizedDescription = @"Connection to RVI node has failed due to TLS error: Failed to allocate memory.";                                       break; // -108
        case errSecUserCanceled                     : localizedDescription = @"Connection to RVI node has failed due to TLS error: User canceled the operation.";                                     break; // -128
        case errSecBadReq                           : localizedDescription = @"Connection to RVI node has failed due to TLS error: Bad parameter or invalid state for operation.";                    break; // -909
        case errSecInternalComponent                : localizedDescription = @"Connection to RVI node has failed due to TLS error: errSecInternalComponent";                                          break; // -2070
        case errSecNotAvailable                     : localizedDescription = @"Connection to RVI node has failed due to TLS error: No keychain is available. You may need to restart your computer."; break; // -25291
        case errSecDuplicateItem                    : localizedDescription = @"Connection to RVI node has failed due to TLS error: The specified item already exists in the keychain.";               break; // -25299
        case errSecItemNotFound                     : localizedDescription = @"Connection to RVI node has failed due to TLS error: The specified item could not be found in the keychain.";           break; // -25300
        case errSecInteractionNotAllowed            : localizedDescription = @"Connection to RVI node has failed due to TLS error: User interaction is not allowed.";                                 break; // -25308
        case errSecDecode                           : localizedDescription = @"Connection to RVI node has failed due to TLS error: Unable to decode the provided data.";                              break; // -26275
        case errSecAuthFailed                       : localizedDescription = @"Connection to RVI node has failed due to TLS error: The user name or passphrase you entered is not correct.";          break; // -25293
        case kSecTrustResultDeny                    : localizedDescription = @"Connection to RVI node has failed due to TLS error: User-configured deny.";                                            break; // 3
        case kSecTrustResultUnspecified             : localizedDescription = @"Connection to RVI node has failed due to TLS error: User intent is unknown.";                                          break; // 4
        case kSecTrustResultRecoverableTrustFailure : localizedDescription = @"Connection to RVI node has failed due to TLS error: Trust framework failure; retry after fixing inputs.";              break; // 5
        case kSecTrustResultFatalTrustFailure       : localizedDescription = @"Connection to RVI node has failed due to TLS error: Trust framework failure; no \"easy\" fix.";                        break; // 6
        case kSecTrustResultOtherError              : localizedDescription = @"Connection to RVI node has failed due to TLS error: A failure other than that of trust evaluation.";                   break; // 7
        case kRVINodeMissingServerCert              : localizedDescription = @"Connection to RVI node has failed due to TLS error: Failure loading server cert.";                                     break; // 1003
        case kRVINodeMissingClientCert              : localizedDescription = @"Connection to RVI node has failed due to TLS error: Failure loading client cert.";                                     break; // 1004
        case kRVINodeNotReceivingCertFromServer     : localizedDescription = @"Connection to RVI node has failed due to TLS error: Server connection did not send cert.";                             break; // 1005
        default                                     : localizedDescription = @"The secure connection failed for an unknown reason. Check underlying error";                                           break;
    }

    DLog(@"%@", localizedDescription);

    [self.delegate onRemoteConnectionDidFailToConnect:[NSError errorWithDomain:GENIVI_ERROR_DOMAIN
                                                                          code:code
                                                                      userInfo:@{ NSLocalizedDescriptionKey : localizedDescription,
                                                                                  NSUnderlyingErrorKey : underlyingError ? (id)underlyingError : (id)kCFNull }]];

    [self close];
}

- (void)finishConnecting
{
    self.isConnecting = NO;
    self.isConnected = YES;

    [self.delegate onRemoteConnectionDidConnect];
}

- (void)setup
{
    OSStatus  status = errSecSuccess;
    NSURL    *url    = [NSURL URLWithString:self.serverUrl];

    DLog(@"Setting up connection to %@ : %i", [url absoluteString], (int)self.serverPort);

    NSBundle *bundle                = [NSBundle bundleForClass:[self class]];
    NSData   *iosTrustedCertDerData = [NSData dataWithContentsOfFile:[bundle pathForResource:[self.serverCertificate stringByDeletingPathExtension]
                                                                                      ofType:@"der"]];

    if (!iosTrustedCertDerData)
    {
        [self errorConnecting:kRVINodeMissingServerCert underlyingError:nil];
        return;
    }

    SecCertificateRef certificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)iosTrustedCertDerData);

    if (!certificate)
    {
        [self errorConnecting:kRVINodeMissingServerCert underlyingError:nil];
        return;
    }

    self.certificate = certificate;

    NSString *path = [[NSBundle mainBundle] pathForResource:[self.clientCertificate stringByDeletingPathExtension]
                                                     ofType:@"p12"];

    CFStringRef cfPassword = CFStringCreateWithCString(NULL,
                                                       self.clientCertificatePassword.UTF8String,
                                                       kCFStringEncodingUTF8);

    const void *keys[]   = { kSecImportExportPassphrase };
    const void *values[] = { cfPassword };

    CFDictionaryRef optionsDictionary = CFDictionaryCreate(kCFAllocatorDefault, keys, values, 1, NULL, NULL);

    NSData *fileContent = [[NSData alloc] initWithContentsOfFile:path];
    CFDataRef cfDataOfFileContent = (__bridge CFDataRef)fileContent;

    if (!cfDataOfFileContent)
    {
        [self errorConnecting:kRVINodeMissingClientCert underlyingError:nil];
        return;
    }

    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    status = SecPKCS12Import(cfDataOfFileContent,
                             optionsDictionary,
                             &items);

    if (status != errSecSuccess)
    {
        [self errorConnecting:status underlyingError:nil];
        return;
    }

    CFDictionaryRef yourIdentityAndTrust = CFArrayGetValueAtIndex(items, 0);
    const void *tempIdentity = NULL;
    tempIdentity = CFDictionaryGetValue(yourIdentityAndTrust,
                                        kSecImportItemIdentity);

    SecIdentityRef yourIdentity = (SecIdentityRef)tempIdentity;

    SecCertificateRef yourCertificate = NULL;
    status = SecIdentityCopyCertificate(yourIdentity, &yourCertificate);

    if (status != errSecSuccess)
    {
        [self errorConnecting:status underlyingError:nil];
        return;
    }

    const void *keys2[]   = { kSecValueRef,    kSecClass };
    const void *values2[] = { yourCertificate, kSecClassCertificate };
    CFDictionaryRef dict  = CFDictionaryCreate(kCFAllocatorDefault, keys2, values2, 2, NULL, NULL);
    status = SecItemAdd(dict, NULL);

    if (status != errSecSuccess && status != errSecDuplicateItem)
    {
        [self errorConnecting:status underlyingError:nil];
        return;
    }

    CFReadStreamRef  readStream;
    CFWriteStreamRef writeStream;

    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)[url absoluteString], self.serverPort, &readStream, &writeStream);

    self.inputStream  = (__bridge_transfer NSInputStream *)readStream;
    self.outputStream = (__bridge_transfer NSOutputStream *)writeStream;

    NSDictionary *sslSettings = @{  (id)kCFStreamSSLValidatesCertificateChain : (id)kCFBooleanFalse,
                                    (id)kCFStreamSSLPeerName                  : self.serverUrl,
                                    (id)kCFStreamSSLLevel                     : (id)kCFStreamSocketSecurityLevelSSLv3,
                                    (id)kCFStreamPropertySocketSecurityLevel  : (id)kCFStreamSocketSecurityLevelSSLv3,
                                    (id)kCFStreamSSLCertificates              : @[(__bridge id)yourIdentity],
                                    (id)kCFStreamSSLIsServer                  : (id)kCFBooleanFalse };

    [self.inputStream setProperty:sslSettings
                           forKey:(__bridge NSString *)kCFStreamPropertySSLSettings];

    [self.outputStream setProperty:sslSettings
                            forKey:(__bridge NSString *)kCFStreamPropertySSLSettings];
}

- (void)open
{
    DLog(@"Opening streams.");

    [self.inputStream setDelegate:self];
    [self.outputStream setDelegate:self];

    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

    [self.inputStream open];
    [self.outputStream open];
}

- (void)close
{
    DLog(@"Closing streams.");

    [self.inputStream close];
    [self.outputStream close];

    [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

    [self.inputStream setDelegate:nil];
    [self.outputStream setDelegate:nil];

    self.inputStream  = nil;
    self.outputStream = nil;

    self.verifiedInputCerts = NO;
    self.verifiedOutputCerts = NO;

    self.certificate = nil;
}

- (void)readString:(NSString *)string
{
    [self.delegate onRemoteConnectionDidReceiveData:string];
}

- (void)writeString:(NSString *)string
{
    [self.outputStream write:(uint8_t *)[string UTF8String] maxLength:strlen((char *)[string UTF8String])];
}

- (NSInteger)verifyCertsForStream:(NSStream *)stream
{
    DLog(@"");

    SecTrustRef serverTrust;
    SecTrustResultType res = kSecTrustResultInvalid;

    SecPolicyRef policy = SecPolicyCreateSSL(NO, (__bridge CFStringRef)self.serverDomain);
    CFArrayRef streamCertificates = (__bridge CFArrayRef)[stream propertyForKey:(NSString *)kCFStreamPropertySSLPeerCertificates];

    if (!streamCertificates)
        return kRVINodeNotReceivingCertFromServer;

    OSStatus status = SecTrustCreateWithCertificates(streamCertificates, policy, &serverTrust);

    if (status != errSecSuccess)
        return status;

    status = SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)@[(id)self.certificate]);

    if (status != errSecSuccess)
        return status;

    status = SecTrustEvaluate(serverTrust, &res);

    if (status != errSecSuccess)                                            /* The trust evaluation failed for some reason. This probably means your */
        return status;                                                      /* certificate was broken in some way or your code is otherwise wrong.   */

    if (res != kSecTrustResultProceed && res != kSecTrustResultUnspecified) /* The host is not trusted. */
        return res;
    else                                                                    /* Host is trusted. Handle the data callback normally. */
        return errSecSuccess;
}

#pragma mark -
#pragma mark NSStreamDelegate

#define BUFFER_LEN 2048
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    NSInteger result = 0;
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
            
            if (!self.verifiedInputCerts)
                result = [self verifyCertsForStream:stream];
            
            if (result)
            {
                [self errorConnecting:result underlyingError:nil];
                break;
            }

            self.verifiedOutputCerts = NO;

            if (stream == self.inputStream)
            {
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
                DLog(@"stream != self.inputStream");
            }

            break;
        case NSStreamEventHasSpaceAvailable:
            DLog(@"NSStreamEventHasSpaceAvailable");
            
            if (!self.verifiedOutputCerts)
                result = [self verifyCertsForStream:stream];

            
            if (result)
            {
                [self errorConnecting:result underlyingError:nil];
                break;
            }

            self.verifiedOutputCerts = YES;

            if (stream == self.outputStream)
            {
                if (self.isConnecting)
                    [self finishConnecting];
            }
            else
            {
                DLog(@"stream != self.outputStream");
            }
            break;
        case NSStreamEventErrorOccurred:
            DLog(@"unexpected NSStreamEventErrorOccurred: %@", [stream streamError]);

            if (self.isConnecting)
                [self errorConnecting:[[stream streamError] code] underlyingError:[stream streamError]];

            else if (self.isConnected)
                [self disconnect:[stream streamError]];

            break;
        case NSStreamEventEndEncountered:
            DLog(@"NSStreamEventEndEncountered: %@", [[stream class] description]);

            if (self.isConnecting)
                [self errorConnecting:kRVINodeStreamEndEncountered underlyingError:nil];

            else if (self.isConnected)
                [self disconnect:[NSError errorWithDomain:GENIVI_ERROR_DOMAIN
                                                     code:kRVINodeStreamEndEncountered
                                                 userInfo:@{ NSLocalizedDescriptionKey : @"The end of the stream has been reached." }]];

            break;
        default:
            break;
    }
}
@end
