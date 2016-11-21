//
//  sendEmail.m
//  移动办公
//
//  Created by L灰灰Y on 2016/11/21.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import "sendEmail.h"
#define CZBoundary @"luoyun"

@implementation sendEmail
#pragma mark---上传单个文件
/**
 返回上传需要的二进制数据
 1. 文件的数据
 2. 后台给的字段名
 3. 上传的文件名
 */

+ (NSData *)dataWithFileData:(NSData *)fileData fieldName:(NSString *)fieldName fileName:(NSString *)fileName {
    // 可变的二进制数据
    NSMutableData *dataM = [NSMutableData data];
    // 可变字符串用来拼接数据
    NSMutableString *strM = [NSMutableString stringWithFormat:@"--%@\r\n",CZBoundary];
    
    [strM appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\" \r\n",fieldName,fileName];
    
    // application/octet-stream 代表上传所有的二进制格式都支持
    [strM appendString:@"Content-Type: application/octet-stream \r\n\r\n"];
    
    // 把前面一部份数据先拼接
    [dataM appendData:[strM dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 拼接文件的二进制数据
    [dataM appendData:fileData];
    
    // 清空可变字符串之后，再设置内容为\r\n
    [strM setString:@"\r\n"];
    
    [strM appendFormat:@"--%@--",CZBoundary];
    
    // 把最后一部份加到二进制数据中
    [dataM appendData:[strM dataUsingEncoding:NSUTF8StringEncoding]];
    return dataM.copy;
}
#pragma mark---上传多个文件
/**
 拼接多张图片上传的二进制数据
 1. 文件二进制数据，key 是 文件名，value 是文件的二进制数据
 2. 文件上传到后台的字段
 3. 其他的参数，key 后台给的参数名字，value 就是参数的值
 */
+ (NSData *)dataWithFileDatas:(NSDictionary *)fileDatas fileldName:(NSString *)fieldName params:(NSDictionary *)params {
    // 可变的二进制数据
    NSMutableData *dataM = [NSMutableData data];
    // 可变字符串用来拼接数据
    NSMutableString *strM = [NSMutableString stringWithFormat:@"--%@\r\n",CZBoundary];
    // 拼接文件数据 for in
    [fileDatas enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSLog(@"@@@!!!%@",key);
        [strM appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",fieldName,key];
        [strM appendFormat:@"Content-Type: application/octet-stream \r\n\r\n"];
        
        // 先把前面一部份转成二进制
        [dataM appendData:[strM dataUsingEncoding:NSUTF8StringEncoding]];
        // 拼接文件二进制数据
        [dataM appendData:obj];
        // 先清空，再设值
        [strM setString:@"\r\n"];
        [strM appendFormat:@"--%@\r\n",CZBoundary];
    }];
    
    
    // 拼接参数 for in
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSString *  _Nonnull obj, BOOL * _Nonnull stop) {
        // 拼接字段
        [strM appendFormat:@"Content-Disposition: form-data; name=\"%@\" \r\n\r\n",key];
        // 拼接参数值
        [strM appendString:obj];
        // 拼接分隔符
        [strM appendFormat:@"\r\n--%@",CZBoundary];
    }];
    
    
    [strM appendString:@"--"];
    [dataM appendData:[strM dataUsingEncoding:NSUTF8StringEncoding]];
    //    NSLog(@"%@",dataM);
    return dataM.copy;
}


@end
