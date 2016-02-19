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
#import "HVACState.h"
#import "HVACUtil.h"

@interface ViewController () <UIPickerViewDataSource, UIPickerViewDelegate, HVACManagerDelegate>
@property (nonatomic, weak) IBOutlet UIButton      *connectedButton;
@property (nonatomic, weak) IBOutlet UIButton      *settingsButton;
@property (nonatomic, weak) IBOutlet UIButton      *hazardButton;
@property (nonatomic, weak) IBOutlet UIButton      *seatTempLeftButton;
@property (nonatomic, weak) IBOutlet UIButton      *seatTempRightButton;
@property (nonatomic, weak) IBOutlet UIView *tempBarLeft;
@property (nonatomic, weak) IBOutlet UIView *tempBarRight;
@property (nonatomic, weak) IBOutlet UIPickerView  *pickerLeft;
@property (nonatomic, weak) IBOutlet UIPickerView  *pickerRight;
@property (nonatomic, weak) IBOutlet UISlider      *fanSpeedSlider;
@property (nonatomic, weak) IBOutlet UIButton      *airDirectionDownButton;
@property (nonatomic, weak) IBOutlet UIButton      *airDirectionRightButton;
@property (nonatomic, weak) IBOutlet UIButton      *airDirectionUpButton;
@property (nonatomic, weak) IBOutlet UIButton      *fanACButton;
@property (nonatomic, weak) IBOutlet UIButton      *fanAutoButton;
@property (nonatomic, weak) IBOutlet UIButton      *fanCircButton;
@property (nonatomic, weak) IBOutlet UIButton      *defrostMaxButton;
@property (nonatomic, weak) IBOutlet UIButton      *defrostRearButton;
@property (nonatomic, weak) IBOutlet UIButton      *defrostFrontButton;
@property (nonatomic, weak) IBOutlet UIImageView   *logo;
@property (nonatomic)                NSInteger      leftSeatTemp;
@property (nonatomic)                NSInteger      rightSeatTemp;
@property (nonatomic)                BOOL           defrostMaxIsOn;
@property (nonatomic)                BOOL           autoIsOn;
@property (nonatomic, strong)        HVACState     *savedState;
@property (nonatomic)                int            lastSliderIntVal;
@end

#define TAG_AIRFLOW_DIRECTION_DOWN  100
#define TAG_AIRFLOW_DIRECTION_RIGHT 101
#define TAG_AIRFLOW_DIRECTION_UP    102

#define DEFAULT_FAN_SPEED 3
#define MAX_FAN_SPEED     8

#define MAX_TEMP_VALUE    14

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self.airDirectionDownButton  setTag:TAG_AIRFLOW_DIRECTION_DOWN];
    [self.airDirectionRightButton setTag:TAG_AIRFLOW_DIRECTION_RIGHT];
    [self.airDirectionUpButton    setTag:TAG_AIRFLOW_DIRECTION_UP];

    [self.hazardButton            setTag:HSI_HAZARD];
    [self.seatTempLeftButton      setTag:HSI_SEAT_HEAT_LEFT];
    [self.seatTempRightButton     setTag:HSI_SEAT_HEAT_RIGHT];
    [self.pickerLeft              setTag:HSI_TEMP_LEFT];
    [self.pickerRight             setTag:HSI_TEMP_RIGHT];
    [self.fanSpeedSlider          setTag:HSI_FAN_SPEED];
    [self.fanACButton             setTag:HSI_AC];
    [self.fanAutoButton           setTag:HSI_AUTO];
    [self.fanCircButton           setTag:HSI_AIR_CIRC];
    [self.defrostMaxButton        setTag:HSI_DEFROST_MAX];
    [self.defrostRearButton       setTag:HSI_DEFROST_REAR];
    [self.defrostFrontButton      setTag:HSI_DEFROST_FRONT];

    [self.pickerLeft  setDataSource:self];
    [self.pickerRight setDataSource:self];
    [self.pickerLeft  setDelegate:self];
    [self.pickerRight setDelegate:self];

    [self.fanSpeedSlider setMinimumValue:0.0];
    [self.fanSpeedSlider setMaximumValue:MAX_FAN_SPEED];

    [HVACManager setDelegate:self];
    [HVACManager start];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self makeGradientForBar:self.tempBarLeft];
    [self makeGradientForBar:self.tempBarRight];

    [self updateTemperatureBars];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)getAirflowDirectionValue
{
    return ([self.airDirectionDownButton  isSelected] ? 1 : 0) +
           ([self.airDirectionRightButton isSelected] ? 2 : 0) +
           ([self.airDirectionUpButton    isSelected] ? 4 : 0);
}

