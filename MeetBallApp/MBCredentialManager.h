//
//  MBCredentialManager.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 8/30/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBCredentialManager : NSObject

+(void)saveCredential:(NSURLCredential *)credential;
+(NSURLCredential *)defaultCredential;
+(void)clearCredentials;

@end
