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
#import "MBAnnotation.h"
#import "MBMenuNavigator.h"
#import "MBMathBlock.h"
#import "MBAppDelegate.h"
#import "NSManagedObject+MRImportAdditions.h"
#import "MBInvitee.h"
#import "MeetBalls.h"
#import "MBMeetBall.h"
#import "MBHomeDataManager.h"
#import "MBTeamRoserViewController.h"
#import "MBMenuNavigationController.h"

#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import <FacebookSDK/FacebookSDK.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * 180.0 / M_PI)
static NSString * const kAnnotaionId = @"pinId";
static NSString * const kCarKey = @"carLocation";
static NSString * const kAuthentication = @"authenticated";
static NSString * const kAppUserId = @"AppUserId";
static NSString * const kFirstName = @"FirstName";
static NSString * const kSessionId = @"sessionId";


@interface MBHomeViewController () <CLLocationManagerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) MBHomeDataCommunicator *homeCommLink;
@property (strong, nonatomic) MBHomeDataManager *homeDataManager;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (assign, nonatomic) BOOL isShowingMenu;
@property (assign, nonatomic) BOOL isShowingMeetBall;
@property (assign, nonatomic) BOOL isShowingFullScreenMap;
@property (assign, nonatomic) BOOL isFlashing;
@property (assign, nonatomic) CGRect originalRect;
@property (assign, nonatomic) CGRect originalToolbarFrame;
@property (assign, nonatomic) CGRect originalTableFrame;
@property (strong, nonatomic) MBAnnotation *annotation;
@property (strong, nonatomic) NSArray *contactsArray;
@property (strong, nonatomic) NSArray *meetBalls;
@property (strong, nonatomic) NSMutableArray *invtiedFriendsArray;
@property (assign, nonatomic) MBAnnotation *launchAnnotation;
@property (assign, nonatomic) CLLocationCoordinate2D coord;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableHeighConstraint;

@end


@implementation MBHomeViewController 
#pragma mark - Implemenation

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
    [self initMethods];
    
    if ([MBUser findAll].count > 0) {
        self.contactsArray = [MBUser findAll];
    }
    
    [self setMapView];
    [self locationManagerSetup];
    [self getMeetBallContacts];
    
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"environment"] isEqualToString:@"dev"]) {
        [self setTitle:@"Home - Dev"];
    } else {
        [self setTitle:@"Home"];
    }
    
    [self.navigationItem.leftBarButtonItem setTarget:(MBMenuNavigationController *)self.navigationController];
    [self.navigationItem.leftBarButtonItem setAction:@selector(showMenu)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigateWithNotification:) name:@"navigate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signOut:) name:@"signOut" object:nil];
}

- (void)checkForCarLocation {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kCarKey]) {
        NSDictionary *d = [[NSUserDefaults standardUserDefaults] objectForKey:kCarKey];
        CLLocationCoordinate2D cord = CLLocationCoordinate2DMake([d[@"lat"] floatValue], [d[@"lon"] floatValue]);
        self.annotation = [[MBAnnotation alloc] initWithTitle:@"Car Location" andCoordinate:cord reuseId:kAnnotaionId withID:0];
        [self.mapView addAnnotation:self.annotation];
    }
}

- (void)initMethods {
    self.homeCommLink = [[MBHomeDataCommunicator alloc] init];
    self.homeDataManager = [[MBHomeDataManager alloc] init];
    self.invtiedFriendsArray = [[NSMutableArray alloc] init];
}

- (void)setMapView {
    [self.mapView setDelegate:self];
    self.mapView.showsUserLocation = YES;
}

- (void)locationManagerSetup {
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
    [self.locationManager setHeadingFilter:kCLHeadingFilterNone];
}

- (void)createAnnotations {
    __weak MBHomeViewController *weakSelf = self;
    [self.homeDataManager getUpcomingMeetBalls:^(BOOL done) {
        [self resetSubViewsAfterThrow];
        weakSelf.meetBalls = [MBMeetBall findAllSortedBy:@"meetBallId" ascending:YES];
        [weakSelf addAnnotationsFromMeetball];
    }];
}

- (void)flashOff:(UIView *)v
{
    [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^ {
        v.alpha = .2;  //don't animate alpha to 0, otherwise you won't be able to interact with it
    } completion:^(BOOL finished) {
        if (self.throwMBButton.enabled) {
            [self flashOn:v];
        }
    }];
}

