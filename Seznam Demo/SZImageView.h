//
//  SZImageView.h
//  Seznam Demo
//
//  Created by Peter Molnár on 2.5.2014.
//  Copyright (c) 2014 Peter Molnár. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SZViewController;
@class SZThumbnailView;


/*
 Detail obrazku - fullscreen
 */

@interface SZImageView : UIView <UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property	(weak, nonatomic, readonly)			SZViewController	*viewController;

@property	(assign, nonatomic)					SZThumbnailView		*thumbnailView;

@property	(assign, nonatomic)					BOOL				visible;
@property	(assign, nonatomic)					BOOL				doneButtonVisible;
@property	(assign, nonatomic)					BOOL				shareButtonVisible;

@property	(strong, nonatomic)					UIButton			*doneButton;
@property	(strong, nonatomic)					UIButton			*shareButton;

@property	(strong, nonatomic)					UIScrollView		*scrollView;
@property	(strong, nonatomic)					UIImageView			*imageView;


- (id)initWithViewController:(SZViewController *)viewController;

- (void) setVisible:(BOOL)visible animated:(BOOL)animated;

@end
