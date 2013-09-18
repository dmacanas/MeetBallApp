//
//  MBDataCommunicator.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 8/28/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBDataCommunicator : NSObject

//POST methods
- (void)executeRequestWithData:(NSDictionary *)data succss:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success failure:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;
-(void)updatePasswordForNewFacebookUser:(NSDictionary *)data succss:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;
-(void)registerNewUser:(NSDictionary *)data succss:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;
-(void)resetPassword:(NSString *)email succss:(void (^)(id JSON))success failure:(void (^)(NSError *error, id JSON))failure;

//GET methods
- (void)getPhoneNumberWithUserInfo:(NSDictionary *)userInfo succss:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success failure:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;
- (void)getUserInfoWithFacebookID:(NSDictionary *)data succss:(void(^)(NSDictionary *JSON))success failure:(void(^)(NSError *error))failure;
- (void)getSessionID:(void(^)(NSString *sid))completion failure:(void(^)(NSError *error))failure;

@end
