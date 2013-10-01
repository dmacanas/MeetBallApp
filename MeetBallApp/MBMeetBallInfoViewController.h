//
//  MBMeetBallInfoViewController.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/30/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBMeetBallInfoViewController : UIViewController
@property (strong, nonatomic) NSDictionary *userInfo;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)signUp:(id)sender;
- (IBAction)cancelButton:(id)sender;

@end
