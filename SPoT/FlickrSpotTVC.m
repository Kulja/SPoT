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
@property (strong, nonatomic) NSArray *spots;
@end

@implementation FlickrSpotTVC

// starts creating the model for this VC

- (void)makeStanfordSpotsWithArrayOfPhotos:(NSArray *)stanfordImages
{
    // final array of dictionaries which will be sorted by tags
    //  we will use this because allKeys on dictionary does not preserve order
    NSMutableArray *sortedDictionariesInArray = [NSMutableArray array];
    
    // dictionary with stanford images sorted by keys (keys are tags)
    NSMutableDictionary *sortedPhotosByTags = [NSMutableDictionary dictionary];
    
    for (NSDictionary *imageInfo in stanfordImages) {
        
        // getting FLICKR_TAGS out of our image and formating it to our needs
        NSArray *tempArray = [[imageInfo objectForKey:FLICKR_TAGS] componentsSeparatedByString:@" "];
        NSString *tag = @"";
        for (NSString *tempString in tempArray) {
            if (![tempString isEqualToString:@"cs193pspot"] && ![tempString isEqualToString:@"portrait"] && ![tempString isEqualToString:@"landscape"]) {
                tag = [tag stringByAppendingFormat:@"%@ ", tempString];
            }
        }
        // removing space at the end of our formated tag and capitalizing it
        if ([tag length] > 0) {
            tag = [[tag substringToIndex:[tag length] - 1] capitalizedString];
        }
        
        // if our formated tag exist (as a key) in our sortedPhotosByTags dictionary then add our image to it in an array
        if ([sortedPhotosByTags objectForKey:tag]) {
            [sortedPhotosByTags setObject:[[sortedPhotosByTags objectForKey:tag] arrayByAddingObject:imageInfo] forKey:tag];
        } else {
            // if it doesn't exist then create one
            [sortedPhotosByTags setObject:[NSArray arrayWithObject:imageInfo] forKey:tag];
        }
    }
    
    // preparing for sorting each array of images in sortedPhotosByTags dictionary by FLICKR_PHOTO_TITLE
    NSSortDescriptor* photoTitleSortDescriptor = [[NSSortDescriptor alloc] initWithKey:FLICKR_PHOTO_TITLE ascending:YES];
    
    // sort our tags (keys) so that we put our dictionaries in sortedDictionariesInArray by ordered tags
    NSArray *sortedKeys = [[sortedPhotosByTags allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    for (NSString *key in sortedKeys) {
        // creating sorted (by keys) array of images (sorted by FLICKR_PHOTO_TITLE) and adding that array to sortedDictionariesInArray
        NSArray* sortedArray = [[sortedPhotosByTags objectForKey:key] sortedArrayUsingDescriptors:[NSArray arrayWithObject:photoTitleSortDescriptor]];
        [sortedDictionariesInArray addObject:[NSDictionary dictionaryWithObject:sortedArray forKey:key]];
    }
    
    self.spots = sortedDictionariesInArray;
}

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
