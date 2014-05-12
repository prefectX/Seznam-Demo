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

@property	(assign, nonatomic, readonly)			int					connectorType;
@property	(assign, nonatomic)						NSInteger			imageIndex;
@property	(assign, nonatomic)						NSInteger			count;

@property	(strong, nonatomic)						NSURLConnection		*connection;
@property	(strong, nonatomic)						NSMutableData		*responseData;

+ (SZConnector *) downloadDataFromImageIndex:(NSInteger)imageIndex count:(NSInteger)count searchText:(NSString *)searchText viewController:(SZViewController *)viewController;
+ (SZConnector *) downloadImageWithImageIndex:(NSInteger)imageIndex URL:(NSURL *)imageURL connectorType:(int)connectorType viewController:(SZViewController *)viewController;

@end
