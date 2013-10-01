//
//  MBComment.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/27/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBComment : NSObject

@property (strong, nonatomic) NSDate *commentDate;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *comment;
@property (assign, nonatomic) NSInteger appUserId;
@end
