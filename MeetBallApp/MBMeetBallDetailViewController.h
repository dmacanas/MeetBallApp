//
//  MBMeetBallDetailViewController.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/12/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MBMeetBallDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *compassContainer;
@property (weak, nonatomic) IBOutlet UIImageView *compass;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
