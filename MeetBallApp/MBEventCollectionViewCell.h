//
//  MBEventCollectionViewCell.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/5/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBFriendsCollectionView.h"

@interface MBEventCollectionViewCell : UICollectionViewCell <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *stockPhotoImageView;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UILabel *titleHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleSubheader1;
@property (weak, nonatomic) IBOutlet UILabel *titleSubheader2;
@property (weak, nonatomic) IBOutlet UIView *dividerView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *contentHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentNoteCountLabel;
@property (strong, nonatomic) MBFriendsCollectionView *friendsCollectionView;
@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet UIButton *hideButton;
@property (weak, nonatomic) IBOutlet UIButton *NotesButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *throwButton;
@property (weak, nonatomic) IBOutlet UIImageView *ownerIcon;

- (IBAction)hideAction:(id)sender;
- (IBAction)notesAction:(id)sender;
- (IBAction)saveAction:(id)sender;
- (IBAction)throwAction:(id)sender;
@end
