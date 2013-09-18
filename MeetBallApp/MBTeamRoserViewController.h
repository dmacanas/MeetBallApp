//
//  MBTeamRoserViewController.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/17/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBTeamRoserViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *menuContainer;
@property (weak, nonatomic) IBOutlet UIImageView *blurView;
@property (weak, nonatomic) IBOutlet UITableView *friendsTableView;
- (IBAction)showMenu:(id)sender;

@end
