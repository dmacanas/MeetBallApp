//
//  MBSettingsOptionsViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 10/3/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBSettingsOptionsViewController.h"

static NSString * const kFriendSorting = @"friendSorting";
static NSString * const kMeetBallSorting = @"meetBallSorting";

@interface MBSettingsOptionsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *OptionArray;

@end

@implementation MBSettingsOptionsViewController

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
    //@[@"Friend Sorting", @"MeetBall Sorting"], @[@"My MeetBalls", @"Location"]
    [self setTitle:self.optionTitle];
    if ([self.optionTitle isEqualToString:@"My MeetBalls"]) {
        self.OptionArray = @[@"Just Me", @"My Friends", @"Anyone"];
    } else if ([self.optionTitle isEqualToString:@"Location"]){
        self.OptionArray = @[@"Share", @"Share with Friends", @"Share with Owner", @"Do Not Share"];
    } else if ([self.optionTitle isEqualToString:@"Friend Sorting"]) {
        self.OptionArray = @[@"First Name", @"Last Name"];
    } else {
        self.OptionArray = @[@"Name", @"Owner", @"Start Time", @"End Time"];
    }
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    if ([self.optionTitle isEqualToString:@"Friend Sorting"]) {
        self.selectedOption = [[[NSUserDefaults standardUserDefaults] objectForKey:kFriendSorting] integerValue];
    } else if ([self.optionTitle isEqualToString:@"MeetBall Sorting"]) {
        self.selectedOption = [[[NSUserDefaults standardUserDefaults] objectForKey:kMeetBallSorting] integerValue];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    if (self.selectedOption == indexPath.row +1) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    cell.textLabel.text = [self.OptionArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.OptionArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UITableViewCell *checkedCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedOption - 1 inSection:0]];
    self.selectedOption = indexPath.row + 1;
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    checkedCell.accessoryType = UITableViewCellAccessoryNone;
    [self.delegate changedOptionValue:self.selectedOption key:self.optionTitle];
    if ([self.optionTitle isEqualToString:@"Friend Sorting"]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",self.selectedOption] forKey:kFriendSorting];
    } else if ([self.optionTitle isEqualToString:@"MeetBall Sorting"]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", self.selectedOption] forKey:kMeetBallSorting];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)save:(id)sender {
}
@end
