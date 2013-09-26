//
//  MBHomeDataManager.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/25/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBHomeDataManager : NSObject

- (void)getUpcomingMeetBalls:(void (^)(BOOL))completion;
- (NSArray *)getActiveMeetBalls:(NSArray *)meetBalls;

@end
