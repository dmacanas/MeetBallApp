//
//  NSManagedObject+MRImportAdditions.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/19/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "NSManagedObject+MRImportAdditions.h"

@implementation NSManagedObject (MRImportAdditions)

+ (NSArray *)MR_importFromArrayAndWait:(NSArray *)listOfObjectData inContext:(NSManagedObjectContext *)contect {
    NSMutableArray *objectIds = [NSMutableArray array];
        [listOfObjectData enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *objectData = (NSDictionary *)obj;
            NSManagedObject *dataObject = [self MR_importFromObject:objectData inContext:contect];
            if ([contect obtainPermanentIDsForObjects:[NSArray arrayWithObject:dataObject] error:nil]) {
                [objectIds addObject:[dataObject objectID]];
            }
        }];
    
    return [self MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"self IN %@",objectIds] inContext:contect];
}

@end
