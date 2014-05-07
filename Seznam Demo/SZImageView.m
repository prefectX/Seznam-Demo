//
//  SZImageView.m
//  Seznam Demo
//
//  Created by Peter Molnár on 2.5.2014.
//  Copyright (c) 2014 Peter Molnár. All rights reserved.
//

#import "SZImageView.h"
#import "SZViewController.h"
#import "SZThumbnailView.h"


#define ANIM_DURATION 0.5

@implementation SZImageView

#pragma mark - Initialize
//****************************************************************************************************
//*** Initialize
//****************************************************************************************************
//----------------------------------------------------------------------------------------------------
- (id)initWithViewController:(SZViewController *)viewController
//----------------------------------------------------------------------------------------------------
{
	CGRect viewFrame = CGRectMake(0, 0, 320, 480);
    self = [super initWithFrame:viewFrame ];
    if (!self)
		return nil;

	_viewController = viewController;
	self.backgroundColor = [ UIColor blackColor ];

	viewFrame = CGRectMake(0, 0, 320, 480);
	_scrollView = [[ UIScrollView alloc ] initWithFrame:viewFrame ];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.delegate = self;
	_scrollView.minimumZoomScale = 1.0;
	_scrollView.maximumZoomScale = 4.0;
	[ self addSubview:_scrollView ];
	
	viewFrame = CGRectMake(0, 0, 320, 480);
	_imageView = [[ UIImageView alloc ] initWithFrame:viewFrame ];
	_imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_imageView.contentMode = UIViewContentModeScaleAspectFit;
	[ self addSubview:_imageView ];

	viewFrame = CGRectMake(10, 30, 100, 30);
	_doneButton = [ UIButton buttonWithType:UIButtonTypeCustom ];
	_doneButton.frame = viewFrame;
	_doneButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
	_doneButton.layer.borderColor = [ UIColor whiteColor ].CGColor;
	_doneButton.layer.borderWidth = 1.0;
	_doneButton.layer.cornerRadius = 5.0;
	_doneButton.alpha = 0.0;
	_doneButton.titleLabel.font = [ UIFont systemFontOfSize:10 ];
	[ _doneButton addTarget:self action:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside ];
	[ _doneButton setTitle:@"Hotovo" forState:UIControlStateNormal ];
	[ self addSubview:_doneButton ];

	viewFrame = CGRectMake(self.frame.size.width-35, 30, 30, 30);
	_shareButton = [ UIButton buttonWithType:UIButtonTypeCustom ];
	_shareButton.frame = viewFrame;
	_shareButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	_shareButton.backgroundColor = [ UIColor whiteColor ];
	_shareButton.alpha = 0.0;
	[ _shareButton setImage:[ UIImage imageNamed:@"Share Image" ] forState:UIControlStateNormal ];
	[ _shareButton addTarget:self action:@selector(shareButtonTapped:) forControlEvents:UIControlEventTouchUpInside ];
	[ self addSubview:_shareButton ];

	UISwipeGestureRecognizer *swipeGestureRecognizer = [[ UISwipeGestureRecognizer alloc ] initWithTarget:self action:@selector(leftSwipeGesture:) ];
	swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
	[ self addGestureRecognizer:swipeGestureRecognizer ];
	
	swipeGestureRecognizer = [[ UISwipeGestureRecognizer alloc ] initWithTarget:self action:@selector(rightSwipeGesture:) ];
	swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
	[ self addGestureRecognizer:swipeGestureRecognizer ];
	

	
    return self;
}


//----------------------------------------------------------------------------------------------------
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
//----------------------------------------------------------------------------------------------------
{
	return _imageView;
}


//----------------------------------------------------------------------------------------------------
- (void) scrollViewDidZoom:(UIScrollView *)scrollView
//----------------------------------------------------------------------------------------------------
{
	if( _scrollView.zoomScale > 1.0 )
	{
		self.doneButtonVisible = NO;
		self.shareButtonVisible = NO;
	}
	else
	{
		self.doneButtonVisible = YES;
		self.shareButtonVisible = YES;
	}
}

