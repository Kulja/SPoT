//
//  FlickrSpotTVC.m
//  SPoT
//
//  Created by Marko Kuljanski on 2/20/13.
//  Copyright (c) 2013 Marko Kuljanski. All rights reserved.
//

#import "FlickrSpotTVC.h"
#import "FlickrFetcher.h"

@interface FlickrSpotTVC ()

@end

@implementation FlickrSpotTVC

// sets the Model
// reloads the UITableView (since Model is changing)

- (void)setSpots:(NSArray *)spots
{
    _spots = spots;
    [self.tableView reloadData];
}

#pragma mark - Segue

// prepares for the "Show Photos in Spot" segue by seeing if the destination view controller of the segue
//  understands the method "setPhotos:"
// if it does, it sends setPhotos: to the destination view controller with
//  the NSArray of NSDictionaries of the spot that was selected in the UITableView as the argument
// also sets the title of the destination view controller to the spots's title

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Photos in Spot"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setPhotos:)]) {
                    NSArray *array = [[self.spots objectAtIndex:indexPath.row] objectForKey:[self titleForRow:indexPath.row]];
                    [segue.destinationViewController performSelector:@selector(setPhotos:) withObject:array];
                    [segue.destinationViewController setTitle:[self titleForRow:indexPath.row]];
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
    return [self.spots count];
}

// a helper method that looks in the Model for the spot dictionary at the given row
//  and gets the last Key as a title (there will always be only one Key so with lastObject we ge the title that we want)

- (NSString *)titleForRow:(NSUInteger)row
{
    return [[[self.spots objectAtIndex:row] allKeys] lastObject];
}

// a helper method that looks in the Model for the spot dictionary at the given row
//  and gets the number of NSArray objects in that NSDictionary 

- (NSString *)subtitleForRow:(NSUInteger)row
{
    return [NSString stringWithFormat:@"%d photos", [[[self.spots objectAtIndex:row] objectForKey:[self titleForRow:row]] count]];
}

// loads up a table view cell with the spot name and number of photos in that spot at the given row in the Model

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Spot";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [self titleForRow:indexPath.row];
    cell.detailTextLabel.text = [self subtitleForRow:indexPath.row];
    
    return cell;
}


@end
