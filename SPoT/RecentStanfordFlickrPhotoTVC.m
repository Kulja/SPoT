//
//  RecentStanfordFlickrPhotoTVC.m
//  SPoT
//
//  Created by Marko Kuljanski on 2/21/13.
//  Copyright (c) 2013 Marko Kuljanski. All rights reserved.
//

#import "RecentStanfordFlickrPhotoTVC.h"
#import "FlickrFetcher.h"

@implementation RecentStanfordFlickrPhotoTVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
    self.photos = [[NSUserDefaults standardUserDefaults] objectForKey:@"Recent Photos"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Recents";
}

@end
