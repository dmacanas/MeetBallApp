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
#import "MBMenuView.h"
#import "MBAnnotation.h"
#import "MBMenuNavigator.h"

#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import <FacebookSDK/FacebookSDK.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * 180.0 / M_PI)

@interface MBHomeViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) MBHomeDataCommunicator *homeCommLink;
@property (strong, nonatomic) MBMenuView *menu;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (assign, nonatomic) BOOL isShowingMenu;
@property (assign, nonatomic) BOOL isShowingMeetBall;
@property (assign, nonatomic) BOOL isShowingFullScreenMap;
@property (assign, nonatomic) CGRect originalRect;
@property (assign, nonatomic) CGRect originalToolbarFrame;
@property (strong, nonatomic) MBAnnotation *annotation;

@end

static NSString * const kAuthentication = @"authenticated";
static NSString * const kAppUserId = @"AppUserId";
static NSString * const kFirstName = @"FirstName";
static NSString * const kSessionId = @"sessionId";

@implementation MBHomeViewController 
#pragma mark - Implemenation

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
    self.homeCommLink = [[MBHomeDataCommunicator alloc] init];
    
    [self setMapView];
    [self setAnchorPoint:CGPointMake(0.5, 0.5) forView:self.compassImageVIew];
    [self locationManagerSetup];
    [self createAnnotations];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigateWithNotification:) name:@"navigate" object:nil];
}

-(void)setAnchorPoint:(CGPoint)anchorpoint forView:(UIView *)view
{
    CGPoint oldOrigin = view.frame.origin;
    view.layer.anchorPoint = anchorpoint;
    CGPoint newOrigin = view.frame.origin;
    
    CGPoint transition;
    transition.x = newOrigin.x - oldOrigin.x;
    transition.y = oldOrigin.y - oldOrigin.y;
    
    view.center = CGPointMake (view.center.x - transition.x, view.center.y - transition.y);
}

- (void)setMapView {
    [self.mapView setDelegate:self];
    self.mapView.showsUserLocation = YES;
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
}

- (void)locationManagerSetup {
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
    [self.locationManager setHeadingFilter:kCLHeadingFilterNone];
}

- (void)createAnnotations {
    CLLocationCoordinate2D one = CLLocationCoordinate2DMake(42.068147, -87.694432);
    CLLocationCoordinate2D two = CLLocationCoordinate2DMake(42.066877, -87.691739);
    CLLocationCoordinate2D three = CLLocationCoordinate2DMake(42.066140, -87.690693);
    CLLocationCoordinate2D four = CLLocationCoordinate2DMake(42.064691, -87.694523);
    CLLocationCoordinate2D five = CLLocationCoordinate2DMake(42.064412, -87.692893);
    
    MBAnnotation *aOne = [[MBAnnotation alloc] initWithTitle:@"Tailgate One" andCoordinate:one];
    MBAnnotation *aTwo = [[MBAnnotation alloc] initWithTitle:@"Tailgate Two" andCoordinate:two];
    MBAnnotation *aThree = [[MBAnnotation alloc] initWithTitle:@"Tailgate Three" andCoordinate:three];
    MBAnnotation *aFour =[[MBAnnotation alloc] initWithTitle:@"Tailgate Four" andCoordinate:four];
    MBAnnotation *aFive = [[MBAnnotation alloc] initWithTitle:@"Tailgate Five" andCoordinate:five];
    
    NSArray *a = [[NSArray alloc] initWithObjects:aOne, aTwo, aThree, aFour, aFive, nil];
    
    [self.mapView addAnnotations:a];
    
}

- (void)menuSetup {
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"MBMenuView" owner:self options:nil];
    self.menu = [array objectAtIndex:0];
    self.menu.delegate = self;
    [self.menuContainer addSubview:self.menu];
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.isShowingFullScreenMap) {
        [self resetHomeScreen];
    }
    self.originalRect = self.mapView.frame;
    self.originalToolbarFrame = self.mapToolBar.frame;
    [self.locationManager startUpdatingHeading];
    [self.locationManager startUpdatingLocation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.locationManager stopUpdatingHeading];
    [self.locationManager stopUpdatingLocation];
}


#pragma mark - Mapview Delegates

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    MKAnnotationView *annotationView = [views objectAtIndex:0];
	id <MKAnnotation> mp = [annotationView annotation];
    if([mp class] != [MKUserLocation class]){
        [self.mapView setRegion:[self.mapView regionThatFits:MKCoordinateRegionMake([mp coordinate], MKCoordinateSpanMake(1, 1))] animated:YES];
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
}

#pragma mark - Menu Delegate

