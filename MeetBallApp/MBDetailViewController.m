//
//  MBDetailViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 10/4/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBDetailViewController.h"
#import "MBWebServiceConstants.h"
#import "MBWebServiceManager.h"
#import "MBInvitee.h"

static NSString * const kSessionId = @"sessionId";

@interface MBDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableIndexSet *expandedSections;
@property (strong, nonatomic) NSMutableArray *inviteeArray;
@property (strong, nonatomic) NSArray *sectionArray;
@property (strong, nonatomic) NSArray *dateArray;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) UIDatePicker *picker;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (assign, nonatomic) BOOL isExpanded;
@property (assign, nonatomic) BOOL isEditing;
@end

@implementation MBDetailViewController

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
    self.expandedSections = [[NSMutableIndexSet alloc] init];
    self.inviteeArray = [[NSMutableArray alloc] init];
    self.picker = [[UIDatePicker alloc] init];
    self.sectionArray = @[@"Information", @"Invited Friends"];
    self.startDate = [self dateFromString:self.meetBall.startDate];
    self.endDate = [self dateFromString:self.meetBall.endDate];
    self.dateArray = @[[self dateFromMeetBallDate:self.meetBall.startDate], [self dateFromMeetBallDate:self.meetBall.endDate]];
    [self getMeetBallInvitees];
	// Do any additional setup after loading the view.
}

- (void)getMeetBallInvitees {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *meetballId = [NSString stringWithFormat:@"%d",self.meetBall.meetBallId];
    NSDictionary *dict = @{@"version": [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"], @"sessionId":[[NSUserDefaults standardUserDefaults] objectForKey:kSessionId], @"meetballId":meetballId};
    __weak MBDetailViewController *weakSelf = self;
    [MBWebServiceManager AFHTTPRequestForWebService:kWebServiceGetMeetBallInvitees URLReplacements:dict success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (responseObject) {
            NSError *err;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&err];
            [weakSelf createInvitees:dict[@"Items"]];
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSLog(@"%@", error);
    }];
}

- (void)createInvitees:(NSArray *)array {
    for (NSDictionary *dict in array) {
        MBInvitee *i = [[MBInvitee alloc] init];
        i.FirstName = dict[@"FirstName"];
        i.LastName = dict[@"LastName"];
        i.Email = dict[@"Email"];
        i.AppUserId = [dict[@"AppUserId"] integerValue];
        i.FacebookId = dict[@"FacebookId"];
        [self.inviteeArray addObject:i];
    }
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"Start Date: %@",[self dateFormatWithDate:self.startDate]];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = [NSString stringWithFormat:@"End Date: %@",[self dateFormatWithDate:self.endDate]];
        }
        if (indexPath.row == 1 && self.selectedIndexPath.row == 0 && self.selectedIndexPath) {
            cell.textLabel.text = @"";
            [self.picker setDate:self.startDate];
            [cell addSubview:self.picker];
            [cell setAccessibilityLabel:@"StartDate"];
        } else if (indexPath.row == 2 && self.selectedIndexPath.row == 1) {
            cell.textLabel.text = @"";
            [self.picker setDate:self.endDate];
            [cell addSubview:self.picker];
            [cell setAccessibilityLabel:@"EndDate"];
        }
    }else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row != self.inviteeArray.count) {
            MBInvitee *i = [self.inviteeArray objectAtIndex:indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", i.FirstName, i.LastName];
            cell.detailTextLabel.text = i.Email;
        }
        if (self.isEditing && indexPath.row == self.inviteeArray.count) {
            cell.textLabel.text = @"Invite more friends...";
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1 && self.selectedIndexPath.row == 0 && self.selectedIndexPath) {
        return 216;
    } else if (indexPath.row == 2 && self.selectedIndexPath.row == 1){
        return 216;
    }
    
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.expandedSections containsIndex:section]) {
        if (section == 0) {
            return 3;
        }
    }
    
    if (self.isEditing && section == 1) {
        return self.inviteeArray.count + 1;
    }
    
    if (section == 0) {
        return 2;
    } else {
        return self.inviteeArray.count;
    }
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sectionArray objectAtIndex:section];
}

