//
//  MBSettingsViewController.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/23/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBSettingsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
- (IBAction)save:(id)sender;

@end
