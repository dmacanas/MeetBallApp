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
    [self.secondaryCollectionView setDelegate:self];
    [self.secondaryCollectionView setDataSource:self];
    [self.secondaryCollectionView setTag:2];
    
    UINib *cellNib = [UINib nibWithNibName:@"MBEventCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"EventCell"];
    [self.secondaryCollectionView registerNib:cellNib forCellWithReuseIdentifier:@"EventCell"];
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"MBMenuView" owner:self options:nil];
    self.menu = [array objectAtIndex:0];
    self.menu.delegate = self;
    self.homeCommLink = [[MBHomeDataCommunicator alloc] init];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
    [self.scrollView setContentSize:CGSizeMake(320, 660)];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    
}

//main collectionview delegates

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellID = @"EventCell";
    MBEventCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    if (indexPath.row % 3 == 1) {
        cell.titleSubheader1.text = @"5:00PM CST";
        cell.titleSubheader2.text = @"Saturday September 7th";
        cell.contentHeaderLabel.text = @"Dominic shared an event";
        cell.dividerView.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:156.0/255.0 blue:17.0/255.0 alpha:1.0];
        cell.friendsCollectionView.hidden = YES;
        cell.contentNoteCountLabel.text = @"2 Notes";
    } else if (indexPath.row % 3 == 2) {
        cell.titleHeaderLabel.text = @"Ryan Field";
        cell.titleSubheader1.text = @"1501 Central St.";
        cell.titleSubheader2.text = @"Evanston, IL 60201";
        cell.contentHeaderLabel.text = @"Dominic shared a location";
        cell.dividerView.backgroundColor = [UIColor colorWithRed:208.0/255.0 green:44.0/255.0 blue:48.0/255.0 alpha:1.0];
        cell.friendsCollectionView.hidden = YES;
        cell.contentNoteCountLabel.text = @"4 Notes";
    } else {
        cell.titleHeaderLabel.text = @"NUMBAlum Tailgate";
        cell.titleSubheader1.text = @"5:00PM Saturday";
        cell.titleSubheader2.text = @"13 Friends Going";
        cell.contentHeaderLabel.text = @"Dominic threw a MeetBall";
        cell.dividerView.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:83.0/255.0 blue:172.0/255.0 alpha:1.0];
        cell.friendsCollectionView.hidden = NO;
        cell.contentNoteCountLabel.text = @"7 Notes";
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 15;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected %@", indexPath);
    [self performSegueWithIdentifier:@"detailsPush" sender:self];
}

- (void)didSelectionMenuItem:(NSString *)item {
    NSLog(@"Menu Select %@", item);
    self.isShowingMenu = NO;
    [self.menu removeFromSuperview];
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
