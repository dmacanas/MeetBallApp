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
#import "MBMenuNaviagtionViewController.h"
#import "MBFriendDetailViewController.h"

#import <AddressBook/AddressBook.h>
static NSString * const kFriendSorting = @"friendSorting";

@interface MBTeamRoserViewController () <MBMenuViewDelegate, UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate>

@property (strong, nonatomic) MBMenuView *menu;
@property (assign, nonatomic) BOOL isShowingMenu;
@property (strong, nonatomic) NSMutableArray *addressBookData;
@property (strong, nonatomic) MBPerson *person;
@property (strong, nonatomic) NSArray *searchResults;

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

- (void)tableViewSetUp
{
    self.friendsTableView.delegate = self;
    self.friendsTableView.dataSource = self;
    self.addressBookData = [[NSMutableArray alloc] init];
    [self getPersonOutOfAddressBook];
    [self.friendsTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpMenu];
    [self tableViewSetUp];
    [self.navigationItem.leftBarButtonItem setTarget:(MBMenuNaviagtionViewController *)self.navigationController];
    [self.navigationItem.leftBarButtonItem setAction:@selector(showMenu)];
	// Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)setUpMenu
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"MBMenuView" owner:self options:nil];
    self.menu = [array objectAtIndex:0];
    self.menu.delegate = self;
    [self.menuContainer addSubview:self.menu];
}

- (void)didSelectionMenuItem:(NSString *)item {
    self.isShowingMenu = NO;
    self.menuContainer.hidden = YES;
    self.blurView.hidden = YES;
    if ([item isEqualToString:@"Friends"]) {
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.searchResults.count;
    } else {
        return self.addressBookData.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    MBPerson *p;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        p = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        p = [self.addressBookData objectAtIndex:indexPath.row];
    }
    cell.textLabel.text = p.fullName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MBPerson *p;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        p = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        p = [self.addressBookData objectAtIndex:indexPath.row];
    }
    self.person = p;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self performSegueWithIdentifier:@"friendDetail" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"friendDetail"]) {
        MBFriendDetailViewController *vc = (MBFriendDetailViewController *)[segue destinationViewController];
        vc.person = self.person;
    }
}

#pragma mark - Address book fetching

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
            if (firstName.length == 0) {
                firstName = @"";
            }
            NSString *lastName =  (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            if (lastName.length == 0) {
                lastName = @"";
            }
            NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            person.firstName = firstName;
            person.lastName = lastName;
            person.fullName = fullName;
            
            //email
            //5
            ABMultiValueRef emails = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
            ABMultiValueRef phones = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
            
            //6
            NSMutableArray *emailArray = [[NSMutableArray alloc] init];
            NSMutableArray *emailLabArra = [[NSMutableArray alloc] init];
            NSUInteger j = 0;
            for (j = 0; j < ABMultiValueGetCount(emails); j++)
            {
                NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, j);
                CFStringRef l = ABMultiValueCopyLabelAtIndex(emails, j);
                NSString *label = (__bridge NSString *)ABAddressBookCopyLocalizedLabel(l);
                [emailArray addObject:email];
                [emailLabArra addObject:label];
                if (j == 0)
                {
                    person.homeEmail = email;
                }
                
                else if (j==1)
                    person.workEmail = email;
            }
            person.emailAddresses = emailArray;
            person.emailLabels = emailLabArra;
            NSMutableArray *phoneArray = [[NSMutableArray alloc] init];
            NSMutableArray *labelArray = [[NSMutableArray alloc] init];
            for (NSInteger i = 0; i < ABMultiValueGetCount(phones); i++) {
                NSString *phone =  (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, i);
                CFStringRef l = ABMultiValueCopyLabelAtIndex(phones, i);
                NSString *label = (__bridge NSString *)ABAddressBookCopyLocalizedLabel(l);
                [phoneArray addObject:phone];
                [labelArray addObject:label];
            }
            person.phoneNumbers = phoneArray;
            person.phoneLabels = labelArray;
            //7
            if (person.firstName.length > 0 || person.lastName.length > 0) {
                [self.addressBookData addObject:person];
            }

        }
        [self friendSorting];
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

- (void)friendSorting {
    
    NSSortDescriptor *sort;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kFriendSorting]) {
        NSInteger sorting = [[[NSUserDefaults standardUserDefaults] objectForKey:kFriendSorting] integerValue];
        if (sorting == 1) {
            sort = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
        } else {
            sort = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
        }
    } else {
        sort = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    }
    NSArray *sortDesc = [NSArray arrayWithObject:sort];
    NSArray *array = [self.addressBookData sortedArrayUsingDescriptors:sortDesc];
    self.addressBookData = [array mutableCopy];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"firstName contains[cd] %@ || lastName contains[cd] %@",
                                    searchText, searchText];
    
    self.searchResults = [self.addressBookData filteredArrayUsingPredicate:resultPredicate];
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
