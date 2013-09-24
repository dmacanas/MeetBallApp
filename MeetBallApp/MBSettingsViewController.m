//
//  MBSettingsViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/23/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBSettingsViewController.h"
#import "MBMenuNavigator.h"
#import "MBMenuView.h"

@interface MBSettingsViewController () <MBMenuViewDelegate>

@property (strong, nonatomic) MBMenuView *menu;
@property (assign, nonatomic) BOOL isShowingMenu;

@end

@implementation MBSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setUpMenu
{
	// Do any additional setup after loading the view.
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"MBMenuView" owner:self options:nil];
    self.menu = [array objectAtIndex:0];
    self.menu.delegate = self;
    [self.menuContainer addSubview:self.menu];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpMenu];
}

- (void)didSelectionMenuItem:(NSString *)item {
    self.isShowingMenu = NO;
    self.menuContainer.hidden = YES;
    self.blurView.hidden = YES;
    if ([item isEqualToString:@"Settings"]) {
        return;
    }
    
    [self dismissViewControllerAnimated:NO completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"navigate" object:item];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showMenu:(id)sender {
    if (self.isShowingMenu) {
        self.menuContainer.hidden = YES;
        self.blurView.hidden = YES;
        self.isShowingMenu = !self.isShowingMenu;
    } else {
        [self.menu createBlurViewInView:self.view forImageView:self.blurView];
        self.menuContainer.hidden = NO;
        self.blurView.hidden = NO;
        self.isShowingMenu = !self.isShowingMenu;
    }
}
@end