- (void)flashOn:(UIView *)v
{
    [UIView animateWithDuration:0.9 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^ {
        v.alpha = 1;
    } completion:^(BOOL finished) {
        if (self.throwMBButton.enabled) {
            [self flashOff:v];
        }
    }];
}

#pragma mark - view appearing

- (void)viewDidAppear:(BOOL)animated {
    if (self.isShowingFullScreenMap) {
        [self resetHomeScreen];
    }
    
    [self tableViewFrameUpdate];
    [self setOriginalFrames];
    
    [self.locationManager startUpdatingHeading];
    [self.locationManager startUpdatingLocation];
    
}

- (void)tableViewFrameUpdate {
    self.tableHeighConstraint.constant = self.homeTableView.contentSize.height;
    [self.view needsUpdateConstraints];
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width, self.homeTableView.contentSize.height + self.mapView.frame.size.height + self.mainToolbar.frame.size.height)];
}

- (void)setOriginalFrames {
    self.originalRect = self.mapView.frame;
    self.originalToolbarFrame = self.mapToolBar.frame;
    self.originalTableFrame = self.homeTableView.frame;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.locationManager stopUpdatingHeading];
    [self.locationManager stopUpdatingLocation];
}

- (void)addAnnotationsFromMeetball{
    [self.mapView removeAnnotations:self.mapView.annotations];
    NSMutableArray *annotationArray = [[NSMutableArray alloc] init];
    NSArray *a = [self.homeDataManager getActiveMeetBalls:self.meetBalls];
    for (MBMeetBall *mb in a) {
        CLLocationCoordinate2D loc = [self extractLocationFromString:mb.generalLocationGPX];
        MBAnnotation *a = [[MBAnnotation alloc] initWithTitle:[mb.meetBallName stringByReplacingOccurrencesOfString:@"/" withString:@""] andCoordinate:loc reuseId:kAnnotaionId withID:mb.meetBallId];
        [annotationArray addObject:a];
    }
    [self.mapView addAnnotations:annotationArray];
//    if (annotationArray.count > 0) {
//        self.compassImageVIew.hidden = NO;
//        self.coord = [(MBAnnotation *)[annotationArray objectAtIndex:0] coordinate];
//        [self.mapView selectAnnotation:[annotationArray objectAtIndex:0] animated:YES];
//    }
    [self checkForCarLocation];
}

- (CLLocationCoordinate2D)extractLocationFromString:(NSString *)location {
    NSString *d1 = [location stringByReplacingOccurrencesOfString:@"POINT (" withString:@""];
    NSString *d2 = [d1 stringByReplacingOccurrencesOfString:@")" withString:@""];

    NSArray *a = [d2 componentsSeparatedByString:@" "];
    NSString *lon = (NSString *)[a objectAtIndex:0];
    NSString *lat = (NSString *)[a objectAtIndex:1];
    
    double longitude = [lon doubleValue];
    double latitude = [lat doubleValue];
    return CLLocationCoordinate2DMake(latitude, longitude);
}

#pragma mark - location manager stuffs
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
//    [self setMeetBallHeading:newHeading];
}

- (void)setMeetBallHeading:(CLHeading *)heading{
    double head = [MBMathBlock setMeetBallHeading:heading toPoint:self.coord userLocation:[self.mapView userLocation].coordinate];
    CGAffineTransform rotate = CGAffineTransformMakeRotation(head);
    [self.compassImageVIew setTransform:rotate];
}


