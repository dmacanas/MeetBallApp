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
    
    self.labelArray = [[NSArray alloc] initWithObjects:@"First Name", @"Last Name", @"Email", @"Phone Number", @"MeetBall Handle", @"Password", @"Confirm Password", nil];
    [self.tableView setDelegate: self];
    [self.tableView setDataSource:self];
    self.commLink = [[MBDataCommunicator alloc] init];
	// Do any additional setup after loading the view.
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
        [self.tableView setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.view.frame.size.height - 216)];
    }
    NSIndexPath *ind = [self.tableView indexPathForCell:(MBSuitUpCell *)[textField.superview superview]];
    [self.tableView scrollToRowAtIndexPath:ind atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSIndexPath *ind = [self.tableView indexPathForCell:(MBSuitUpCell *)[textField.superview superview]];
    
    if(ind.row + 1 == [self.tableView numberOfRowsInSection:0]){
        [self.tableView endEditing:YES];
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
        __weak MBSuitUpViewController *weakSelf = self;
        __block NSString *firstName = [[(MBSuitUpCell *)[self.tableView viewWithTag:2] textField] text];
        __block NSString *lastName = [[(MBSuitUpCell *)[self.tableView viewWithTag:3] textField] text];
        __block NSString *email = [[(MBSuitUpCell *)[self.tableView viewWithTag:4] textField] text];
        __block NSString *handle = [[(MBSuitUpCell *)[self.tableView viewWithTag:6] textField] text];
        __block NSString *phone = [[(MBSuitUpCell *)[self.tableView viewWithTag:5] textField] text];
        [self.commLink getSessionID:^(NSString *sid) {
            if(sid){
                //actual user registration
                NSDictionary *params = @{@"firstName": firstName, @"lastName":lastName, @"email":email, @"handle":handle,@"phone":phone,@"sessionId":[sid stringByReplacingOccurrencesOfString:@"\"" withString:@""]};
                [weakSelf completionBlock:params];
            }
        }];
    }
}

- (void)completionBlock:(NSDictionary *)data {
    
    __weak MBSuitUpViewController *weakSelf = self;
    [self.commLink registerNewUser:data succss:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if ([[(NSDictionary *)JSON[@"InsertAppUserJsonResult"][@"MbResult"] objectForKey: @"Success"] boolValue]){
            NSDictionary *data = @{@"AppUserId": @"",@"password":@""};
//            [weakSelf.commLink updatePasswordForNewFacebookUser:data succss:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//                NSLog(@"JSON %@", JSON);
//            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//                NSLog(@"Error %@ %s", error, __PRETTY_FUNCTION__);
//            }];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Error %@ %s", error, __PRETTY_FUNCTION__);
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
