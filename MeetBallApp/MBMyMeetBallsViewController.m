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
#import "MBMeetBallDetailViewController.h"

#import "MBMeetBall.h"

@interface MBMyMeetBallsViewController () <MBMenuViewDelegate>

@property (assign, nonatomic) BOOL isShowingMenu;
@property (strong, nonatomic) MBMenuView *menu;
@property (strong, nonatomic) MBMeetBall *meetBall;
@property (strong, nonatomic) NSString *titleString;
@property (strong, nonatomic) NSString *coordString;
@property (strong, nonatomic) NSArray *meetBallArray;



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
    self.meetBallArray = [self getActiveMeetBalls:[MBMeetBall findAllSortedBy:@"meetBallId" ascending:YES]];
	// Do any additional setup after loading the view.
}

- (void)menuSetup {
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"MBMenuView" owner:self options:nil];
    self.menu = [array objectAtIndex:0];
    self.menu.delegate = self;
    [self.menuContainer addSubview:self.menu];
}

- (NSArray *)getActiveMeetBalls:(NSArray *)meetBalls {
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (MBMeetBall *mhb in meetBalls) {
        if ([self isStillActive:mhb.endDate]) {
            [temp addObject:mhb];
        }
    }
    
    return (NSArray *)temp;
}

- (BOOL)isStillActive:(NSString *)fromDateString {
    NSString *d1 = [fromDateString stringByReplacingOccurrencesOfString:@"/Date(" withString:@""];
    NSString *d2 = [d1 stringByReplacingOccurrencesOfString:@")/" withString:@""];
    
    NSArray *a = [d2 componentsSeparatedByString:@"-"];
    
    NSString *time = (NSString *)[a objectAtIndex:0];
    double mSec = [time doubleValue];
    double sec = mSec/1000;
    sec += 600;
    
    NSDate *date = [NSDate date];
    double current = [date timeIntervalSince1970];
    
    return sec > current;
}

- (NSDate *)dateFromString:(NSString *)fromDateString {
    NSString *d1 = [fromDateString stringByReplacingOccurrencesOfString:@"/Date(" withString:@""];
    NSString *d2 = [d1 stringByReplacingOccurrencesOfString:@")/" withString:@""];
    
    NSArray *a = [d2 componentsSeparatedByString:@"-"];
    
    NSString *time = (NSString *)[a objectAtIndex:0];
    double mSec = [time doubleValue];
    double sec = mSec/1000;
    sec += 600;
    
    return [NSDate dateWithTimeIntervalSince1970:sec];
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.meetBallArray.count == 0) {
        UIAlertView *noMeetBalls = [[UIAlertView alloc] initWithTitle:@"No Active MeetBalls" message:@"Throw a MeetBall and get the party started!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
        [noMeetBalls show];
    }
}

#pragma mark - tableView Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.meetBallArray.count;
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
    MBMeetBall *mb = (MBMeetBall *)[[NSManagedObjectContext MR_contextForCurrentThread] objectWithID:[[self.meetBallArray objectAtIndex:indexPath.row] objectID]];
    cell.titleLabel.text = [mb.meetBallName stringByReplacingOccurrencesOfString:@"/" withString:@""];
    cell.ownerLabel.text = mb.ownersName;
    cell.coordinateString = mb.generalLocationGPX;
    cell.meetBall = mb;
    NSString *dateString = [self dateFromMeetBallDate:mb.startDate];
    cell.dateLabel.text = [NSString stringWithFormat:@"Start Date: %@",dateString];
    return cell;
}

- (NSString *)dateFromMeetBallDate:(NSString *)dateString {
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"MM/dd/yyyy HH:mm"];
    NSString *string = [df stringFromDate:(NSDate *)[self dateFromString:dateString]];
    return string;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    meetBallListTableViewCell *cell = (meetBallListTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    self.titleString = cell.titleLabel.text;
    self.coordString = cell.coordinateString;
    self.meetBall = cell.meetBall;
    [self performSegueWithIdentifier:@"meetBallDetailPush" sender:self];
}

#pragma mark - segue prep methods

- (CLLocationCoordinate2D)extractLocationFromString:(NSString *)location {
    NSString *d1 = [location stringByReplacingOccurrencesOfString:@"POINT (" withString:@""];
    NSString *d2 = [d1 stringByReplacingOccurrencesOfString:@")" withString:@""];
    
    NSArray *a = [d2 componentsSeparatedByString:@" "];
    NSString *lon = (NSString *)[a objectAtIndex:0];
    NSString *lat = (NSString *)[a objectAtIndex:1];
    //    NSString *alt = (NSString *)[a objectAtIndex:2];
    double longitude = [lon doubleValue];
    double latitude = [lat doubleValue];
    return CLLocationCoordinate2DMake(latitude, longitude);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MBMeetBallDetailViewController *mVC = [segue destinationViewController];
    mVC.titleString = self.titleString;
    mVC.cord = [self extractLocationFromString:self.coordString];
    mVC.meetBall = self.meetBall;
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
    
    [self dismissViewControllerAnimated:NO completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"navigate" object:item];
    }];
//    __weak MBMyMeetBallsViewController *weakSelf = self;
//    [MBMenuNavigator navigateToMenuItem:item fromVC:weakSelf];
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
