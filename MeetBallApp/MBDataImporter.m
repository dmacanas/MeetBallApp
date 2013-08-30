//
//  MBDataImporter.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 8/28/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBDataImporter.h"
#import "MBDataCommunicator.h"
#import "NSManagedObjectContext+MagicalThreading.h"
#import "MagicalRecordShorthand.h"
#import "NSManagedObject+MagicalFinders.h"
#import "MagicalRecord+Actions.h"

@implementation MBDataImporter

- (void)getUserWithCredtentials:(NSDictionary *)userInfo success:(void (^)(NSURLRequest *, NSHTTPURLResponse *, id))success failure:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id))failure{
    MBDataCommunicator *comm = [[MBDataCommunicator alloc] init];
    [comm executeRequestWithData:userInfo succss:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if(JSON) {
            if(success){
                success(request, response, JSON);
            }
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if(failure){
            failure(request, response, error, JSON);
        }
    }];
}

- (void)getUserWithFacebookID:(NSDictionary *)userInfo success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure {
    MBDataCommunicator *comm = [[MBDataCommunicator alloc] init];
    [comm getUserInfoWithFacebookID:userInfo succss:^(NSDictionary *JSON) {
        if(JSON){
            if(success){
                success(JSON);
            }
        }
    } failure:^(NSError *error) {
        if(failure){
            failure(error);
        }
    }];
}

- (void)setUserPasswordForFacebookUser:(NSDictionary *)userInfo success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure {
    MBDataCommunicator *comm = [[MBDataCommunicator alloc] init];
    [comm updatePasswordForNewFacebookUser:userInfo succss:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if(JSON){
            if(success){
                success(JSON);
            }
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if(failure){
            failure(error);
        }
    }];
}

@end