//----------------------------------------------------------------------------------------------------
- (void) setVisible:(BOOL)visible
//----------------------------------------------------------------------------------------------------
{
	_visible = visible;
	
	//----- Image Detail Visible -----
	if( _visible == YES )
	{
		CGRect frame = CGRectMake(0, 0, 0, 0);
		
		if( UIInterfaceOrientationIsPortrait(_viewController.interfaceOrientation) )
		{
			frame.size.width = _viewController.view.frame.size.width;
			frame.size.height = _viewController.view.frame.size.height;
		}
		else
		{
			frame.size.width = _viewController.view.frame.size.height;
			frame.size.height = _viewController.view.frame.size.width;
		}
		
		self.frame = frame;
		
		[ _viewController.view addSubview:self ];

		[ _scrollView setZoomScale:1.0 animated:NO ];

		_imageView.image = _thumbnailView.image;
		_imageView.frame = [ self convertRect:_thumbnailView.imageThumbnailView.frame fromView:_thumbnailView.imageThumbnailView.superview ];
		[ self addSubview:_imageView ];
		
		//--- Background Animation ---
		self.alpha = 0.0;
		[ UIView animateWithDuration:ANIM_DURATION
							   delay:0.0
							 options:0
						  animations:^{
							  self.alpha = 1.0;
						  }
						  completion:^(BOOL finished){
						  }];
		
		//--- Image View Animation ---
		[ UIView animateWithDuration:ANIM_DURATION
							   delay:ANIM_DURATION
							 options:0
						  animations:^{
							  _imageView.frame = frame ;//CGRectMake(0, 0, 320, 480);
						  }
						  completion:^(BOOL finished){
							  [ _imageView removeFromSuperview ];
							  [ self.scrollView addSubview:_imageView ];

							  self.doneButtonVisible = ( UIInterfaceOrientationIsPortrait(_viewController.interfaceOrientation) ) ? YES : NO;
							  self.shareButtonVisible = YES;
						  }];
	}
	
	
	//----- Image Detail Not Visible -----
	else
	{
		[ _scrollView scrollRectToVisible:CGRectMake(0, 0, 320, 480) animated:YES ];
		[ _scrollView setZoomScale:1.0 animated:YES ];

		self.doneButtonVisible = NO;
		self.shareButtonVisible = NO;
		
		//--- Image View Animation ---
		[ _imageView removeFromSuperview ];
		[ self addSubview:_imageView ];
		[ UIView animateWithDuration:ANIM_DURATION
							   delay:ANIM_DURATION
							 options:0
						  animations:^{
							  _imageView.frame = [ self convertRect:_thumbnailView.imageThumbnailView.frame fromView:_thumbnailView.imageThumbnailView.superview ];
						  }
						  completion:^(BOOL finished){
						  }];
		
		//--- Background Animation ---
		[ UIView animateWithDuration:ANIM_DURATION
							   delay:2*ANIM_DURATION
							 options:0
						  animations:^{
							  self.alpha = 0.0;
						  }
						  completion:^(BOOL finished){
						  }];
		
	}
}

//----------------------------------------------------------------------------------------------------
- (void) setDoneButtonVisible:(BOOL)doneButtonVisible
//----------------------------------------------------------------------------------------------------
{
	if( doneButtonVisible && UIInterfaceOrientationIsLandscape(_viewController.interfaceOrientation))
		return;
	
	//--- Buttons Animation ---
	[ UIView animateWithDuration:ANIM_DURATION
						   delay:0.0
						 options:0
					  animations:^{
						  _doneButton.alpha = (doneButtonVisible == YES) ? 1.0 : 0.0;
					  }
					  completion:^(BOOL finished){
					  }];
	
}

