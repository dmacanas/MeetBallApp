//
//  MBPerson.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/17/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBPerson : NSObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *homeEmail;
@property (nonatomic, strong) NSString *workEmail;
@property (nonatomic, strong) NSArray *phoneNumbers;
@property (nonatomic, strong) NSArray *phoneLabels;
@property (nonatomic, strong) NSArray *emailAddresses;
@property (nonatomic, strong) NSArray *emailLabels;

@end
