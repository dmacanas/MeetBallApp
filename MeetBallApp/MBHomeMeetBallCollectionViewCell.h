//
//  MBHomeMeetBallCollectionViewCell.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/9/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBHomeMeetBallCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *viewButton;
- (IBAction)accept:(id)sender;
- (IBAction)decline:(id)sender;


@end
