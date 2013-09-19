//
//  NSManagedObject+MRImportAdditions.h
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/19/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (MRImportAdditions)
+ (NSArray *)MR_importFromArrayAndWait:(NSArray *)listOfObjectData inContext:(NSManagedObjectContext *)contect;
@end
