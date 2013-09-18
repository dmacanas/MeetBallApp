//
//  MBTeamRoserViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/17/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBTeamRoserViewController.h"
#import "MBMenuNavigator.h"
#import "MBMenuView.h"
#import "MBPerson.h"

#import <AddressBook/AddressBook.h>

@interface MBTeamRoserViewController () <MBMenuViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) MBMenuView *menu;
@property (assign, nonatomic) BOOL isShowingMenu;
@property (strong, nonatomic) NSMutableArray *addressBookData;

@end

@implementation MBTeamRoserViewController

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
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"MBMenuView" owner:self options:nil];
    self.menu = [array objectAtIndex:0];
    self.menu.delegate = self;
    [self.menuContainer addSubview:self.menu];
    
    self.friendsTableView.delegate = self;
    self.friendsTableView.dataSource = self;
    self.addressBookData = [[NSMutableArray alloc] init];
    [self getPersonOutOfAddressBook];
    [self.friendsTableView reloadData];
	// Do any additional setup after loading the view.
}

- (void)didSelectionMenuItem:(NSString *)item {
    self.isShowingMenu = NO;
    self.menuContainer.hidden = YES;
    self.blurView.hidden = YES;
    if ([item isEqualToString:@"Team Roster"]) {
        return;
    }

    [self dismissViewControllerAnimated:NO completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"navigate" object:item];
    }];
//    [MBMenuNavigator navigateToMenuItem:item fromVC:self];
}


#pragma mark - Table View 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.addressBookData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    MBPerson *p = [self.addressBookData objectAtIndex:indexPath.row];
    cell.textLabel.text = p.fullName;
    cell.detailTextLabel.text = p.homeEmail;
    return cell;
}

- (void)getPersonOutOfAddressBook
{
    //1
    CFErrorRef error = NULL;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
//        dispatch_release(sema);
    }
    
    if (accessGranted) {
    
    if (addressBook != nil)
    {
        NSLog(@"Succesful.");
        //2
        NSArray *allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        
        //3
        NSUInteger i = 0;
        for (i = 0; i < [allContacts count]; i++)
        {
            MBPerson *person = [[MBPerson alloc] init];
            
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            
            //4
            NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
            NSString *lastName =  (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            
            person.firstName = firstName;
            person.lastName = lastName;
            person.fullName = fullName;
            
            //email
            //5
            ABMultiValueRef emails = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
            
            //6
            NSUInteger j = 0;
            for (j = 0; j < ABMultiValueGetCount(emails); j++)
            {
                NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, j);
                if (j == 0)
                {
                    person.homeEmail = email;
                    NSLog(@"person.homeEmail = %@ ", person.homeEmail);
                }
                
                else if (j==1)
                    person.workEmail = email;
            }
            
            //7
            [self.addressBookData addObject:person];
        }
        
        //8
        CFRelease(addressBook);
    }
    else
    {
        //9
        NSLog(@"Error reading Address Book");
    }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showMenu:(id)sender {
    if (self.isShowingMenu) {
        self.menuContainer.hidden = YES;
        self.blurView.hidden = YES;
        self.isShowingMenu = !self.isShowingMenu;
    } else {
        [self.menu createBlurViewInView:self.view forImageView:self.blurView];
        self.menuContainer.hidden = NO;
        self.blurView.hidden = NO;
        self.isShowingMenu = !self.isShowingMenu;
    }
}


@end
