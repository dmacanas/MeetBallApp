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

@interface MBSettingsViewController () <MBMenuViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) MBMenuView *menu;
@property (assign, nonatomic) BOOL isShowingMenu;
@property (strong, nonatomic) NSArray *sectionHeaderArray;
@property (strong, nonatomic) NSArray *sectionValueArray;

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
    self.sectionHeaderArray = [NSArray arrayWithObjects:@"Home Screen Settings", @"Sharing Settings", @"Notification Settings", nil];
    self.sectionValueArray = [NSArray arrayWithObjects:@[@"Friend Sorting", @"Sub-heading Sorting"], @[@"My MeetBalls", @"Location"], @[@"Push Notifications", @"Text Messages", @"Email"], nil];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sectionHeaderArray objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellId";
    NSArray *array = [self.sectionValueArray objectAtIndex:indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    cell.textLabel.text = [array objectAtIndex:indexPath.row];
    [cell.textLabel setTextColor:[UIColor darkGrayColor]];
    
    if (indexPath.section == 2) {
        UISwitch *swtch = [[UISwitch alloc] init];
        cell.accessoryView = swtch;
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.sectionValueArray objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionHeaderArray.count;
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

- (IBAction)save:(id)sender {
    
}
@end
