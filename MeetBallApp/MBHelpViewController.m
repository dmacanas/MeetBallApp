//
//  MBHelpViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/23/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBHelpViewController.h"
#import "MBMenuNavigator.h"
#import "MBMenuNavigationController.h"

@interface MBHelpViewController ()



@end

@implementation MBHelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [self.navigationItem.leftBarButtonItem setTarget:(MBMenuNavigationController *)self.navigationController];
    [self.navigationItem.leftBarButtonItem setAction:@selector(showMenu)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
