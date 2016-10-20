//
//  NSString+base64.h
//  SKYOA
//
//  Created by struggle on 16/8/31.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (base64)
+ (NSString *)base64Encode:(NSString *)str;
+ (NSString *)base64Decode:(NSString *)str;


@end
