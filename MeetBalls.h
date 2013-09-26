//
//  MeetBalls.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/3/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MeetBalls : NSObject

@property (strong, nonatomic) NSString *generalLocationZip;
@property (strong, nonatomic) NSString *locationNotes;
@property (assign, nonatomic) BOOL ownerPrivate;
@property (strong, nonatomic) NSString *generalLocationGPX;
@property (assign, nonatomic) NSInteger usageId;
@property (assign, nonatomic) NSInteger ownerId;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSString *generalLocationCity;
@property (strong, nonatomic) NSString *generalLocationAddress1;
@property (strong, nonatomic) NSString *generalLocationState;
@property (strong, nonatomic) NSString *meetBallName;
@property (strong, nonatomic) NSString *meetBallDescription;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSString *locationName;
@property (strong, nonatomic) NSArray *invitees;

@end
