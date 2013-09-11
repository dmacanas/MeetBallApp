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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
    self.homeCommLink = [[MBHomeDataCommunicator alloc] init];
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.mapView setDelegate:self];
    self.mapView.showsUserLocation = YES;
    
    [self locationManagerSetup];
}

- (void)locationManagerSetup {
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
    [self.locationManager setHeadingFilter:kCLHeadingFilterNone];
    [self.locationManager startUpdatingHeading];
}

- (void)menuSetup {
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"MBMenuView" owner:self options:nil];
    self.menu = [array objectAtIndex:0];
    self.menu.delegate = self;
    [self.menuContainer addSubview:self.menu];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Mapview Delegates

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    MKAnnotationView *annotationView = [views objectAtIndex:0];
	id <MKAnnotation> mp = [annotationView annotation];
    if([mp class] != [MKUserLocation class]){
        [self.mapView setRegion:[self.mapView regionThatFits:MKCoordinateRegionMake([mp coordinate], MKCoordinateSpanMake(1, 1))] animated:YES];
    } else {
        [self.mapView setRegion:[self.mapView regionThatFits:MKCoordinateRegionMake([self.mapView userLocation].coordinate, MKCoordinateSpanMake(0.005, 0.005))] animated:YES];
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
//    [self.mapView setRegion:[self.mapView regionThatFits:MKCoordinateRegionMake([self.mapView userLocation].coordinate, MKCoordinateSpanMake(0.005, 0.005))] animated:YES];
}

#pragma mark - Menu Delegate

- (void)didSelectionMenuItem:(NSString *)item {
    NSLog(@"Menu Select %@", item);
    self.isShowingMenu = NO;
    self.menuContainer.hidden = YES;
    if ([item isEqualToString:@"My MeetBalls"]) {
        
    }

}

#pragma mark - Location Manager Delegates
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
    
    [self.headingLabel sizeToFit];
    NSInteger trueNorth = heading.trueHeading;
    CGAffineTransform rotate = CGAffineTransformMakeRotation(degreesToRadians(-trueNorth));
    [self.compassImageVIew setTransform:rotate];
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
    [self.headingLabel setText:@"Dominic's MeetBall"];
    [self.headingLabel sizeToFit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions
- (IBAction)showMenu:(id)sender {
    if (self.isShowingMenu == NO){
        self.menuContainer.hidden = NO;
        self.isShowingMenu = YES;
    } else {
        self.menuContainer.hidden = YES;
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
        CGAffineTransform rotate = CGAffineTransformMakeRotation(degreesToRadians(0));
        [self.compassImageVIew setTransform:rotate];
        self.isShowingMeetBall = YES;
        [self.compassImageVIew setImage:[UIImage imageNamed:@"meetBallCompass"]];
        if (self.annotation == nil) {
            CLLocationCoordinate2D cord = CLLocationCoordinate2DMake(42.06540, -87.69442);
            NSString *title = @"Dominic's MeetBall";
            self.annotation = [[MBAnnotation alloc] initWithTitle:title andCoordinate:cord];
            [self.mapView addAnnotation:self.annotation];
            [self.mapView selectAnnotation:self.annotation animated:YES];
        }
    } else {
        CGAffineTransform rotate = CGAffineTransformMakeRotation(degreesToRadians(0));
        [self.compassImageVIew setTransform:rotate];
        self.isShowingMeetBall = NO;
        [self.mapView removeAnnotation:self.annotation];
        self.annotation = nil;
        [self.compassImageVIew setImage:[UIImage imageNamed:@"compass"]];
        [self.mapView setRegion:[self.mapView regionThatFits:MKCoordinateRegionMake([self.mapView userLocation].coordinate, MKCoordinateSpanMake(0.005, 0.005))] animated:YES];
    }

}

- (IBAction)throwMeetBallAction:(id)sender {
}

@end
