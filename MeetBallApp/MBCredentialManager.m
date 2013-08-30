//
//  MBCredentialManager.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 8/30/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBCredentialManager.h"

static NSString * const kHost = @"meetball.com";

@implementation MBCredentialManager

+(void)saveCredential:(NSURLCredential *)credential {
    if (credential == nil) {
        return;
    }

    [[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential:credential forProtectionSpace:[MBCredentialManager defaultSpace]];
}

+(NSURLCredential *)defaultCredential {
    return [[NSURLCredentialStorage sharedCredentialStorage] defaultCredentialForProtectionSpace:[MBCredentialManager defaultSpace]];
}


+(NSURLProtectionSpace *)defaultSpace {
    NSURLProtectionSpace *space = [[NSURLProtectionSpace alloc] initWithHost:kHost port:0 protocol:@"https" realm:nil authenticationMethod:nil];
    return space;
}

+(void)clearCredentials{
    if([MBCredentialManager defaultCredential]){
        [[NSURLCredentialStorage sharedCredentialStorage] removeCredential:[MBCredentialManager defaultCredential] forProtectionSpace:[MBCredentialManager defaultSpace]];
    }
}


@end
