//
//  ProposedActivityViewController.h
//  Fitivity
//
//	Displays all comments/activity within the proposed activity
//
//  Created by Nathan Doe on 7/26/12.
//  Copyright (c) 2012 Fitivity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>

#import "OHAttributedLabel.h"

@interface ProposedActivityViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	NSMutableArray *results;
	
	BOOL posting;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil proposedActivity:(PFObject *)pa;
- (IBAction) textFieldDidUpdate:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *activityHeader;
@property (weak, nonatomic) IBOutlet UIImageView *creatorPicture;
@property (weak, nonatomic) IBOutlet UILabel *creatorName;
@property (weak, nonatomic) IBOutlet OHAttributedLabel *activityMessage;
@property (weak, nonatomic) IBOutlet UILabel *activityCreateTime;

@property (strong, nonatomic) IBOutlet UIView *activityFooter;
@property (weak, nonatomic) IBOutlet UITextField *activityComment;

@property (weak, nonatomic) IBOutlet UITableView *commentsTable;
@property (nonatomic, retain) PFObject *parent;

@end
