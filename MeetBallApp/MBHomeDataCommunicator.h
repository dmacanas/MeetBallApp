//
//  MBHomeDataCommunicator.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/3/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MeetBalls.h"

@interface MBHomeDataCommunicator : NSObject

- (void)getMeetBallContacts:(void (^)(id contacts))success failure:(void (^)(NSError *))failure;
- (void)throwMeetBall:(MeetBalls *)meetBAll success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
- (void)getUpcomingMeetBalls:(void (^)(NSDictionary *items))success failure:(void (^)(NSError *error))failure;

@end
