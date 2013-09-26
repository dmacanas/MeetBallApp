//
//  MBAnnotation.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/11/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MBAnnotation : NSObject <MKAnnotation> 

@property (nonatomic, copy) NSString *title;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *reuseId;
@property (nonatomic, readonly) NSInteger meetBallId;

- (id)initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d reuseId:(NSString *)rid withID:(NSInteger)mbid;

@end
