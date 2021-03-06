//
//  DiscoverFeedViewController.m
//  Fitivity
//
//  Created by Nathan Doe on 8/8/12.
//  Copyright (c) 2012 Fitivity. All rights reserved.
//

#import "DiscoverFeedViewController.h"
#import "DiscoverCell.h"
#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"
#import "GooglePlacesObject.h"
#import "GroupPageViewController.h"
#import "ProposedActivityViewController.h"

#define kFeedLimit			40
#define kCellHeight			92.0f

#define kCellTypeGroup		0
#define kCellTypePA			1
#define kCellTypeComment	2

#define kMetersToMiles		0.000621371192
#define kMilesRadius		20.0

@interface DiscoverFeedViewController ()

@end

@implementation DiscoverFeedViewController

@synthesize locationManager;

#pragma mark - Helper Methods 

- (void)imageView:(PFImageView *)imgView setImage:(PFFile *)imageFile styled:(BOOL)styled {
	//NSData *picData = [imageFile getData];
	
	imgView.image = [UIImage imageNamed:@"FeedCellProfilePlaceholderPicture.png"]; //Placeholder
	
	if (imageFile) {
		imgView.file = imageFile;
		[imgView loadInBackground];
	}
	else {
		[imgView setImage:[UIImage imageNamed:@"FeedCellProfilePlaceholderPicture.png"]];
	}
	
	if (styled) {
		//Style user photo
		[imgView.layer setCornerRadius:10.0f];
		[imgView.layer setMasksToBounds:YES];
		[imgView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
		[imgView.layer setBorderWidth:4];
	}
}


- (NSAttributedString *)colorLabelString:(NSString *)string {
	NSArray *components = [string componentsSeparatedByString:@" at "];
	NSMutableAttributedString *attrStr = [NSMutableAttributedString attributedStringWithString:string];
	[attrStr setTextColor:[UIColor whiteColor]];
	[attrStr setFont:[UIFont fontWithName:@"Helvetica" size:14]];
	
	// now we change the color of the activity & location
	[attrStr setTextColor:[UIColor blueColor] range:[string rangeOfString:[components objectAtIndex:0]]];
	[attrStr setTextColor:[UIColor yellowColor] range:[string rangeOfString:[components objectAtIndex:1]]];
	
	return attrStr;
}

- (NSString *)stringForDate:(NSDate *)date {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"hh:mm a"];
	return [formatter stringFromDate:date];
}

- (BOOL)happendToday:(NSDate *)date {
	
	BOOL ret = NO;
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"MM/dd/yyyy"];
	
	NSDate *today = [NSDate date];
	NSString *todayString = [formatter stringFromDate:today];
	
	if ([todayString isEqualToString:[formatter stringFromDate:date]]) {
		ret = YES;
	}
	
	return ret;
}

- (NSString *)getDistanceAwayString:(PFGeoPoint *)locationTo {
	double distance = 0.0;
	distance = [userGeoPoint distanceInMilesTo:locationTo];
	return [NSString stringWithFormat:@"%.1f miles", distance];
}

- (void)configurePACell:(DiscoverCell *)cell withObject:(PFObject *)object {
	
	if (!object) {
		return;
	}
	
	//Get the PA and the parent group
	PFObject *pa = [object objectForKey:@"proposedActivity"];
	PFObject *group = [object objectForKey:@"group"];
	
	if (pa && group) {
		
		//Incase the data isn't loaded yet
		[pa fetchIfNeeded];
		[group fetchIfNeeded];
		
		PFUser *user = [pa objectForKey:@"creator"];
		[user fetchIfNeeded];
		
		PFFile *pic = [user objectForKey:@"image"];
		
		[cell.titleLabel setText:[NSString stringWithFormat:@"%@ proposed a group activity", [user username]]];
		[cell.activityLabel setText:[NSString stringWithFormat:@"at %@", [group objectForKey:@"place"]]];
		[cell.milesAwayLabel setText:[self getDistanceAwayString:[group objectForKey:@"location"]]];
		[cell.timeLabel setText:[self stringForDate:[pa updatedAt]]];
		[self imageView:cell.pictureView setImage:pic styled:YES];
		
		if ([self happendToday:[pa updatedAt]]) {
			[cell.todayIndicator setHidden:NO];
		}
		else {
			[cell.todayIndicator setHidden:YES];
		}
	}
}

