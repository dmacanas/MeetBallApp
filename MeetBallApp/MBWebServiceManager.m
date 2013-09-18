//
//  MBWebServiceManager.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/18/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBWebServiceManager.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPRequestOperation.h"


@implementation MBWebServiceManager

+ (NSString *)getPlistForEnvironment {
    NSString *userDefaults = [[NSUserDefaults standardUserDefaults] objectForKey:@"environment"];
    NSString *plist = [NSString stringWithFormat:@"wsresources_%@",userDefaults];
    return plist;
}

+ (NSURL *)createURLForService:(NSString *)webService withURLReplacements:(NSDictionary *)URLReplacements {
    NSDictionary *service = [MBWebServiceManager getWebServiceDictionaryForKey:webService];
    NSMutableDictionary *fullReplacements = [URLReplacements mutableCopy];
    if (service[@"apikey"]) {
        [fullReplacements setObject:service[@"apikey"] forKey:@"apikey"];
    }
    NSURL *url = [NSURL URLWithString:[MBWebServiceManager urlStringWithReplacementsForString:service[@"URL"] withReplacements:fullReplacements]];
    return url;
}

+ (NSString *)urlStringWithReplacementsForString:(NSString *)rawURL withReplacements:(NSDictionary *)replacements{
    __block NSString *urlString = [rawURL copy];
    if (replacements) {
        [replacements enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
            NSString *search = [NSString stringWithFormat:@"{%@}",key];
            NSString *objS = [NSString stringWithFormat:@"%@",obj];
            urlString = [urlString stringByReplacingOccurrencesOfString:search withString:objS];

        }];
    }
    
    return urlString;
}

+ (NSURLRequest *)buildURLRequestForWebService:(NSString *)webService withURLReplacements:(NSDictionary *)URLReplacements withUserInfo:(NSDictionary *)userInfo {
    NSDictionary *service = [MBWebServiceManager getWebServiceDictionaryForKey:webService];
    NSURL *url = [NSURL URLWithString:[MBWebServiceManager urlStringWithReplacementsForString:service[@"URL"] withReplacements:URLReplacements]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:service[@"method"]];
    [request setValue:service[@"Content-Type"] forHTTPHeaderField:@"Content-Type"];
    [request setValue:service[@"Accept"] forHTTPHeaderField:@"Accept"];
    
    NSMutableDictionary *d = [userInfo mutableCopy];
    if (service[@"apikey"]) {
        [d setObject:service[@"apikey"] forKey:@"apikey"];
    }
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:d options:0 error:&jsonError];
    [request setHTTPBody:jsonData];
    
    return request;
}

+ (NSDictionary *)getWebServiceDictionaryForKey:(NSString *)webService {
    NSString *plist = [[NSBundle mainBundle] pathForResource:[MBWebServiceManager getPlistForEnvironment] ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plist];
    return dict[webService];
}

+ (void)AFJSONRequestForWebService:(NSString *)webService URLReplacements:(NSDictionary *)URLReplacements UserInfo:(NSDictionary *)userInfo success:(MBWebServiceSuccessBlock)success failure:(MBWebServiceFailureBlock)failure {
    NSURLRequest *request = [MBWebServiceManager buildURLRequestForWebService:webService withURLReplacements:URLReplacements withUserInfo:userInfo];
    AFJSONRequestOperation *AFRequest = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:success failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failure(request,response,error);
    }];
    
    [AFRequest setJSONReadingOptions:NSJSONReadingMutableContainers | NSJSONReadingAllowFragments];
    [AFRequest start];
}

+ (void)AFHTTPRequestForWebService:(NSString *)webService URLReplacements:(NSDictionary *)URLReplacemeents success:(MBWebServiceSuccessBlock)success failure:(MBWebServiceFailureBlock)failure {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[MBWebServiceManager createURLForService:webService withURLReplacements:URLReplacemeents]];
    [request setHTTPMethod:@"GET"];
    
    AFHTTPRequestOperation *AFRequest = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [AFRequest setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(operation.request, operation.response, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation.request, operation.response, error);
        }
    }];
    [AFRequest start];
}



@end
