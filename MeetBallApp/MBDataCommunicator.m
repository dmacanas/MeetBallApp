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

@interface MBDataCommunicator()

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSDictionary *dictionary;

@end

static NSString * const kSessionId = @"sessionId";

@implementation MBDataCommunicator

- (void)executeRequestWithData:(NSDictionary *)data succss:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure {
    NSURL *url = [[NSURL alloc] initWithString:@"http://wsdev.meetball.com/2.0/service.svc/json/Session/Login"];
    self.email = [data objectForKey:@"email"];
    self.password = [data objectForKey:@"password"];
    NSURLRequest *request = [self createURLRequestWithURL:url forFacebook:NO];
    
    AFJSONRequestOperation *AFRequest = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if(success){
            success(request, response, JSON);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if(failure){
            failure(request, response, error, JSON);
        }
    }];
    
    [AFRequest setJSONReadingOptions:NSJSONReadingMutableContainers | NSJSONReadingAllowFragments];
    [AFRequest start];
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
        params = @{@"appUserId": self.email, @"oldPassword":[NSNull null], @"newPassword":self.password, @"apikey":@"43f1f673-959b-4abd-8619-027902a3a4a8"};
    }else{
        params = @{@"email": self.email, @"password":self.password, @"apikey":@"43f1f673-959b-4abd-8619-027902a3a4a8"};
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

- (void)getSessionID:(void(^)(NSString *sid))completion {
    NSURL *url = [[NSURL alloc] initWithString:@"http://wsdev.meetball.com/2.0/service.svc/json/Session/GetSessionId?existingId=null&appUserId=-1&apiKey=43f1f673-959b-4abd-8619-027902a3a4a8"];
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

-(void)getUserInfoWithFacebookID:(NSDictionary *)data succss:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure {
    [self getSessionID:^(NSString *sid) {
        [[NSUserDefaults standardUserDefaults] setObject:sid forKey:kSessionId];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSString *str = [[NSString alloc] initWithFormat:@"%@?firstName=%@&lastName=%@&facebookId=%@&email=%@&accessToken=417231521721790",sid,data[@"first_name"],data[@"last_name"],data[@"id"],data[@"email"]];
        NSString *urlString = [NSString stringWithFormat:@"http://wsdev.meetball.com/2.0/service.svc/json/AppUser/Facebook/%@",str];
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        AFHTTPClient *AFClient = [[AFHTTPClient alloc] initWithBaseURL:url];
        [AFClient getPath:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if(responseObject){
                NSError* error;
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
                if(success){
                    success(json);
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    }];
}

-(void)updatePasswordForNewFacebookUser:(NSDictionary *)data succss:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure {
    self.email = [data objectForKey:@"AppUserId"];
    self.password = [data objectForKey:@"password"];
    
    NSString *urlString = [NSString stringWithFormat:@"http://wsdev.meetball.com/2.0/service.svc/json/AppUser/Password?appUserId=%@",self.email];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLRequest *request = [self createURLRequestWithURL:url forFacebook:YES];
    
    AFJSONRequestOperation *AFRequest = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if(success){
            success(request, response, JSON);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if(failure){
            failure(request, response, error, JSON);
        }
    }];
    
    [AFRequest waitUntilFinished];
    [AFRequest setJSONReadingOptions:NSJSONReadingMutableContainers | NSJSONReadingAllowFragments];
    [AFRequest start];
}

-(void)registerNewUser:(NSDictionary *)data succss:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure {
    [self getSessionID:^(NSString *sid) {
        [[NSUserDefaults standardUserDefaults] setObject:sid forKey:kSessionId];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString *urlString = [NSString stringWithFormat:@"http://wsdev.meetball.com/2.0/service.svc/json/AppUser"];
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        NSMutableDictionary *d = [data mutableCopy];
        [d setValue:sid forKey:@"sessionId"];
        
        NSURLRequest *request = [self createURLRequestForNewUserWithURL:url withInfo:d];
        
        AFJSONRequestOperation *AFRequest = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            if(success){
                success(request, response, JSON);
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            if(failure){
                failure(request, response, error, JSON);
            }
        }];
        
        [AFRequest setJSONReadingOptions:NSJSONReadingMutableContainers | NSJSONReadingAllowFragments];
        [AFRequest start];
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
        [[NSUserDefaults standardUserDefaults] setObject:sid forKey:kSessionId];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString *urlString = [NSString stringWithFormat:@"http://wsdev.meetball.com/2.0/service.svc/json/AppUser/ResetPassword"];
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        NSDictionary *dict = @{@"email": email,@"sessionId":sid};
        NSURLRequest *request = [self createURLRequestForResetPassword:url withInfo:dict];
        
        AFJSONRequestOperation *AFRequest = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            if(success){
                success(JSON);
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            if(failure){
                failure(error, JSON);
            }
        }];
        
        [AFRequest setJSONReadingOptions:NSJSONReadingMutableContainers | NSJSONReadingAllowFragments];
        [AFRequest start];
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

@end
