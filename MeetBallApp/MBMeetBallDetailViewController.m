//
//  MBMeetBallDetailViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/12/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBMeetBallDetailViewController.h"
#import "MBAnnotation.h"

#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * 180.0 / M_PI)

@interface MBMeetBallDetailViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MBAnnotation *annotaion;

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
    
    [self.mapView setDelegate:self];
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
    [self annotationSetup];
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
        MBAnnotation *annotation = [[MBAnnotation alloc] initWithTitle:self.titleString andCoordinate:one];
        self.cord = one;
        [self.mapView addAnnotation:annotation];
    } else if ([self.titleString isEqualToString:@"Tailgate Two"]){
        MBAnnotation *annotation = [[MBAnnotation alloc] initWithTitle:self.titleString andCoordinate:two];
        self.cord = two;
        [self.mapView addAnnotation:annotation];
    } else if ([self.titleString isEqualToString:@"Tailgate Three"]) {
        MBAnnotation *annotation = [[MBAnnotation alloc] initWithTitle:self.titleString andCoordinate:three];
        self.cord = three;
        [self.mapView addAnnotation:annotation];
    } else if ([self.titleString isEqualToString:@"Tailgate Four"]) {
        MBAnnotation *annotation = [[MBAnnotation alloc] initWithTitle:self.titleString andCoordinate:four];
        self.cord = four;
        [self.mapView addAnnotation:annotation];
    } else if ([self.titleString isEqualToString:@"Tailgate Five"]) {
        MBAnnotation *annotation = [[MBAnnotation alloc] initWithTitle:self.titleString andCoordinate:five];
        self.cord = five;
        [self.mapView addAnnotation:annotation];
    }
    
}

#pragma mark - location manager delegates

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
//    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
    [self setMeetBallHeading:newHeading];
}

- (void)setMeetBallHeading:(CLHeading *)heading{
    double lon = self.cord.longitude - [self.mapView userLocation].coordinate.longitude;
    double dlon = degreesToRadians(lon);
    double lat1 = degreesToRadians([self.mapView userLocation].coordinate.latitude);
    double lat2 = degreesToRadians(self.cord.latitude);
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
    [self.compass setTransform:rotate];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self calculateDistance:[(CLLocation *)[locations objectAtIndex:0] coordinate]];
    
}

- (void)calculateDistance:(CLLocationCoordinate2D)userLocation {
    double R = 6371; // km
    double lat = self.cord.latitude - userLocation.latitude;
    double dLat = degreesToRadians(lat);
    double lon = self.cord.longitude - userLocation.longitude;
    double dLon = degreesToRadians(lon);
    double lat1 = degreesToRadians(userLocation.latitude);
    double lat2 = degreesToRadians(self.cord.latitude);
    
    double a = sin(dLat/2) * sin(dLat/2) + sin(dLon/2) * sin(dLon/2) * cos(lat1) *cos(lat2);
    double c = 2 * atan2(sqrt(a), sqrt(1-a));
    double d = R * c;
    double dft = d * 3280.84;
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
        self.annotaion = [[MBAnnotation alloc] initWithTitle:@"Car Location" andCoordinate:[self.mapView userLocation].coordinate];
    } else {
        self.annotaion = [[MBAnnotation alloc] initWithTitle:@"Car Location" andCoordinate:[self.mapView userLocation].coordinate];
    }
    
    [self.mapView addAnnotation:self.annotaion];
}
@end
