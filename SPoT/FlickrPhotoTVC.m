//
//  FlickrPhotoTVC.m
//  Shutterbug
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "FlickrPhotoTVC.h"
#import "FlickrFetcher.h"
#import "ImageViewController.h"

@implementation FlickrPhotoTVC

// sets the Model
// reloads the UITableView (since Model is changing)

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    [self.tableView reloadData];
}

#define MAX_NUMBER_OF_RECENT_PHOTOS 10

- (void)addPhotoToNSUserDefaults:(NSDictionary *)photo
{
    // initial save
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"Recent Photos"]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObject:photo] forKey:@"Recent Photos"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    BOOL exists = NO;
    for (NSDictionary *recentPhoto in [[NSUserDefaults standardUserDefaults] objectForKey:@"Recent Photos"]) {
        if ([[recentPhoto objectForKey:FLICKR_PHOTO_ID] isEqualToString:[photo objectForKey:FLICKR_PHOTO_ID]]) {
            exists = YES;
        }
    }
    // save to NSUserDefaults if that photo does not exist in NSUserDefaults
    if (!exists) {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"Recent Photos"] count] >= MAX_NUMBER_OF_RECENT_PHOTOS) {
            NSMutableArray *mutableArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Recent Photos"] mutableCopy];
            [mutableArray removeLastObject];
            [[NSUserDefaults standardUserDefaults] setObject:mutableArray forKey:@"Recent Photos"];
        }
        [[NSUserDefaults standardUserDefaults] setObject:[[NSArray arrayWithObject:photo] arrayByAddingObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"Recent Photos"]] forKey:@"Recent Photos"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - Segue

// prepares for the "Show Image" segue by seeing if the destination view controller of the segue
//  understands the method "setImageURL:"
// if it does, it sends setImageURL: to the destination view controller with
//  the URL of the photo that was selected in the UITableView as the argument
// also sets the title of the destination view controller to the photo's title

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Image"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]) {
                    NSURL *url = [FlickrFetcher urlForPhoto:self.photos[indexPath.row] format:FlickrPhotoFormatLarge];
                    [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:url];
                    [segue.destinationViewController setTitle:[self titleForRow:indexPath.row]];
                    
                    [self addPhotoToNSUserDefaults:self.photos[indexPath.row]];
                }
            }
        }
    }
}

#pragma mark - UITableViewDataSource

// lets the UITableView know how many rows it should display
// in this case, just the count of dictionaries in the Model's array

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count];
}

// a helper method that looks in the Model for the photo dictionary at the given row
//  and gets the title out of it

- (NSString *)titleForRow:(NSUInteger)row
{
    return [self.photos[row][FLICKR_PHOTO_TITLE] description]; // description because could be NSNull
}

// a helper method that looks in the Model for the photo dictionary at the given row
//  and gets the description of the photo out of it

- (NSString *)subtitleForRow:(NSUInteger)row
{
    return [[self.photos[row] valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] description]; // description because could be NSNull
}

// loads up a table view cell with the title and owner of the photo at the given row in the Model

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [self titleForRow:indexPath.row];
    cell.detailTextLabel.text = [self subtitleForRow:indexPath.row];
    
    return cell;
}

// in iPad version we dont't use segues so instead we just set .ImageUrl to URL of selected image

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.splitViewController.viewControllers lastObject] isKindOfClass:[ImageViewController class]]) {
        ((ImageViewController *)[self.splitViewController.viewControllers lastObject]).imageURL = [FlickrFetcher urlForPhoto:self.photos[indexPath.row] format:FlickrPhotoFormatOriginal];
        
        // we want our view to call viewDidLayoutSubviews once the image is loaded
        [((ImageViewController *)[self.splitViewController.viewControllers lastObject]) viewDidLayoutSubviews];
        
        [self addPhotoToNSUserDefaults:self.photos[indexPath.row]];
    }
}

@end
