//
//  MBFriendDetailViewController.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 10/10/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBPerson.h"

@interface MBFriendDetailViewController : UIViewController

@property (strong, nonatomic) MBPerson *person;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *inviteButton;
- (IBAction)invite:(id)sender;

@end
