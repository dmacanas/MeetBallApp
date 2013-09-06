//
//  MBMenuView.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/5/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MBMenuViewDelegate;

@interface MBMenuView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileIcon;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userHandle;
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;

@property (weak, nonatomic) id<MBMenuViewDelegate> delegate;

@end


@protocol MBMenuViewDelegate <NSObject>

- (void)didSelectionMenuItem:(NSString *)item;

@end