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
#import "MBCombinedViewController.h"

#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import <FacebookSDK/FacebookSDK.h>

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * 180.0 / M_PI)

@interface MBHomeViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) MBHomeDataCommunicator *homeCommLink;
@property (strong, nonatomic) MBMenuView *menu;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (assign, nonatomic) BOOL isShowingMenu;
@property (assign, nonatomic) BOOL isShowingMeetBall;

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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
    self.homeCommLink = [[MBHomeDataCommunicator alloc] init];
    
    [self.mapView setDelegate:self];
    self.mapView.showsUserLocation = YES;
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
    [self.locationManager setHeadingFilter:kCLHeadingFilterNone];
    [self.locationManager startUpdatingHeading];
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
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    [self.mapView setRegion:[self.mapView regionThatFits:MKCoordinateRegionMake([self.mapView userLocation].coordinate, MKCoordinateSpanMake(0.005, 0.005))] animated:YES];
}


- (void)didSelectionMenuItem:(NSString *)item {
    NSLog(@"Menu Select %@", item);
    self.isShowingMenu = NO;
    [self.menu removeFromSuperview];
    if ([item isEqualToString:@"My MeetBalls"]) {
        MBCombinedViewController *vc = [[MBCombinedViewController alloc] init];
        UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:navC animated:NO completion:nil];
    }

}

// location manager delegates
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if(self.isShowingMeetBall == NO){
        [self setHeading:newHeading];
    } else {
        [self setMeetBallHeading:newHeading];
    }
}

- (void)setHeading:(CLHeading *)heading {
    float mHeading = heading.trueHeading;
    if ((mHeading >= 339) || (mHeading <= 22)) {
        [self.headingLabel setText:[NSString stringWithFormat:@"Heading: %.1f N", mHeading]];
    }else if ((mHeading > 23) && (mHeading <= 68)) {
        [self.headingLabel setText:[NSString stringWithFormat:@"Heading: %.1f NE", mHeading]];
    }else if ((mHeading > 69) && (mHeading <= 113)) {
        [self.headingLabel setText:[NSString stringWithFormat:@"Heading: %.1f E", mHeading]];
    }else if ((mHeading > 114) && (mHeading <= 158)) {
        [self.headingLabel setText:[NSString stringWithFormat:@"Heading: %.1f SE", mHeading]];
    }else if ((mHeading > 159) && (mHeading <= 203)) {
        [self.headingLabel setText:[NSString stringWithFormat:@"Heading: %.1f S", mHeading]];
    }else if ((mHeading > 204) && (mHeading <= 248)) {
        [self.headingLabel setText:[NSString stringWithFormat:@"Heading: %.1f SW", mHeading]];
    }else if ((mHeading > 249) && (mHeading <= 293)) {
        [self.headingLabel setText:[NSString stringWithFormat:@"Heading: %.1f W", mHeading]];
    }else if ((mHeading > 294) && (mHeading <= 338)) {
        [self.headingLabel setText:[NSString stringWithFormat:@"Heading: %.1f NW", mHeading]];
    }
    
    NSInteger trueNorth = heading.trueHeading;
    CGAffineTransform rotate = CGAffineTransformMakeRotation(degreesToRadians(-trueNorth));
    [self.compassImageVIew setTransform:rotate];
}

- (void)setMeetBallHeading:(CLHeading *)heading{
    CLLocationCoordinate2D cord = CLLocationCoordinate2DMake(41.955846, -87.67348529);
    double dlon = degreesToRadians(cord.longitude - [self.mapView userLocation].coordinate.longitude);
    double lat1 = degreesToRadians([self.mapView userLocation].coordinate.latitude);
    double lat2 = degreesToRadians(cord.latitude);
    
    double y = sin(dlon) * cos(lat2);
    double x = (cos(lat1) * sin(lat2)) - (sin(lat1) * cos(lat2) * cos(dlon));
    double brng = radiansToDegrees(atan2(y, x));
        
    if (brng<0) {
        brng = (180+(180+brng));
    }
    
    double trueNorth = heading.trueHeading;
    double hd = 360 - (trueNorth - brng);

    CGAffineTransform rotate = CGAffineTransformMakeRotation(degreesToRadians(hd));
    [self.compassImageVIew setTransform:rotate];
    [self.headingLabel setText:@"Dominic's MeetBall"];
    [self.headingLabel sizeToFit];
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
    if (self.isShowingMeetBall == NO) {
        self.isShowingMeetBall = YES;
        [self.compassImageVIew setImage:[UIImage imageNamed:@"meetBallCompass"]];
    } else {
        self.isShowingMeetBall = NO;
        [self.compassImageVIew setImage:[UIImage imageNamed:@"compass"]];
    }

}

- (IBAction)throwMeetBallAction:(id)sender {
}
@end
