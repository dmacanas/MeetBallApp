//
//  MBMenuDisplayViewController.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 10/3/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"

@interface MBMenuDisplayViewController : REFrostedViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, readwrite, nonatomic) UINavigationController *navigationController;

@end
