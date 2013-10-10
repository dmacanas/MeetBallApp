//
//  MBDetailViewController.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 10/4/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBMeetBall.h"

@interface MBDetailViewController : UIViewController

@property (strong, nonatomic) MBMeetBall *meetBall;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

- (IBAction)editing:(id)sender;

@end
