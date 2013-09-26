//
//  MBMeetBall.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/25/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface MBMeetBall : NSManagedObject

@property (strong, nonatomic) NSString *generalLocationZip;
@property (strong, nonatomic) NSString *locationNotes;
@property (assign, nonatomic) BOOL ownerPrivate;
@property (strong, nonatomic) NSString *generalLocationGPX;
@property (strong, nonatomic) NSString *ownersName;
@property (assign, nonatomic) NSInteger meetBallId;
@property (assign, nonatomic) NSInteger usageId;
@property (assign, nonatomic) NSInteger ownerId;
@property (assign, nonatomic) NSInteger facebookId;
@property (strong, nonatomic) NSString *startDate;
@property (strong, nonatomic) NSString *generalLocationCity;
@property (strong, nonatomic) NSString *generalLocationAddress1;
@property (strong, nonatomic) NSString *generalLocationAddress2;
@property (strong, nonatomic) NSString *generalLocationState;
@property (strong, nonatomic) NSString *generalLocationPhone;
@property (strong, nonatomic) NSString *meetBallName;
@property (strong, nonatomic) NSString *meetBallDescription;
@property (assign, nonatomic) BOOL isPrivate;
@property (assign, nonatomic) NSInteger ownerSharingId;
@property (assign, nonatomic) NSInteger responseId;
@property (strong, nonatomic) NSString *specificLocationGPX;
@property (strong, nonatomic) NSString *endDate;
@property (strong, nonatomic) NSString *locationName;

@end
