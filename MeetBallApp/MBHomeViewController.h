//
//  MBHomeViewController.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 8/27/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBUser.h"
#import "MBMenuView.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface MBHomeViewController : UIViewController <MBMenuViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *compassImageVIew;
@property (weak, nonatomic) IBOutlet UIView *menuContainer;
@property (weak, nonatomic) IBOutlet UITableView *homeTableView;

- (IBAction)showMenu:(id)sender;
- (IBAction)testCancel:(id)sender;
- (IBAction)noMeetBalls:(id)sender;
- (IBAction)throwMeetBall:(id)sender;

@end
