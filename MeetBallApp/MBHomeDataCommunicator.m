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

static NSString * const kSessionId = @"sessionId";
static NSString * const kAppUserId = @"AppUserId";

@implementation MBHomeDataCommunicator

- (void)getUpcomingMeetBallsWithSuccess:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kAppUserId] && [[NSUserDefaults standardUserDefaults] objectForKey:kSessionId]) {
        [self getUpcomingMeetBallsWithSuccess:success failure:failure];
    }else if([[NSUserDefaults standardUserDefaults] objectForKey:kAppUserId] && ![[NSUserDefaults standardUserDefaults] objectForKey:kSessionId]){
        [self getUpcomingMeetBallsWithNoSessionIDWithSuccess:success failure:failure];
    }
}

- (void)getUpcomingMeetBallsWithSessionIDWithSuccess:(void (^)(NSDictionary *JSON))success failure:(void (^)(NSError *er))failure {
    NSString *appId = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:kAppUserId]];
    NSString *sessId = [[NSUserDefaults standardUserDefaults] objectForKey:kSessionId];
    
    NSString *urlString = [NSString stringWithFormat:@"http://wsdev.meetball.com/2.0/service.svc/json/Meetball/Current/%@?appUserId=%@",sessId,appId];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    AFHTTPRequestOperation *AFRequest = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [AFRequest setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(responseObject){
            if(success){
                NSError* error;
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
                success(json);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Get session id failure");
    }];
    [AFRequest start];
}

-(void)getUpcomingMeetBallsWithNoSessionIDWithSuccess:(void (^)(NSDictionary *JSON))success failure:(void (^)(NSError *er))failure {
    [self getSessionID:^(NSString *sid) {
        NSString *appId = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:kAppUserId]];
        
        NSString *urlString = [NSString stringWithFormat:@"http://wsdev.meetball.com/2.0/service.svc/json/Meetball/Current/%@?appUserId=%@",sid,appId];
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod:@"GET"];
        
        AFHTTPRequestOperation *AFRequest = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [AFRequest setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if(responseObject){
                if(success){
                    NSError* error;
                    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
                    success(json);
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Get session id failure");
        }];
        [AFRequest start];
    }];
}

- (void)getSessionID:(void(^)(NSString *sid))completion {
    NSURL *url = [[NSURL alloc] initWithString:@"http://wsdev.meetball.com/2.0/service.svc/json/Session/GetSessionId?existingId=null&appUserId=-1&apiKey=6FC455D3-6207-4112-9D71-005A6EF96422"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    AFHTTPRequestOperation *AFRequest = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [AFRequest setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(responseObject){
            NSString *str = [[NSString alloc] initWithData:(NSData *)responseObject encoding:NSUTF8StringEncoding];
            str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            if(completion){
                completion(str);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Get session id failure");
    }];
    [AFRequest start];
}

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
        [MBWebServiceManager AFHTTPRequestForWebService:kWebServiceGetSessionId URLReplacements:@{@"version":[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]} success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
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

@end
