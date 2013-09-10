//
//  MBCombinedViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/9/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBCombinedViewController.h"

@interface MBCombinedViewController ()

@end

@implementation MBCombinedViewController

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
    [self.mapView setDelegate:self];
    self.mapView.showsUserLocation = YES;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
    [self.mapView setRegion:[self.mapView regionThatFits:MKCoordinateRegionMake([self.mapView userLocation].coordinate, MKCoordinateSpanMake(0.05, 0.05))] animated:YES];
    [self.mapView setMapType:MKMapTypeHybrid];
    self.longLabel.text = [NSString stringWithFormat:@"Long:%f",self.mapView.userLocation.coordinate.longitude];
    self.latLabel.text = [NSString stringWithFormat:@"Lat:%f", self.mapView.userLocation.coordinate.latitude];
    // Do any additional setup after loading the view from its nib.
}

-(void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)throwMeetBallAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
