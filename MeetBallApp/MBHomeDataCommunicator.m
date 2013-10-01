//
//  MBHomeDataCommunicator.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/3/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBHomeDataCommunicator.h"
#import "MBDataCommunicator.h"
#import "MBWebServiceManager.h"
#import "MBWebServiceConstants.h"
#import "AFJsonRequestOperation.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPClient.h"
#import "MBUser.h"
#import "MBInvitee.h"

static NSString * const kSessionId = @"sessionId";
static NSString * const kAppUserId = @"AppUserId";

@implementation MBHomeDataCommunicator


- (void)getMeetBallContacts:(void (^)(id))success failure:(void (^)(NSError *))failure {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kAppUserId] && [[NSUserDefaults standardUserDefaults] objectForKey:kSessionId]) {
        [MBWebServiceManager AFHTTPRequestForWebService:kWebServiceGetMeetBallFriends URLReplacements:@{@"version":[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"],@"sessionId":[[NSUserDefaults standardUserDefaults] objectForKey:kSessionId],@"appUserId":[[NSUserDefaults standardUserDefaults] objectForKey:kAppUserId]} success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
            if (success) {
                success(responseObject);
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    } else if([[NSUserDefaults standardUserDefaults] objectForKey:kAppUserId] && ![[NSUserDefaults standardUserDefaults] objectForKey:kSessionId]){
        NSDictionary *dict;
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"AppUserId"]) {
            dict = @{@"version": [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"], @"appUserId":[[NSUserDefaults standardUserDefaults] objectForKey:@"AppUserId"]};
        }
        [MBWebServiceManager AFHTTPRequestForWebService:kWebServiceGetSessionId URLReplacements:dict success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
            if (responseObject) {
                NSString *str = [[NSString alloc] initWithData:(NSData *)responseObject encoding:NSUTF8StringEncoding];
                str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                [[NSUserDefaults standardUserDefaults] setObject:str forKey:kSessionId];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [MBWebServiceManager AFHTTPRequestForWebService:kWebServiceGetMeetBallFriends URLReplacements:@{@"version":[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"],@"sessionId":str,@"appUserId":[[NSUserDefaults standardUserDefaults] objectForKey:kAppUserId]} success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
                    if (success) {
                        success(responseObject);
                    }
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    if (failure) {
                        failure(error);
                    }
                }];
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    }
}

- (void)throwMeetBall:(MeetBalls *)meetBAll success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    __weak MBHomeDataCommunicator *weakSelf = self;
    [MBWebServiceManager AFJSONRequestForWebService:kWebServiceCreateNewMeetBall URLReplacements:@{@"version":[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]} UserInfo:@{@"sessionId":[[NSUserDefaults standardUserDefaults] objectForKey:kSessionId], @"meetball":[self createDictionaryWithMeetBall:meetBAll]} success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
        if (responseObject) {
            if ([[(NSDictionary *)responseObject[@"CreateCompleteMeetballWithAcceptedResponsesJsonResult"][@"MbResult"] objectForKey:@"Success"] boolValue]) {
                [MBWebServiceManager AFJSONRequestForWebService:kWebServiceAddInviteesToMeetBall URLReplacements:@{@"version": [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]} UserInfo:[weakSelf buildAddToInviteesUserInfo:meetBAll.invitees meetBallId:[(NSDictionary *)responseObject[@"CreateCompleteMeetballWithAcceptedResponsesJsonResult"] objectForKey:@"Id"]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
                    if (success) {
                        success(responseObject);
                    }
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    if (failure) {
                        failure(error);
                    }
                }];
            }
        }
//        success(success);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        failure(error);
    }];
}

- (NSDictionary *)createDictionaryWithMeetBall:(MeetBalls *)MB {
    double sDate = [MB.startDate timeIntervalSince1970] * 1000;
    sDate -= 600;
    double eDate = [MB.endDate timeIntervalSince1970] * 1000;
    eDate -= 600;

    NSString *usageId = [NSString stringWithFormat:@"%d",MB.usageId];
    NSString *private = [NSString stringWithFormat:@"%d",MB.ownerPrivate];
    NSString *startDate = [NSString stringWithFormat:@"/Date(%1.0f-0600)/",sDate];
    NSString *endDate = [NSString stringWithFormat:@"/Date(%1.0f-0600)/",eDate];
    NSDictionary *meetball = @{@"Name": MB.meetBallName,
                               @"Description":MB.meetBallDescription,
                               @"OwnerId":[[NSUserDefaults standardUserDefaults] objectForKey:kAppUserId],
                               @"UsageId":usageId,
                               @"StartDate":startDate,
                               @"EndDate":endDate,
                               @"LocationNotes":[NSNull null],
                               @"Private":private,
                               @"Invitees":[NSNull null],
                               @"LocationName":MB.locationName,
                               @"GeneralLocationAddress1":MB.generalLocationAddress1,
                               @"GeneralLocationCity":MB.generalLocationCity,
                               @"GeneralLocationState":MB.generalLocationState,
                               @"GeneralLocationZip":MB.generalLocationZip,
                               @"GeneralLocationGpxWkt":MB.generalLocationGPX
                               };
    
    return meetball;
}

- (NSDictionary *)buildAddToInviteesUserInfo:(NSArray *)invitees meetBallId:(NSString *)meetBallId {
    NSDictionary *userInfo = @{@"sessionId" : [[NSUserDefaults standardUserDefaults] objectForKey:kSessionId],
                               @"meetballId" : meetBallId,
                               @"invitees" : @{@"Invitees":[self buildInviteeArray:invitees]}
                               };
    return userInfo;
}

- (NSArray *)buildInviteeArray:(NSArray *)mbInvitees {
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (MBInvitee *i in mbInvitees) {
        NSString *appId = [NSString stringWithFormat:@"%d",i.AppUserId];
        NSDictionary *d = @{@"AppUserId": appId,
                            @"Email":i.Email,
                            @"FacebookId":i.FacebookId,
                            @"FirstName":i.FirstName,
                            @"LastName":i.LastName,
                            @"Mobile":i.Mobile};
        [temp addObject:d];
    }
    
    return (NSArray *)temp;
}

- (void)getUpcomingMeetBalls:(void (^)(NSDictionary *JSON))success failure:(void (^)(NSError *error))failure {
    [MBWebServiceManager AFHTTPRequestForWebService:kWebServiceGetUpcomingMeetBalls URLReplacements:@{@"version":[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"], @"sessionId":[[NSUserDefaults standardUserDefaults] objectForKey:kSessionId], @"appUserId":[[NSUserDefaults standardUserDefaults] objectForKey:kAppUserId]} success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
        if (success) {
            NSError *jsonError;
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&jsonError];
            success(JSON);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end
