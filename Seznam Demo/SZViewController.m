//
//  SZViewController.m
//  Seznam Demo
//
//  Created by Peter Molnár on 2.5.2014.
//  Copyright (c) 2014 Peter Molnár. All rights reserved.
//

#import "SZViewController.h"
#import "SZConnector.h"

#define THUMBNAIL_COUNT		10   // Required thumbnails count after first visible thummbnail
#define THUMBNAIL_MIN		5    // Mininimum thumbnails count before first visible thumbnail

@interface SZViewController ()

@end





@implementation SZViewController

#pragma mark - Initialize
//****************************************************************************************************
//*** Initialize
//****************************************************************************************************
//----------------------------------------------------------------------------------------------------
- (void) viewDidLoad
//----------------------------------------------------------------------------------------------------
{
    [super viewDidLoad];
	
	_connectors = [[ NSMutableArray alloc ] init ];

	_prevScrolledImageIndex = -1;
	_thumbnailViews = [[ NSMutableArray alloc ] init ];
	_imageView = [[ SZImageView alloc ] initWithViewController:self ];

	[ SZConnector downloadDataFromImageIndex:1 count:THUMBNAIL_COUNT searchText:_searchBar.text viewController:self ];
}

//----------------------------------------------------------------------------------------------------
- (void) viewWillAppear:(BOOL)animated
//----------------------------------------------------------------------------------------------------
{
	[ super viewWillAppear:animated ];

	if( UIInterfaceOrientationIsLandscape(self.interfaceOrientation) )
	{
		if( _thumbnailViews.count > 0 )
			_imageView.thumbnailView = _thumbnailViews.firstObject;
		else
			[ NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateLandscapeImageTimer:) userInfo:nil repeats:YES ];
		
		[ _imageView setVisible:YES animated:NO ];
	}
}

//----------------------------------------------------------------------------------------------------
- (void) updateLandscapeImageTimer:(NSTimer *)timer
//----------------------------------------------------------------------------------------------------
{
	NSLog(@"Timer");
	if( _thumbnailViews.count > 0 )
	{
		_imageView.thumbnailView = _thumbnailViews.firstObject;
		[ timer invalidate ];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
//----------------------------------------------------------------------------------------------------
{
    [super didReceiveMemoryWarning];
}


//----------------------------------------------------------------------------------------------------
- (UIStatusBarStyle)preferredStatusBarStyle
//----------------------------------------------------------------------------------------------------
{
	if( _imageView.visible == YES )
		return UIStatusBarStyleLightContent;
	
	return UIStatusBarStyleDefault;
}





#pragma mark - Connectors
//****************************************************************************************************
//*** Connectors
//****************************************************************************************************
//----------------------------------------------------------------------------------------------------
- (void) addConnector:(SZConnector *)connector
//----------------------------------------------------------------------------------------------------
{
	[ _connectors addObject:connector ];

	if( _connectors.count > 0 )
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES ];
}

//----------------------------------------------------------------------------------------------------
- (void) removeConnector:(SZConnector *)connector
//----------------------------------------------------------------------------------------------------
{
	[ _connectors removeObject:connector ];

	if( _connectors.count == 0 )
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO ];
}

//----------------------------------------------------------------------------------------------------
- (SZConnector *) connectorForImageIndex:(NSInteger)imageIndex
//----------------------------------------------------------------------------------------------------
{
	SZConnector *connector = nil;
	
	for(SZConnector *con in _connectors)
	{
		if( con.connectorType != 0 )
			continue;
		
		if( con.imageIndex >= imageIndex && imageIndex < con.imageIndex + con.count )
		{
			connector = con;
			break;
		}
	}
	
	return connector;
}



#pragma mark - Thumbnail Views
//****************************************************************************************************
//*** Thumbnail View
//****************************************************************************************************
//----------------------------------------------------------------------------------------------------
- (SZThumbnailView *) thumbnailWithImageIndex:(NSInteger)index
//----------------------------------------------------------------------------------------------------
{
	for( SZThumbnailView *thumbnailView in _thumbnailViews )
	{
		if( thumbnailView.imageIndex == index )
			return thumbnailView;
	}
	
	return nil;
}

