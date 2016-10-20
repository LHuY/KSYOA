//
//  AppDelegate.m
//  SKYOA
//
//  Created by struggle on 16/8/16.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSURL *cookieHost = [NSURL URLWithString:@"http://19.89.119.59:7002/oa/AppHttpService"];
    
    NSDictionary *propertiesDict = [NSDictionary dictionaryWithObjectsAndKeys:[cookieHost host],NSHTTPCookieDomain,[cookieHost path],NSHTTPCookiePath,@"COOKIE_NAME",NSHTTPCookieName,@"COOKIE_VALUE",NSHTTPCookieValue,nil];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:propertiesDict];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    return YES;
}
- (void)applicationDidBecomeActive:(UIApplication *)application {    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
