//
//  MBEditProfileViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 10/2/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBEditProfileViewController.h"
#import "MBWebServiceConstants.h"
#import "MBWebServiceManager.h"

static NSString * const kAppUserId = @"AppUserId";
static NSString * const kSessionId = @"sessionId";
static NSString * const kPhoneAppId = @"phoneAppId";

@interface MBEditProfileViewController ()

@end

@implementation MBEditProfileViewController

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
    [self setTitle:self.field];
    self.previousTextField.text = self.value;
    if ([self.field isEqualToString:@"Password"]) {
        [self.previousTextField setSecureTextEntry:YES];
        [self.changeTextField setSecureTextEntry:YES];
    } else if ([self.field isEqualToString:@"Phone Number"]) {
        self.previousTextField.keyboardType = UIKeyboardTypePhonePad;
        self.changeTextField.keyboardType = UIKeyboardTypePhonePad;
        if (self.value.length == 0) {
            self.changeTextField.hidden = YES;
            self.previousTextField.placeholder = @"Add a phone number";
        }
    }
    self.previousTextField.placeholder = [NSString stringWithFormat:@"Current %@", self.field];
    self.changeTextField.placeholder = [NSString stringWithFormat:@"New %@", self.field];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)save:(id)sender {
    if ([self.field isEqualToString:@"Password"]) {
        //params = @{@"appUserId": self.email, @"oldPassword":[NSNull null], @"newPassword":self.password, @"apikey":@"6FC455D3-6207-4112-9D71-005A6EF96422"};
        if (self.previousTextField.text.length > 0 && self.changeTextField.text.length > 0) {
            self.progressView.hidden = NO;
            [self.progressView setProgress:0.7 animated:YES];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            NSDictionary *dict = @{@"appUserId": [[NSUserDefaults standardUserDefaults] objectForKey:kAppUserId], @"oldPassword":self.previousTextField.text, @"newPassword":self.changeTextField.text};
            [self communicationMethodURLReplacements:@{@"version":[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"],@"appUserId":[[NSUserDefaults standardUserDefaults] objectForKey:kAppUserId]}  post:dict lookUpKey:@"UpdateAppUserPasswordJsonResult" successMessage:@"Your password has been changed" webService:kWebServiceUpdatePassword];
        } else {
            [self showAlertWithTitle:nil body:@"Please complete all fields"];
        }
    } else if ([self.field isEqualToString:@"Phone Number"]) {
        NSDictionary *dict = @{@"version":[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]};
        if (self.previousTextField.text.length > 0 && self.changeTextField.text.length > 0 && self.changeTextField.hidden == NO) {
            // change default phone number
            self.progressView.hidden = NO;
            [self.progressView setProgress:0.7 animated:YES];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            [self communicationMethodURLReplacements:dict post:@{@"phone": self.changeTextField.text, @"sessionId":[[NSUserDefaults standardUserDefaults] objectForKey:kSessionId], @"phoneId" : [[NSUserDefaults standardUserDefaults] objectForKey:kPhoneAppId]} lookUpKey:@"UpdateAppUserPhoneResult" successMessage:@"Your phone number has been updated" webService:kWebServiceUpdatePhoneNumber];
        } else if (self.previousTextField.text.length > 0 && self.changeTextField.hidden) {
            self.progressView.hidden = NO;
            [self.progressView setProgress:0.7 animated:YES];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            [self communicationMethodURLReplacements:dict post:@{@"phone": self.previousTextField.text, @"sessionId":[[NSUserDefaults standardUserDefaults] objectForKey:kSessionId]} lookUpKey:@"InsertAppUserPhoneResult" successMessage:@"Your phone number has been added" webService:kWebServiceAddPhoneNumber];
        } else {
            [self showAlertWithTitle:nil body:@"Please complete all fields"];
        }
    }
}

- (void)communicationMethodURLReplacements:(NSDictionary *)URLReplacements post:(NSDictionary *)body lookUpKey:(NSString *)key successMessage:(NSString *)message webService:(NSString *)webService{
    __weak MBEditProfileViewController *weakSelf = self;
    [MBWebServiceManager AFJSONRequestForWebService:webService URLReplacements:URLReplacements UserInfo:body success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
        if (responseObject) {
            NSDictionary *dict = (NSDictionary *)responseObject[key];
            if ([dict[@"MbResult"][@"Success"] boolValue]) {
                [weakSelf showAlertWithTitle:@"Success" body:message];
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            } else  {
                [weakSelf showAlertWithTitle:@"Fumble" body:dict[@"MbResult"][@"FriendlyErrorMsg"]];
            }
        }
        weakSelf.progressView.hidden = YES;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        weakSelf.progressView.hidden = YES;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [weakSelf showAlertWithTitle:@"Fumble" body:error.localizedDescription];
    }];
}

- (void)showAlertWithTitle:(NSString *)title body:(NSString *)body {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:body delegate:Nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
    [alert show];
}
@end