- (NSDate *)dateFromString:(NSString *)fromDateString {
    NSString *d1 = [fromDateString stringByReplacingOccurrencesOfString:@"/Date(" withString:@""];
    NSString *d2 = [d1 stringByReplacingOccurrencesOfString:@")/" withString:@""];
    
    NSArray *a = [d2 componentsSeparatedByString:@"-"];
    
    NSString *time = (NSString *)[a objectAtIndex:0];
    double mSec = [time doubleValue];
    double sec = mSec/1000;
    sec += 600;
    
    return [NSDate dateWithTimeIntervalSince1970:sec];
}

- (NSString *)dateFromMeetBallDate:(NSString *)dateString {
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"MM/dd HH:mm"];
    NSString *string = [df stringFromDate:(NSDate *)[self dateFromString:dateString]];
    return string;
}

- (NSString *)dateFormatWithDate:(NSDate *)date {
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"MM/dd HH:mm"];
    NSString *string = [df stringFromDate:date];
    return string;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // only first row toggles exapand/collapse
    if (self.isEditing) {
        if (indexPath.section == 0) {
            [self datePickerUpdatesFor:tableView indexPath:indexPath];
        } else {
            
        }
    }
}

- (void)inviteeUpdateInTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {

}

- (void)datePickerUpdatesFor:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.selectedIndexPath) {
        if (indexPath.row != self.selectedIndexPath.row) {
            return;
        }
    }
    [self.tableView beginUpdates];
    self.selectedIndexPath = indexPath;
    NSInteger section = indexPath.section;
    BOOL currentlyExpanded = [self.expandedSections containsIndex:section];
    
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    if (currentlyExpanded)
    {
        [self.expandedSections removeIndex:section];
        self.isExpanded = NO;
        self.selectedIndexPath = nil;
    }
    else
    {
        self.isExpanded = YES;
        [self.expandedSections addIndex:section];
    }
    
    if (currentlyExpanded)
    {
        if (indexPath.row == 1) {
            self.endDate = self.picker.date;
        } else {
            self.startDate = self.picker.date;
        }
        [self.picker removeFromSuperview];
        NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:section];
        [tmpArray addObject:tmpIndexPath];
        [tableView deleteRowsAtIndexPaths:tmpArray
                         withRowAnimation:UITableViewRowAnimationTop];
//        [tableView reloadData];
    }
    else
    {
        NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:section];
        [tmpArray addObject:tmpIndexPath];
        [tableView insertRowsAtIndexPaths:tmpArray
                         withRowAnimation:UITableViewRowAnimationTop];
    }
    
    [self.tableView endUpdates];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)editing:(id)sender {
    self.isEditing = !self.isEditing;
    if (!self.isEditing) {
        [self.editButton setTitle:@"Edit"];

        [self.tableView beginUpdates];
        if (self.isExpanded) {
            [self collapseExtraCellIfExpanded];
        }
        [self removeAddInviteRow];
        [self.tableView endUpdates];
    } else {
        [self.editButton setTitle:@"Done"];
        [self insertInviteRow];
    }
    
}

- (void)collapseExtraCellIfExpanded {
    self.isExpanded = NO;
    [self.expandedSections removeIndex:self.selectedIndexPath.section];
    NSIndexPath *tmp = [NSIndexPath indexPathForRow:self.selectedIndexPath.row+1 inSection:self.selectedIndexPath.section];
    NSArray *ar = @[tmp];
    [self.tableView deleteRowsAtIndexPaths:ar withRowAnimation:UITableViewRowAnimationTop];
    self.selectedIndexPath = nil;
}

- (void)removeAddInviteRow {
    NSMutableArray *tmpArray = [NSMutableArray array];
    NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:self.inviteeArray.count inSection:1];
    [tmpArray addObject:tmpIndexPath];
    [self.tableView deleteRowsAtIndexPaths:tmpArray withRowAnimation:UITableViewRowAnimationTop];
}

- (void)insertInviteRow {
    [self.tableView beginUpdates];
    NSMutableArray *tmpArray = [NSMutableArray array];
    NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:self.inviteeArray.count inSection:1];
    [tmpArray addObject:tmpIndexPath];
    [self.tableView insertRowsAtIndexPaths:tmpArray withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
}
@end
