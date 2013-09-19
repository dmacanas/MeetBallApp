//
//  MBMathBlock.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/19/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBMathBlock.h"

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * 180.0 / M_PI)

@implementation MBMathBlock

+ (double)setMeetBallHeading:(CLHeading *)heading toPoint:(CLLocationCoordinate2D)destination userLocation:(CLLocationCoordinate2D)userLocation{
    double lon = destination.longitude - userLocation.longitude;
    double dlon = degreesToRadians(lon);
    double lat1 = degreesToRadians(userLocation.latitude);
    double lat2 = degreesToRadians(destination.latitude);
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
    return degreesToRadians(hd);
}

+ (double)getDistanceBetweenUserLocation:(CLLocationCoordinate2D)userLocation andDestination:(CLLocationCoordinate2D)destination {
    double R = 6371; // km
    double lat = destination.latitude - userLocation.latitude;
    double dLat = degreesToRadians(lat);
    double lon = destination.longitude - userLocation.longitude;
    double dLon = degreesToRadians(lon);
    double lat1 = degreesToRadians(userLocation.latitude);
    double lat2 = degreesToRadians(destination.latitude);
    
    double a = sin(dLat/2) * sin(dLat/2) + sin(dLon/2) * sin(dLon/2) * cos(lat1) *cos(lat2);
    double c = 2 * atan2(sqrt(a), sqrt(1-a));
    double d = R * c;
    double dft = d * 3280.84;
    return dft;
}

@end
