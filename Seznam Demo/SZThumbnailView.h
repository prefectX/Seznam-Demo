//
//  SZThumbnailView.h
//  Seznam Demo
//
//  Created by Peter Molnár on 2.5.2014.
//  Copyright (c) 2014 Peter Molnár. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SZViewController;

/*
 Nahlad obrazku
 */

@interface SZThumbnailView : UIView

@property	(weak, nonatomic, readonly)				SZViewController			*viewController;

@property	(assign, nonatomic)						NSInteger					imageIndex;
@property	(strong, nonatomic)						NSURL						*imageURL;
@property	(strong, nonatomic)						NSURL						*thumbnailURL;

@property	(strong, nonatomic)						UIActivityIndicatorView		*activityView;

@property	(strong, nonatomic)						UIImageView					*imageThumbnailView;
@property	(strong, nonatomic)						UILabel						*imageNameTF;
@property	(strong, nonatomic)						UILabel						*imageSizeTF;

@property	(assign, nonatomic, readonly)			UIImage						*thumbnailImage;
@property	(strong, nonatomic, readonly)			UIImage						*image;

@property	(strong, nonatomic)						UIView						*lineView;


- (id)initWithViewController:(SZViewController *)viewController;

@end
