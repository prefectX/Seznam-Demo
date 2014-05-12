//
//  SZThumbnailView.m
//  Seznam Demo
//
//  Created by Peter Molnár on 2.5.2014.
//  Copyright (c) 2014 Peter Molnár. All rights reserved.
//

#import "SZThumbnailView.h"
#import "SZViewController.h"

@implementation SZThumbnailView



#pragma mark - Initialize
//****************************************************************************************************
//*** Initialize
//****************************************************************************************************
//----------------------------------------------------------------------------------------------------
- (id)initWithViewController:(SZViewController *)viewController
//----------------------------------------------------------------------------------------------------
{
	CGRect viewFrame = CGRectMake(0, 0, 320, 260);
	self = [super initWithFrame:viewFrame];
    if (!self)
		return nil;

	_viewController = viewController;
	self.userInteractionEnabled = YES;
	
	_imageIndex = -1;
	
	viewFrame = CGRectMake(20, 20, 280, 210);
	_imageThumbnailView = [[ UIImageView alloc ] initWithFrame:viewFrame ];
	_imageThumbnailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_imageThumbnailView.userInteractionEnabled = NO;
	_imageThumbnailView.contentMode = UIViewContentModeScaleAspectFit;
	[ self addSubview:_imageThumbnailView ];

	viewFrame = CGRectMake(20, 237, 200, 15);
	_imageNameTF = [[ UILabel alloc ] initWithFrame:viewFrame ];
	_imageNameTF.font = [ UIFont fontWithName:@"HelveticaNeue-Light" size:12 ];
	_imageNameTF.textColor = [ UIColor lightGrayColor ];
	[ self addSubview:_imageNameTF ];
	
	viewFrame = CGRectMake(228, 237, 72, 15);
	_imageSizeTF = [[ UILabel alloc ] initWithFrame:viewFrame ];
	_imageSizeTF.font = [ UIFont fontWithName:@"HelveticaNeue-Light" size:12 ];
	_imageSizeTF.textColor = [ UIColor lightGrayColor ];
	_imageSizeTF.textAlignment = NSTextAlignmentRight;
	[ self addSubview:_imageSizeTF ];
	
	viewFrame = CGRectMake(20, self.frame.size.height-1, self.frame.size.width-20, 1);
	_lineView = [[ UIView alloc ] initWithFrame:viewFrame ];
	_lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	_lineView.backgroundColor = [ UIColor lightGrayColor ];
	[ self addSubview:_lineView ];

	_activityView = [[ UIActivityIndicatorView alloc ] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray ];
	_activityView.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
	_activityView.color = [ UIColor blackColor ];
	[ self addSubview:_activityView ];
	[ _activityView startAnimating ];

	UITapGestureRecognizer *tapGestureRecognizer = [[ UITapGestureRecognizer alloc ] initWithTarget:self action:@selector(thumbnailViewTapped:) ];
	[ self addGestureRecognizer:tapGestureRecognizer ];

    return self;
}


#pragma mark - Properties
//****************************************************************************************************
//*** Properties
//****************************************************************************************************
//----------------------------------------------------------------------------------------------------
- (void) setThumbnailURL:(NSURL *)thumbnailURL
//----------------------------------------------------------------------------------------------------
{
	_thumbnailURL = thumbnailURL;
	
	[ SZConnector downloadImageWithImageIndex:_imageIndex URL:thumbnailURL connectorType:1 viewController:_viewController ];
}

//----------------------------------------------------------------------------------------------------
- (void) setThumbnailImage:(UIImage *)thumbnailImage
//----------------------------------------------------------------------------------------------------
{
	_thumbnailImage = thumbnailImage;
	_imageThumbnailView.image = thumbnailImage;
	
	[ _activityView stopAnimating ];
}

//----------------------------------------------------------------------------------------------------
- (void) setImageURL:(NSURL *)imageURL
//----------------------------------------------------------------------------------------------------
{
	_imageURL = imageURL;

	[ SZConnector downloadImageWithImageIndex:_imageIndex URL:imageURL connectorType:2 viewController:_viewController ];
}


//----------------------------------------------------------------------------------------------------
- (void) thumbnailViewTapped:(UITapGestureRecognizer *)gestureRecognizer
//----------------------------------------------------------------------------------------------------
{
	NSLog(@"Tapped: %d: %@", (int)self.imageIndex, self.imageURL );
	
	if( self.image )
	{
		_viewController.imageView.thumbnailView = self;
		_viewController.imageView.visible = YES;
	}
	else
	{
		UIAlertView *alert = [[ UIAlertView alloc ] initWithTitle:@"Error" message:@"No image found" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil ];
		[ alert show];
	}
}

@end
