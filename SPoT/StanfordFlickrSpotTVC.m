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
    self.navigationItem.title = @"SPoT";
    [self.refreshControl addTarget:self action:@selector(loadStanfordPhotosFromFlickr) forControlEvents:UIControlEventValueChanged];
    [self loadStanfordPhotosFromFlickr];
}

- (void)loadStanfordPhotosFromFlickr
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t stanfordPhotoLoaderQ = dispatch_queue_create("stanford photo loader", NULL);
    dispatch_async(stanfordPhotoLoaderQ, ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSArray *arrayOfStanfordPhotos = [FlickrFetcher stanfordPhotos];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self makeStanfordSpotsWithArrayOfPhotos:arrayOfStanfordPhotos];
            [self.refreshControl endRefreshing];
        });
    });
}



@end
