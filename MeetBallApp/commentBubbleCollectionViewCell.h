//
//  commentBubbleCollectionViewCell.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/26/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface commentBubbleCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) NSString *user;
@property (assign, nonatomic) BOOL isCurrentUser;
@property (weak, nonatomic) IBOutlet UIImageView *bubbleImageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

@end
