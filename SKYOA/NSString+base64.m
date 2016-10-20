//
//  NSString+base64.m
//  SKYOA
//
//  Created by struggle on 16/8/31.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import "NSString+base64.h"


@implementation NSString (base64)





/**
 *  base64 编码
 *  A ==> QQ==
 */
+ (NSString *)base64Encode:(NSString *)str {
    if (str == nil) return nil;
    // 将字符串转换成二进制
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    // 进行base64编码
    return [data base64EncodedStringWithOptions:0];
}
/**
 *  base64 解码
 *
 *  @param str 编码过的字符串
 *
 *  @return 解码的结果
 *  QQ== ===> A
 */
+ (NSString *)base64Decode:(NSString *)str {
    if (str == nil) return nil;
    // 将字符串转换成二进制
    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:0];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