#pragma mark - Mapview Delegates


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MBAnnotation class]]) {
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kAnnotaionId];
        if (pinView == nil) {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kAnnotaionId];
            pinView.pinColor = MKPinAnnotationColorPurple;
            pinView.animatesDrop = YES;
            pinView.canShowCallout = YES;
            UIButton *callout = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            if ([[(MBAnnotation *)annotation title] isEqualToString:@"Car Location"]) {
                pinView.pinColor = MKPinAnnotationColorRed;
                [callout setImage:[UIImage imageNamed:@"hide"] forState:UIControlStateNormal];
                callout.tag = 1;
            } else {
                pinView.pinColor = MKPinAnnotationColorPurple;
                [callout setImage:[UIImage imageNamed:@"car"] forState:UIControlStateNormal];
                callout.tag = 2;
            }
            pinView.rightCalloutAccessoryView = callout;
        }else {
            UIButton *callout = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            if ([[(MBAnnotation *)annotation title] isEqualToString:@"Car Location"]) {
                pinView.pinColor = MKPinAnnotationColorRed;
                [callout setImage:[UIImage imageNamed:@"hide"] forState:UIControlStateNormal];
                callout.tag = 1;
            } else {
                pinView.pinColor = MKPinAnnotationColorPurple;
                [callout setImage:[UIImage imageNamed:@"car"] forState:UIControlStateNormal];
                callout.tag = 2;
            }
            pinView.rightCalloutAccessoryView = callout;
            pinView.annotation = annotation;
        }
        
        return pinView;
    }

    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    if ([view.annotation isKindOfClass:[MBAnnotation class]]) {
        if ([[(MBAnnotation*)view.annotation title] isEqualToString:@"Car Location"]) {
            [self.mapView removeAnnotation:self.annotation];
            self.annotation = nil;
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCarKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            self.launchAnnotation = view.annotation;
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Launch Navigation?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Launch Maps", nil];
            [actionSheet showInView:self.view];
        }
    }
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    self.coord = [(MBAnnotation *)view.annotation coordinate];
}


#pragma mark - Action Sheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving};
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.launchAnnotation.coordinate addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        mapItem.name = self.launchAnnotation.title;
        [mapItem openInMapsWithLaunchOptions:launchOptions];
    }
}

#pragma mark - contacts setUp
- (void)getMeetBallContacts {
    __weak MBHomeViewController *weakSelf = self;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.homeCommLink getMeetBallContacts:^(id contacts){
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:contacts options:kNilOptions error:&error];
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            [MBUser truncateAllInContext:localContext];
            [MBUser MR_importFromArrayAndWait:json[@"Items"] inContext:localContext];
        } completion:^(BOOL success, NSError *error) {
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"firstName != %@ && firstName != %@ && meetBallID > 0 && email.length > 0", @"Ad Hoc", @"First"];
            weakSelf.contactsArray = [MBUser findAllSortedBy:@"firstName" ascending:YES withPredicate:pred];
            [weakSelf.homeTableView reloadData];
            weakSelf.tableHeighConstraint.constant = weakSelf.homeTableView.contentSize.height;
            [weakSelf.view needsUpdateConstraints];
            [weakSelf.scrollView setContentSize:CGSizeMake(weakSelf.scrollView.contentSize.width, weakSelf.homeTableView.contentSize.height + weakSelf.mapView.frame.size.height + weakSelf.mainToolbar.frame.size.height)];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }];
        
        [weakSelf createAnnotations];
    } failure:^(NSError *err) {
        NSLog(@"error %@",err);
    }];
}

#pragma mark - tableView methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    if (indexPath.row == self.contactsArray.count) {
        cell.textLabel.text = @"Add More Friends...";
        cell.detailTextLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    if (self.contactsArray && self.contactsArray.count > 1) {
        MBUser *u = (MBUser *)[[NSManagedObjectContext MR_contextForCurrentThread] objectWithID:[[self.contactsArray objectAtIndex:indexPath.row] objectID]];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", u.firstName, u.lastName];
        cell.detailTextLabel.text = u.email;
    }
