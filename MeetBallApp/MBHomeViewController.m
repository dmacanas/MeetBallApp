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
#import "MBMathBlock.h"
#import "MBAppDelegate.h"
#import "NSManagedObject+MRImportAdditions.h"

#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import <FacebookSDK/FacebookSDK.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * 180.0 / M_PI)
static NSString * const kAnnotaionId = @"pinId";

@interface MBHomeViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) MBHomeDataCommunicator *homeCommLink;
@property (strong, nonatomic) MBMenuView *menu;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (assign, nonatomic) BOOL isShowingMenu;
@property (assign, nonatomic) BOOL isShowingMeetBall;
@property (assign, nonatomic) BOOL isShowingFullScreenMap;
@property (assign, nonatomic) CGRect originalRect;
@property (assign, nonatomic) CGRect originalToolbarFrame;
@property (assign, nonatomic) CGRect originalTableFrame;
@property (strong, nonatomic) MBAnnotation *annotation;
@property (strong, nonatomic) NSArray *contactsArray;

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
//    self.contactsArray = [[NSMutableArray alloc] init];
    [self setMapView];
    [self setAnchorPoint:CGPointMake(0.5, 0.5) forView:self.compassImageVIew];
    [self locationManagerSetup];
    [self createAnnotations];
    [self getMeetBallContacts];
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
    
    MBAnnotation *aOne = [[MBAnnotation alloc] initWithTitle:@"Tailgate One" andCoordinate:one reuseId:kAnnotaionId];
    MBAnnotation *aTwo = [[MBAnnotation alloc] initWithTitle:@"Tailgate Two" andCoordinate:two reuseId:kAnnotaionId];
    MBAnnotation *aThree = [[MBAnnotation alloc] initWithTitle:@"Tailgate Three" andCoordinate:three reuseId:kAnnotaionId];
    MBAnnotation *aFour =[[MBAnnotation alloc] initWithTitle:@"Tailgate Four" andCoordinate:four reuseId:kAnnotaionId];
    MBAnnotation *aFive = [[MBAnnotation alloc] initWithTitle:@"Tailgate Five" andCoordinate:five reuseId:kAnnotaionId];
    
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
    self.originalTableFrame = self.homeTableView.frame;
    [self.locationManager startUpdatingHeading];
    [self.locationManager startUpdatingLocation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.locationManager stopUpdatingHeading];
    [self.locationManager stopUpdatingLocation];
}


#pragma mark - Mapview Delegates

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {

}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MBAnnotation class]]) {
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kAnnotaionId];
        if (pinView == nil) {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kAnnotaionId];
            pinView.pinColor = MKPinAnnotationColorPurple;
            pinView.animatesDrop = YES;
            pinView.canShowCallout = YES;
            UIButton *callout = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            [callout setImage:[UIImage imageNamed:@"car"] forState:UIControlStateNormal];
            pinView.rightCalloutAccessoryView = callout;
        }else {
            pinView.annotation = annotation;
        }
        
        return pinView;
    }

    return nil;
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

#pragma mark - contacts setUp
- (void)getMeetBallContacts {
    __weak MBHomeViewController *weakSelf = self;
//    __block NSManagedObjectContext *moc = [NSManagedObjectContext MR_contextForCurrentThread];
//    __block NSMutableArray *objectIds = [NSMutableArray array];
    [self.homeCommLink getMeetBallContacts:^(id contacts){
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:contacts options:kNilOptions error:&error];
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            weakSelf.contactsArray = [MBUser MR_importFromArrayAndWait:json[@"Items"] inContext:localContext];
            [weakSelf.homeTableView reloadData];
        }];
    } failure:^(NSError *err) {
        NSLog(@"error %@",err);
    }];
}

#pragma mark - tableView methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    if (indexPath.row == self.contactsArray.count) {
        cell.textLabel.text = @"Add More Friends...";
        return cell;
    }
    if (self.contactsArray && self.contactsArray.count > 1) {
        MBUser *u = (MBUser *)[[NSManagedObjectContext MR_contextForCurrentThread] objectWithID:[[self.contactsArray objectAtIndex:indexPath.row] objectID]];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", u.firstName, u.lastName];
        cell.detailTextLabel.text = u.email;
    }

    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contactsArray.count + 1;
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
        self.annotation = [[MBAnnotation alloc] initWithTitle:@"Car Location" andCoordinate:[self.mapView userLocation].coordinate reuseId:kAnnotaionId];
    } else {
        self.annotation = [[MBAnnotation alloc] initWithTitle:@"Car Location" andCoordinate:[self.mapView userLocation].coordinate reuseId:kAnnotaionId];
    }
    
    [self.mapView addAnnotation:self.annotation];
}

- (void)resetHomeScreen {
    [self.toolBarButton setImage:[UIImage imageNamed:@"fullScreen_ic"]];
    self.isShowingFullScreenMap = NO;
    __weak MBHomeViewController *weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        [weakSelf.mapView setFrame:weakSelf.originalRect];
        [weakSelf.mapToolBar setFrame:weakSelf.originalToolbarFrame];
        [weakSelf.scrollView setScrollEnabled:YES];
        weakSelf.homeTableView.hidden = NO;

    }];
    
    [UIView animateWithDuration:0.5 animations:^{
        [weakSelf.homeTableView setFrame:weakSelf.originalTableFrame];
    } completion:^(BOOL finished) {
         weakSelf.mainToolbar.hidden = NO;
    }];

}

- (void)setForFullScreen {
    [self.scrollView scrollRectToVisible:self.mapView.frame animated:NO];
    [self.scrollView setScrollEnabled:NO];
    [self.toolBarButton setImage:[UIImage imageNamed:@"shrink_ic"]];
    self.isShowingFullScreenMap = YES;
}

- (void)setFramesForFullScreen {
    __weak MBHomeViewController *weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        CGRect f = weakSelf.homeTableView.frame;
        f.origin.y = weakSelf.scrollView.frame.size.height;
        [weakSelf.homeTableView setFrame:f];
        weakSelf.mainToolbar.hidden = YES;
    } completion:^(BOOL finished) {
        weakSelf.homeTableView.hidden = YES;
    }];
    
    [UIView animateWithDuration:0.5 animations:^{
        CGRect f = weakSelf.mapView.frame;
        f.size.height = weakSelf.scrollView.frame.size.height -64;
        [weakSelf.mapView setFrame:f];
        f = weakSelf.mapToolBar.frame;
        f.origin.y = weakSelf.mapView.frame.size.height - weakSelf.mapToolBar.frame.size.height;
        [weakSelf.mapToolBar setFrame:f];

    }];
}

#pragma mark - notifications
- (void)navigateWithNotification:(NSNotification *)notification {
    if ([(NSString *)notification.object isEqualToString:@"Home"]) {
        return;
    }
    [MBMenuNavigator navigateToMenuItem:(NSString *)notification.object fromVC:self];
}

@end
