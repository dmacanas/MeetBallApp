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
//    NSManagedObjectContext *managedOC = [NSManagedObjectContext MR_contextForCurrentThread];
//    [managedOC setPersistentStoreCoordinator:[NSPersistentStoreCoordinator defaultStoreCoordinator]];
//    [managedOC setUndoManager:nil];
    __weak MBDataImporter *weakSelf = self;
    [comm executeRequestWithData:userInfo succss:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if(JSON) {
//            NSDictionary *d = (NSDictionary *)JSON;
//            if ([[[[d objectForKey:@"LoginAppUserJsonResult"] objectForKey:@"MbResult"] objectForKey:@"Success"] boolValue]) {
//                NSDictionary *user = [[[d objectForKey:@"LoginAppUserJsonResult"] objectForKey:@"Items"] objectAtIndex:0];
//                MBUser *mbuser = [MBUser createEntity];
//                mbuser.firstName = user[@"FirstName"];
//                mbuser.lastName = userInfo[@"LastName"];
//                mbuser.meetBallHandle = user[@"Handle"];
//                mbuser.meetBallID = @"601";
//                mbuser.facebookID = user[@"FacebookId"];
//                mbuser.email = user[@"Email"];
//                mbuser.phoneNumber = @"1234567890";
//                [managedOC saveToPersistentStoreAndWait];
////                [weakSelf storeUser:user inContext:managedOC completion:nil];
//            }
            
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

- (void)storeUser:(NSDictionary *)userInfo inContext:(NSManagedObjectContext *)moc completion:(void(^)())completion{
    MBUser *user = [MBUser createEntity];
    user.firstName = userInfo[@"FirstName"];
    user.lastName = userInfo[@"LastName"];
    user.meetBallHandle = userInfo[@"Handle"];
    user.meetBallID = @"601";
    user.facebookID = userInfo[@"FacebookId"];
    user.email = userInfo[@"Email"];
    user.phoneNumber = @"1234567890";
    [[NSManagedObjectContext MR_contextForCurrentThread] saveWithOptions:MRSaveSynchronously|MRSaveParentContexts completion:^(BOOL success, NSError *error) {
        if(error){
            NSLog(@"error %@",error);
        }
    }];
}

- (void)getPhoneNumbersForInfo:(NSDictionary *)userInfo {
    
}

- (void)getUserWithFacebookID:(NSDictionary *)userInfo success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure {
    MBDataCommunicator *comm = [[MBDataCommunicator alloc] init];
    
    __weak MBDataImporter *weakSelf = self;
    [comm getUserInfoWithFacebookID:userInfo succss:^(NSDictionary *JSON) {
        if(JSON){
            if ([[[JSON objectForKey:@"MbResult"] objectForKey:@"Success"] boolValue]) {
                NSDictionary *user = [[JSON objectForKey:@"Items"] objectAtIndex:0];
                [weakSelf storeUser:user inContext:weakSelf.moc completion:nil];
            }
            
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

@end
