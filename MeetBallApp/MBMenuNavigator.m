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
    } else if ([feature isEqualToString:@"Profile"]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"ProfileStoryboard" bundle:nil];
        UIViewController *vc = [sb instantiateInitialViewController];
        [weakVC presentViewController:vc animated:NO completion:nil];
    } else if ([feature isEqualToString:@"Settings"]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"SettingsStoryboard" bundle:nil];
        UIViewController *vc = [sb instantiateInitialViewController];
        [weakVC presentViewController:vc animated:NO completion:nil];
    } else if ([feature isEqualToString:@"Help"]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"HelpStoryboard" bundle:nil];
        UIViewController *vc = [sb instantiateInitialViewController];
        [weakVC presentViewController:vc animated:NO completion:nil];
    }
}

@end
