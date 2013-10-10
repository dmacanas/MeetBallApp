//
//  MBMenuDisplayViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 10/3/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBMenuDisplayViewController.h"
#import "MBMenuCell.h"
#import "MBMenuNaviagtionViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

static NSString * const kProfilePicture = @"profilePic";

@interface MBMenuDisplayViewController ()

@property (strong, readwrite, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *menuItems;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation MBMenuDisplayViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.menuItems = [[NSArray alloc] initWithObjects:@"Home", @"My MeetBalls", @"Friends", @"Profile", @"Settings", @"Help", nil];
    self.tableView = [[UITableView alloc] init]; // Frame will be automatically set
    self.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.imageView =[[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 100, 100)];
    self.tableView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 184.0f)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 100, 100)];
        imageView.tag = 100;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        __block UIImage *image = nil;
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kProfilePicture]) {
            NSURL *url = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kProfilePicture]];
            ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
            [lib assetForURL:url resultBlock:^(ALAsset *asset) {
                image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                imageView.image = image;
            } failureBlock:nil];
            
        }else {
            imageView.image = [UIImage imageNamed:@"pl_icon"];
        }
        
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 50.0;
        imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        imageView.layer.borderWidth = 3.0f;
        imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        imageView.layer.shouldRasterize = YES;
        imageView.clipsToBounds = YES;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 0, 24)];
        label.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"FirstName"];
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
        [label sizeToFit];
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [view addSubview:imageView];
        [view addSubview:label];
        view;
    });
    [self.view addSubview:self.tableView];
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:kProfilePicture options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == [NSUserDefaults standardUserDefaults] && [keyPath isEqualToString:kProfilePicture]) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 184.0f)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 100, 100)];
        imageView.tag = 100;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        __block UIImage *image = nil;
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kProfilePicture]) {
            NSURL *url = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kProfilePicture]];
            ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
            [lib assetForURL:url resultBlock:^(ALAsset *asset) {
                image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                imageView.image = image;
            } failureBlock:nil];
            
        }else {
            imageView.image = [UIImage imageNamed:@"pl_icon"];
        }
        
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 50.0;
        imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        imageView.layer.borderWidth = 3.0f;
        imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        imageView.layer.shouldRasterize = YES;
        imageView.clipsToBounds = YES;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 0, 24)];
        label.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"FirstName"];
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
        [label sizeToFit];
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [view addSubview:imageView];
        [view addSubview:label];
        [self.tableView setTableHeaderView:view];
    }
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return nil;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 34)];
    view.backgroundColor = [UIColor colorWithRed:167/255.0f green:167/255.0f blue:167/255.0f alpha:0.6f];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 0, 0)];
    label.text = @"Friends Online";
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return 0;
    
    return 34;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MBMenuCell *cell = (MBMenuCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSString *feature = cell.menuLabel.text;
    self.navigationController.viewControllers = nil;
    if ([feature isEqualToString:@"My MeetBalls"]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"myMeetBallsStoryBoard" bundle:nil];
        UIViewController *vc = [sb instantiateInitialViewController];
        self.navigationController.viewControllers = @[vc];
    } else if ([feature isEqualToString:@"Friends"]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"TeamRosterStoryboard" bundle:nil];
        UIViewController *vc = [sb instantiateInitialViewController];
        self.navigationController.viewControllers = @[vc];
    } else if ([feature isEqualToString:@"Profile"]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"ProfileStoryboard" bundle:nil];
        UIViewController *vc = [sb instantiateInitialViewController];
        self.navigationController.viewControllers = @[vc];
    } else if ([feature isEqualToString:@"Settings"]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"SettingsStoryboard" bundle:nil];
        UIViewController *vc = [sb instantiateInitialViewController];
        self.navigationController.viewControllers = @[vc];
    } else if ([feature isEqualToString:@"Help"]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"HelpStoryboard" bundle:nil];
        UIViewController *vc = [sb instantiateInitialViewController];
        self.navigationController.viewControllers = @[vc];
    }else {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"homeStoryBoard" bundle:nil];
        MBMenuNaviagtionViewController *nvc = (MBMenuNaviagtionViewController *)[sb instantiateInitialViewController];
        UIViewController *vc = [nvc.viewControllers objectAtIndex:0];
        self.navigationController.viewControllers = @[vc];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = @"menuCell";
    MBMenuCell *cell = (MBMenuCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell == nil) {
        NSArray *ar = [[NSBundle mainBundle] loadNibNamed:@"MBMenuCell" owner:self options:nil];
        cell = [ar objectAtIndex:0];
    }
    
    cell.menuLabel.text = [self.menuItems objectAtIndex:indexPath.row];
    [cell.icon setImage:[UIImage imageNamed:[cell.menuLabel.text lowercaseString]]];
    [cell.textLabel setBackgroundColor:[UIColor whiteColor]];
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
