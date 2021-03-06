//
//  MBMeetBallInfoViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/30/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBMeetBallInfoViewController.h"
#import "MBSuitUpCell.h"
#import "MBDataCommunicator.h"
#import "MBCredentialManager.h"

#import <FacebookSDK/FacebookSDK.h>


static NSString * const kAuthentication = @"authenticated";
static NSString * const kAppUserId = @"AppUserId";
static NSString * const kFirstName = @"FirstName";
static NSString * const kFacebookId = @"facebookId";

@interface MBMeetBallInfoViewController () <UITextFieldDelegate>

@property (strong, nonatomic) NSArray *labelArray;
@property (assign, nonatomic) CGSize originalSize;
@property (strong, nonatomic) MBDataCommunicator *commLink;

@end

@implementation MBMeetBallInfoViewController

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
    self.labelArray = [[NSArray alloc] initWithObjects: @"MeetBall Handle", @"Password", nil];
    self.commLink = [[MBDataCommunicator alloc] init];
    [self setupBackgrounds];
	// Do any additional setup after loading the view.
}

- (void)setupBackgrounds {
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ballz.png"]]];
    UIView *v = [[UIView alloc] initWithFrame:self.tableView.frame];
    [v setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ballz.png"]]];
    [self.tableView setBackgroundView:v];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if ([mainLabelText isEqualToString:@"Password:"]) {
        cell.textField.secureTextEntry = YES;
    } else {
        cell.textField.text = self.userInfo[@"facebookId"];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSIndexPath *ind;
    ind = [self.tableView indexPathForCell:(MBSuitUpCell *)[[textField.superview superview] superview]];
    
    if(ind.row + 1 == [self.tableView numberOfRowsInSection:0]){
        [textField resignFirstResponder];
    } else{
        NSIndexPath *ind2 = [NSIndexPath indexPathForItem:(ind.row + 1) inSection:ind.section];
        MBSuitUpCell *cell = (MBSuitUpCell *)[self.tableView cellForRowAtIndexPath:ind2];
        [cell.textField becomeFirstResponder];
    }
    return YES;
}


- (IBAction)suitUpAction:(id)sender {
    
    if([self validateSuitUpCells]){
        self.progressView.hidden = NO;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [self.view endEditing:YES];
        NSString *firstName = self.userInfo[@"firstName"];
        NSString *lastName = self.userInfo[@"lastName"];
        NSString *email = self.userInfo[@"email"];
        NSString *handle = [[(MBSuitUpCell *)[self.view viewWithTag:2] textField] text];
        NSString *phone = self.userInfo[@"phone"];
        NSString *cpwd = [[(MBSuitUpCell *)[self.view viewWithTag:3] textField] text];
        NSDictionary *params = @{@"firstName": firstName, @"lastName":lastName, @"email":email, @"handle":handle,@"phone":phone,@"sessionId":@""};
        NSDictionary *dict = @{@"firstName": firstName, @"lastName":lastName, @"email":email, @"handle":handle,@"phone":phone,@"version":[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]};
        __weak MBMeetBallInfoViewController *weakSelf = self;
        [self.commLink getHandleAvailable:dict success:^(id responseObj) {
            [weakSelf.progressView setProgress:0.3];
            NSDictionary *dict = (NSDictionary *)responseObj;
            if ([dict[@"MbResult"][@"Success"] boolValue]) {
                [weakSelf.commLink registerNewUser:params succss:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                    [weakSelf.progressView setProgress:0.6 animated:YES];
                    if(JSON){
                        if ([[[[(NSDictionary *)JSON objectForKey:@"InsertAppUserJsonResult"] objectForKey:@"MbResult"] objectForKey:@"Success"] boolValue]) {
                            [weakSelf.commLink updatePasswordForNewFacebookUser:@{@"appUserId":[[(NSDictionary *)JSON objectForKey:@"InsertAppUserJsonResult"] objectForKey:@"Id"],@"newPassword":cpwd} succss:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                [weakSelf.progressView setProgress:0.9 animated:YES];
                                [[NSUserDefaults standardUserDefaults] setObject:(NSDictionary *)[(NSArray *)[(NSDictionary *)JSON[@"UpdateAppUserPasswordJsonResult"] objectForKey:@"Items"] objectAtIndex:0][@"AppUserId"] forKey:kAppUserId];
                                [[NSUserDefaults standardUserDefaults] setObject:firstName forKey:kFirstName];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                
                                if(JSON && [[(NSDictionary *)JSON[@"UpdateAppUserPasswordJsonResult"][@"MbResult"] objectForKey:@"Success"] boolValue]){
                                    
                                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                    weakSelf.progressView.hidden = YES;
                                    NSURLCredential *newCreds = [NSURLCredential credentialWithUser:email password:cpwd persistence:NSURLCredentialPersistencePermanent];
                                    [MBCredentialManager saveCredential:newCreds];
                                    
                                    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"homeStoryBoard" bundle:nil];
                                    UIViewController *vc = [sb instantiateInitialViewController];
                                    [weakSelf presentViewController:vc animated:NO completion:nil];
                                } else {
                                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                    weakSelf.progressView.hidden = YES;
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fumble" message:[[[(NSDictionary *)JSON objectForKey:@"UpdateAppUserPasswordJsonResult"] objectForKey:@"MbResult"] objectForKey:@"FriendlyErrorMsg"] delegate:Nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
                                    [alert show];
                                }
                            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                weakSelf.progressView.hidden = YES;
                                NSLog(@"%@", error);
                            }];
                            
                        } else {
                            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                            weakSelf.progressView.hidden = YES;
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fumble" message:[[[(NSDictionary *)JSON objectForKey:@"InsertAppUserJsonResult"] objectForKey:@"MbResult"] objectForKey:@"FriendlyErrorMsg"] delegate:Nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
                            [alert show];
                        }
                    }
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                    NSLog(@"error %@",error);
                }];

            } else {
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                weakSelf.progressView.hidden = YES;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fumble" message:@"That handle is already in use" delegate:Nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
                [alert show];
            }
        } failure:^(NSError *error) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            weakSelf.progressView.hidden = YES;
            NSLog(@"%@", error);
        }];
        
    }
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
    
    return YES;
}

- (IBAction)signUp:(id)sender {
}


- (IBAction)cancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
