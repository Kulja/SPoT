//
//  ImageViewController.m
//  Shutterbug
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleBarButtonItem;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (readonly, strong, nonatomic) NSURL *imageCacheFilePath;
@property (readonly, strong, nonatomic) NSURL *cacheDirectory;
@property (readonly, nonatomic) double cacheSize;
@end

@implementation ImageViewController

- (double)cacheSize
{
    if (self.scrollView.bounds.size.width > 600) {
        return 10000000;
    } else {
        return 3000000;
    }
}

- (NSURL *)cacheDirectory
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *paths = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL *url = [[paths lastObject] URLByAppendingPathComponent:@"/images/"];
    if (![url checkResourceIsReachableAndReturnError:nil]) {
        [fileManager createDirectoryAtURL:url withIntermediateDirectories:NO attributes:nil error:nil];
    }

    return url;
}

- (NSURL *)imageCacheFilePath
{
    NSURL *url = nil;
    if (self.imageURL) {
        // getting just the last part of url with extension
        url = [self.cacheDirectory URLByAppendingPathComponent:[[self.imageURL pathComponents] lastObject]];
    }
    return url;
}

// set splitViewBarButtonItem when we are in split view controller

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    UIToolbar *toolbar = [self toolbar]; // probably an outlet
    NSMutableArray *toolbarItems = [toolbar.items mutableCopy];
    if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
    // put the bar button on the left of our existing toolbar
    if (barButtonItem) [toolbarItems insertObject:barButtonItem atIndex:0];
    toolbar.items = toolbarItems;
    _splitViewBarButtonItem = barButtonItem;
}

// set title for titleBarButtonItem whenever we set title for our view controller

- (void)setTitle:(NSString *)title
{
    super.title = title;
    self.titleBarButtonItem.title = title;
}

// resets the image whenever the URL changes

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self resetImage];
}

// fetches the data from the URL or from cache
// turns it into an image
// adjusts the scroll view's content size to fit the image
// sets the image as the image view's image

- (void)resetImage
{
    if (self.scrollView) {
        self.scrollView.contentSize = CGSizeZero;
        self.imageView.image = nil;
        NSURL *imageURL = self.imageURL;
        
        [self.spinner startAnimating];
        dispatch_queue_t imageFetchQ = dispatch_queue_create("image fetcher", NULL);
        dispatch_async(imageFetchQ, ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            NSData *imageData = [NSData dataWithContentsOfURL:self.imageCacheFilePath];
            UIImage *image = [UIImage imageWithData:imageData];
            if (!image) {
                imageData = [[NSData alloc] initWithContentsOfURL:self.imageURL];
                image = [[UIImage alloc] initWithData:imageData];
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            if (self.imageURL == imageURL) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image) {
                        self.scrollView.zoomScale = 1.0;
                        self.scrollView.contentSize = image.size;
                        self.imageView.image = image;
                        self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                        
                        [self viewDidLayoutSubviews];
                        [self savePhotoInCache:imageData];
                    }
                    [self.spinner stopAnimating];
                });
            }
        });
    }
}

// image caching

- (void)savePhotoInCache:(NSData *)imageData
{
    dispatch_queue_t imageFetchQ = dispatch_queue_create("image writter", NULL);
    dispatch_async(imageFetchQ, ^{
        [imageData writeToURL:self.imageCacheFilePath atomically:YES];
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        double cache_folder_size = 0;
        NSURL *lastAccessedImagePath;
        for (NSURL *url in [fileManager contentsOfDirectoryAtURL:self.cacheDirectory includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLFileSizeKey, NSURLContentAccessDateKey, nil] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil]) {
            cache_folder_size += [[[url resourceValuesForKeys:[NSArray arrayWithObject:NSURLFileSizeKey] error:nil] objectForKey:NSURLFileSizeKey] doubleValue];
            
            // making sure that lastly accessed photo path is in lastAccessedImagePath
            if (([[[lastAccessedImagePath resourceValuesForKeys:[NSArray arrayWithObject:NSURLContentAccessDateKey] error:nil] objectForKey:NSURLContentAccessDateKey] compare:[[url resourceValuesForKeys:[NSArray arrayWithObject:NSURLContentAccessDateKey] error:nil] objectForKey:NSURLContentAccessDateKey]] == NSOrderedDescending) || !lastAccessedImagePath) {
                lastAccessedImagePath = url;
            }
        }
        
        if (cache_folder_size > self.cacheSize) {
            [fileManager removeItemAtURL:lastAccessedImagePath error:nil];
        }
    });
}

// lazy instantiation

- (UIImageView *)imageView
{
    if (!_imageView) _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    return _imageView;
}

// returns the view which will be zoomed when the user pinches
// in this case, it is the image view, obviously
// (there are no other subviews of the scroll view in its content area)

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

// add the image view to the scroll view's content area
// setup zooming by setting min and max zoom scale
//   and setting self to be the scroll view's delegate
// resets the image in case URL was set before outlets (e.g. scroll view) were set

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
    [self resetImage];
    self.titleBarButtonItem.title = self.title;
}

// after every bounds change set the zoomScale to show as much of the photo as possible with
//  no extra unused space

- (void)viewDidLayoutSubviews
{
    CGFloat scaleWidth = self.scrollView.bounds.size.width / self.imageView.bounds.size.width;
    CGFloat scaleHeight = self.scrollView.bounds.size.height / self.imageView.bounds.size.height;
    
    self.scrollView.minimumZoomScale = MIN(scaleWidth, scaleHeight);
    self.scrollView.zoomScale = MAX(scaleWidth, scaleHeight);
    
    [self centerScrollViewContents];

    // whenever we change our bounds check if splitViewBarButtonItem should be set or not
    self.splitViewBarButtonItem = self.splitViewBarButtonItem;
}

// positioning the image view such that it is always in the center of the scroll view’s bounds

- (void)centerScrollViewContents {
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < self.scrollView.bounds.size.width) {
        contentsFrame.origin.x = (self.scrollView.bounds.size.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < self.scrollView.bounds.size.height) {
        contentsFrame.origin.y = (self.scrollView.bounds.size.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so you need to re-center the contents
    [self centerScrollViewContents];
}

@end
