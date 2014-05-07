//
//  SZViewController.h
//  Seznam Demo
//
//  Created by Peter Molnár on 2.5.2014.
//  Copyright (c) 2014 Peter Molnár. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SZThumbnailView.h"
#import "SZImageView.h"

@interface SZViewController : UIViewController <UIScrollViewDelegate, UISearchBarDelegate>
{
	NSInteger _prevScrolledImageIndex;
	
}

@property	(weak, nonatomic)				IBOutlet		UISearchBar				*searchBar;
@property	(weak, nonatomic)				IBOutlet		UIScrollView			*scrollView;

@property	(strong, nonatomic, readonly)					NSMutableArray			*thumbnailViews;
@property	(strong, nonatomic, readonly)					SZImageView				*imageView;

@property	(strong, nonatomic)								NSMutableArray			*connectors;


- (SZThumbnailView *) thumbnailWithImageIndex:(NSInteger)index;

- (void) addThumbnailView:(SZThumbnailView *)thumbnailView;
- (void) removeThumbnailViews;

- (IBAction) thumbnailViewTapped:(id)sender;

@end
