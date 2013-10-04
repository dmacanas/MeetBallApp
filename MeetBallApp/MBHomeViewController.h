//
//  MBHomeViewController.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 8/27/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBUser.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface MBHomeViewController : UIViewController < CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *compassImageVIew;
@property (weak, nonatomic) IBOutlet UIView *menuContainer;
@property (weak, nonatomic) IBOutlet UITableView *homeTableView;
@property (weak, nonatomic) IBOutlet UIImageView *blurView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *menuSuperContainer;
@property (weak, nonatomic) IBOutlet UIToolbar *mapToolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *toolBarButton;
@property (weak, nonatomic) IBOutlet UIToolbar *mainToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *adjustLocation;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *throwMBButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;

- (IBAction)showMenu:(id)sender;
- (IBAction)testCancel:(id)sender;
- (IBAction)throwMeetBalls:(id)sender;
- (IBAction)adjustMap:(id)sender;
- (IBAction)adjustUserLocation:(id)sender;
- (IBAction)carLocation:(id)sender;


@end
