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

@interface MBHomeViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, MBMenuViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *headingLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *compassImageVIew;

- (IBAction)showMenu:(id)sender;
- (IBAction)testCancel:(id)sender;
- (IBAction)noMeetBalls:(id)sender;
- (IBAction)throwMeetBallAction:(id)sender;

@end
