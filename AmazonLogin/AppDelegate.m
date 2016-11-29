//
//  AppDelegate.m
//  AmazonLogin
//
//  Created by Pankaj Rathor on 24/11/16.
//  Copyright © 2016 Sogeti B.V. All rights reserved.
//

#import "AppDelegate.h"
#import <LoginWithAmazon/LoginWithAmazon.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    BOOL isValidRedirectSignInURL = [AIMobileLib handleOpenURL:url sourceApplication:sourceApplication];
    
    if (!isValidRedirectSignInURL)
        return NO;
    
    return YES;
}

@end
