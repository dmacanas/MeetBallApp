//
//  MBViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 8/27/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBLandingScreenViewController.h"
#import "SVProgressHUD.h"

@interface MBLandingScreenViewController ()

@end

static NSString * const kAuthentication = @"authenticated";

@implementation MBLandingScreenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self.toolBar setBackgroundImage:[UIImage imageNamed:@"toolbar"] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ballz.png"]]];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kAuthentication]){
        __weak MBLandingScreenViewController *weakSelf = self;
//        [SVProgressHUD showWithStatus:@"Loading Profile" maskType:SVProgressHUDMaskTypeClear];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"homeStoryBoard" bundle:[NSBundle mainBundle]];
        UIViewController *vc = [sb instantiateInitialViewController];
        [weakSelf presentViewController:vc animated:NO completion:nil];
    }
}

@end
