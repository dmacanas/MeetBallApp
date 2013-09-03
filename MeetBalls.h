//
//  MeetBalls.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/3/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@interface MeetBalls : NSManagedObject

@property (strong, nonatomic) NSString *generalLocationZip;
@property (strong, nonatomic) NSString *locationNotes;
@property (assign, nonatomic) BOOL ownerPrivate;
@property (strong, nonatomic) CLLocation *generalLocationGPX;
@property (strong, nonatomic) NSString *ownersName;
@property (assign, nonatomic) NSInteger *meetBallId;
@property (assign, nonatomic) NSInteger *usageId;
@property (assign, nonatomic) NSInteger *ownerId;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSString *generalLocationCity;
@property (strong, nonatomic) NSString *generalLocationAddress1;
@property (strong, nonatomic) NSString *meetBallName;
@property (strong, nonatomic) NSString *meetBallDescription;
@property (assign, nonatomic) NSInteger *responseId;
@property (strong, nonatomic) CLLocation *specificLocationGPX;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSString *locationName;

@end
