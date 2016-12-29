//
//  AppDelegate.m
//  SKYOA
//
//  Created by struggle on 16/8/16.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import "AppDelegate.h"
#import "KYNetManager.h"
#import "aboutViewController.h"
#import "MBProgressHUD+PKX.h"
#import "ViewController.h"

@interface AppDelegate ()
@property (nonatomic, strong) ViewController *rvc;
@end

@implementation AppDelegate

// 应用启动完成之后才会调用
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //新特性的增加
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        // 不需要显示
        self.window.backgroundColor = [UIColor whiteColor];
        UINavigationController *nav = [[UINavigationController alloc] init];
        //则跳转到登录页面
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"Log" bundle:nil];
        ViewController * vc = [sb instantiateInitialViewController];
        vc.isAoto = YES;
        self.rvc = vc;
        [nav addChildViewController:vc];
        self.window.rootViewController = nav;
        [self.window makeKeyAndVisible];
    

    
    
//    
        self.splashScreenView = [[SplashScreenView alloc] initWithFrame:self.window.bounds defaultImage:[UIImage imageNamed:@"defaultStartScreen"]];
    [self.window addSubview:self.splashScreenView];
    self.splashScreenView.animationStartBlock = ^void(){
        NSLog(@"Animation Start......");
    };
    self.splashScreenView.animationCompletedBlock = ^void(){
        NSLog(@"Animation Completed......");
    };
//
    
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
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options NS_AVAILABLE_IOS(9_0){
    NSString * canshu = url.absoluteString;
//    NSString * str = @"SKYOA://?appid=SKYOA&childSecret=2C387AA2FC84686219E6498F40868C94&userid=20600003";
//    str = [str substringFromIndex:9];
//    //获取参数，向服务器发送请求
//    str = [str stringByReplacingOccurrencesOfString:@"SKYOA" withString:@"SKYOA://"];
//    NSLog(@"%@",[NSString stringWithFormat:@"http://mcp.hzti.net/mobileapi/public/function/checkCasValidity.do?model=iPhone 6&version=2.0&equipmentSystem=7.100000&ip=192.168.6.7&imei=&sblx=IPad&%@",str] );
//    str = [NSString stringWithFormat:@"http://mcp.hzti.net/mobileapi/public/function/checkCasValidity.do?model=iPhone 6&version=2.0&equipmentSystem=7.100000&ip=192.168.6.7&imei=&sblx=IPad&%@",str];
//    str = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    self.rvc.URL= canshu;
//    [MBProgressHUD showSuccess:canshu];
    return YES;
}

@end
@implementation NSURLRequest(DataController)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
}
@end
