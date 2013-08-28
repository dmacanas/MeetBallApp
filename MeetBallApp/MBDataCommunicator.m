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

@end

@implementation MBDataCommunicator

- (void)executeRequestWithData:(NSDictionary *)data succss:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure {
    NSURL *url = [[NSURL alloc] initWithString:@"http://wsdev.meetball.com/2.0/service.svc/json/Session/Login"];
    self.email = [data objectForKey:@"email"];
    self.password = [data objectForKey:@"password"];
    NSURLRequest *request = [self createURLRequestWithURL:url];
    
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

- (NSURLRequest *)createURLRequestWithURL:(NSURL *)url {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPBody:[self createJSONBodyForRequest]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    return request;
}

- (NSData *)createJSONBodyForRequest {
    NSDictionary *params = @{@"email": self.email, @"password":self.password, @"apikey":@"43f1f673-959b-4abd-8619-027902a3a4a8"};
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

    AFHTTPClient *AFClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [AFClient getPath:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(responseObject){
            NSString *str = [[NSString alloc] initWithData:(NSData *)responseObject encoding:NSUTF8StringEncoding];
            if(completion){
                completion(str);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Get session id failure");
    }];
}

-(void)getUserInfoWithFacebookID:(NSDictionary *)data succss:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure {
    [self getSessionID:^(NSString *sid) {
        NSString *token = [sid stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSString *str = [[NSString alloc] initWithFormat:@"%@?firstName=%@&lastName=%@&facebookId=%@&email=%@&accessToken=417231521721790",token,data[@"first_name"],data[@"last_name"],data[@"id"],data[@"email"]];
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

@end
