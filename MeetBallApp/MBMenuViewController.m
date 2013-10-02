//
//  MBMenuViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 10/2/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBMenuViewController.h"
#import "MBMenuView.h"

@interface MBMenuViewController () <MBMenuViewDelegate>

@property (strong, nonatomic) MBMenuView *menu;

@end

@implementation MBMenuViewController

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
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"MBMenuView" owner:self options:nil];
    self.menu = [array objectAtIndex:0];
    self.menu.delegate = self;
    [self.view addSubview:self.menu];
    // Do any additional setup after loading the view from its nib.
}

- (void)didSelectionMenuItem:(NSString *)item {
    NSLog(@"menu");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
