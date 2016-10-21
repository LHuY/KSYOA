//
//  path.m
//  SKYOA
//
//  Created by struggle on 16/9/18.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import "path.h"

@implementation path
+(NSString *)UstringWithURL:(NSString *)path{
    NSString * fielPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject]stringByAppendingPathComponent:@"IP.plist"];
    NSDictionary * arr = [[NSDictionary alloc]initWithContentsOfFile:fielPath];
    NSString * str = @"http://";
    NSString * POSTstr;
//    if ([arr[@"服务器"]isEqualToString:@"121.15.254.8"]) {
//        //兼容ipv6
//       POSTstr = [str stringByAppendingString:@"www.huizhouhecheng.com"];
//    }else if ([arr[@"服务器"]isEqualToString:@"19.89.119.59"]){
//       POSTstr = [str stringByAppendingString:@"19.89.119.59"];
//    }
    POSTstr = [str stringByAppendingString:arr[@"服务器"]];
    NSString * d = [NSString stringWithFormat:@":%@",arr[@"端口号"]];
    POSTstr = [POSTstr stringByAppendingString:d];
    NSString * oa = [NSString stringWithFormat:@"/%@",arr[@"oa"]];
    POSTstr = [POSTstr stringByAppendingString:oa];
    return POSTstr;
}
+(id)BarButtonItemWithTitle:(NSString *)title addImage:(NSString *)image{
    
    return nil;
}

@end
