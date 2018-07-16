
#import <Foundation/Foundation.h>
#import "TwitterConnect.h"
#import <Fabric/Fabric.h>
#import <TwitterKit/TWTRKit.h>

@implementation TwitterConnect

- (void)pluginInitialize
{
    
    NSString* consumerKey = [self.commandDelegate.settings objectForKey:[@"TwitterConsumerKey" lowercaseString]];
    NSString* consumerSecret = [self.commandDelegate.settings objectForKey:[@"TwitterConsumerSecret" lowercaseString]];
    [[TWTRTwitter sharedInstance] startWithConsumerKey:consumerKey consumerSecret:consumerSecret];
    [Fabric with:@[[TWTRTwitter sharedInstance]]];
    
    //    [Fabric with:@[TwitterKit]];
}


- (void)login:(CDVInvokedUrlCommand*)command
{
    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
        CDVPluginResult* pluginResult = nil;
        if (session){
            NSLog(@"signed in as %@", [session userName]);
            NSDictionary *userSession = @{
                                          @"userName": [session userName],
                                          @"userId": [session userID],
                                          @"secret": [session authTokenSecret],
                                          @"token" : [session authToken]};
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:userSession];
        } else {
            NSLog(@"error: %@", [error localizedDescription]);
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)logout:(CDVInvokedUrlCommand*)command
{
    TWTRSession *session = [TWTRTwitter sharedInstance].sessionStore.session;
    [ [[TWTRTwitter sharedInstance] sessionStore] logOutUserID:(session.userID)];
    CDVPluginResult* pluginResult = pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)showUser:(CDVInvokedUrlCommand*)command
{
    //    TWTRAPIClient *apiClient = [[TWTRTwitter sharedInstance] client];
    //    TWTRAPIClient *apiClient = [[TWTRAPIClient self] APIClient];
    TWTRAPIClient *apiClient = [[TWTRAPIClient alloc] init];
    
    NSDictionary *requestParameters = [NSDictionary dictionaryWithObjectsAndKeys:[[[[TWTRTwitter sharedInstance] sessionStore] session] userID], @"user_id", nil];
    NSError *error = nil;
    //    NSURLRequest *apiRequest = [apiClient URLRequestWithMethod:@"GET"
    //                                                           URL:@"https://api.twitter.com/1.1/users/show.json"
    //                                                    parameters:requestParameters
    //                                                         error:&error];
    NSURLRequest *apiRequest = [apiClient URLRequestWithMethod:@"GET" URLString:@"https://api.twitter.com/1.1/users/show.json" parameters:requestParameters error:&error ];
    
    [apiClient sendTwitterRequest:apiRequest
                       completion:^(NSURLResponse *response, NSData *data, NSError *error) {
                           NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                           NSInteger _httpStatus = [httpResponse statusCode];
                           
                           CDVPluginResult *pluginResult = nil;
                           NSLog(@"API Response :%@",response);
                           if (error != nil) {
                               pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
                           } else if (_httpStatus == 200) {
                               NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                               pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
                           }
                           [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                           
                       }];
}

- (void)accountVerify:(CDVInvokedUrlCommand*)command
{
    //    TWTRAPIClient *apiClient = [[Twitter sharedInstance] APIClient];
    //    TWTRAPIClient *apiClient = [[TWTRAPIClient self] APIClient];
    TWTRAPIClient *apiClient = [[TWTRAPIClient alloc] init];
    NSDictionary *requestParameters = [NSDictionary dictionaryWithObjectsAndKeys: @"true",@"include_email",@"false",@"include_entities",@"true",@"skip_status",nil];
    
    //    NSDictionary *requestParameters = [NSDictionary dictionaryWithObjectsAndKeys:[[[Twitter sharedInstance] session] userID], @"user_id", @"true",@"include_email",@"true",@"include_entities",@"true",@"skip_status",nil];
    NSError *error = nil;//?include_email=true?include_entities=true?skip_status=true
    //    [requestParameters setValue:@"true" forKey:@"include_email"];
    //    [requestParameters setValue:@"true" forKey:@"include_entities"];
    //    [requestParameters setValue:@"true" forKey:@"skip_status"];
    //    NSURLRequest *apiRequest = [apiClient URLRequestWithMethod:@"GET"
    //                                                           URL:@"https://api.twitter.com/1.1/account/verify_credentials.json"
    //                                                    parameters:requestParameters
    //                                                         error:&error];
    NSURLRequest *apiRequest = [apiClient URLRequestWithMethod:@"GET" URLString:@"https://api.twitter.com/1.1/account/verify_credentials.json" parameters:requestParameters error:&error ];
    
    //    if ([[Twitter sharedInstance] session]) {
    //
    //        TWTRShareEmailViewController *shareEmailViewController =
    //        [[TWTRShareEmailViewController alloc]
    //         initWithCompletion:^(NSString *email, NSError *error) {
    //             NSLog(@"Email %@ | Error: %@", email, error);
    //         }];
    //
    //        [self.viewController presentViewController:shareEmailViewController
    //                           animated:YES
    //                         completion:nil];
    //    } else {
    //        // Handle user not signed in (e.g. attempt to log in or show an alert)
    //    }
    
    NSString *urlString = [apiRequest.URL absoluteString];
    //    NSLog(urlString);
    [apiClient sendTwitterRequest:apiRequest
                       completion:^(NSURLResponse *response, NSData *data, NSError *error) {
                           NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                           NSInteger _httpStatus = [httpResponse statusCode];
                           NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                           NSLog(@"**********************************************************");
                           //                           NSLog(myString);
                           
                           CDVPluginResult *pluginResult = nil;
                           NSLog(@"API Response :%@",response);
                           if (error != nil) {
                               pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
                           } else if (_httpStatus == 200) {
                               NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                               pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
                           }
                           [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                           
                       }];
}


- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    return [[Twitter sharedInstance] application:app openURL:url options:options];
}

@end
