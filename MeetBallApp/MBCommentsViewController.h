//
//  MBCommentsViewController.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/26/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBMeetBall.h"

@interface MBCommentsViewController : UIViewController

@property (strong, nonatomic) MBMeetBall *meetBall;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
- (IBAction)sendComment:(id)sender;

@end
