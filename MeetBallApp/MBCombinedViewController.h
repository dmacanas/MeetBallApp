//
//  MBCombinedViewController.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/9/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MBCombinedViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *compassView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *throwMeetball;
@property (weak, nonatomic) IBOutlet UILabel *latLabel;
@property (weak, nonatomic) IBOutlet UILabel *longLabel;
- (IBAction)throwMeetBallAction:(id)sender;

@end
