//
//  MBEditProfileViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 10/2/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBEditProfileViewController.h"

@interface MBEditProfileViewController ()

@end

@implementation MBEditProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setTitle:self.field];
    self.previousTextField.text = self.value;
    if ([self.field isEqualToString:@"Password"]) {
        [self.previousTextField setSecureTextEntry:YES];
        [self.changeTextField setSecureTextEntry:YES];
    } else if ([self.field isEqualToString:@"Phone Number"]) {
        self.previousTextField.keyboardType = UIKeyboardTypePhonePad;
        self.changeTextField.keyboardType = UIKeyboardTypePhonePad;
    }
    self.previousTextField.placeholder = [NSString stringWithFormat:@"Current %@", self.field];
    self.changeTextField.placeholder = [NSString stringWithFormat:@"New %@", self.field];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)save:(id)sender {
}
@end
