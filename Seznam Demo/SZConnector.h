//
//  SZConnector.h
//  Seznam Demo
//
//  Created by Peter Molnár on 5.5.2014.
//  Copyright (c) 2014 Peter Molnár. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SZViewController;

/*
 Stahnovanie dat zo servera
 */

@interface SZConnector : NSObject

@property	(weak, nonatomic)						SZViewController	*viewController;
@property	(strong, nonatomic)						NSURLConnection		*connection;
@property	(strong, nonatomic)						NSMutableData		*responseData;
@property	(assign, nonatomic)						NSInteger			imageIndex;
@property	(assign, nonatomic)						NSInteger			count;

+ (SZConnector *) downloadDataFromImageIndex:(NSInteger)imageIndex count:(NSInteger)count searchText:(NSString *)searchText viewController:(SZViewController *)viewController;

@end
