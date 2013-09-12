//
//  meetBallListTableBiewCell.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/11/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBCommentsCollectionView.h"

static NSString *collectionViewCellID = @"commentCell";

@interface meetBallListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *ownerLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (strong, nonatomic) IBOutlet MBCommentsCollectionView *commentsCollectionView;

-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index;

@end
