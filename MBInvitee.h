//
//  MBInvitee.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/24/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBInvitee : NSObject

@property (strong, nonatomic) NSString *FirstName;
@property (strong, nonatomic) NSString *LastName;
@property (strong, nonatomic) NSString *Email;
@property (assign, nonatomic) NSInteger AppUserId;
@property (strong, nonatomic) NSString *FacebookId;
@property (strong, nonatomic) NSString *Mobile;

- (id)initWithFristName:(NSString *)fn lastName:(NSString *)ln email:(NSString *)email Id:(NSInteger)Id;

@end
