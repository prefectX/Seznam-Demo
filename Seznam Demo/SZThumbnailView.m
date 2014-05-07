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
	_imageThumbnailView.backgroundColor = [ UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0 ];
//	_imageThumbnailView.hidden = YES;
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
	
	dispatch_queue_t backgroundQueue = dispatch_queue_create("cz.seznam",NULL);
	dispatch_async(backgroundQueue, ^(void) {

		NSURLRequest *req = [ NSURLRequest requestWithURL:thumbnailURL ];
		NSURLResponse *res = nil;
		NSError *error = nil;
		
		NSData *data = [ NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&error ];
		if( data )
		{
			UIImage *thumbnailImage = [ UIImage imageWithData:data ];
			if( thumbnailImage )
			{
				dispatch_async(dispatch_get_main_queue(), ^{
					self.imageThumbnailView.image = thumbnailImage;
//					_imageThumbnailView.hidden = NO;
					[ _activityView stopAnimating ];
				});
			}
			
			dispatch_async(dispatch_get_main_queue(), ^{
			});
		}
	});
}

//----------------------------------------------------------------------------------------------------
- (void) setImageURL:(NSURL *)imageURL
//----------------------------------------------------------------------------------------------------
{
	_imageURL = imageURL;
	
	dispatch_queue_t backgroundQueue = dispatch_queue_create("cz.seznam",NULL);
	dispatch_async(backgroundQueue, ^(void) {
		
		NSURLResponse *response = nil;
		NSError *error = nil;
		
		NSData *data = [ NSURLConnection sendSynchronousRequest:[ NSURLRequest requestWithURL:_imageURL ] returningResponse:&response error:&error ];
		if( error )
		{
			NSLog(@"Image Download Error: %@", error.description);
			return;
		}
		
		if( data )
		{
			_image = [ UIImage imageWithData:data ];
			if( !_image )
			{
				NSLog(@"Image Data Error: %d -> %@", (int)_imageIndex, _imageURL);
			}
		}
	});
}


//----------------------------------------------------------------------------------------------------
- (void) thumbnailViewTapped:(UITapGestureRecognizer *)gestureRecognizer
//----------------------------------------------------------------------------------------------------
{
	[ self.viewController thumbnailViewTapped:self ];
}

@end