//----------------------------------------------------------------------------------------------------
- (void) addThumbnailView:(SZThumbnailView *)thumbnailView
//----------------------------------------------------------------------------------------------------
{
	SZThumbnailView *lt = [ _thumbnailViews lastObject ];
	CGRect lastViewFrame = lt.frame;
	
	
	SZThumbnailView *prevThumbnailView = nil;
	SZThumbnailView *nextThumbnailView = nil;

	if( [ self thumbnailWithImageIndex:thumbnailView.imageIndex ])
	{
		NSLog(@"ERROR Thumbnail: %d", (int)thumbnailView.imageIndex);
		return;
	}
	
	NSInteger index = 0;
	for( int j = 0; j < (int)_thumbnailViews.count; j += 1 )
	{
		prevThumbnailView = [ _thumbnailViews objectAtIndex:j ];
		if( j < _thumbnailViews.count-1 )
			nextThumbnailView = [ _thumbnailViews objectAtIndex:j+1 ];

		//--- Add to Middle ---
		if( nextThumbnailView && thumbnailView.imageIndex > prevThumbnailView.imageIndex && thumbnailView.imageIndex < nextThumbnailView.imageIndex )
		{
			index += 1;
			break;
		}

		//--- Add to Top ---
		else if( nextThumbnailView && thumbnailView.imageIndex < nextThumbnailView.imageIndex )
		{
			break;
		}

		index += 1;
	}
	
	[ _thumbnailViews insertObject:thumbnailView atIndex:index ];
	[ _scrollView insertSubview:thumbnailView atIndex:index ];
	
	//----- Layout Thumbnail Views -----
	CGRect viewFrame;
	float currentY = 0;

	for( SZThumbnailView *subview in _thumbnailViews )
	{
		viewFrame = subview.frame;
		viewFrame.origin.y = currentY;
		subview.frame = viewFrame;
		
		currentY += viewFrame.size.height;
	}
	
	CGPoint offset = _scrollView.contentOffset;
	offset.y += lt.frame.origin.y - lastViewFrame.origin.y;
	
	_scrollView.delegate = nil;
	_scrollView.contentSize = CGSizeMake(viewFrame.size.width, currentY);
	_scrollView.contentOffset = offset;
	_scrollView.delegate = self;
}

//----------------------------------------------------------------------------------------------------
- (void) removeThumbnailViews
//----------------------------------------------------------------------------------------------------
{
	CGPoint scrollPoint = _scrollView.contentOffset;
	int currentThumbnailIndex = scrollPoint.y / 260.0;
	
	BOOL update = NO;
	
	//----- Update Thumbnail Views -----
	
	//--- Remove Thumbnail from Top ---
	if( currentThumbnailIndex - (currentThumbnailIndex % THUMBNAIL_MIN) - THUMBNAIL_MIN > 0 )
	{
		_scrollView.delegate = nil;
		int thumbsCount = currentThumbnailIndex - (currentThumbnailIndex % THUMBNAIL_MIN) - THUMBNAIL_MIN;
		
		for( int i = 0; i < thumbsCount; i += 1)
		{
			SZThumbnailView *thumbnailView = [ _thumbnailViews firstObject ];
			
			[ thumbnailView removeFromSuperview ];
			[ _thumbnailViews removeObjectAtIndex:0 ];

			currentThumbnailIndex -= 1;
			
			scrollPoint.y -= 260;
			_scrollView.contentOffset = scrollPoint;
			
			update = YES;
		}
		_scrollView.delegate = self;
	}
	
	//--- Remove Thumbnail from End ---
	if( currentThumbnailIndex + (THUMBNAIL_MIN - currentThumbnailIndex % THUMBNAIL_MIN) + THUMBNAIL_COUNT < _thumbnailViews.count )
	{
		NSInteger thubsCount = _thumbnailViews.count - (currentThumbnailIndex + (THUMBNAIL_MIN - currentThumbnailIndex % THUMBNAIL_MIN) + THUMBNAIL_COUNT);// - THUMBNAIL_COUNT;// - THUMBNAIL_MIN;
		for( int i = 0; i < thubsCount; i += 1)
		{
			SZThumbnailView *thumbnailView = [ _thumbnailViews lastObject ];
			
			[ thumbnailView removeFromSuperview ];
			[ _thumbnailViews removeLastObject ];

			update = YES;
		}
	}
	
	//----- Layout Thumbnail Views -----
	if( update )
	{
		CGRect viewFrame;
		float currentY = 0;
		for( SZThumbnailView *subview in _thumbnailViews )
		{
			viewFrame = subview.frame;
			viewFrame.origin.y = currentY;
			subview.frame = viewFrame;
			
			currentY += viewFrame.size.height;
		}
		
		_scrollView.delegate = nil;
		_scrollView.contentSize = CGSizeMake(viewFrame.size.width, currentY);
		_scrollView.delegate = self;
		
	}
}




