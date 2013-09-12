//
//  meetBallListTableBiewCell.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/11/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "meetBallListTableViewCell.h"

@implementation meetBallListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UINib *cellNib = [UINib nibWithNibName:@"commentsCollectionViewCell" bundle:nil];
        [self.commentsCollectionView registerNib:cellNib forCellWithReuseIdentifier:@"commentCell"];
    }
    return self;
}

- (void)awakeFromNib {
    UINib *cellNib = [UINib nibWithNibName:@"commentsCollectionViewCell" bundle:nil];
    [self.commentsCollectionView registerNib:cellNib forCellWithReuseIdentifier:@"commentCell"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index
{
    self.commentsCollectionView.dataSource = dataSourceDelegate;
    self.commentsCollectionView.delegate = dataSourceDelegate;
    self.commentsCollectionView.index = index;
    
    [self.commentsCollectionView reloadData];
}

@end
