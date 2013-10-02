//
//  MBSuitUpViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 8/27/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBSuitUpViewController.h"
#import "MBSuitUpCell.h"
#import "MBDataCommunicator.h"
#import "MBMeetBallInfoViewController.h"
#import "MBCredentialManager.h"
#import "SVProgressHUD.h"

#import <FacebookSDK/FacebookSDK.h>

static NSString * const kAuthentication = @"authenticated";
static NSString * const kAppUserId = @"AppUserId";
static NSString * const kFirstName = @"FirstName";
static NSString * const kFacebookId = @"facebookId";

@interface MBSuitUpViewController ()

@property (strong, nonatomic) NSArray *labelArray;
@property (assign, nonatomic) CGSize originalSize;
@property (strong, nonatomic) MBDataCommunicator *commLink;

@end



@implementation MBSuitUpViewController

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
    
    self.labelArray = [NSArray arrayWithObjects:@"First Name", @"Last Name", @"Email", @"Phone Number", nil];
    [self.tableView setDelegate: self];
    [self.tableView setDataSource:self];
    self.commLink = [[MBDataCommunicator alloc] init];
    [self setupBackgrounds];

}

- (void)setupBackgrounds {
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ballz.png"]]];
    UIView *v = [[UIView alloc] initWithFrame:self.tableView.frame];
    [v setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ballz.png"]]];
    [self.tableView setBackgroundView:v];
}


-(void)viewDidAppear:(BOOL)animated {
    self.originalSize = self.tableView.frame.size;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.labelArray.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID = @"SuitUpCell";
    MBSuitUpCell *cell = (MBSuitUpCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    
    if(cell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MBSuitUpCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSString *mainLabelText = [[NSString alloc] initWithFormat:@"%@:",[self.labelArray objectAtIndex:indexPath.row]];
    [cell.mainLabel setText:mainLabelText];
    [cell.textField setPlaceholder:[self.labelArray objectAtIndex:indexPath.row]];
    [cell.textField setDelegate:self];
    if (indexPath.row == self.labelArray.count-1) {
        cell.textField.returnKeyType = UIReturnKeyDone;
    }
    if (indexPath.row == 2) {
        cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
    } else {
        cell.textField.keyboardType = UIKeyboardTypeDefault;
    }

    cell.tag = indexPath.row+2;
    
    return cell;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(self.tableView.frame.size.height == self.originalSize.height){
        [self.tableView setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.view.frame.size.height - 200)];
    }
    NSIndexPath *ind = [self.tableView indexPathForCell:(MBSuitUpCell *)[textField.superview superview]];
    [self.tableView scrollToRowAtIndexPath:ind atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    return YES;
}

// add phone number text length limit

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSIndexPath *ind;
    ind = [self.tableView indexPathForCell:(MBSuitUpCell *)[[textField.superview superview] superview]];
    
    if(ind.row + 1 == [self.tableView numberOfRowsInSection:0]){
        [textField resignFirstResponder];
    } else{
        NSIndexPath *ind2 = [NSIndexPath indexPathForItem:(ind.row + 1) inSection:ind.section];
        MBSuitUpCell *cell = (MBSuitUpCell *)[self.tableView cellForRowAtIndexPath:ind2];
        [cell.textField becomeFirstResponder];
        if(cell == nil){
            [self.tableView scrollToRowAtIndexPath:ind2 atScrollPosition:UITableViewScrollPositionNone animated:YES];
        }
    }
    return YES;
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([self validateSuitUpCells]) {
        return YES;
    }
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MBSuitUpCell *fname = (MBSuitUpCell *)[self.view viewWithTag:2];
    MBSuitUpCell *lname = (MBSuitUpCell *)[self.view viewWithTag:3];
    MBSuitUpCell *email = (MBSuitUpCell *)[self.view viewWithTag:4];
    MBSuitUpCell *phone = (MBSuitUpCell *)[self.view viewWithTag:5];

    MBMeetBallInfoViewController *vc = (MBMeetBallInfoViewController *)[segue destinationViewController];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kFacebookId]) {
        vc.userInfo = @{@"firstName": fname.textField.text, @"lastName":lname.textField.text, @"email":email.textField.text, @"phone":phone.textField.text, @"facebookId":[[NSUserDefaults standardUserDefaults] objectForKey:kFacebookId]};
    } else {
        vc.userInfo = @{@"firstName": fname.textField.text, @"lastName":lname.textField.text, @"email":email.textField.text, @"phone":phone.textField.text, @"facebookId":@""};
    }
    
}

- (IBAction)connectFacebook:(id)sender {
    UISwitch *sw = sender;
    FBSession *session = [[FBSession alloc] init];
    [FBSession setActiveSession:session];
    __weak MBSuitUpViewController *weakSelf = self;
    [session openWithBehavior:FBSessionLoginBehaviorWithFallbackToWebView completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        MBSuitUpCell *fname = (MBSuitUpCell *)[weakSelf.view viewWithTag:2];
        MBSuitUpCell *lname = (MBSuitUpCell *)[weakSelf.view viewWithTag:3];
        MBSuitUpCell *email = (MBSuitUpCell *)[weakSelf.view viewWithTag:4];
        if (status == FBSessionStateOpen && sw.isOn) {
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                NSDictionary *dict = (NSDictionary *)result;
                fname.textField.text = dict[@"first_name"];
                lname.textField.text = dict[@"last_name"];
                email.textField.text = dict[@"email"];
                [[NSUserDefaults standardUserDefaults] setObject:dict[@"username"] forKey:kFacebookId];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }];
        } else {
            fname.textField.text = @"";
            lname.textField.text = @"";
            email.textField.text = @"";
        }

    }];
}

- (BOOL)validateSuitUpCells{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 2; i < self.labelArray.count+2; i++){
        MBSuitUpCell *cell = (MBSuitUpCell *)[self.tableView viewWithTag:i];
        if (cell.textField.text.length == 0) {
            [array addObject:cell.textField.placeholder];
        }
    }
    
    if(array.count > 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter all of your information" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    
    //add alpha and numeric regex checks
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
