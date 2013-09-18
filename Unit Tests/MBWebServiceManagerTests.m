//
//  MBWebServiceManagerTests.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/18/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MBWebServiceManager.h"
#import "MBWebServiceConstants.h"

@interface MBWebServiceManagerTests : XCTestCase

@end

@implementation MBWebServiceManagerTests

- (void)setUp
{
    [super setUp];
    [[NSUserDefaults standardUserDefaults] setObject:@"dev" forKey:@"environment"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testEnvironmentSetUp {
    [[NSUserDefaults standardUserDefaults] setObject:@"prod" forKey:@"environment"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *plist = [MBWebServiceManager getPlistForEnvironment];
    XCTAssertEqualObjects(plist, @"wsresources_prod", @"Not returning correct plist file getting:%@", plist);
    
    [[NSUserDefaults standardUserDefaults] setObject:@"dev" forKey:@"environment"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    plist = [MBWebServiceManager getPlistForEnvironment];
    XCTAssertEqualObjects(plist, @"wsresources_dev", @"Not returning correct plist file getting:%@", plist);
}

- (void)testURLReplacements {
    NSString *rawURL = @"http://wsdev.meetball.com/{version}/service.svc/json/AppUser/Browse/Phone/{sessionId}/?appUserId={appUserId}";
    NSDictionary *dic = @{@"version": @"2.1",@"appUserId":@"123",@"sessionId":@"123456"};
    NSString *url = [MBWebServiceManager urlStringWithReplacementsForString:rawURL withReplacements:dic];
    NSString *urlString = @"http://wsdev.meetball.com/2.1/service.svc/json/AppUser/Browse/Phone/123456/?appUserId=123";
    XCTAssertEqualObjects(url, urlString, @"url replacement keys not being replaced");
}

- (void)testURLForWebService {
    NSDictionary *dic = @{@"version": @"2.1",@"appUserId":@"123",@"sessionId":@"123456"};
    NSString *urlString = @"http://wsdev.meetball.com/2.1/service.svc/json/AppUser/Browse/Phone/123456/?appUserId=123";
    NSURL *comp = [NSURL URLWithString:urlString];
    NSURL *url = [MBWebServiceManager createURLForService:kWebSerivceGetPhoneNumbers withURLReplacements:dic];
    XCTAssertEqualObjects(url, comp, @"URL is not formatted equally");
}

- (void)testAPIKeyReplacement {
    NSDictionary *dic = @{@"version":@"2.1"};
    NSString *urlString = @"http://wsdev.meetball.com/2.1/service.svc/json/Session/GetSessionId?existingId=null&appUserId=-1&apiKey=6FC455D3-6207-4112-9D71-005A6EF96422";
    NSURL *comp = [NSURL URLWithString:urlString];
    NSURL *url = [MBWebServiceManager createURLForService:kWebServiceGetSessionId withURLReplacements:dic];
    XCTAssertEqualObjects(url, comp, @"api key error");
    
    urlString = @"http://wsdev.meetball.com/2.1/service.svc/json/Session/Login";
    comp = [NSURL URLWithString:urlString];
    url = [MBWebServiceManager createURLForService:kWebSerivceMeetBallLogin withURLReplacements:dic];
    XCTAssertEqualObjects(url, comp, @"api key error with no url replacement");
}

- (void)testNullReplacements {
    NSURL *url = [MBWebServiceManager createURLForService:kWebServiceCreateNewUser withURLReplacements:nil];
    XCTAssertNil(url, @"error when given nil replacement, needs version at minimum ");
}

- (void)testBuildingRequest {
    NSDictionary *dict = @{@"version":@"2.1"};
    NSDictionary *userInfo = @{@"email": @"test@mail.com",@"password":@"password"};
    NSURLRequest *request = [MBWebServiceManager buildURLRequestForWebService:kWebSerivceMeetBallLogin withURLReplacements:dict withUserInfo:userInfo];
    
    NSMutableURLRequest *comp = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://wsdev.meetball.com/2.1/service.svc/json/Session/Login"]];
    NSDictionary *info = @{@"email": @"test@mail.com",@"password":@"password",@"apikey":@"6FC455D3-6207-4112-9D71-005A6EF96422"};
    [comp setHTTPMethod:@"POST"];
    [comp setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [comp setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info options:0 error:&jsonError];
    [comp setHTTPBody:jsonData];
    
    XCTAssertEqualObjects(request, comp, @"url request formatting error");
}

@end
