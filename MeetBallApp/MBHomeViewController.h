//
//  MBHomeViewController.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 8/27/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBUser.h"
#import "MBMenuView.h"

@interface MBHomeViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, MBMenuViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (IBAction)showMenu:(id)sender;
- (IBAction)testCancel:(id)sender;

@end
