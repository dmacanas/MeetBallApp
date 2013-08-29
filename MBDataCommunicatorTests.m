//
//  MBDataCommunicatorTests.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 8/28/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBDataCommunicatorTests.h"
#import "MBDataCommunicator.h"

@implementation MBDataCommunicatorTests

- (void)testSessionID {
    MBDataCommunicator *comm = [[MBDataCommunicator alloc] init];
    __block NSString *string;
    [comm getSessionID:^(NSString *sid) {
        string = sid;
        STAssertNotNil(string, @"session id is nill");
    }];
}

@end
