//
//  MBSettingsOptionsViewController.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 10/3/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MBSettingsOptionDelegate;

@interface MBSettingsOptionsViewController : UIViewController

@property (assign, nonatomic) NSInteger selectedOption;
@property (strong, nonatomic) NSString *optionTitle;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) id<MBSettingsOptionDelegate> delegate;

@end

@protocol MBSettingsOptionDelegate <NSObject>

- (void)changedOptionValue:(NSInteger)value key:(NSString *)key;

@end