- (void)setAirflowDirectionButtons:(NSInteger)value
{
    [self.airDirectionDownButton  setSelected:(value % 2 == 1)]; value /= 2;
    [self.airDirectionRightButton setSelected:(value % 2 == 1)]; value /= 2;
    [self.airDirectionUpButton    setSelected:(value % 2 == 1)];
}

- (NSInteger)newSeatTempFrom:(NSInteger)previous
{
    previous += previous == 0 ? 1 : 2;

    return previous == 7 ? 0 : previous;
}

- (NSInteger)updateSeatTempButton:(UIButton *)button savedTemp:(NSInteger)oldTemp invokeService:(HVACServiceIdentifier)serviceIdentifier
{
    NSInteger newTemp = [self newSeatTempFrom:oldTemp];

    [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"SeatHeat%@_%d.png", button.tag == HSI_SEAT_HEAT_LEFT ? @"Left" : @"Right", newTemp]]
            forState:UIControlStateNormal];

    if (serviceIdentifier != HSI_NONE)
        [HVACManager invokeService:serviceIdentifier
                             value:@(newTemp)];

    return newTemp;
}

- (IBAction)seatTempButtonPressed:(id)sender
{
    if (sender == self.seatTempLeftButton)
    {
        self.leftSeatTemp = [self updateSeatTempButton:self.seatTempLeftButton savedTemp:self.leftSeatTemp invokeService:HSI_SEAT_HEAT_LEFT];
    }
    else
    {
        self.rightSeatTemp = [self updateSeatTempButton:self.seatTempRightButton savedTemp:self.rightSeatTemp invokeService:HSI_SEAT_HEAT_RIGHT];
    }
}

- (void)toggleTheToggleButton:(UIButton *)button
{
    button.selected = !button.selected;
}

- (HVACServiceIdentifier)getServiceIdentifierFromTag:(NSInteger)tag
{
    if (tag == TAG_AIRFLOW_DIRECTION_DOWN ||
            tag == TAG_AIRFLOW_DIRECTION_RIGHT ||
            tag == TAG_AIRFLOW_DIRECTION_UP)
        return HSI_AIRFLOW_DIRECTION;

    return (HVACServiceIdentifier)tag;
}

- (BOOL)shouldBreakOutOfMaxDefrostGivenServiceIdentifier:(HVACServiceIdentifier)serviceIdentifier
{
    switch (serviceIdentifier) {
        case HSI_DEFROST_REAR:
        case HSI_DEFROST_FRONT:
        case HSI_AUTO:
            return YES;
        default:
            return NO;
    }
}

- (BOOL)shouldBreakOutOfAutoGivenServiceIdentifier:(HVACServiceIdentifier)serviceIdentifier
{
    switch (serviceIdentifier) {
        case HSI_FAN_SPEED:
        case HSI_AIRFLOW_DIRECTION:
        case HSI_DEFROST_MAX:
        case HSI_AIR_CIRC:
        case HSI_AC:
        case HSI_AUTO:
            return YES;
        default:
            return NO;
    }
}

- (void)breakOutOfAuto:(HVACServiceIdentifier)serviceIdentifier
{
    self.autoIsOn = NO;

    if (serviceIdentifier != HSI_FAN_SPEED && self.savedState.fanSpeed != 0 && serviceIdentifier!= HSI_DEFROST_MAX) {
        [self.fanSpeedSlider setValue:self.savedState.fanSpeed];
        [HVACManager invokeService:HSI_FAN_SPEED value:@(self.savedState.fanSpeed)];
    }

    if (serviceIdentifier != HSI_AIRFLOW_DIRECTION && serviceIdentifier!= HSI_DEFROST_MAX) {
        [self setAirflowDirectionButtons:self.savedState.airDirection];
        [HVACManager invokeService:HSI_AIRFLOW_DIRECTION value:@(self.savedState.airDirection)];
    }

    if (serviceIdentifier != HSI_AC) {
        if (self.fanACButton.selected != self.savedState.ac)
            [self toggleButtonPressed:self.fanACButton];
    }

    if (serviceIdentifier != HSI_AIR_CIRC) {
        if (self.fanCircButton.selected != self.savedState.circ)
            [self toggleButtonPressed:self.fanCircButton];
    }

    if (serviceIdentifier != HSI_DEFROST_MAX) {
        if (self.defrostMaxButton.selected != self.savedState.defrostMax)
            [self toggleButtonPressed:self.defrostMaxButton];
    }

    if (serviceIdentifier != HSI_AUTO) {
        [self toggleTheToggleButton:self.fanAutoButton];
        [HVACManager invokeService:HSI_AUTO value:@(NO)];
    }
}

