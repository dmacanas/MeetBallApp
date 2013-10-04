//
//  MBMenuNaviagtionViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 10/2/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBMenuNaviagtionViewController.h"
#import "MBMenuDisplayViewController.h"

@interface MBMenuNaviagtionViewController ()

@property (strong, readwrite, nonatomic) MBMenuDisplayViewController *menuViewController;

@end

@implementation MBMenuNaviagtionViewController

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
    self.menuViewController = [[MBMenuDisplayViewController alloc] init];
    self.menuViewController.navigationController = self;
    
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
}

- (void)showMenu
{
    [self.menuViewController presentFromViewController:self animated:YES completion:nil];
}

#pragma mark -
#pragma mark Rotation handling


#pragma mark -
#pragma mark Gesture recognizer

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    [self.menuViewController presentFromViewController:self panGestureRecognizer:sender];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
