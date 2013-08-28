//
//  MBHomeViewController.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 8/27/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBHomeViewController : UIViewController
@property (strong, nonatomic) NSDictionary *userInfo;

@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@end
