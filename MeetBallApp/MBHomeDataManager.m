//
//  MBHomeDataManager.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/25/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBHomeDataManager.h"
#import "MBHomeDataCommunicator.h"
#import "MBMeetBall.h"

@implementation MBHomeDataManager

- (void)getUpcomingMeetBalls:(void (^)(BOOL))completion {
    MBHomeDataCommunicator *communicator = [[MBHomeDataCommunicator alloc] init];
    [communicator getUpcomingMeetBalls:^(NSDictionary *responseObject) {
        [MBMeetBall truncateAll];
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            for (NSDictionary *dict in responseObject[@"Items"]) {
                [MBMeetBall importFromObject:dict];
            }
        } completion:^(BOOL success, NSError *error) {
            completion(success);
        }];
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}
//
- (NSArray *)getActiveMeetBalls:(NSArray *)meetBalls {
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (MBMeetBall *mhb in meetBalls) {
        if ([self isStillActive:mhb.endDate]) {
            [temp addObject:mhb];
        }
    }
    
    return (NSArray *)temp;
}

- (BOOL)isStillActive:(NSString *)fromDateString {
    NSString *d1 = [fromDateString stringByReplacingOccurrencesOfString:@"/Date(" withString:@""];
    NSString *d2 = [d1 stringByReplacingOccurrencesOfString:@")/" withString:@""];
    
    NSArray *a = [d2 componentsSeparatedByString:@"-"];
    
    NSString *time = (NSString *)[a objectAtIndex:0];
    double mSec = [time doubleValue];
    double sec = mSec/1000;
    sec += 600;
    
    NSDate *date = [NSDate date];
    double current = [date timeIntervalSince1970];
    
    return sec > current;
}

@end
