//
//  MBMenuView.m
//  MeetBallApp
//
//  Created by Dominic Macanas on 9/5/13.
//  Copyright (c) 2013 MeetBall. All rights reserved.
//

#import "MBMenuView.h"

@interface MBMenuView()

@property (strong, nonatomic) NSArray *menuItems;

@end

@implementation MBMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.menuTableView setDataSource:self];
    [self.menuTableView setDelegate:self];
    self.menuItems = [[NSArray alloc] initWithObjects:@"Home", @"My MeetBalls", @"Team Roster", @"Profile", @"Settings", @"Help", nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.highlighted = NO;
    [self.delegate didSelectionMenuItem:cell.textLabel.text];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [self.menuItems objectAtIndex:indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)createBlurViewInView:(UIView *)view forImageView:(UIImageView *)imageView {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CIImage *blur = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:blur forKey:@"inputImage"];
    [filter setValue:[NSNumber numberWithFloat:10.0] forKey:@"inputRadius"];
    CIImage *final = [filter valueForKey:@"outputImage"];
    CIImage *f = [final imageByCroppingToRect:blur.extent];
    UIImage *endImage = [[UIImage alloc] initWithCIImage:f scale:2.0 orientation:UIImageOrientationUp];
    [imageView setImage:endImage];
}

@end
