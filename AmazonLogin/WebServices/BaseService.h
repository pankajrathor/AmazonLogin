//
//  BaseService.h
//  AmazonLogin
//
//  Created by Pankaj Rathor on 28/11/16.
//  Copyright © 2016 Sogeti B.V. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseService : NSOperation

@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) NSString *requestURL;
@property (nonatomic, strong) NSDictionary *httpHeaderFields;
@property (nonatomic, strong) NSDictionary *bodyParameters;
@property (nonatomic, strong) NSString *methodType;

- (BOOL) initializeSession;

@end