//    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contactsArray.count + 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Select Friends - Throw MeetBall - Meet Up!";
    }
    
    return @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.contactsArray.count) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    
    MBUser *u = (MBUser *)[[NSManagedObjectContext MR_contextForCurrentThread] objectWithID:[[self.contactsArray objectAtIndex:indexPath.row] objectID]];
    MBInvitee *i = [[MBInvitee alloc] initWithFristName:u.firstName lastName:u.lastName email:u.email Id:u.meetBallID];
    i.FacebookId = @"";
    i.Mobile = @"";
    
    BOOL foundUser = NO;
    for (MBInvitee *invitee in self.invtiedFriendsArray) {
        if (invitee.AppUserId == i.AppUserId) {
            foundUser = YES;
        }
    }
    
    if (foundUser == NO) {
        [self.invtiedFriendsArray addObject:i];
    }
    
    if (self.invtiedFriendsArray.count > 0) {
        self.throwMBButton.enabled = YES;
        if (self.isFlashing == NO) {
            [self flashOn:self.throwMBButton];
            self.isFlashing = YES;
        }
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.contactsArray.count) {
        return;
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (self.invtiedFriendsArray.count == 1) {
        self.throwMBButton.enabled = NO;
        [self.throwMBButton.layer removeAllAnimations];
        self.isFlashing = NO;
    }
    
    MBUser *u = (MBUser *)[[NSManagedObjectContext MR_contextForCurrentThread] objectWithID:[[self.contactsArray objectAtIndex:indexPath.row] objectID]];
    MBInvitee *i = [[MBInvitee alloc] initWithFristName:u.firstName lastName:u.lastName email:u.email Id:u.meetBallID];
    for (MBInvitee *invitee in self.invtiedFriendsArray) {
        if (invitee.AppUserId == i.AppUserId) {
            [self.invtiedFriendsArray removeObject:invitee];
            return;
        }
    }
    
}

#pragma mark - clean up
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions
- (IBAction)showMenu:(id)sender {

}

- (IBAction)testCancel:(id)sender {


}

- (IBAction)throwMeetBalls:(id)sender {
    if (self.invtiedFriendsArray.count == 0) {
        return;
    }
    [self setTitle:@"Throwing ..."];
    self.progressView.hidden = NO;
    [self.progressView setProgress:0.4 animated:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.mainToolbar setUserInteractionEnabled:NO];
    __block MeetBalls *mb = [[MeetBalls alloc] init];
    mb.ownerId = (NSInteger)[[NSUserDefaults standardUserDefaults] objectForKey:kAppUserId];
    mb.meetBallName = [NSString stringWithFormat:@"%@/'s MeetBall", [[NSUserDefaults standardUserDefaults] objectForKey:kFirstName]];
    mb.meetBallDescription = [NSString stringWithFormat:@"Meet %@", [[NSUserDefaults standardUserDefaults] objectForKey:kFirstName]];
    mb.startDate = [NSDate date];
    mb.endDate = [NSDate dateWithTimeInterval:7200 sinceDate:mb.startDate];
    mb.usageId = 1;
    mb.invitees = self.invtiedFriendsArray;
    mb.ownerPrivate = NO;
    mb.locationNotes = nil;
    mb.generalLocationGPX = [NSString stringWithFormat:@"POINT(%f %f %f)",[self.locationManager location].coordinate.longitude, [self.locationManager location].coordinate.latitude, [self.locationManager location].altitude];
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[self.mapView userLocation].coordinate.latitude longitude:[self.mapView userLocation].coordinate.longitude];
    __weak MBHomeViewController *weakSelf = self;
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            weakSelf.progressView.hidden = YES;
            [weakSelf.mainToolbar setUserInteractionEnabled:YES];
            NSLog(@"%@", error);
            return;
        }
        
        NSDictionary *address = [(CLPlacemark *)[placemarks objectAtIndex:0] addressDictionary];
        mb.locationName =[(CLPlacemark *)[placemarks objectAtIndex:0] name];
        mb.generalLocationAddress1 = address[@"Street"];
        mb.generalLocationCity = address[@"City"];
        mb.generalLocationState = address[@"State"];
        mb.generalLocationZip = address[@"ZIP"];
    
        [weakSelf.progressView setProgress:0.8 animated:YES];
        [weakSelf.homeCommLink throwMeetBall:mb success:^(id responseObject) {
            [weakSelf.progressView setProgress:0.9 animated:YES];
            if (responseObject && [[(NSDictionary *)responseObject[@"AddInviteesToExistingMeetBallJsonResult"][@"MbResult"] objectForKey:@"Success"] boolValue]) {
                [weakSelf threwMeetBall];
                [weakSelf resetSubViewsAfterThrow];
            }
            NSLog(@"%@", responseObject);
        } failure:^(NSError *error) {
            NSLog(@"%@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fumble!" message:error.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
            [alert show];
            [self setTitle:@"Home"];
            [weakSelf resetSubViewsAfterThrow];
        }];
    }];
}

