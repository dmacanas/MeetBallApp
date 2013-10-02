//
//  MBDataCommunicator.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 8/28/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBDataCommunicator.h"
#import "AFJsonRequestOperation.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPClient.h"
#import "MBWebServiceManager.h"
#import "MBWebServiceConstants.h"

@interface MBDataCommunicator()

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSDictionary *dictionary;

@end

static NSString * const kSessionId = @"sessionId";

@implementation MBDataCommunicator

- (void)executeRequestWithData:(NSDictionary *)data succss:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure {
    [MBWebServiceManager AFJSONRequestForWebService:kWebSerivceMeetBallLogin URLReplacements:@{@"version":[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]} UserInfo:data success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
        if (success) {
            success(request, response, responseObject);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        if (failure) {
            failure(request, response, error, nil);
        }
    }];
}

- (NSURLRequest *)createURLRequestWithURL:(NSURL *)url forFacebook:(BOOL)fbUser{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPBody:[self createJSONBodyForRequest:fbUser]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    return request;
}

- (NSData *)createJSONBodyForRequest:(BOOL)forFacebook{
    NSDictionary *params;
    if(forFacebook) {
        params = @{@"appUserId": self.email, @"oldPassword":[NSNull null], @"newPassword":self.password, @"apikey":@"6FC455D3-6207-4112-9D71-005A6EF96422"};
    }else{
        params = @{@"email": self.email, @"password":self.password, @"apikey":@"6FC455D3-6207-4112-9D71-005A6EF96422"};
    }
    
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&jsonError];
    
    return jsonData;
}

- (void)handleLoginFailureWithError:(NSString *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:error delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
    [alert show];
}

- (void)getPhoneNumberWithUserInfo:(NSDictionary *)userInfo succss:(void (^)(NSURLRequest *, NSHTTPURLResponse *, id))success failure:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id))failure {
    
}

- (void)getSessionID:(void(^)(NSString *sid))completion failure:(void(^)(NSError *error))failure{
    NSDictionary *dict;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"AppUserId"]) {
        dict = @{@"version": [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"], @"appUserId":[[NSUserDefaults standardUserDefaults] objectForKey:@"AppUserId"]};
    }else {
        dict = @{@"version": [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"], @"appUserId":@"-1"};
    }
    [MBWebServiceManager AFHTTPRequestForWebService:kWebServiceGetSessionId URLReplacements:dict success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
        if(responseObject){
            NSString *str = [[NSString alloc] initWithData:(NSData *)responseObject encoding:NSUTF8StringEncoding];
            str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            if(completion){
                completion(str);
            }
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

-(void)getUserInfoWithFacebookID:(NSDictionary *)data succss:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure {
        [MBWebServiceManager AFJSONRequestForWebService:kWebServiceGetUserWithFacebookId URLReplacements:@{@"version":[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]} UserInfo:data success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
            if (success) {
                success(responseObject);
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
}

-(void)updatePasswordForNewFacebookUser:(NSDictionary *)data succss:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure {
    NSMutableDictionary *dict = [data mutableCopy];
    [dict setObject:[NSNull null] forKey:@"oldPassword"];
    [MBWebServiceManager AFJSONRequestForWebService:kWebServiceUpdatePassword URLReplacements:@{@"version":[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"],@"appUserId":data[@"appUserId"]} UserInfo:dict success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
        if (success) {
            success(request, response, responseObject);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        if (failure) {
            failure(request, response, error, nil);
        }
    }];
}

-(void)registerNewUser:(NSDictionary *)data succss:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure {
    [self getSessionID:^(NSString *sid) {
        NSMutableDictionary *d = [data mutableCopy];
        [d setValue:sid forKey:@"sessionId"];
        
        [MBWebServiceManager AFJSONRequestForWebService:kWebServiceCreateNewUser URLReplacements:@{@"version":[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]} UserInfo:d success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
            if (success) {
                success(request, response, responseObject);
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            if (failure) {
                failure(request, response, error, nil);
            }
        }];
    } failure:^(NSError *error) {
        if (failure) {
            failure(nil, nil, error, nil);
        }
    }];
}

- (NSURLRequest *)createURLRequestForNewUserWithURL:(NSURL *)url withInfo:(NSDictionary *)info{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPBody:[self createJSONBodyForNewUser:info]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    return request;
}

- (NSData *)createJSONBodyForNewUser:(NSDictionary *)data{
    NSDictionary *params = @{@"firstName": data[@"firstName"], @"lastName":data[@"lastName"], @"email":data[@"email"], @"handle":data[@"handle"],@"phone":data[@"phone"],@"sessionId":data[@"sessionId"]};
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&jsonError];
    
    return jsonData;
}

-(void)resetPassword:(NSString *)email succss:(void (^)(id JSON))success failure:(void (^)(NSError *error, id JSON))failure {
    [self getSessionID:^(NSString *sid) {
        NSDictionary *dict = @{@"email": email,@"sessionId":sid};
        
        [MBWebServiceManager AFJSONRequestForWebService:kWebServiceResetPassword URLReplacements:@{@"version":[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]} UserInfo:dict success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
            if (success) {
                success(responseObject);
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            if (failure) {
                failure(error, nil);
            }
        }];
    } failure:^(NSError *error) {
        if (failure) {
            failure(error, nil);
        }
    }];
}

- (NSURLRequest *)createURLRequestForResetPassword:(NSURL *)url withInfo:(NSDictionary *)info{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info options:0 error:&jsonError];
    [request setHTTPBody:jsonData];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    return request;
}

- (void)getHandleAvailable:(NSDictionary *)userInfo success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    [MBWebServiceManager AFHTTPRequestForWebService:kWebServiceGetIsHandleAvailable URLReplacements:userInfo success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
        if (success) {
            NSError *err;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&err];
            success(json);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end
