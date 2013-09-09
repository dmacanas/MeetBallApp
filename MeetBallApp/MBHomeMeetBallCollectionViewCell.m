//
//  MBHomeMeetBallCollectionViewCell.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/9/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBHomeMeetBallCollectionViewCell.h"

@implementation MBHomeMeetBallCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib {
    self.titleLabel.text = @"Dominic threw you a MeetBall";
    self.acceptButton.hidden = NO;
    self.declineButton.hidden = NO;
    self.viewButton.hidden = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)accept:(id)sender {
    self.titleLabel.text = @"Accepted";
    self.acceptButton.hidden = YES;
    self.declineButton.hidden = YES;
    self.viewButton.hidden = NO;
}

- (IBAction)decline:(id)sender {
//    self.hidden = YES;
    self.titleLabel.text = @"Declined";
}
@end