- (void)resetSubViewsAfterThrow {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.progressView setHidden:YES];
    [self.invtiedFriendsArray removeAllObjects];
    [self.mainToolbar setUserInteractionEnabled:YES];
    for (NSIndexPath *index in self.homeTableView.indexPathsForSelectedRows) {
        [self.homeTableView deselectRowAtIndexPath:index animated:NO];
    }
}

- (void)threwMeetBall {
    [self setTitle:@"Home"];
    UIAlertView *throw = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Successfully threw your MeetBall" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
    [throw show];
    [self createAnnotations];
}

- (IBAction)adjustMap:(id)sender {
    if (self.isShowingFullScreenMap) {
        [self resetHomeScreen];
    } else {
        [UIView animateWithDuration:0.1f animations:^{
            [self setForFullScreen];
        } completion:^(BOOL finished) {
            [self setFramesForFullScreen];
        }];
    }
}

- (IBAction)adjustUserLocation:(id)sender {
    [self.mapView setRegion:[self.mapView regionThatFits:MKCoordinateRegionMake([self.mapView userLocation].coordinate, MKCoordinateSpanMake(0.005, 0.005))] animated:YES];
}

- (IBAction)carLocation:(id)sender {
    if (self.annotation) {
        [self.mapView removeAnnotation:self.annotation];
        self.annotation = nil;
        self.annotation = [[MBAnnotation alloc] initWithTitle:@"Car Location" andCoordinate:[self.mapView userLocation].coordinate reuseId:kAnnotaionId withID:0];
    } else {
        self.annotation = [[MBAnnotation alloc] initWithTitle:@"Car Location" andCoordinate:[self.mapView userLocation].coordinate reuseId:kAnnotaionId withID:0];
    }
    [[NSUserDefaults standardUserDefaults] setObject:@{@"lat":[NSString stringWithFormat:@"%f",self.annotation.coordinate.latitude], @"lon":[NSString stringWithFormat:@"%f",self.annotation.coordinate.longitude]} forKey:kCarKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.mapView addAnnotation:self.annotation];
}

- (void)resetHomeScreen {
    [self.toolBarButton setImage:[UIImage imageNamed:@"fullScreen_ic"]];
    self.isShowingFullScreenMap = NO;
    __weak MBHomeViewController *weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        [weakSelf.mapView setFrame:weakSelf.originalRect];
        [weakSelf.mapToolBar setFrame:weakSelf.originalToolbarFrame];
        [weakSelf.scrollView setScrollEnabled:YES];
        weakSelf.homeTableView.hidden = NO;

    }];
    
    [UIView animateWithDuration:0.5 animations:^{
        [weakSelf.homeTableView setFrame:weakSelf.originalTableFrame];
    } completion:^(BOOL finished) {
         weakSelf.mainToolbar.hidden = NO;
    }];

}

- (void)setForFullScreen {
    [self.scrollView scrollRectToVisible:self.mapView.frame animated:NO];
    [self.scrollView setScrollEnabled:NO];
    [self.toolBarButton setImage:[UIImage imageNamed:@"shrink_ic"]];
    self.isShowingFullScreenMap = YES;
}

- (void)setFramesForFullScreen {
    __weak MBHomeViewController *weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        CGRect f = weakSelf.homeTableView.frame;
        f.origin.y = weakSelf.scrollView.frame.size.height;
        [weakSelf.homeTableView setFrame:f];
        weakSelf.mainToolbar.hidden = YES;
    } completion:^(BOOL finished) {
        weakSelf.homeTableView.hidden = YES;
    }];
    
    [UIView animateWithDuration:0.5 animations:^{
        CGRect f = weakSelf.mapView.frame;
        f.size.height = weakSelf.scrollView.frame.size.height -64;
        [weakSelf.mapView setFrame:f];
        f = weakSelf.mapToolBar.frame;
        f.origin.y = weakSelf.mapView.frame.size.height - weakSelf.mapToolBar.frame.size.height;
        [weakSelf.mapToolBar setFrame:f];

    }];
}

#pragma mark - notifications
- (void)navigateWithNotification:(NSNotification *)notification {
    if ([(NSString *)notification.object isEqualToString:@"Home"]) {
        return;
    }
    [MBMenuNavigator navigateToMenuItem:(NSString *)notification.object fromVC:self];
}

- (void)signOut:(NSNotification *)notification {
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
