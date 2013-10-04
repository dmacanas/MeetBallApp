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
#import "MBMenuNavigator.h"
#import "MBMeetBallDetailViewController.h"
#import "MBHomeDataManager.h"
#import "MBMenuNaviagtionViewController.h"
#import "MBWebServiceConstants.h"
#import "MBWebServiceManager.h"
#import "MBCommentsCollectionView.h"

#import "MBMeetBall.h"
#import "MBComment.h"
static NSString * const kSessionId = @"sessionId";
static NSString * const kAppUserId = @"AppUserId";

@interface MBMyMeetBallsViewController ()

@property (strong, nonatomic) MBMeetBall *meetBall;
@property (strong, nonatomic) NSString *titleString;
@property (strong, nonatomic) NSString *coordString;
@property (strong, nonatomic) NSArray *meetBallArray;
@property (strong, nonatomic) NSMutableArray *meetBallIdArray;
@property (strong, nonatomic) NSMutableArray *bigCommentArray;
@property (strong, nonatomic) MBHomeDataManager *dataManager;



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
    self.meetBallArray = [self getActiveMeetBalls:[MBMeetBall findAllSortedBy:@"meetBallId" ascending:YES]];
    self.dataManager = [[MBHomeDataManager alloc] init];
    self.meetBallIdArray = [[NSMutableArray alloc] init];
    self.bigCommentArray = [[NSMutableArray alloc] init];
    [self.navigationItem.leftBarButtonItem setTarget:(MBMenuNaviagtionViewController *)self.navigationController];
    [self.navigationItem.leftBarButtonItem setAction:@selector(showMenu)];
    [self getCommentsForMeetBalls];
	// Do any additional setup after loading the view.
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

- (void)getCommentsForMeetBalls {
    for (MBMeetBall *mb in self.meetBallArray) {
        [self getCommentsForMeetBall:mb.meetBallId];
    }
    
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
    NSString *endDate = [self dateFromMeetBallDate:mb.endDate];
    cell.dateLabel.text = [NSString stringWithFormat:@"Start Date: %@",dateString];
    cell.endDateLabel.text = [NSString stringWithFormat:@"End Date: %@",endDate];
    cell.commentsCollectionView.index = indexPath.row;
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


- (void)getCommentsForMeetBall:(NSInteger)meetball {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *meetballId = [NSString stringWithFormat:@"%d",meetball];
        __weak MBMyMeetBallsViewController *weakSelf = self;
        [MBWebServiceManager AFHTTPRequestForWebService:kWebServiceGetMeetBallComments URLReplacements:@{@"version": [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"], @"sessionId":[[NSUserDefaults standardUserDefaults] objectForKey:kSessionId], @"meetballId":meetballId} success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
            if (responseObject) {
                NSError *jsonError;
                NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&jsonError];
                NSArray *items = JSON[@"Items"];
                NSMutableArray *array = [[NSMutableArray alloc] init];
                for (NSDictionary *dict  in items) {
                    MBComment *comm = [[MBComment alloc] init];
                    comm.firstName = dict[@"FirstName"];
                    comm.comment = dict[@"Comment"];
                    comm.commentDate = [weakSelf dateFromString:dict[@"CommentDate"]];
                    comm.appUserId = [(NSString *)dict[@"AppUserId"] integerValue];
                    [array addObject:comm];
                }
                [weakSelf.bigCommentArray addObject:array];
                [weakSelf.tableView reloadData];
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"%@",error);
        }];
    });

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
- (NSInteger)collectionView:(MBCommentsCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.bigCommentArray.count != self.meetBallArray.count) {
        return 0;
    }else {
        return [[self.bigCommentArray objectAtIndex:collectionView.index] count];
    }
}

- (commentsCollectionViewCell *)collectionView:(MBCommentsCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    commentsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"commentCell" forIndexPath:indexPath];
    NSArray *array = [self.bigCommentArray objectAtIndex:collectionView.index];
    MBComment *comm = [array objectAtIndex:indexPath.row];
    cell.commentLabel.text = comm.comment;
    return cell;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}



- (IBAction)refresh:(id)sender {
    __weak MBMyMeetBallsViewController *weakSelf = self;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.dataManager getUpcomingMeetBalls:^(BOOL done) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSArray *a = [MBMeetBall findAllSortedBy:@"meetBallId" ascending:YES];
        weakSelf.meetBallArray = [weakSelf.dataManager getActiveMeetBalls:a];
        [weakSelf.tableView reloadData];
    }];
}
@end
