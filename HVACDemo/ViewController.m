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
#import "HVACManager.h"

@interface ViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, weak) UIPickerView *pickerLeft;
@property (nonatomic, weak) UIPickerView *pickerRight;
@property (nonatomic, weak) IBOutlet UIButton *airDirectionDown;
@property (nonatomic, weak) IBOutlet UIButton *airDirectionRight;
@property (nonatomic, weak) IBOutlet UIButton *airDirectionUp;
@property (nonatomic, weak) IBOutlet UIButton *fanAC;
@property (nonatomic, weak) IBOutlet UIButton *fanAuto;
@property (nonatomic, weak) IBOutlet UIButton *fanCirc;
@property (nonatomic, weak) IBOutlet UIButton *fanMax;
@property (nonatomic, weak) IBOutlet UIButton *defrostRear;
@property (nonatomic, weak) IBOutlet UIButton *defrostFront;
@property (nonatomic, weak) IBOutlet UIButton *hazards;
@property (nonatomic, weak) IBOutlet UIButton *seatTempLeft;
@property (nonatomic, weak) IBOutlet UIButton *seatTempRight;
@property (nonatomic, weak) IBOutlet UIButton *settings;
@property                   NSInteger          leftSeatTemp;
@property                   NSInteger          rightSeatTemp;
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
    if (row == 0)  return @"LO";
    if (row == 14) return @"HI";

    return [NSString stringWithFormat:@"%d", row + 15];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [HVACManager sendService:(pickerView == self.pickerLeft) ? @"/temp_left" : @"/temp_right"
                       value:[NSString stringWithFormat:@"%d", row + 15]];
}

- (IBAction)airDirectionButtonPressed:(id)sender
{
    self.airDirectionDown.selected  =
    self.airDirectionRight.selected =
    self.airDirectionUp.selected    = NO;

    ((UIButton *)sender).selected   = YES;
}

- (IBAction)seatTempButtonPressed:(id)sender
{
    if (sender == self.seatTempLeft)
    {
        self.leftSeatTemp = (self.leftSeatTemp + 1) % 3;
        [self.seatTempLeft setTitle:[NSString stringWithFormat:@"%d", self.leftSeatTemp]
                           forState:UIControlStateNormal];
    }
    else
    {
        self.rightSeatTemp = (self.rightSeatTemp + 1) % 3;
        [self.seatTempRight setTitle:[NSString stringWithFormat:@"%d", self.rightSeatTemp]
                            forState:UIControlStateNormal];
    }

    [HVACManager sendService:@"/temp_left"
                       value:@"20"];
}

- (IBAction)fanACButtonPressed:(id)sender
{
    ((UIButton *)sender).selected = !((UIButton *)sender).selected;
}

- (IBAction)fanAutoButtonPressed:(id)sender
{
    ((UIButton *)sender).selected = !((UIButton *)sender).selected;

}

- (IBAction)fanCircButtonPressed:(id)sender
{
    ((UIButton *)sender).selected = !((UIButton *)sender).selected;

}

- (IBAction)fanMaxButtonPressed:(id)sender
{
    ((UIButton *)sender).selected = !((UIButton *)sender).selected;

}

- (IBAction)defrostButtonPressed:(id)sender
{
    ((UIButton *)sender).selected = !((UIButton *)sender).selected;

}

- (IBAction)hazardsButtonPressed:(id)sender
{
    self.hazards.selected = !self.hazards.selected;
}

- (IBAction)settingsButtonPressed:(id)sender
{

}



@end
