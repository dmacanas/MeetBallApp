//
//  MBMenuNavigator.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/12/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBMenuNavigator.h"
#import "MBLandingScreenViewController.h"

@implementation MBMenuNavigator

+ (void)navigateToMenuItem:(NSString *)feature fromVC:(UIViewController *)VC{
    __weak UIViewController *weakVC = VC;
    if ([feature isEqualToString:@"My MeetBalls"]) {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"myMeetBallsStoryBoard" bundle:nil];
            UIViewController *vc = [sb instantiateInitialViewController];
            [weakVC presentViewController:vc animated:NO completion:nil];
    } else if ([feature isEqualToString:@"Team Roster"]) {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"TeamRosterStoryboard" bundle:nil];
            UIViewController *vc = [sb instantiateInitialViewController];
            [weakVC presentViewController:vc animated:NO completion:nil];
    }
//    else if ([feature isEqualToString:@"Home"]) {
//        [weakVC dismissViewControllerAnimated:NO completion:nil];
//    }
}

@end
