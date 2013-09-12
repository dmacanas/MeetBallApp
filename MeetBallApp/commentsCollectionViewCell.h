//
//  commentsCollectionViewCell.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/11/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface commentsCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileIcon;

@end
