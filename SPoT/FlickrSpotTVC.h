//
//  FlickrSpotTVC.h
//  SPoT
//
//  Created by Marko Kuljanski on 2/20/13.
//  Copyright (c) 2013 Marko Kuljanski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrSpotTVC : UITableViewController

// the Model for this VC
// an array of dictionaries of arrays of Flickr information obtained using Flickr API
// each object in spots array is a dictionary wihh only ONE key that represents one spot
//  and object under that key is an array of dictionaries that represent images info
@property (nonatomic, strong) NSArray *spots; // of NSDictionary of NSArray

@end
