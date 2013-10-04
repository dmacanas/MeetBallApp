//
//  MBCommentsViewController.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/26/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBCommentsViewController.h"
#import "commentBubbleCollectionViewCell.h"
#import "MBWebServiceConstants.h"
#import "MBWebServiceManager.h"

#import "MBComment.h"
static NSString * const kSessionId = @"sessionId";
static NSString * const kAppUserId = @"AppUserId";

@interface MBCommentsViewController () <UITextFieldDelegate>

@property (strong, nonatomic) NSMutableArray *commentArray;
@property (assign, nonatomic) CGRect originalToolbar;

@end

@implementation MBCommentsViewController

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
    self.commentArray = [[NSMutableArray alloc] init];
    [self getCommentsForMeetBall];
    self.originalToolbar = self.toolbar.frame;
}

- (void)getCommentsForMeetBall {
    NSString *meetballId = [NSString stringWithFormat:@"%d",self.meetBall.meetBallId];
    __weak MBCommentsViewController *weakSelf = self;
    [MBWebServiceManager AFHTTPRequestForWebService:kWebServiceGetMeetBallComments URLReplacements:@{@"version": [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"], @"sessionId":[[NSUserDefaults standardUserDefaults] objectForKey:kSessionId], @"meetballId":meetballId} success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
        if (responseObject) {
            NSError *jsonError;
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&jsonError];
            NSArray *items = JSON[@"Items"];
            [weakSelf createComments:items];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"%@",error);
    }];
}



- (void)createComments:(NSArray *)rawArray {
    for (NSDictionary *dict  in rawArray) {
        MBComment *comm = [[MBComment alloc] init];
        comm.firstName = dict[@"FirstName"];
        comm.comment = dict[@"Comment"];
        comm.commentDate = [self dateFromString:dict[@"CommentDate"]];
        comm.appUserId = [(NSString *)dict[@"AppUserId"] integerValue];
        [self.commentArray addObject:comm];
    }
    
    [self createCommentBubbles];
}

- (NSDate *)dateFromString:(NSString *)string {
    NSString *d1 = [string stringByReplacingOccurrencesOfString:@"/Date(" withString:@""];
    NSString *d2 = [d1 stringByReplacingOccurrencesOfString:@")/" withString:@""];
    
    NSArray *a = [d2 componentsSeparatedByString:@"-"];
    
    NSString *time = (NSString *)[a objectAtIndex:0];
    double mSec = [time doubleValue];
    double sec = mSec/1000;
    sec += 600;
    
    return [NSDate dateWithTimeIntervalSince1970:sec];
}


- (void)createCommentBubbles {
    for (int i = 0; i < self.commentArray.count; i++) {
        MBComment *comm = [self.commentArray objectAtIndex:i];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 200, 100)];
        NSDateFormatter* df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"MM/dd HH:mm"];
        NSString *ds = [df stringFromDate:comm.commentDate];
        label.text = [NSString stringWithFormat:@"%@\n%@ - %@",comm.comment,comm.firstName,ds];
        label.numberOfLines = 0;
        [label sizeToFit];
        
        UIView *view = [[UIView alloc] init];
        view.tag = i + 2;
        if (comm.appUserId == [[[NSUserDefaults standardUserDefaults] objectForKey:kAppUserId] integerValue]) {
            if (i == 0) {
                view.frame = CGRectMake(80, 20, 220, label.frame.size.height + 30);
            } else {
                UIView *v = [self.scrollView viewWithTag:(i - 1)+2];
                float y = v.frame.size.height + v.frame.origin.y + 10;
                view.frame = CGRectMake(80, y, 220, label.frame.size.height + 30);
            }
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
            [imageView setImage:[[UIImage imageNamed:@"greenBubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 10, 10)]];
            [view addSubview:imageView];
            [view addSubview:label];
        } else {
            if (i == 0) {
                view.frame = CGRectMake(20, 20, 220, label.frame.size.height + 30);
            } else {
                UIView *v = [self.scrollView viewWithTag:(i - 1)+2];
                float y = v.frame.size.height + v.frame.origin.y + 10;
                view.frame = CGRectMake(20, y, 220, label.frame.size.height + 30);
            }
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
            [imageView setImage:[[UIImage imageNamed:@"grayBubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 10, 10,5)]];
            [view addSubview:imageView];
            [view addSubview:label];
        }
        
        [self.scrollView addSubview:view];
    }
   
    float sizeOfContent = 0;
    UIView *lLast = [self.scrollView.subviews lastObject];
    NSInteger wd = lLast.frame.origin.y;
    NSInteger ht = lLast.frame.size.height;
    
    sizeOfContent = wd+ht+20;
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, sizeOfContent);
}


#pragma mark - textfield handling 
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.toolbar.frame;
        frame.origin.y = frame.origin.y - 216;
        self.toolbar.frame = frame;
    }];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.35 animations:^{
        self.toolbar.frame = self.originalToolbar;
    }];
    
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendComment:(id)sender {
    [self.textField endEditing:YES];
    if (self.textField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fumble!" message:@"Please add text" delegate:Nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
        [alert show];
    } else {
        [self.progressView setProgress:0.7 animated:YES];
        self.progressView.hidden = NO;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSString *meetballId = [NSString stringWithFormat:@"%d",self.meetBall.meetBallId];
        NSDictionary *dict = @{@"meetballId": meetballId, @"appUserId":[[NSUserDefaults standardUserDefaults] objectForKey:kAppUserId], @"comment":self.textField.text, @"approved":@"1", @"sessionId":[[NSUserDefaults standardUserDefaults] objectForKey:kSessionId]};
        
        __weak MBCommentsViewController *weakSelf = self;
        
        [MBWebServiceManager AFJSONRequestForWebService:kWebServiceAddMeetBallComment URLReplacements:@{@"version": [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"], @"meetballId":meetballId} UserInfo:dict success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
            if (responseObject && [[(NSDictionary *)responseObject[@"InsertMeetballCommentJsonResult"][@"MbResult"] objectForKey:@"Success"] boolValue]) {
                weakSelf.textField.text = nil;
                [weakSelf.commentArray removeAllObjects];
                [weakSelf.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                [weakSelf.progressView setHidden:YES];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                [weakSelf getCommentsForMeetBall];
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"%@", error);
            [self.progressView setHidden:YES];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }];
    }
}
@end
