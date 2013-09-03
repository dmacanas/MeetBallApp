//
//  MBForgotPasswordViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/3/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBForgotPasswordViewController.h"
#import "MBDataCommunicator.h"
#import "SVProgressHUD.h"

@interface MBForgotPasswordViewController ()

@property (strong, nonatomic) MBDataCommunicator *commLink;

@end

@implementation MBForgotPasswordViewController

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
	// Do any additional setup after loading the view.
    self.commLink = [[MBDataCommunicator alloc] init];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ballz.png"]]];
    [self.resetButton setBackgroundImage:[[UIImage imageNamed:@"btn-blue.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:14] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)resetPassword:(id)sender {
    if(self.emailTextField.text.length > 0){
        [SVProgressHUD showWithStatus:@"Reseting password" maskType:SVProgressHUDMaskTypeClear];
        [self.commLink resetPassword:self.emailTextField.text succss:^(id JSON) {
            if(JSON){
                [SVProgressHUD dismiss];
                if ([[[(NSDictionary *)JSON objectForKey:@"ResetAppUserPasswordJsonResult"][@"MbResult"] objectForKey:@"Success"] boolValue]) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Reset Password" message:@"New login information will be emailed shortly" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    [a show];
                }else {
                    UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Reset Password Error" message:[[(NSDictionary *)JSON objectForKey:@"ResetAppUserPasswordJsonResult"][@"MbResult"] objectForKey:@"FriendlyErrorMsg"] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    [a show];
                }
                
            }
        } failure:^(NSError *error, id JSON) {
            NSLog(@"Reset password error %@", error);
        }];
    }
}
@end
