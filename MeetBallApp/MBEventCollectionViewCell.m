//
//  MBEventCollectionViewCell.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/5/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBEventCollectionViewCell.h"

@implementation MBEventCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(40, 40);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.friendsCollectionView = [[MBFriendsCollectionView alloc] initWithFrame:CGRectMake(0, 25, 265, 60) collectionViewLayout:layout];
    [self.friendsCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CellID"];
    self.friendsCollectionView.backgroundColor = [UIColor whiteColor];
    self.friendsCollectionView.showsHorizontalScrollIndicator = NO;
    [self.contentView addSubview:self.friendsCollectionView];
    
    
    [self.friendsCollectionView setDelegate:self];
    [self.friendsCollectionView setDataSource:self];
}

- (NSInteger)numberOfSectionsInCollectionView:(MBFriendsCollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(MBFriendsCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 13;
}

-(UICollectionViewCell *)collectionView:(MBFriendsCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = @"CellID";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];

    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [image setImage:[UIImage imageNamed:@"pl_icon"]];
    [cell addSubview:image];
    
    return cell;
}

- (IBAction)hideAction:(id)sender {
}

- (IBAction)notesAction:(id)sender {
}

- (IBAction)saveAction:(id)sender {
}

- (IBAction)throwAction:(id)sender {
}
@end