/* USER INTERFACE CALLBACK */
- (IBAction)toggleButtonPressed:(id)sender
{
    DLog(@"");

    UIButton *toggleButton = (UIButton *)sender;
    HVACServiceIdentifier serviceIdentifier = [self getServiceIdentifierFromTag:toggleButton.tag];

    /* Toggle the state of the toggle button */
    [self toggleTheToggleButton:toggleButton];

    if (self.autoIsOn && [self shouldBreakOutOfAutoGivenServiceIdentifier:serviceIdentifier])
        [self breakOutOfAuto:serviceIdentifier];

    if (self.defrostMaxIsOn && [self shouldBreakOutOfMaxDefrostGivenServiceIdentifier:serviceIdentifier])
        [self toggleButtonPressed:self.defrostMaxButton]; /* Call this method again, passing in the defrost max button */

    switch (serviceIdentifier) {
        case HSI_AIRFLOW_DIRECTION:

            /* If the fan speed is off, turn it on */
            if (self.fanSpeedSlider.value == 0) {
                self.fanSpeedSlider.value = DEFAULT_FAN_SPEED;
                [HVACManager invokeService:HSI_FAN_SPEED value:@(DEFAULT_FAN_SPEED)];
            }

            if ([self getAirflowDirectionValue] == 0) {
                self.fanSpeedSlider.value = 0;
                [HVACManager invokeService:HSI_FAN_SPEED value:@(0)];
            }

            [HVACManager invokeService:serviceIdentifier value:@([self getAirflowDirectionValue])];

            break;

        case HSI_AUTO:

            if (toggleButton.selected) {
                self.savedState = [HVACState hvacStateWithAirDirection:[self getAirflowDirectionValue]
                                                              fanSpeed:(NSInteger)self.fanSpeedSlider.value
                                                                    ac:self.fanACButton.isSelected
                                                                  circ:self.fanCircButton.isSelected
                                                            defrostMax:self.defrostMaxButton.isSelected];
                
                [self setAirflowDirectionButtons:0];
                [HVACManager invokeService:HSI_AIRFLOW_DIRECTION value:@(0)];

                self.fanSpeedSlider.value = 0;
                [HVACManager invokeService:HSI_FAN_SPEED value:@(0)];

                if (!self.fanACButton.selected)
                    [self toggleButtonPressed:self.fanACButton];

                if (self.fanCircButton.selected)
                    [self toggleButtonPressed:self.fanCircButton];

                if (self.defrostMaxButton.selected)
                    [self toggleButtonPressed:self.defrostMaxButton];

                self.autoIsOn = YES;
            }

            [HVACManager invokeService:serviceIdentifier value:@(toggleButton.selected)];

            break;

        case HSI_DEFROST_MAX:

            if (toggleButton.selected) {
                if (!self.defrostFrontButton.selected)
                    [self toggleButtonPressed:self.defrostFrontButton];

                if (!self.defrostRearButton.selected)
                    [self toggleButtonPressed:self.defrostRearButton];

                [self setAirflowDirectionButtons:4];
                [HVACManager invokeService:HSI_AIRFLOW_DIRECTION value:@(4)];

                self.fanSpeedSlider.value = 5;
                [HVACManager invokeService:HSI_FAN_SPEED value:@(5)];


                self.defrostMaxIsOn = YES;
            } else {
                self.defrostMaxIsOn = NO;
            }

        case HSI_AC:
        case HSI_DEFROST_REAR:
        case HSI_DEFROST_FRONT:
        case HSI_AIR_CIRC:

            [HVACManager invokeService:serviceIdentifier value:@(toggleButton.selected)];

            break;

        default:
            break;
    }
}

- (IBAction)sliderValueChanged:(UISlider *)sender
{
    DLog(@"%f", self.fanSpeedSlider.value);
    
    /* Truncate the value to an int and only send when changed. */
    int sliderIntVal = (int)sender.value;
    if (sliderIntVal != self.lastSliderIntVal) {
        [HVACManager invokeService:HSI_FAN_SPEED value:@((int)self.fanSpeedSlider.value)];
    
        if (sliderIntVal == 0) {
            [self setAirflowDirectionButtons:0];
            [HVACManager invokeService:HSI_AIRFLOW_DIRECTION value:@(0)];
        }

        self.lastSliderIntVal = sliderIntVal;
    }
}

