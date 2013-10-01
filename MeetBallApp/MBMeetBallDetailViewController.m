//
//  MBMeetBallDetailViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/12/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBMeetBallDetailViewController.h"
#import "MBAnnotation.h"
#import "MBMathBlock.h"
#import "MBTipView.h"
#import "MBCommentsViewController.h"

#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * 180.0 / M_PI)

static NSString * const kAnnotationId = @"pinId";
static NSString * const kCarKey = @"carLocation";
static NSString * const kCarTip = @"carTip";

@interface MBMeetBallDetailViewController () <CLLocationManagerDelegate, MKMapViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MBAnnotation *annotaion;
@property (strong, nonatomic) MBAnnotation *meetBallAnnotation;
@property (strong, nonatomic) MBTipView *tipView;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;

@end

@implementation MBMeetBallDetailViewController

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
    if (self.titleString) {
        [self setTitle:self.titleString];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kCarKey]) {
        NSDictionary *d = [[NSUserDefaults standardUserDefaults] objectForKey:kCarKey];
        CLLocationCoordinate2D cord = CLLocationCoordinate2DMake([d[@"lat"] floatValue], [d[@"lon"] floatValue]);
        self.annotaion = [[MBAnnotation alloc] initWithTitle:@"Car Location" andCoordinate:cord reuseId:kAnnotationId withID:0];
        [self.mapView addAnnotation:self.annotaion];
    }
    
    [self.mapView setDelegate:self];
    [self annotationSetup];
    [self locationManagerSetup];
    [self setAnchorPoint:CGPointMake(0.5, 0.5) forView:self.compass];
    
    
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

- (void)viewDidAppear:(BOOL)animated {
    [self.locationManager startUpdatingHeading];
    [self.locationManager startUpdatingLocation];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
    
    [self showCoachTip];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.locationManager stopUpdatingHeading];
    [self.locationManager stopUpdatingLocation];
//    [self.mapView removeFromSuperview];
//    self.mapView.delegate = nil;
//    self.locationManager.delegate = nil;
//    self.mapView = nil;
//    self.locationManager = nil;

}

- (void)locationManagerSetup {
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
    [self.locationManager setHeadingFilter:kCLHeadingFilterNone];
}

- (void)annotationSetup {
    MBAnnotation *annotation = [[MBAnnotation alloc] initWithTitle:self.titleString andCoordinate:self.cord reuseId:kAnnotationId withID:0];
    [self.mapView addAnnotation:annotation];
}

- (void)showCoachTip {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kCarTip] == NO) {
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissCoachTip:)];
        [self.view addGestureRecognizer:self.tapGesture];
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MBTipView" owner:self options:nil];
        self.tipView = [nib objectAtIndex:0];
        CGRect f = self.tipView.frame;
        f.origin = self.toolbarl.frame.origin;
        [self.tipView setFrame:f];
        [self.view addSubview:self.tipView];
        [UIView animateWithDuration:0.5 animations:^{
            CGRect fr = self.tipView.frame;
            fr.origin.y -= fr.size.height;
            [self.tipView setFrame:fr];
        }];
    }
}

- (void)dismissCoachTip:(UITapGestureRecognizer *)tap {
    CGPoint location = [tap locationInView:self.view];
    if (CGRectContainsPoint(self.tipView.frame, location)) {
        [self.view removeGestureRecognizer:self.tapGesture];
        [UIView animateWithDuration:0.4 animations:^{
            CGRect fr = self.tipView.frame;
            fr.origin.y += fr.size.height +200;
            [self.tipView setFrame:fr];
        } completion:^(BOOL finished) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kCarTip];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.tipView removeFromSuperview];
            self.tipView = nil;
        }];
    }
}

#pragma mark - location manager delegates

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
//    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
    [self setMeetBallHeading:newHeading];
}

- (void)setMeetBallHeading:(CLHeading *)heading{
    double head = [MBMathBlock setMeetBallHeading:heading toPoint:self.cord userLocation:[self.mapView userLocation].coordinate];
    CGAffineTransform rotate = CGAffineTransformMakeRotation(head);
    [self.compass setTransform:rotate];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self calculateDistance:[(CLLocation *)[locations objectAtIndex:0] coordinate]];
    
}

