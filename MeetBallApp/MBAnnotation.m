//
//  MBAnnotation.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/11/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBAnnotation.h"

@implementation MBAnnotation

- (id)initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d reuseId:(NSString *)rid withID:(NSInteger)mbid{
    self = [super init];
    if (self) {
        _title = ttl;
        _coordinate = c2d;
        _reuseId = rid;
        _meetBallId = mbid;
    }
	return self;
}

@end
