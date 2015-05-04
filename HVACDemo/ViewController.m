// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
// Copyright (c) 2015 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
//
// File:    ViewController.m
// Project: HVACDemo
//
// Created by Lilli Szafranski on 5/1/15.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


#import "ViewController.h"
#import "RPCClient.h"

@interface ViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 15;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
//    switch (component)
//    {
//        case 0:
//            return @"LO";
//        case 1:
    if (row == 0)  return @"LO";
    if (row == 14) return @"HI";
    
    return [NSString stringWithFormat:@"%d", row + 15];
//        case 2:
//            return @"HI";
//        default:
//            return @"";
//    }
//    return nil;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    RPCClient *rpc = [[RPCClient alloc] initWithServiceEndpoint:@"http://rvi1.nginfotpdx.net:8801"];

	[rpc postRequest:[RPCRequest requestWithMethod:@"message"
                                            params:@{
                                               @"service_name": @"jlr.com/vin/lilli/hvac/temp_left",
                                               @"timeout": @((NSInteger)([[NSDate date] timeIntervalSince1970] + 5000)),
                                               @"parameters": @[
                                                   @{
                                                           @"sending_node" : @"jlr.com/backend/Rt9f1qISRm/",
                                                           @"value" : [self pickerView:pickerView titleForRow:row forComponent:component]
                                                   }
                                               ]
                                           }
                                          callback:^(RPCResponse *response) {
                                              NSLog(@"Sync request: %@", response);
                                              NSLog(@"Sync request error: %@", response.error);
                                          }]];

}

@end