- (void)calculateDistance:(CLLocationCoordinate2D)userLocation {
    double dft = [MBMathBlock getDistanceBetweenUserLocation:userLocation andDestination:self.cord];
    self.distanceLabel.text = [NSString stringWithFormat:@"Distance:%1.0f ft", dft];
    [self.distanceLabel sizeToFit];
}

#pragma mark - Map view methods
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
//    MBAnnotation *mp = [views objectAtIndex:0];
//    [self.mapView setRegion:[self.mapView regionThatFits:MKCoordinateRegionMake([mp coordinate], MKCoordinateSpanMake(0.5, 0.5))] animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MBAnnotation class]]) {
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kAnnotationId];
        if (pinView == nil) {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kAnnotationId];
            pinView.pinColor = MKPinAnnotationColorPurple;
            pinView.animatesDrop = YES;
            pinView.canShowCallout = YES;
            UIButton *callout = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            if ([[(MBAnnotation *)annotation title] isEqualToString:@"Car Location"]) {
                [callout setImage:[UIImage imageNamed:@"hide"] forState:UIControlStateNormal];
                callout.tag = 1;
            } else {
                [callout setImage:[UIImage imageNamed:@"car"] forState:UIControlStateNormal];
                callout.tag = 2;
            }
            pinView.rightCalloutAccessoryView = callout;
        }else {
            UIButton *callout = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            if ([[(MBAnnotation *)annotation title] isEqualToString:@"Car Location"]) {
                [callout setImage:[UIImage imageNamed:@"hide"] forState:UIControlStateNormal];
                callout.tag = 1;
            } else {
                [callout setImage:[UIImage imageNamed:@"car"] forState:UIControlStateNormal];
                callout.tag = 2;
            }
            pinView.rightCalloutAccessoryView = callout;
            pinView.annotation = annotation;
        }
        
        return pinView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    if ([view.annotation isKindOfClass:[MBAnnotation class]]) {
        if ([[(MBAnnotation*)view.annotation title] isEqualToString:@"Car Location"]) {
            [self.mapView removeAnnotation:self.annotaion];
            self.annotaion = nil;
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCarKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            self.meetBallAnnotation = view.annotation;
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Launch Navigation?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Launch Maps", nil];
            [actionSheet showInView:self.view];
        }
    }
    
}

#pragma mark - action Sheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving};
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.meetBallAnnotation.coordinate addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        mapItem.name = self.meetBallAnnotation.title;
        [mapItem openInMapsWithLaunchOptions:launchOptions];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Actions

- (IBAction)adjustUserLocation:(id)sender {
    [self.mapView setRegion:[self.mapView regionThatFits:MKCoordinateRegionMake([self.mapView userLocation].coordinate, MKCoordinateSpanMake(0.005, 0.005))] animated:YES];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
}

- (IBAction)carLocation:(id)sender {
    if (self.annotaion) {
        [self.mapView removeAnnotation:self.annotaion];
        self.annotaion = nil;
        self.annotaion = [[MBAnnotation alloc] initWithTitle:@"Car Location" andCoordinate:[self.mapView userLocation].coordinate reuseId:kAnnotationId withID:0];
    } else {
        self.annotaion = [[MBAnnotation alloc] initWithTitle:@"Car Location" andCoordinate:[self.mapView userLocation].coordinate reuseId:kAnnotationId withID:0];
    }
    [[NSUserDefaults standardUserDefaults] setObject:@{@"lat":[NSString stringWithFormat:@"%f",self.annotaion.coordinate.latitude], @"lon":[NSString stringWithFormat:@"%f",self.annotaion.coordinate.longitude]} forKey:kCarKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.mapView addAnnotation:self.annotaion];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MBCommentsViewController *vc = (MBCommentsViewController *)[segue destinationViewController];
    vc.meetBall = self.meetBall;
}
@end
