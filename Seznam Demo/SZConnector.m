//
//  SZConnector.m
//  Seznam Demo
//
//  Created by Peter Molnár on 5.5.2014.
//  Copyright (c) 2014 Peter Molnár. All rights reserved.
//

#import "SZConnector.h"
#import "SZViewController.h"
#import "SZThumbnailView.h"

@implementation SZConnector

#pragma mark - Initialize
//****************************************************************************************************
//*** Initialize
//****************************************************************************************************
//----------------------------------------------------------------------------------------------------
+ (SZConnector *) downloadDataFromImageIndex:(NSInteger)imageIndex count:(NSInteger)count searchText:(NSString *)searchText viewController:(SZViewController *)viewController
//----------------------------------------------------------------------------------------------------
{
	SZConnector *connector = [[ SZConnector alloc ] init ];
	[ connector downloadDataFromImageIndex:imageIndex count:count searchText:searchText viewController:viewController ];
	
	return connector;
}

//----------------------------------------------------------------------------------------------------
- (id) init
//----------------------------------------------------------------------------------------------------
{
	self = [ super init ];
	if( !self )
		return nil;
	
	_responseData = [[ NSMutableData alloc ] init ];
	
	return self;
}
#pragma mark -

//----------------------------------------------------------------------------------------------------
- (void) dealloc
//----------------------------------------------------------------------------------------------------
{
}





#pragma mark - HTTP Connection
//****************************************************************************************************
//*** HTTP Connection
//****************************************************************************************************
//----------------------------------------------------------------------------------------------------
- (void) downloadDataFromImageIndex:(NSInteger)imageIndex count:(NSInteger)count searchText:(NSString *)searchText viewController:(SZViewController *)viewController
//----------------------------------------------------------------------------------------------------
{
	if( count < 0 )
	{
		imageIndex = imageIndex + count;
		count = -count;
	}
	
	_viewController = viewController;
	_imageIndex = imageIndex;
	_count = count;
	
	if( searchText == nil || [ searchText isEqualToString:@"" ] )
		searchText = @"iphone%20ipad";
	
	searchText = [ searchText stringByReplacingOccurrencesOfString:@" " withString:@"%%20" ];
	
	NSString *urlString = [ NSString stringWithFormat:@"http://obrazky.cz/searchAjax?q=%@&s=&step=%d&size=any&color=any&filter=true&from=%d", searchText, (int)count, (int)imageIndex ];
	NSURL *requestURL = [ NSURL URLWithString:urlString ];
	
//	NSLog(@"URL: %@", urlString);
    NSURLRequest *request = [ [NSURLRequest alloc ]initWithURL:requestURL cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:5 ];
    _connection = [[ NSURLConnection alloc ] initWithRequest:request delegate:self startImmediately:NO ];
	[ _connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode: NSRunLoopCommonModes ];
	[ _connection start ];
}

//----------------------------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
//----------------------------------------------------------------------------------------------------
{
    [ self.responseData setLength:0 ];
}

//----------------------------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
//----------------------------------------------------------------------------------------------------
{
    [ self.responseData appendData:data ];
}

//----------------------------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
//----------------------------------------------------------------------------------------------------
{
	[ _viewController.connectors removeObject:self ];

	UIAlertView *alert = [[ UIAlertView alloc ] initWithTitle:@"Network Error" message:@"Data download failed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil ];
	[ alert show ];
}

//----------------------------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
//----------------------------------------------------------------------------------------------------
{
	[ _viewController.connectors removeObject:self ];
	
	NSString *responseString = [ NSString stringWithUTF8String:_responseData.bytes ];
	if( responseString == nil || responseString.length == 0 )
	{
		NSLog(@"Data Dowload Error: Empty Response string" );
		return;
	}
	
	responseString = [ responseString stringByReplacingOccurrencesOfString:@"\\'" withString:@"'" ];
	
    // convert to JSON
	NSError  *error  = NULL;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:[ NSData dataWithBytes:[ responseString cStringUsingEncoding:NSUTF8StringEncoding ] length:responseString.length ] options:NSJSONReadingAllowFragments|NSJSONWritingPrettyPrinted error:&error ];
	
	if( res == nil )
	{
		NSLog(@"JSON  Parse Error:  ->%@", error.description );
		return;
	}
	
	
	NSString *string = [[ res objectForKey:@"result" ] objectForKey:@"boxes" ];
	NSRegularExpression *regex = [ NSRegularExpression regularExpressionWithPattern:@"<a.*? data-dot=\\\"(.*?)\\\".*?>\\s*<img.*?src=\\\"(.*?)\\\".*?/>.*?<span class='anchorlike'>(.*?)</span>.*?<span>(\\d+x\\d+)</span>.*?</a>"  options:0 error:&error ];
	
	__block  NSInteger imageIndex = _imageIndex;
	__block  int index = 0;

	[ regex enumerateMatchesInString:string
							 options:0
							   range:NSMakeRange(0, string.length)
						  usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop){
							  NSRange matchRange = [ result rangeAtIndex:1 ];
							  NSString *imageURLString = [ string substringWithRange:matchRange ];
							  
							  matchRange = [ result rangeAtIndex:2 ];
							  NSString *thumbnailURLString = [[ string substringWithRange:matchRange ] stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&" ];
							  
							  matchRange = [ result rangeAtIndex:3 ];
							  NSString *imageName = [[ string substringWithRange:matchRange ] stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&" ];
							  
							  matchRange = [ result rangeAtIndex:4 ];
							  NSString *imageSize = [[ string substringWithRange:matchRange ] stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&" ];
							  

							  NSURL *thumbnailURL = [ NSURL URLWithString:thumbnailURLString ];
							  NSURL *imageURL = [ NSURL URLWithString:imageURLString ];
							  
							  if( index < _count )
							  {
								  SZThumbnailView *thumbnailView = [[ SZThumbnailView alloc ] initWithViewController:_viewController ];
								  thumbnailView.imageIndex = imageIndex;
								  thumbnailView.thumbnailURL = thumbnailURL;
								  thumbnailView.imageURL = imageURL;
								  thumbnailView.imageNameTF.text = imageName;
								  thumbnailView.imageSizeTF.text = imageSize;
								  
								  [ _viewController addThumbnailView:thumbnailView ];
							  }
							  
							  imageIndex = imageIndex + 1;
							  index += 1;
					}
	 ];
}
@end
