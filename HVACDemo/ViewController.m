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
@property (nonatomic, weak) IBOutlet UIButton *seatTempLeftButton;
@property (nonatomic, weak) IBOutlet UIButton *seatTempRightButton;
@property (nonatomic, weak) IBOutlet UIButton *settings;
@property                   NSInteger          leftSeatTemp;
@property                   NSInteger          rightSeatTemp;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [HVACManager start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)getAirflowDirectionValue
{
    return ([self.airDirectionDown  isHighlighted] ? 1 : 0) +
           ([self.airDirectionRight isHighlighted] ? 2 : 0) +
           ([self.airDirectionUp    isHighlighted] ? 4 : 0);
}

- (void)setAirflowDirectionButtons:(NSInteger)value
{

    [self.airDirectionDown  setHighlighted:(value % 2 == 1)]; value /= 2;
    [self.airDirectionRight setHighlighted:(value % 2 == 1)]; value /= 2;
    [self.airDirectionUp    setHighlighted:(value % 2 == 1)];
}

- (IBAction)airDirectionButtonPressed:(id)sender
{
    self.airDirectionDown.selected  =
    self.airDirectionRight.selected =
    self.airDirectionUp.selected    = NO;

    ((UIButton *)sender).selected   = YES;
}

- (NSInteger)newSeatTempFrom:(NSInteger)previous
{
    previous += previous == 0 ? 1 : 2;

    return previous == 7 ? 0 : previous;
}

- (IBAction)seatTempButtonPressed:(id)sender
{
    if (sender == self.seatTempLeftButton)
    {
        self.leftSeatTemp  = [self newSeatTempFrom:self.leftSeatTemp];
        [self.seatTempLeftButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"SeatHeatLeft_%d.png", self.leftSeatTemp]]
                                 forState:UIControlStateNormal];

        [HVACManager invokeService:HVACServiceIdentifier_SEAT_HEAT_LEFT
                             value:@(self.leftSeatTemp)];
    }
    else
    {
        self.rightSeatTemp = [self newSeatTempFrom:self.rightSeatTemp];
        [self.seatTempRightButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"SeatHeatRight_%d.png", self.rightSeatTemp]]
                                  forState:UIControlStateNormal];

        [HVACManager invokeService:HVACServiceIdentifier_SEAT_HEAT_RIGHT
                             value:@(self.rightSeatTemp)];
    }


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
    [HVACManager invokeService:(pickerView == self.pickerLeft) ? HVACServiceIdentifier_TEMP_LEFT : HVACServiceIdentifier_TEMP_RIGHT
                         value:[NSString stringWithFormat:@"%d", row + 15]];
}


@end
