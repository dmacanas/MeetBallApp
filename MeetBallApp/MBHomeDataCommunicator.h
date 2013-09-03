//
//  MBHomeDataCommunicator.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/3/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBHomeDataCommunicator : NSObject

- (void)getUpcomingMeetBallsWithSuccess:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure ;

@end