- (void)configureGroupCell:(DiscoverCell *)cell withObject:(PFObject *)object {
	if (!object) {
		return;
	}
	
	int numberOfMembers = [[object objectForKey:@"number"] integerValue];
	
	[cell.titleLabel setText:[NSString stringWithFormat:@"%i people are doing", numberOfMembers]];
	[cell.pictureView setImage:[UIImage imageNamed:@"FeedCellActiveGroupActivityIconImage.png"]];
	
	//Get the group reference
	PFObject *group = [object objectForKey:@"group"];
	
	if (group) {
		[group fetchIfNeeded];
		
		NSString *activity = [NSString stringWithFormat:@"%@ at %@", [group objectForKey:@"activity"], [group objectForKey:@"place"]];
		[cell.activityLabel setAttributedText:[self colorLabelString:activity]];
		[cell.milesAwayLabel setText:[self getDistanceAwayString:[group objectForKey:@"location"]]];
		[cell.timeLabel setText:[self stringForDate:[group updatedAt]]];
		
		if ([self happendToday:[group updatedAt]]) {
			[cell.todayIndicator setHidden:NO];
		}
		else {
			[cell.todayIndicator setHidden:YES];
		}
	}
}

- (void)configureNewGroupCell:(DiscoverCell *)cell withObject:(PFObject *)object {
	if (!object) {
		return;
	}
	
	//Get the grour reference and the user that created it
	PFObject *group = [object objectForKey:@"group"];
	PFUser *user = [object objectForKey:@"creator"];
	
	if (group && user) {
		[group fetchIfNeeded];
		[user fetchIfNeeded];
		
		PFFile *pic = [user objectForKey:@"image"];
		
		NSString *activity = [NSString stringWithFormat:@"%@ at %@", [group objectForKey:@"activity"], [group objectForKey:@"place"]];
		[cell.activityLabel setAttributedText:[self colorLabelString:activity]];
		[cell.titleLabel setText:[NSString stringWithFormat:@"%@ is doing", [user username]]];
		[cell.milesAwayLabel setText:[self getDistanceAwayString:[group objectForKey:@"location"]]];
		[cell.timeLabel setText:[self stringForDate:[group updatedAt]]];
		[self imageView:cell.pictureView setImage:pic styled:YES];
		
		if ([self happendToday:[group updatedAt]]) {
			[cell.todayIndicator setHidden:NO];
		}
		else {
			[cell.todayIndicator setHidden:YES];
		}
	}
}

- (void)configureCommentCell:(DiscoverCell *)cell withObject:(PFObject *)object {
	if (!object) {
		return;
	}
	
	PFObject *comment = [object objectForKey:@"comment"];
	PFObject *pa = [object objectForKey:@"proposedActivity"];
	[pa fetchIfNeeded];
	
	PFObject *group = [pa objectForKey:@"group"];
	PFUser *user = [object objectForKey:@"creator"];
	
	[comment fetchIfNeeded];
	[group fetchIfNeeded];
	[user fetchIfNeeded];
	
	if (comment && pa && group && user) {
		
		PFFile *pic = [user objectForKey:@"image"];
		
		NSString *activity = [NSString stringWithFormat:@"%@ at %@", [group objectForKey:@"activity"], [group objectForKey:@"place"]];
		[cell.activityLabel setAttributedText:[self colorLabelString:activity]];
		[cell.titleLabel setText:[NSString stringWithFormat:@"%@ commented on proposed activity", [user username]]];
		[cell.milesAwayLabel setText:[self getDistanceAwayString:[group objectForKey:@"location"]]];
		[cell.timeLabel setText:[self stringForDate:[group updatedAt]]];
		[self imageView:cell.pictureView setImage:pic styled:YES];
		
		if ([self happendToday:[group updatedAt]]) {
			[cell.todayIndicator setHidden:NO];
		}
		else {
			[cell.todayIndicator setHidden:YES];
		}
	}
}

#pragma mark - PFQueryTableViewController 

// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.className];
	
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
	
	//Need to find all groups/proposed activities that are close by
	PFQuery *innerGroupQuery = [PFQuery queryWithClassName:@"Groups"];
	[innerGroupQuery whereKey:@"location" nearGeoPoint:userGeoPoint withinMiles:kMilesRadius];
	
	[query whereKey:@"group" matchesQuery:innerGroupQuery];
    [query orderByDescending:@"updatedAt"];
	
    return query;
}

// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
	static NSString *CellIdentifier = @"Cell";

	DiscoverCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DiscoverCell" owner:self options:nil];
		cell = [nib objectAtIndex:0];
    }
	
	[object fetchIfNeeded];
	
	//Get the type of the activity
	NSString *typeString = [object objectForKey:@"type"];
	NSString *statusString = [object objectForKey:@"status"];
	int type = ([typeString isEqualToString:@"NORMAL"]) ? kCellTypeGroup : ([statusString isEqualToString:@"COMMENT"]) ? kCellTypeComment : kCellTypePA;
	int numberOfMemebers = 0;
	
	if (type == kCellTypeGroup) {
		numberOfMemebers = [[object objectForKey:@"number"] integerValue];
	}
	
	switch (type) {
		case kCellTypeGroup:
			if (numberOfMemebers > 1) {
				[self configureGroupCell:cell withObject:object];	//Configure for multiple people doing this
			}
			else {
				[self configureNewGroupCell:cell withObject:object];	//New event with only one user
			}
			break;
		case kCellTypePA:
			[self configurePACell:cell withObject:object];
			break;
		case kCellTypeComment:
			[self configureCommentCell:cell withObject:object];
			break;
		default:
			break;
	}
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return kCellHeight;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
	
	if ([[self objects] count] <= indexPath.row) {
		return;
	}
	
	PFObject *object = [self objectAtIndex:indexPath];
	
	//Get the data if it hasn't been pulled from the server yet
	[object fetchIfNeeded];
	
	NSString *typeString = [object objectForKey:@"type"];
	int type = ([typeString isEqualToString:@"NORMAL"]) ? kCellTypeGroup : kCellTypePA;
	
	if (!object) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Loading" message:@"Cannot load this activity at this time" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		return;
	}
	
	PFObject *group = [object objectForKey:@"group"];
	[group fetchIfNeeded];
	
	switch (type) {
		case kCellTypeGroup: {
			PFGeoPoint *point = [group objectForKey:@"location"];
			GooglePlacesObject *place = [[GooglePlacesObject alloc] initWithName:[group objectForKey:@"place"] latitude:point.latitude longitude:point.longitude placeIcon:nil rating:nil vicinity:nil type:nil reference:nil url:nil addressComponents:nil formattedAddress:nil formattedPhoneNumber:nil website:nil internationalPhone:nil searchTerms:nil distanceInFeet:nil distanceInMiles:nil];
			GroupPageViewController *groupPage = [[GroupPageViewController alloc] initWithNibName:@"GroupPageViewController" bundle:nil place:place
																						 activity:[group objectForKey:@"activity"] challenge:NO autoJoin:NO];
			[self.navigationController pushViewController:groupPage animated:YES];
			break;
		}
		case kCellTypePA: {
			PFObject *selectedPA = [object objectForKey:@"proposedActivity"];
			[selectedPA fetchIfNeeded];
			ProposedActivityViewController *pa = [[ProposedActivityViewController alloc] initWithNibName:@"ProposedActivityViewController" bundle:nil proposedActivity:selectedPA];
			
			[self.navigationController pushViewController:pa animated:YES];
			break;
		}
		default:
			break;
	}
	
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - CLLocationManager Delegate

- (BOOL) isValidDistance:(CLLocation *)newLocation oldLocation:(CLLocation *)oldLocation {
    double distance = [newLocation distanceFromLocation:oldLocation] * kMetersToMiles;
    if (distance > .5) {
        return NO;
    }
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
	if (![self isValidDistance:newLocation oldLocation:oldLocation]) {
		return;
	}
	
	[locationManager stopUpdatingLocation];
	
	userGeoPoint = [PFGeoPoint geoPointWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
	
	[self.tableView reloadData];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error  {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't Find You"
													message:@"We could not find your location. Try again when you are in a better service area" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}


#pragma mark - View Life Cycle

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom the table
        if ([[FConfig instance] connected]) {
			locationManager = [[CLLocationManager alloc] init];
			[locationManager setDesiredAccuracy:kCLLocationAccuracyKilometer];
			[locationManager setDelegate:self];
			[locationManager setPurpose:@"To find activities close to you."];
			[locationManager startUpdatingLocation];
		}
		
        // The className to query on
        self.className = @"ActivityEvent";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 10;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
	self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	
    [locationManager stopUpdatingLocation];
	[locationManager setDelegate:nil];
	locationManager = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
