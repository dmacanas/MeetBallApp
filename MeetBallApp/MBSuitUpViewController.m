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
#import "MBCredentialManager.h"
#import "SVProgressHUD.h"

@interface MBSuitUpViewController ()

@property (strong, nonatomic) NSArray *labelArray;
@property (assign, nonatomic) CGSize originalSize;
@property (strong, nonatomic) MBDataCommunicator *commLink;

@end

static NSString * const kAuthentication = @"authenticated";
static NSString * const kAppUserId = @"AppUserId";
static NSString * const kFirstName = @"FirstName";

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
    
    self.labelArray = [[NSArray alloc] initWithObjects:@"First Name", @"Last Name", @"Email", @"Phone Number", @"MeetBall Handle", @"Password", @"Confirm Password", nil];
    [self.tableView setDelegate: self];
    [self.tableView setDataSource:self];
    self.commLink = [[MBDataCommunicator alloc] init];
    [self setupBackgrounds];
    [self.suitUpButton setBackgroundImage:[[UIImage imageNamed:@"btn-blue.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateNormal];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
//    [self setupButtons];
    // Do any additional setup after loading the view.
}

- (void)setupBackgrounds {
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ballz.png"]]];
    UIView *v = [[UIView alloc] initWithFrame:self.tableView.frame];
    [v setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ballz.png"]]];
    [self.tableView setBackgroundView:v];
}

- (void)setupButtons {
    [self.cancelButton setBackgroundImage:[[UIImage imageNamed:@"btn-cancel"] stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateNormal];
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
    if ([mainLabelText isEqualToString:@"Password:"] || [mainLabelText isEqualToString:@"Confirm Password:"]) {
        cell.textField.secureTextEntry = YES;
    }
    if([cell.textField.placeholder isEqualToString:@"Confirm Password"]){
        [cell.textField setReturnKeyType:UIReturnKeyDone];
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
    if([[[UIDevice currentDevice] systemVersion] isEqualToString:@"6.1"]){
        ind = [self.tableView indexPathForCell:(MBSuitUpCell *)[textField.superview superview]];
    } else{
        ind = [self.tableView indexPathForCell:(MBSuitUpCell *)[[textField.superview superview] superview]];
    }
    
    if(ind.row + 1 == [self.tableView numberOfRowsInSection:0]){
        [textField resignFirstResponder];
        if(self.tableView.frame.size.height != self.originalSize.height){
            [self.tableView setFrame:CGRectMake(0, 0, self.originalSize.width, self.originalSize.height)];
        }
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

- (IBAction)suitUpAction:(id)sender {
    
    if([self validateSuitUpCells]){
        [SVProgressHUD showWithStatus:@"Creating Account" maskType:SVProgressHUDMaskTypeClear];
        NSString *firstName = [[(MBSuitUpCell *)[self.tableView viewWithTag:2] textField] text];
        NSString *lastName = [[(MBSuitUpCell *)[self.tableView viewWithTag:3] textField] text];
        NSString *email = [[(MBSuitUpCell *)[self.tableView viewWithTag:4] textField] text];
        NSString *handle = [[(MBSuitUpCell *)[self.tableView viewWithTag:6] textField] text];
        NSString *phone = [[(MBSuitUpCell *)[self.tableView viewWithTag:5] textField] text];
        NSString *cpwd = [[(MBSuitUpCell *)[self.tableView viewWithTag:8] textField] text];
        NSDictionary *params = @{@"firstName": firstName, @"lastName":lastName, @"email":email, @"handle":handle,@"phone":phone,@"sessionId":@""};
        [self.commLink registerNewUser:params succss:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            if(JSON){
                if ([[[[(NSDictionary *)JSON objectForKey:@"InsertAppUserJsonResult"] objectForKey:@"MbResult"] objectForKey:@"Success"] boolValue]) {
                    //self.email = [data objectForKey:@"AppUserId"];
                    //self.password = [data objectForKey:@"password"];
                    [self.commLink updatePasswordForNewFacebookUser:@{@"AppUserId":[[(NSDictionary *)JSON objectForKey:@"InsertAppUserJsonResult"] objectForKey:@"Id"],@"password":cpwd} succss:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                        NSLog(@"%@",JSON);
                        [[NSUserDefaults standardUserDefaults] setObject:[[(NSDictionary *)JSON objectForKey:@"InsertAppUserJsonResult"] objectForKey:@"Id"] forKey:kAppUserId];
                        [[NSUserDefaults standardUserDefaults] setObject:firstName forKey:kFirstName];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        if(JSON && [[(NSDictionary *)JSON[@"UpdateAppUserPasswordJsonResult"][@"MbResult"] objectForKey:@"Success"] boolValue]){
                            [SVProgressHUD dismiss];
                            NSURLCredential *newCreds = [NSURLCredential credentialWithUser:email password:cpwd persistence:NSURLCredentialPersistencePermanent];
                            [MBCredentialManager saveCredential:newCreds];
                            
                            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"homeStoryBoard" bundle:nil];
                            UIViewController *vc = [sb instantiateInitialViewController];
                            [self presentViewController:vc animated:NO completion:nil];
                        }
                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                        NSLog(@"%@", error);
                    }];

                }
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            NSLog(@"error %@",error);
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
    
    NSString *pwd = [[(MBSuitUpCell *)[self.tableView viewWithTag:7] textField] text];
    NSString *cpwd = [[(MBSuitUpCell *)[self.tableView viewWithTag:8] textField] text];
    if(![pwd isEqualToString:cpwd]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Passwords don't match" message:nil delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
