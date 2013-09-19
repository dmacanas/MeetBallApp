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

#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * 180.0 / M_PI)

static NSString * const kAnnotationId = @"pinId";
static NSString * const kCarKey = @"carLocation";
static NSString * const kCarTip = @"carTip";

@interface MBMeetBallDetailViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MBAnnotation *annotaion;
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
        self.annotaion = [[MBAnnotation alloc] initWithTitle:@"Car Location" andCoordinate:cord reuseId:kAnnotationId];
        [self.mapView addAnnotation:self.annotaion];
    }
    
    [self.mapView setDelegate:self];
    [self locationManagerSetup];
    [self setAnchorPoint:CGPointMake(0.5, 0.5) forView:self.compass];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissCoachTip:)];
    [self.view addGestureRecognizer:self.tapGesture];
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
    [self annotationSetup];
    [self showCoachTip];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.locationManager stopUpdatingHeading];
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManagerSetup {
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
    [self.locationManager setHeadingFilter:kCLHeadingFilterNone];
}

- (void)annotationSetup {
    CLLocationCoordinate2D one = CLLocationCoordinate2DMake(42.068147, -87.694432);
    CLLocationCoordinate2D two = CLLocationCoordinate2DMake(42.066877, -87.691739);
    CLLocationCoordinate2D three = CLLocationCoordinate2DMake(42.066140, -87.690693);
    CLLocationCoordinate2D four = CLLocationCoordinate2DMake(42.064691, -87.694523);
    CLLocationCoordinate2D five = CLLocationCoordinate2DMake(42.064412, -87.692893);
    
    
    if ([self.titleString isEqualToString:@"Tailgate One"]) {
        MBAnnotation *annotation = [[MBAnnotation alloc] initWithTitle:self.titleString andCoordinate:one reuseId:kAnnotationId];
        self.cord = one;
        [self.mapView addAnnotation:annotation];
    } else if ([self.titleString isEqualToString:@"Tailgate Two"]){
        MBAnnotation *annotation = [[MBAnnotation alloc] initWithTitle:self.titleString andCoordinate:two reuseId:kAnnotationId];
        self.cord = two;
        [self.mapView addAnnotation:annotation];
    } else if ([self.titleString isEqualToString:@"Tailgate Three"]) {
        MBAnnotation *annotation = [[MBAnnotation alloc] initWithTitle:self.titleString andCoordinate:three reuseId:kAnnotationId];
        self.cord = three;
        [self.mapView addAnnotation:annotation];
    } else if ([self.titleString isEqualToString:@"Tailgate Four"]) {
        MBAnnotation *annotation = [[MBAnnotation alloc] initWithTitle:self.titleString andCoordinate:four reuseId:kAnnotationId];
        self.cord = four;
        [self.mapView addAnnotation:annotation];
    } else if ([self.titleString isEqualToString:@"Tailgate Five"]) {
        MBAnnotation *annotation = [[MBAnnotation alloc] initWithTitle:self.titleString andCoordinate:five reuseId:kAnnotationId];
        self.cord = five;
        [self.mapView addAnnotation:annotation];
    }
}

- (void)showCoachTip {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kCarTip] == NO) {
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
    self.distanceLabel.text = [NSString stringWithFormat:@"Distance:%f ft", dft];
    [self.distanceLabel sizeToFit];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    MBAnnotation *mp = [views objectAtIndex:0];
    [self.mapView setRegion:[self.mapView regionThatFits:MKCoordinateRegionMake([mp coordinate], MKCoordinateSpanMake(0.5, 0.5))] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)adjustUserLocation:(id)sender {
    [self.mapView setRegion:[self.mapView regionThatFits:MKCoordinateRegionMake([self.mapView userLocation].coordinate, MKCoordinateSpanMake(0.005, 0.005))] animated:YES];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
}

- (IBAction)carLocation:(id)sender {
    if (self.annotaion) {
        [self.mapView removeAnnotation:self.annotaion];
        self.annotaion = nil;
        self.annotaion = [[MBAnnotation alloc] initWithTitle:@"Car Location" andCoordinate:[self.mapView userLocation].coordinate reuseId:kAnnotationId];
    } else {
        self.annotaion = [[MBAnnotation alloc] initWithTitle:@"Car Location" andCoordinate:[self.mapView userLocation].coordinate reuseId:kAnnotationId];
    }
    [[NSUserDefaults standardUserDefaults] setObject:@{@"lat":[NSString stringWithFormat:@"%f",self.annotaion.coordinate.latitude], @"lon":[NSString stringWithFormat:@"%f",self.annotaion.coordinate.longitude]} forKey:kCarKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.mapView addAnnotation:self.annotaion];
}
@end
