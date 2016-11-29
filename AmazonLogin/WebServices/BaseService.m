//
//  BaseService.m
//  AmazonLogin
//
//  Created by Pankaj Rathor on 28/11/16.
//  Copyright © 2016 Sogeti B.V. All rights reserved.
//

#import "BaseService.h"

@interface BaseService () <NSURLSessionDelegate> {
    BOOL executing;
    BOOL finished;
}

@property (nonatomic, strong) NSURLSessionDataTask *urlSessionDataTask;

- (void) notifyStart;
- (void) notifyFinish;

- (NSMutableURLRequest *) prepareRequestWithURLPath:(NSString *) urlPath methodType:(NSString *) methodType requestBody:(NSDictionary *) bodyParameters HTTPHeaders:(NSDictionary *) httpHeaders;

@end
@implementation BaseService

- (void)dealloc {
    _urlSessionDataTask = nil;
    _urlSession = nil;
    _requestURL = nil;
    _httpHeaderFields = nil;
    _methodType = nil;
    _bodyParameters = nil;
}

- (BOOL)initializeSession {
    
    BOOL returnStatus = NO;
    if (_urlSession == nil) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        if (configuration) {
            self.urlSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        }
    }
    else {
        returnStatus = YES;
    }
    
    return returnStatus;
}

- (void)start {
    
    NSMutableURLRequest *URLRequest = [self prepareRequestWithURLPath:self.requestURL methodType:self.methodType requestBody:self.bodyParameters HTTPHeaders:self.httpHeaderFields];
    
    if (URLRequest) {
        self.urlSessionDataTask = [self.urlSession dataTaskWithRequest:URLRequest];
        
        [self.urlSessionDataTask resume];
    }
}

- (NSMutableURLRequest *)prepareRequestWithURLPath:(NSString *)urlPath methodType:(NSString *)methodType requestBody:(NSDictionary *)bodyParameters HTTPHeaders:(NSDictionary *)httpHeaders {
    NSMutableURLRequest *urlRequest = nil;
    
    NSURLComponents *components = [NSURLComponents componentsWithString:urlPath];
    
    urlRequest = [NSMutableURLRequest requestWithURL:[components URL]];
    
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [httpHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) { //synchronous traversals
        
        NSString *keyString = (NSString *)key;
        NSString *headerValue = (NSString *)obj;
        [urlRequest addValue:headerValue forHTTPHeaderField:keyString];
    }];

    if (bodyParameters && bodyParameters.count > 0) {
        
        NSData *postData = [NSJSONSerialization dataWithJSONObject:bodyParameters options:0 error:nil];
        [urlRequest setHTTPBody:postData];
    }
    
    [urlRequest setHTTPMethod:methodType];
    [urlRequest setTimeoutInterval:60.0f];
    
    return urlRequest;
}

@end
