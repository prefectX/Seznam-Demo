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

	SZConnector *connector = [ SZConnector downloadDataFromImageIndex:1 count:THUMBNAIL_COUNT searchText:_searchBar.text viewController:self ];
	[ _connectors addObject:connector ];
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
//----------------------------------------------------------------------------------------------------
{
    [super didReceiveMemoryWarning];
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
//		NSLog(@"ERROR Thumbnail: %d", (int)thumbnailView.imageIndex);
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
			[ self removeThumbnailAtTop ];
			currentThumbnailIndex -= 1;
			
			scrollPoint.y -= 260;
			_scrollView.contentOffset = scrollPoint;
			
			update = YES;
		}
		_scrollView.delegate = self;
	}
	
	//--- Remove Thumbnail from End ---
	if( currentThumbnailIndex + (currentThumbnailIndex - currentThumbnailIndex % THUMBNAIL_MIN) + THUMBNAIL_COUNT < _thumbnailViews.count )
	{
		NSInteger thubsCount = _thumbnailViews.count + (currentThumbnailIndex - currentThumbnailIndex % THUMBNAIL_MIN) - THUMBNAIL_COUNT - THUMBNAIL_MIN;
		for( int i = 0; i < thubsCount; i += 1)
		{
			[ self removeThumbnailAtEnd ];
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


//----------------------------------------------------------------------------------------------------
- (void) removeThumbnailAtTop
//----------------------------------------------------------------------------------------------------
{
	SZThumbnailView *thumbnailView = [ _thumbnailViews firstObject ];

	[ thumbnailView removeFromSuperview ];
	[ _thumbnailViews removeObjectAtIndex:0 ];
}

//----------------------------------------------------------------------------------------------------
- (void) removeThumbnailAtEnd
//----------------------------------------------------------------------------------------------------
{
	SZThumbnailView *thumbnailView = [ _thumbnailViews lastObject ];
	
	[ thumbnailView removeFromSuperview ];
	[ _thumbnailViews removeLastObject ];
}
#pragma mark -

//----------------------------------------------------------------------------------------------------
- (IBAction) thumbnailViewTapped:(id)sender
//----------------------------------------------------------------------------------------------------
{
	SZThumbnailView *thumbnailView = (SZThumbnailView *)sender;
	if( thumbnailView.image )
	{
		_imageView.thumbnailView = thumbnailView;
		_imageView.visible = YES;
	}
	else
	{
		UIAlertView *alert = [[ UIAlertView alloc ] initWithTitle:@"Error" message:@"No image found" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil ];
		[ alert show];
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
		
		
		SZConnector *connector = [ SZConnector downloadDataFromImageIndex:fromIndex count:imagesCount searchText:_searchBar.text viewController:self ];
		[ _connectors addObject:connector ];
	}
	
	//--- Add Thumbnail to Bottom ---
	else if( currentThumbnailIndex + THUMBNAIL_COUNT > _thumbnailViews.count )
	{
		SZConnector *connector = [ SZConnector downloadDataFromImageIndex:lastThumbnailView.imageIndex+1 count:THUMBNAIL_MIN searchText:_searchBar.text viewController:self ];
		[ _connectors addObject:connector ];
	}

	_prevScrolledImageIndex = currentThumbnailView.imageIndex;
}

//----------------------------------------------------------------------------------------------------
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
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
	CGRect frame = CGRectMake(0, 0, 0, 0);
	
	if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
	{
		frame.size.width = self.view.frame.size.height;
		frame.size.height = self.view.frame.size.width;
		
		self.imageView.doneButtonVisible = NO;
	}
	
	else
	{
		frame.size.width = self.view.frame.size.width;
		frame.size.height = self.view.frame.size.height;

		self.imageView.doneButtonVisible = YES;
	}

	self.imageView.frame = frame;
	self.imageView.imageView.frame = frame;
	self.imageView.scrollView.zoomScale = 1.0;
	self.imageView.scrollView.contentSize = frame.size;
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
	
	SZConnector *connector = [ SZConnector downloadDataFromImageIndex:1 count:THUMBNAIL_COUNT searchText:searchBar.text viewController:self ];
	[ _connectors addObject:connector ];
}
@end