#pragma mark - Scroll View Delegate
//****************************************************************************************************
//*** Scroll View Delegate
//****************************************************************************************************
//----------------------------------------------------------------------------------------------------
- (void) scrollViewDidScroll:(UIScrollView *)scrollView
//----------------------------------------------------------------------------------------------------
{
	CGPoint scrollPoint = _scrollView.contentOffset;
	int currentThumbnailIndex = scrollPoint.y / 260.0;
	
	SZThumbnailView *currentThumbnailView = [ _thumbnailViews objectAtIndex:currentThumbnailIndex ];
	SZThumbnailView *firstThumbnailView  = [ _thumbnailViews firstObject ];
	SZThumbnailView *lastThumbnailView  = [ _thumbnailViews lastObject ];
	
	if( _prevScrolledImageIndex == currentThumbnailView.imageIndex )
		return;
	
	//--- Add Thumbnail to Top ---
	if( firstThumbnailView.imageIndex > 1 && currentThumbnailIndex - THUMBNAIL_MIN < 0  )
	{
		NSInteger fromIndex = currentThumbnailView.imageIndex;
		NSInteger imagesCount = THUMBNAIL_MIN;
		
		if( currentThumbnailView.imageIndex - THUMBNAIL_MIN < 0 )
		{
			fromIndex = 1;
			imagesCount = currentThumbnailView.imageIndex;
		}
		
		else
		{
			fromIndex = currentThumbnailView.imageIndex - (currentThumbnailIndex % THUMBNAIL_MIN) - THUMBNAIL_MIN;
			imagesCount = THUMBNAIL_MIN;
		}
		
		if([ self connectorForImageIndex:fromIndex ] == nil)
			[ SZConnector downloadDataFromImageIndex:fromIndex count:imagesCount searchText:_searchBar.text viewController:self ];
		else
			NSLog(@"Connector exists: %d", (int)fromIndex );
	}
	
	//--- Add Thumbnail to Bottom ---
	else if( currentThumbnailIndex + THUMBNAIL_COUNT > _thumbnailViews.count )
	{
		if([ self connectorForImageIndex:lastThumbnailView.imageIndex+1 ] == nil)
			[ SZConnector downloadDataFromImageIndex:lastThumbnailView.imageIndex+1 count:THUMBNAIL_MIN searchText:_searchBar.text viewController:self ];
		else
			NSLog(@"Connector exists: %d", (int)lastThumbnailView.imageIndex+1 );
	}

	_prevScrolledImageIndex = currentThumbnailView.imageIndex;
}

//----------------------------------------------------------------------------------------------------
- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//----------------------------------------------------------------------------------------------------
{
	if( decelerate == NO )
		[ self removeThumbnailViews ];
}

//----------------------------------------------------------------------------------------------------
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//----------------------------------------------------------------------------------------------------
{
	[ self removeThumbnailViews ];
}





#pragma mark - Interface orientation
//****************************************************************************************************
//*** Interface orientation
//****************************************************************************************************
//----------------------------------------------------------------------------------------------------
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//----------------------------------------------------------------------------------------------------
{
	if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
	{
		NSInteger currentThumbnailIndex = ( _imageView.visible ) ? [ _thumbnailViews indexOfObject:_imageView.thumbnailView ] : _scrollView.contentOffset.y / 260.0;

		_fromLandscape = ( _imageView.visible ) ? NO : YES;

		_imageView.thumbnailView = [ _thumbnailViews objectAtIndex:currentThumbnailIndex ];
		_imageView.visible = YES;
	}

	else
	{
		_imageView.visible = ( _fromLandscape ) ? NO : YES;
	}
}





#pragma mark - SearchBar Delegate
//****************************************************************************************************
//*** SearchBar Delegate
//****************************************************************************************************
//----------------------------------------------------------------------------------------------------
- (void)searchBarTextDidBeginEditing:(UISearchBar *) bar
//----------------------------------------------------------------------------------------------------
{
    UITextField *searchBarTextField = nil;
    NSArray *views = [[bar.subviews objectAtIndex:0] subviews];
    for (UIView *subview in views)
    {
        if ([subview isKindOfClass:[UITextField class]])
        {
            searchBarTextField = (UITextField *)subview;
            break;
        }
    }

    searchBarTextField.enablesReturnKeyAutomatically = NO;
}

//----------------------------------------------------------------------------------------------------
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
//----------------------------------------------------------------------------------------------------
{
	[ _searchBar resignFirstResponder ];
	
	for( SZThumbnailView *thumbnailView in _thumbnailViews )
	{
		[ thumbnailView removeFromSuperview ];
	}
	
	[ _thumbnailViews removeAllObjects ];
	
	[ SZConnector downloadDataFromImageIndex:1 count:THUMBNAIL_COUNT searchText:searchBar.text viewController:self ];
//	[ _connectors addObject:connector ];
}
@end













