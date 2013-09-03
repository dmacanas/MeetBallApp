//
//  MBLoginViewController.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 8/27/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface MBLoginViewController : UIViewController <UITextFieldDelegate, FBLoginViewDelegate, UIAlertViewDelegate>


@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet FBLoginView *FacebookLogin;

- (IBAction)login:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)forgotPasswordAction:(id)sender;


@end
