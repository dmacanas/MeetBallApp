//
//  MBDataImporter.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 8/28/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBUser.h"

@interface MBDataImporter : NSObject

@property (strong, nonatomic) NSManagedObjectContext *moc;

- (void)getUserWithCredtentials:(NSDictionary *)userInfo success:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success failure:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

- (void)getUserWithFacebookID:(NSDictionary *)userInfo success:(void(^)(NSDictionary *JSON))success failure:(void(^)(NSError *error))failure;

@end