/* RVI SERVICE INVOCATION CALLBACK */
- (void)onServiceInvoked:(HVACServiceIdentifier)serviceIdentifier withValue:(id)value
{
    UIView *view = [self.view viewWithTag:serviceIdentifier];
    BOOL newToggleButtonState;

    switch (serviceIdentifier) {
        case HSI_DEFROST_MAX:
        case HSI_AUTO:

            newToggleButtonState = [(NSNumber *)value boolValue];

            /* Special extra work for auto/max_defrost */
            if (newToggleButtonState)
                self.savedState = [HVACState hvacStateWithAirDirection:[self getAirflowDirectionValue]
                                                              fanSpeed:(NSInteger)self.fanSpeedSlider.value
                                                                    ac:self.fanACButton.isSelected
                                                                  circ:self.fanCircButton.isSelected
                                                            defrostMax:self.defrostMaxButton.isSelected];


            if (serviceIdentifier == HSI_AUTO)
                self.autoIsOn = newToggleButtonState;

            if (serviceIdentifier == HSI_DEFROST_MAX)
                self.defrostMaxIsOn = newToggleButtonState;

            /* Pass through... */

        case HSI_AC:
        case HSI_AIR_CIRC:
        case HSI_DEFROST_FRONT:
        case HSI_DEFROST_REAR:
            if (view != NULL && [(UIButton *)view isSelected] != [(NSNumber *)value boolValue])
                ((UIButton *)view).selected = !((UIButton *)view).selected;

            break;

        case HSI_AIRFLOW_DIRECTION:
            [self setAirflowDirectionButtons:[(NSNumber *)value integerValue]];

            break;

        case HSI_FAN_SPEED:
            if (view != NULL) [((UISlider *)view) setValue:[(NSNumber *)value floatValue]];

            break;

        case HSI_SEAT_HEAT_LEFT:
            self.leftSeatTemp = [self updateSeatTempButton:self.seatTempLeftButton savedTemp:self.leftSeatTemp invokeService:HSI_NONE];

            break;

        case HSI_SEAT_HEAT_RIGHT:
            self.rightSeatTemp = [self updateSeatTempButton:self.seatTempRightButton savedTemp:self.rightSeatTemp invokeService:HSI_NONE];

            break;

        case HSI_TEMP_LEFT:
        case HSI_TEMP_RIGHT:
            if (view != NULL) [((UIPickerView *)view) selectRow:[(NSNumber *)value integerValue] - 15
                                                    inComponent:0
                                                       animated:YES];

            [self updateTemperatureBars];
            break;

        case HSI_HAZARD:
            //toggleHazardButtonFlashing(Boolean.parseBoolean((String) value));//(Boolean) value);

            break;

        case HSI_SUBSCRIBE:
        case HSI_UNSUBSCRIBE:
        case HSI_NONE:
            break;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 15;
}

- (NSString *)titleForRow:(NSInteger)row
{
    if (row == 0)  return @"LO";
    if (row == 14) return @"HI";

    return [NSString stringWithFormat:@"%d°", row + 15];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[NSAttributedString alloc] initWithString:[self titleForRow:row]
                                           attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor],
                                                         NSFontAttributeName            : [UIFont boldSystemFontOfSize:32]}];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [HVACManager invokeService:(pickerView == self.pickerLeft) ? HSI_TEMP_LEFT : HSI_TEMP_RIGHT
                         value:[NSString stringWithFormat:@"%d", row + 15]];

    [self updateTemperatureBars];
}

- (void)onNodeConnected
{

}

- (void)onNodeDisconnected
{

}

- (void)drawPickerBackground:(UIPickerView *)picker
{

}

#define TEMP_STEPS           (14.0)
#define GRADIENT_UNIT_HEIGHT (0.15)
#define BAR_UNIT_HEIGHT      (1.0 - GRADIENT_UNIT_HEIGHT)
#define TEMP_STEP_HEIGHT     (BAR_UNIT_HEIGHT / TEMP_STEPS)
- (void)drawTemperateBar:(UIView *)bar value:(NSInteger)value
{
    NSInteger inverseValue = 14 - value;
    CALayer *layer = [bar.layer sublayers][0];

    layer.position = CGPointMake(0.0, (CGFloat)(TEMP_STEP_HEIGHT * inverseValue) * bar.frame.size.height);
}

- (void)updateTemperatureBars
{
    [self drawTemperateBar:self.tempBarLeft
                     value:[self.pickerLeft selectedRowInComponent:0]];
    [self drawTemperateBar:self.tempBarRight
                     value:[self.pickerRight selectedRowInComponent:0]];

}

- (void)makeGradientForBar:(UIView *)tempBar
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = tempBar.bounds;

    gradient.anchorPoint = CGPointMake(0, 0);
    gradient.position    = CGPointMake(0, 0);
    gradient.startPoint  = CGPointMake(0.5, GRADIENT_UNIT_HEIGHT);
    gradient.endPoint    = CGPointMake(0.5, 0.0);

    gradient.colors = @[(__bridge id)[[UIColor colorWithRed:(CGFloat)(252.0 / 255.0)
                                                      green:(CGFloat)(138.0 / 255.0)
                                                       blue:(CGFloat)(10.0  / 255.0)
                                                      alpha:1.0] CGColor], (__bridge id)[[UIColor clearColor] CGColor]];

    [tempBar.layer insertSublayer:gradient atIndex:0];
}
@end
