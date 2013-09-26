//
//  MBExtractMeetBallCoordinatesTests.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/25/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <CoreLocation/CoreLocation.h>

@interface MBExtractMeetBallCoordinatesTests : XCTestCase

@end

@implementation MBExtractMeetBallCoordinatesTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testDateExtraction
{
    NSString *rawDate = @"/Date(1380134903703-0500)/";
    NSString *d1 = [rawDate stringByReplacingOccurrencesOfString:@"/Date(" withString:@""];
    NSString *d2 = [d1 stringByReplacingOccurrencesOfString:@")/" withString:@""];
    XCTAssertEqualObjects(d2, @"1380134903703-0500", @"Numbers only");
    
    NSArray *a = [d2 componentsSeparatedByString:@"-"];
    XCTAssertTrue(a.count == 2, @"two components only");
    
    NSString *time = (NSString *)[a objectAtIndex:0];
    double mSec = [time doubleValue];
    double sec = mSec/1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:sec];
    XCTAssertNotNil(date, @"date not formatting");
}

- (void)testDatePassing {
    double endMSec = 1380134903703;
    double endSec = endMSec/1000;
//    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:endSec];
    NSDate *current = [NSDate date];
    double currentSec = [current timeIntervalSince1970];
    
    XCTAssertTrue(currentSec > endSec, @"Times not right");
}

- (void)testPointExtraction
{
    NSString *rawString = @"POINT (-87.69349 42.06436 0)";
    NSString *d1 = [rawString stringByReplacingOccurrencesOfString:@"POINT (" withString:@""];
    NSString *d2 = [d1 stringByReplacingOccurrencesOfString:@")" withString:@""];
    XCTAssertEqualObjects(d2, @"-87.69349 42.06436 0", @"numbers only");
    
    NSArray *a = [d2 componentsSeparatedByString:@" "];
    XCTAssertTrue(a.count == 3, @"not enough components");
    NSString *lon = (NSString *)[a objectAtIndex:0];
    NSString *lat = (NSString *)[a objectAtIndex:1];
//    NSString *alt = (NSString *)[a objectAtIndex:2];
    double longitude = [lon doubleValue];
    double latitude = [lat doubleValue];
    XCTAssertTrue(longitude == -87.69349, @"double format wrong %f", longitude);
    XCTAssertTrue(latitude == 42.06436, @"double format wrong");
}

@end
