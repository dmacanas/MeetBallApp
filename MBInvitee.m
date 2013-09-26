//
//  MBInvitee.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/24/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBInvitee.h"

@implementation MBInvitee

- (id)initWithFristName:(NSString *)fn lastName:(NSString *)ln email:(NSString *)email Id:(NSInteger)Id {
    self = [super init];
    if (self) {
        _FirstName = fn;
        _LastName = ln;
        _Email = email;
        _AppUserId = Id;
    }
    
    return self;
}

@end
