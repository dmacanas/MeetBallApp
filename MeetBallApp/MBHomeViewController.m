//
//  MBHomeViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 8/27/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBHomeViewController.h"
#import "MBCredentialManager.h"
#import "MBLoginViewController.h"
#import "MBSuitUpViewController.h"
#import "MBHomeDataCommunicator.h"
#import "MBCredentialManager.h"
#import "MBEventCollectionViewCell.h"
#import "MBMenuView.h"

#import "MBUser.h"
#import "MeetBalls.h"

#import <CoreData/CoreData.h>
#import <FacebookSDK/FacebookSDK.h>


@interface MBHomeViewController ()

@property (strong, nonatomic) MBHomeDataCommunicator *homeCommLink;
@property (strong, nonatomic) MBMenuView *menu;
@property (assign, nonatomic) BOOL isShowingMenu;

@end

static NSString * const kAuthentication = @"authenticated";
static NSString * const kAppUserId = @"AppUserId";
static NSString * const kFirstName = @"FirstName";
static NSString * const kSessionId = @"sessionId";

@implementation MBHomeViewController

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
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    UINib *cellNib = [UINib nibWithNibName:@"MBEventCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"EventCell"];
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"MBMenuView" owner:self options:nil];
    self.menu = [array objectAtIndex:0];
    self.homeCommLink = [[MBHomeDataCommunicator alloc] init];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    
}

//main collectionview delegates

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellID = @"EventCell";
    MBEventCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 3;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showMenu:(id)sender {
    if (self.isShowingMenu == NO){
        [self.view addSubview:self.menu];
        self.isShowingMenu = YES;
    } else {
        [self.menu removeFromSuperview];
        self.isShowingMenu = NO;
    }
}

- (IBAction)testCancel:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kAuthentication];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if([self.presentingViewController class] == [MBLoginViewController class] || [self.presentingViewController class] ==[MBSuitUpViewController class]){
        [self dismissViewControllerAnimated:YES completion:nil];
    } else{
        [FBSession.activeSession closeAndClearTokenInformation];
        [MBCredentialManager clearCredentials];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"loginFlow" bundle:nil];
        UIViewController *vc = [sb instantiateInitialViewController];
        [self presentViewController:vc animated:NO completion:nil];
    }

}
@end