- (void)didSelectionMenuItem:(NSString *)item {
    self.isShowingMenu = NO;
    self.menuSuperContainer.hidden = YES;
    if ([item isEqualToString:@"Home"]) {
        return;
    }
    __weak MBHomeViewController *weakSelf = self;
    [MBMenuNavigator navigateToMenuItem:item fromVC:weakSelf];
}

#pragma mark - Location Manager Delegates
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if(self.isShowingMeetBall == YES) {
        [self setMeetBallHeading:newHeading];
    }
}

- (void)setMeetBallHeading:(CLHeading *)heading{
    CLLocationCoordinate2D cord = CLLocationCoordinate2DMake(42.06540, -87.69442);
    double lon = cord.longitude - [self.mapView userLocation].coordinate.longitude;
    double dlon = degreesToRadians(lon);
    double lat1 = degreesToRadians([self.mapView userLocation].coordinate.latitude);
    double lat2 = degreesToRadians(cord.latitude);
    double y = sin(dlon) * cos(lat2);
    double x1 = cos(lat1) * sin(lat2);
    double x2 = sin(lat1) * cos(lat2) * cos(dlon);
    double x = x1 - x2;
    double brng = radiansToDegrees(atan2(y, x));
    
    if (brng<0) {
        brng = (180+(180+brng));
    }
    
    double trueNorth = heading.trueHeading;
    double hd = trueNorth - brng;
    hd = 360 - hd;

    CGAffineTransform rotate = CGAffineTransformMakeRotation(degreesToRadians(hd));
    [self.compassImageVIew setTransform:rotate];
}

#pragma mark - tableView methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    if (indexPath.row != 3) {
        cell.textLabel.text = @"Friend Name";
    } else {
        cell.textLabel.text = @"Add more friends ...";
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Select Friends and Throw a MeetBall!";
    }
    
    return @"";
}

#pragma mark - clean up
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions
- (IBAction)showMenu:(id)sender {
    if (self.isShowingMenu == NO){
        [self.menu createBlurViewInView:self.view forImageView:self.blurView];
        self.menuSuperContainer.hidden = NO;
        self.isShowingMenu = YES;
        
    } else {
        self.menuSuperContainer.hidden = YES;
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

}

- (IBAction)throwMeetBall:(id)sender {
}

- (IBAction)adjustMap:(id)sender {
    if (self.isShowingFullScreenMap) {
        [self resetHomeScreen];
    } else {
        [UIView animateWithDuration:0.1f animations:^{
            [self setForFullScreen];
        } completion:^(BOOL finished) {
            [self setFramesForFullScreen];
        }];
    }
}

- (IBAction)adjustUserLocation:(id)sender {
    [self.mapView setRegion:[self.mapView regionThatFits:MKCoordinateRegionMake([self.mapView userLocation].coordinate, MKCoordinateSpanMake(0.005, 0.005))] animated:YES];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
}

- (IBAction)carLocation:(id)sender {
    if (self.annotation) {
        [self.mapView removeAnnotation:self.annotation];
        self.annotation = nil;
        self.annotation = [[MBAnnotation alloc] initWithTitle:@"Car Location" andCoordinate:[self.mapView userLocation].coordinate];
    } else {
        self.annotation = [[MBAnnotation alloc] initWithTitle:@"Car Location" andCoordinate:[self.mapView userLocation].coordinate];
    }
    
    [self.mapView addAnnotation:self.annotation];
}

- (void)resetHomeScreen {
    [self.toolBarButton setImage:[UIImage imageNamed:@"fullScreen_ic"]];
    self.isShowingFullScreenMap = NO;
    
    self.homeTableView.hidden = NO;
    self.mainToolbar.hidden = NO;
    [self.mapView setFrame:self.originalRect];
    [self.mapToolBar setFrame:self.originalToolbarFrame];
    [self.scrollView setScrollEnabled:YES];
}

- (void)setForFullScreen {
    [self.scrollView scrollRectToVisible:self.mapView.frame animated:NO];
    [self.scrollView setScrollEnabled:NO];
    [self.toolBarButton setImage:[UIImage imageNamed:@"shrink_ic"]];
    self.isShowingFullScreenMap = YES;
}

- (void)setFramesForFullScreen {
    self.homeTableView.hidden = YES;
    self.mainToolbar.hidden = YES;
    CGRect f = self.mapView.frame;
    f.size.height = self.scrollView.frame.size.height -64;
    [self.mapView setFrame:f];
    f = self.mapToolBar.frame;
    f.origin.y = self.mapView.frame.size.height - self.mapToolBar.frame.size.height;
    [self.mapToolBar setFrame:f];
}

#pragma mark - notifications
- (void)navigateWithNotification:(NSNotification *)notification {
    if ([(NSString *)notification.object isEqualToString:@"Home"]) {
        return;
    }
    [MBMenuNavigator navigateToMenuItem:(NSString *)notification.object fromVC:self];
}

@end
