//
//  ViewController.m
//  AmazonLogin
//
//  Created by Pankaj Rathor on 24/11/16.
//  Copyright © 2016 Sogeti B.V. All rights reserved.
//

#import "ViewController.h"
#import <LoginWithAmazon/LoginWithAmazon.h>

@interface ViewController () <NSURLSessionDataDelegate>

@property (weak, nonatomic) IBOutlet UILabel *loginStatusLabel;

@end

@implementation ViewController

static NSString *productId = @"AmazonLogin";
static NSString * codeChallenge = @"asdfkjhsdkjfadshfk8yqwruieyq9w73r63eiu238";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginTapped:(id)sender {
    
    NSDictionary *scopeData = @{ @"productID": productId, @"productInstanceAttributes": @{
                                         @"deviceSerialNumber": [UIDevice currentDevice].identifierForVendor.UUIDString
                                         }};
    
    id<AMZNScope> alexaAllScope = [AMZNScopeFactory scopeWithName:@"alexa:all" data:scopeData];
    
    AMZNAuthorizeRequest *request = [[AMZNAuthorizeRequest alloc] init];
    
    request.scopes = @[alexaAllScope];
    request.codeChallenge = codeChallenge;
    request.codeChallengeMethod = @"S256";
    request.grantType = AMZNAuthorizationGrantTypeToken;
    
    request.interactiveStrategy = AMZNInteractiveStrategyAlways;
    
    [[AMZNAuthorizationManager sharedManager] authorize:request withHandler:^(AMZNAuthorizeResult *result, BOOL userDidCancel, NSError *error) {
        NSLog(@"Received handler control");
        if (error) {
            NSLog(@"Error: %@", error.description);
            self.loginStatusLabel.text = @"Login Failed.. 🙁";
        } else if (userDidCancel) {
            NSLog(@"User cancelled");
        } else {
            NSString *accessToken = result.token;
            AMZNUser *user = result.user;
            NSString *userID = user.userID;
            
            NSLog(@"Accesstoken: %@\nuserId: %@\n", accessToken, userID);
            
            [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"AmazonAVSAccessToken"];
            
            self.loginStatusLabel.text = @"Login Successful!! 👍👍👍";
            
            [self initiateDownChannelStream];
        }
        
    }];
    
}

- (void) initiateDownChannelStream {
    
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    
    if (urlSession) {
        
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://avs-alexa-na.amazon.com/v20160207/directives"]];
        
        urlRequest.HTTPMethod = @"GET";
//        urlRequest.timeoutInterval = 200.0f;
        
        NSString *authorizationHeader = [NSString stringWithFormat:@"Bearer %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"AmazonAVSAccessToken"]];
        [urlRequest setValue:authorizationHeader forHTTPHeaderField:@"authorization"];
        
//        NSURLSessionStreamTask *streamTask = [urlSession streamTaskWithHostName:@"avs-alexa-na.amazon.com" port:443];
//    
//        
//        
//        [streamTask resume];
        
        NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            NSLog(@"Status: %ld", ((NSHTTPURLResponse *) response).statusCode);
            
            if (error) {
                NSLog(@"Error: %@", [error description]);
            }
        }];
        
        [dataTask resume];
        
    } else {
        NSLog(@"Error creating URL Session");
    }
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeStreamTask:(NSURLSessionStreamTask *)streamTask {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    
    NSLog(@"Received Challenge...");
    
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    if (completionHandler) {
        
        completionHandler(disposition, credential);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    
}
//- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
//    NSLog(@"%@", NSStringFromSelector(_cmd));
//}
//
//- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
//    NSLog(@"%@", NSStringFromSelector(_cmd));
//}
@end
