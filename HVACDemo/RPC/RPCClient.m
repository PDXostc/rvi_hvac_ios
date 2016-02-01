// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
// Copyright (c) 2015 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
//
// File:    RPCClient.m
// Project: HVACDemo
//
// Created by Lilli Szafranski on 5/1/15.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import "RPCClient.h"

@interface RPCClient ()
@property (nonatomic, strong) NSString *serviceEndpoint;
@end

@implementation RPCClient
{

}

- (id)initWithServiceEndpoint:(NSString *)endpoint
{
    if ((self = [super init]))
    {
        self.serviceEndpoint = endpoint;
    }

    return self;
}

- (void)postRequest:(RPCRequest *)request
{
//    NSError *jsonError;
//    NSData  *payload = [NSJSONSerialization dataWithJSONObject:[request serialize]
//                                                       options:nil
//                                                         error:&jsonError];
//
//    NSLog(@"Sending: %@", [NSString stringWithCString:[payload bytes] encoding:NSUTF8StringEncoding]);
//
////    if(jsonError != nil)
////        [self handleFailedRequest:request withError:[NSError errorWithDomain:@"500" code:500 userInfo:nil]];
////    else
////    {
//    NSMutableURLRequest *serviceRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.serviceEndpoint]];
//    //NSMutableURLRequest *serviceRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://posttestserver.com/post.php"]];//self.serviceEndpoint]];
//
//    [serviceRequest setValue:@"application/json-rpc" forHTTPHeaderField:@"Content-Type"];
//    [serviceRequest setValue:@"objc-JSONRpc/1.0" forHTTPHeaderField:@"User-Agent"];
//
//    [serviceRequest setValue:[NSString stringWithFormat:@"%i", payload.length] forHTTPHeaderField:@"Content-Length"];
//    [serviceRequest setHTTPMethod:@"POST"];
//    [serviceRequest setHTTPBody:payload];
//
////    NSString *foo = [[NSString alloc] initWithData:payload encoding:NSUTF8StringEncoding];
////    NSLog(@"foo: %@", foo);
//
//    NSURLResponse *response = nil;
//    NSError       *error    = nil;
//    NSData        *data     = [NSURLConnection sendSynchronousRequest:serviceRequest returningResponse:&response error:&error];
//
//    NSString *foo2 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"foo2: %@", foo2);
//
//    if(data != nil)
//        [self handleData:data forRequest:request];
//    else
//        [self handleFailedRequest:request withError:[NSError errorWithDomain:@"300" code:300 userInfo:nil]];
//    //}
}


- (void)handleData:(NSData *)data forRequest:(RPCRequest *)request
{
    NSError *jsonError = nil;
    id       results   = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:&jsonError];

//    NSString *foo = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"foo: %@", foo);

    if (data.length == 0)
        request.callback([RPCResponse responseWithError:[NSError errorWithDomain:@"100" code:100 userInfo:nil]]);
    else if (jsonError)
        request.callback([RPCResponse responseWithError:[NSError errorWithDomain:@"200" code:200 userInfo:nil]]);
    else if ([results isKindOfClass:[NSDictionary class]])
        [self handleResult:results forRequest:request];
}

- (void)handleFailedRequest:(RPCRequest *)request withError:(NSError *)error
{
    request.callback([RPCResponse responseWithError:error]);
}

- (void)handleResult:(NSDictionary *)result forRequest:(RPCRequest *)request
{
    if (!request.callback)
        return;

    RPCResponse *response = [[RPCResponse alloc] init];

    response.id      = result[@"id"];
    response.error   = result[@"error"];
    response.version = result[@"version"];
    response.result  = result[@"result"];

    request.callback(response);
}
@end
