//
//  MBFriendDetailViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 10/10/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBFriendDetailViewController.h"

@interface MBFriendDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *sectionHeaders;

@end

@implementation MBFriendDetailViewController

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
    [self setTitle:self.person.firstName];
    self.sectionHeaders = @[@"Name", @"Email Address", @"Phone Numbers"];
    [self footerForTable];
	// Do any additional setup after loading the view.
}

- (void)footerForTable {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 120)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 280, 60)];
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    [label setText:@"Select an Email address or phone number and invite your friends to a MeetBall!"];
    [label setTextColor:[UIColor darkGrayColor]];
    label.numberOfLines = 0;
    [label sizeToFit];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 80, 280, 44)];
    [button setTitle:@"Invite" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor colorWithRed:53/255.0 green:172/255.0 blue:100/255.0 alpha:1.0]];
    
    [view addSubview:label];
    [view addSubview:button];
    [self.tableView setTableFooterView:view];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    if (indexPath.section == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", self.person.firstName, self.person.lastName];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if (indexPath.section == 1) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", [self.person.emailLabels objectAtIndex:indexPath.row],[self.person.emailAddresses objectAtIndex:indexPath.row]];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", [self.person.phoneLabels objectAtIndex:indexPath.row], [self.person.phoneNumbers objectAtIndex:indexPath.row]];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 1:
            return self.person.emailAddresses.count;
        case 2:
            return self.person.phoneNumbers.count;
        default:
            return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sectionHeaders objectAtIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)invite:(id)sender {
}
@end
