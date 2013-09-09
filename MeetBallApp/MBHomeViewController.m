//
//  MBHomeViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 8/27/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBHomeViewController.h"
#import "MBCredentialManager.h"
#import "MBLoginViewController.h"
#import "MBSuitUpViewController.h"
#import "MBHomeDataCommunicator.h"
#import "MBCredentialManager.h"
#import "MBEventCollectionViewCell.h"
#import "MBHomeMeetBallCollectionViewCell.h"
#import "MBMenuView.h"

#import "MBUser.h"
#import "MeetBalls.h"

#import <CoreData/CoreData.h>
#import <FacebookSDK/FacebookSDK.h>


@interface MBHomeViewController ()

@property (strong, nonatomic) MBHomeDataCommunicator *homeCommLink;
@property (strong, nonatomic) MBMenuView *menu;
@property (assign, nonatomic) BOOL isShowingMenu;
@property (assign, nonatomic) BOOL isShowingCollectionView;

@end

static NSString * const kAuthentication = @"authenticated";
static NSString * const kAppUserId = @"AppUserId";
static NSString * const kFirstName = @"FirstName";
static NSString * const kSessionId = @"sessionId";

@implementation MBHomeViewController

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
    [self collectionViewSetup];
    [self menuSetup];
    self.isShowingCollectionView = YES;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
    self.homeCommLink = [[MBHomeDataCommunicator alloc] init];
    
    [self.mapView setDelegate:self];
    self.mapView.showsUserLocation = YES;
}

- (void)collectionViewSetup {
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    UINib *cellNib = [UINib nibWithNibName:@"MBHomeMeetBallCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"HomeCollectionCell"];
}

- (void)menuSetup {
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"MBMenuView" owner:self options:nil];
    self.menu = [array objectAtIndex:0];
    self.menu.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    
}

//main collectionview delegates

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellID = @"HomeCollectionCell";
    MBHomeMeetBallCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    if(cell == nil){
        cell = [[MBHomeMeetBallCollectionViewCell alloc] init];
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

// mapview delegates

-(void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    [self.mapView setRegion:[self.mapView regionThatFits:MKCoordinateRegionMake([self.mapView userLocation].coordinate, MKCoordinateSpanMake(0.0005, 0.0005))] animated:YES];
}

//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"selected %@", indexPath);
//    [self performSegueWithIdentifier:@"detailsPush" sender:self];
//}

- (void)didSelectionMenuItem:(NSString *)item {
    NSLog(@"Menu Select %@", item);
    self.isShowingMenu = NO;
    [self.menu removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showMenu:(id)sender {
    if (self.isShowingMenu == NO){
        [self.view addSubview:self.menu];
        self.isShowingMenu = YES;
    } else {
        [self.menu removeFromSuperview];
        self.isShowingMenu = NO;
    }
}

- (IBAction)testCancel:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kAuthentication];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if([self.presentingViewController class] == [MBLoginViewController class] || [self.presentingViewController class] ==[MBSuitUpViewController class]){
        [self dismissViewControllerAnimated:YES completion:nil];
    } else{
        [FBSession.activeSession closeAndClearTokenInformation];
        [MBCredentialManager clearCredentials];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"loginFlow" bundle:nil];
        UIViewController *vc = [sb instantiateInitialViewController];
        [self presentViewController:vc animated:NO completion:nil];
    }

}

- (IBAction)noMeetBalls:(id)sender {
    if (self.isShowingCollectionView) {
        self.isShowingCollectionView = NO;
        self.collectionView.hidden = YES;
        UILabel *noItems = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 44)];
        noItems.tag = 4;
        noItems.text = @"No active Meetballs!";
        [self.view addSubview:noItems];
    }else {
        self.isShowingCollectionView = YES;
        self.collectionView.hidden = NO;
        UILabel *lab = (UILabel *)[self.view viewWithTag:4];
        [lab removeFromSuperview];

    }
}
@end