//----------------------------------------------------------------------------------------------------
- (void) setShareButtonVisible:(BOOL)shareButtonVisible
//----------------------------------------------------------------------------------------------------
{
	//--- Buttons Animation ---
	[ UIView animateWithDuration:ANIM_DURATION
						   delay:0.0
						 options:0
					  animations:^{
						  _shareButton.alpha = (shareButtonVisible == YES) ? 1.0 : 0.0;
					  }
					  completion:^(BOOL finished){
					  }];
	
}




//----------------------------------------------------------------------------------------------------
- (IBAction) doneButtonTapped:(id)sender
//----------------------------------------------------------------------------------------------------
{
	self.visible = NO;
}

//----------------------------------------------------------------------------------------------------
- (IBAction) shareButtonTapped:(id)sender
//----------------------------------------------------------------------------------------------------
{
	NSArray *activityItems = [NSArray arrayWithObjects:self.imageView.image, nil];
	
	UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
	activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	activityViewController.excludedActivityTypes = @[UIActivityTypePostToWeibo,
										 UIActivityTypeMessage,
										 UIActivityTypePrint,
										 UIActivityTypeCopyToPasteboard,
										 UIActivityTypeAssignToContact,
										 UIActivityTypeSaveToCameraRoll,
										 UIActivityTypeAddToReadingList,
										 UIActivityTypePostToFlickr,
										 UIActivityTypePostToVimeo,
										 UIActivityTypePostToTencentWeibo,
										 UIActivityTypeAirDrop];
	
	[ self.viewController presentViewController:activityViewController animated:YES completion:nil ];
}


#pragma mark Gestures
//----------------------------------------------------------------------------------------------------
- (void) leftSwipeGesture:(UISwipeGestureRecognizer *)gestureRecognizer
//----------------------------------------------------------------------------------------------------
{
	SZThumbnailView *thumbnailView = [ self.viewController thumbnailWithImageIndex:_thumbnailView.imageIndex + 1 ];
	if( thumbnailView == nil )
	{
//		NSLog(@"ERROR: %d", (int)_thumbnailView.imageIndex+1 );
		return;
	}
	
	_thumbnailView = thumbnailView;
	_imageView.image = thumbnailView.image;
	
	CATransition *transition = [ CATransition animation ];
	transition.duration = 0.5f;
	transition.timingFunction = [ CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut ];
	transition.type = kCATransitionPush;
	transition.subtype = kCATransitionFromRight;
	[ _imageView.layer addAnimation:transition forKey:nil ];
	
	//--- Add Thumbnail to Bottom ---
	CGPoint scrollPoint = _viewController.scrollView.contentOffset;
	scrollPoint.y += 260;
	_viewController.scrollView.contentOffset = scrollPoint;

	[ _viewController removeThumbnailViews ];
}

//----------------------------------------------------------------------------------------------------
- (void) rightSwipeGesture:(UISwipeGestureRecognizer *)gestureRecognizer
//----------------------------------------------------------------------------------------------------
{
	if( _thumbnailView.imageIndex == 1 )
		return;
	
	SZThumbnailView *thumbnailView = [ self.viewController thumbnailWithImageIndex:_thumbnailView.imageIndex - 1 ];
	if( thumbnailView == nil )
	{
//		NSLog(@"ERROR: %d", (int)_thumbnailView.imageIndex-1 );
		return;
	}
	
	_thumbnailView = thumbnailView;
	_imageView.image = thumbnailView.image;

	CATransition *transition = [ CATransition animation ];
	transition.duration = 0.5f;
	transition.timingFunction = [ CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut ];
	transition.type = kCATransitionPush;
	transition.subtype = kCATransitionFromLeft;
	[ _imageView.layer addAnimation:transition forKey:nil ];
	
	//--- Add Thumbnail to Top ---
	CGPoint scrollPoint = _viewController.scrollView.contentOffset;
	scrollPoint.y -= 260;
	
	if( scrollPoint.y >= 0)
		_viewController.scrollView.contentOffset = scrollPoint;
	
	[ _viewController removeThumbnailViews ];
}


@end
