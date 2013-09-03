//
//  MBForgotPasswordViewController.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/3/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBForgotPasswordViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;

- (IBAction)resetPassword:(id)sender;

@end
