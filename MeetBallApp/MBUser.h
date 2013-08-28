//
//  MBUser.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 8/28/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MBUser : NSManagedObject

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *facebookID;
@property (strong, nonatomic) NSString *meetBallHandle;
@property (strong, nonatomic) NSString *meetBallID;

@end
