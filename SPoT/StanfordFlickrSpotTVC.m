//
//  StanfordFlickrSpotTVC.m
//  SPoT
//
//  Created by Marko Kuljanski on 2/20/13.
//  Copyright (c) 2013 Marko Kuljanski. All rights reserved.
//

#import "StanfordFlickrSpotTVC.h"
#import "FlickrFetcher.h"

@implementation StanfordFlickrSpotTVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // final array of dictionaries which will be sorted by tags
    //  we will use this because allKeys on dictionary does not preserve order
    NSMutableArray *sortedDictionariesInArray = [NSMutableArray array];
    
    // dictionary with stanford images sorted by keys (keys are tags)
    NSMutableDictionary *sortedPhotosByTags = [NSMutableDictionary dictionary];
    
    for (NSDictionary *imageInfo in [FlickrFetcher stanfordPhotos]) {
        
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

    self.navigationItem.title = @"SPoT";
    self.spots = sortedDictionariesInArray;
}

@end
