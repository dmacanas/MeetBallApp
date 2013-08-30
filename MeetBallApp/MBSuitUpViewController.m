//
//  MBSuitUpViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 8/27/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBSuitUpViewController.h"
#import "MBSuitUpCell.h"

@interface MBSuitUpViewController ()

@property (strong, nonatomic) NSArray *labelArray;

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
	// Do any additional setup after loading the view.
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
    if ([mainLabelText isEqualToString:@"Password:"] || [mainLabelText isEqualToString:@"Confirm Password:"]) {
        cell.textField.secureTextEntry = YES;
    }
    cell.tag = indexPath.row+2;
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)suitUpAction:(id)sender {
    MBSuitUpCell *cell = (MBSuitUpCell *)[self.tableView viewWithTag:2];
    
}
@end
