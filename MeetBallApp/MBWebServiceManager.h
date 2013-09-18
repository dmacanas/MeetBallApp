//
//  MBWebServiceManager.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/18/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <AFNetworking/af

@class AFHTTPRequestOperation;
@class AFJSONRequestOperation;

typedef void (^MBWebServiceSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject);
typedef void (^MBWebServiceFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error);


@interface MBWebServiceManager : NSObject
//Methods do not check for sessionId if it is already in userdefaults, include sessionId into urlreplacements or userinfo dictionaries
/*returns plist file based on nsuserdefaults, implements prod and dev*/
+ (NSString *)getPlistForEnvironment;
//used for http get requests
+ (NSURL *)createURLForService:(NSString *)webService withURLReplacements:(NSDictionary *)URLReplacements;
//takes raw url and returns a formatted string, needs at least version
+ (NSString *)urlStringWithReplacementsForString:(NSString *)rawURL withReplacements:(NSDictionary *)replacements;
//will auto-add apikey if needed to the userinfo object
+ (NSURLRequest *)buildURLRequestForWebService:(NSString *)webService
                           withURLReplacements:(NSDictionary *)URLReplacements
                                  withUserInfo:(NSDictionary *)userInfo;
//JSON POST requests
+ (void)AFJSONRequestForWebService:(NSString *)webService
                   URLReplacements:(NSDictionary *)URLReplacements
                          UserInfo:(NSDictionary *)userInfo
                           success:(MBWebServiceSuccessBlock)success
                           failure:(MBWebServiceFailureBlock)failure;
//HTTP GET requests
+ (void)AFHTTPRequestForWebService:(NSString *)webService
                   URLReplacements:(NSDictionary *)URLReplacemeents
                           success:(MBWebServiceSuccessBlock)success
                           failure:(MBWebServiceFailureBlock)failure;


@end
