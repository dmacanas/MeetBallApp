//
//  MBFriendDetailViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 10/10/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBFriendDetailViewController.h"
#import "MBWebServiceConstants.h"
#import "MBWebServiceManager.h"

static NSString * const kAppUserId = @"AppUserId";
static NSString * const kSessionId = @"sessionId";

@interface MBFriendDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *sectionHeaders;
@property (strong, nonatomic) NSString *selection;
@property (assign, nonatomic) NSInteger selectionOption;

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
    if (self.person.firstName.length > 0) {
        [self setTitle:self.person.firstName];
    }else {
        [self setTitle:self.person.lastName];
    }
    
    self.sectionHeaders = @[@"Name", @"Email Address", @"Phone Numbers"];
    [self footerForTable];
    self.selectionOption = 0;
	// Do any additional setup after loading the view.
}

- (void)footerForTable {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 130)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 280, 60)];
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    [label setText:@"Select an Email address or phone number and invite your friends to a MeetBall!"];
    [label setTextColor:[UIColor darkGrayColor]];
    label.numberOfLines = 0;
    [label sizeToFit];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 80, 280, 44)];
    [button setTitle:@"Invite" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor colorWithRed:53/255.0 green:172/255.0 blue:100/255.0 alpha:1.0]];
    [button addTarget:self action:@selector(invite:) forControlEvents:UIControlEventTouchUpInside];
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        self.selectionOption = 1;
        self.selection = [self.person.emailAddresses objectAtIndex:indexPath.row];
    } else if (indexPath.section == 2) {
        self.selectionOption = 2;
        self.selection = [self.person.phoneNumbers objectAtIndex:indexPath.row];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)invite:(id)sender {
    if (self.selectionOption != 0) {
        NSDictionary *dict = @{@"version": [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"], @"appUserId":[[NSUserDefaults standardUserDefaults] objectForKey:@"AppUserId"]};
        NSString *str;
        if (self.selectionOption == 1) {
            NSLog(@"%@", [self setUpDictionary]);
            str = kWebServiceAddFriendByEmail;
        } else if (self.selectionOption == 2) {
            str = kWebServiceAddFriendByPhone;
        }
        
        self.progressView.hidden = NO;
        [self.progressView setProgress:0.7];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        [MBWebServiceManager AFJSONRequestForWebService:str URLReplacements:dict UserInfo:[self setUpDictionary] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
            self.progressView.hidden = YES;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            NSDictionary *dict = (NSDictionary *)responseObject;
            if ([dict[@"InsertFriendWithEmailJsonResult"][@"MbResult"][@"Success"] boolValue]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:[NSString stringWithFormat:@"An invitation has been sent to %@", self.person.firstName] delegate:Nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
                [alert show];
                [self.navigationController popToRootViewControllerAnimated:YES];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fumble" message:dict[@"InsertFriendWithEmailJsonResult"][@"MbResult"][@"FriendlyErrorMsg"] delegate:Nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
                [alert show];
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            self.progressView.hidden = YES;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fumble" message:error.localizedDescription delegate:Nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
            [alert show];
        }];
    }
}

- (NSDictionary *)setUpDictionary{
    NSMutableDictionary *dict = [@{@"appUserId": [[NSUserDefaults standardUserDefaults] objectForKey:kAppUserId], @"sessionId":[[NSUserDefaults standardUserDefaults] objectForKey:kSessionId], @"firstName":self.person.firstName, @"lastName":self.person.lastName} mutableCopy];
    if (self.selectionOption == 1) {
        [dict setObject:self.selection forKey:@"email"];
    } else if (self.selectionOption == 2) {
        NSString *p = [self.selection stringByReplacingOccurrencesOfString:@"(" withString:@""];
        p = [p stringByReplacingOccurrencesOfString:@")" withString:@""];
        p = [p stringByReplacingOccurrencesOfString:@"-" withString:@""];
        p = [p stringByReplacingOccurrencesOfString:@" " withString:@""];
        [dict setObject:p forKey:@"phone"];
    }
    
    return dict;
}
@end
