//
//  MBNotificationViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 10/8/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBNotificationViewController.h"
#import "MBNotification.h"

@interface MBNotificationViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *notificationArray;

@end

@implementation MBNotificationViewController

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
    self.notificationArray = [MBNotification findAll];
	// Do any additional setup after loading the view.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    MBNotification *note = (MBNotification *)[[NSManagedObjectContext MR_contextForCurrentThread] objectWithID:[[self.notificationArray objectAtIndex:indexPath.row] objectID]];
    cell.textLabel.text = note.notification;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notificationArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
