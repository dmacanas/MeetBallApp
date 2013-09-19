//
//  MBMathBlock.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/19/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MBMathBlock : NSObject

+ (double)setMeetBallHeading:(CLHeading *)heading toPoint:(CLLocationCoordinate2D)destination userLocation:(CLLocationCoordinate2D)userLocation;
+ (double)getDistanceBetweenUserLocation:(CLLocationCoordinate2D)userLocation andDestination:(CLLocationCoordinate2D)destination;

@end
