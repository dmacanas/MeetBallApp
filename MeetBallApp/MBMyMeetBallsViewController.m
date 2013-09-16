//
//  MBMyMeetBallsViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/11/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBMyMeetBallsViewController.h"
#import "meetBallListTableViewCell.h"
#import "commentsCollectionViewCell.h"
#import "MBCommentsCollectionView.h"
#import "MBMenuView.h"
#import "MBMenuNavigator.h"

@interface MBMyMeetBallsViewController () <MBMenuViewDelegate>

@property (assign, nonatomic) BOOL isShowingMenu;
@property (assign, nonatomic) MBMenuView *menu;

@end

@implementation MBMyMeetBallsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self menuSetup];
	// Do any additional setup after loading the view.
}

- (void)menuSetup {
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"MBMenuView" owner:self options:nil];
    self.menu = [array objectAtIndex:0];
    self.menu.delegate = self;
    [self.menuContainer addSubview:self.menu];
}


#pragma mark - tableView Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 132;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(meetBallListTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setCollectionViewDataSourceDelegate:self index:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"meetBallCell";
    meetBallListTableViewCell *cell = (meetBallListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell == nil){
        NSArray *ar = [[NSBundle mainBundle] loadNibNamed:@"meetBallListTableViewCell" owner:self options:nil];
        cell = [ar objectAtIndex:0];
    }
    switch (indexPath.row) {
        case 1:
            cell.titleLabel.text = @"Tailgate Two";
            cell.ownerLabel.text = @"Dominic Macanas";
            break;
        case 2:
            cell.titleLabel.text = @"Tailgate Three";
            cell.ownerLabel.text = @"Northwestern University Marching Band";
            break;
        case 3:
            cell.titleLabel.text = @"Tailgate Four";
            cell.ownerLabel.text = @"Northwestern Alumni Association";
            break;
        case 4:
            cell.titleLabel.text = @"Tailgate Five";
            cell.ownerLabel.text = @"John Doe";
            break;
        default:
            cell.titleLabel.text = @"Tailgate One";
            cell.ownerLabel.text = @"Jane Smith";
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"meetBallDetailPush" sender:self];
}

#pragma mark - collectionView Delegates
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 3;
}

- (UICollectionViewCell *)collectionView:(MBCommentsCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    commentsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"commentCell" forIndexPath:indexPath];
    return cell;
}

#pragma mark - menu delegate 
- (void)didSelectionMenuItem:(NSString *)item {
    self.isShowingMenu = NO;
    self.blurView.hidden = YES;
    self.menuContainer.hidden = YES;
    if ([item isEqualToString:@"My MeetBalls"]) {
        return;
    }
    __weak MBMyMeetBallsViewController *weakSelf = self;
    [MBMenuNavigator navigateToMenuItem:item fromVC:weakSelf];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    self.menu.delegate = nil;
}

- (IBAction)showMenu:(id)sender {
    if (self.isShowingMenu == NO){
        [self.menu createBlurViewInView:self.view forImageView:self.blurView];
        self.blurView.hidden = NO;
        self.menuContainer.hidden = NO;
        self.isShowingMenu = YES;
    } else {
        self.blurView.hidden = YES;
        self.menuContainer.hidden = YES;
        self.isShowingMenu = NO;
    }
}
@end
