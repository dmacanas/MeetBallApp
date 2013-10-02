//
//  MBEditProfileViewController.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 10/2/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBEditProfileViewController : UIViewController
@property (strong, nonatomic) NSString *field;
@property (strong, nonatomic) NSString *value;

@property (weak, nonatomic) IBOutlet UITextField *previousTextField;
@property (weak, nonatomic) IBOutlet UITextField *changeTextField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
- (IBAction)save:(id)sender;

@end
