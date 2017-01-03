//
//  Upload.m
//  移动办公
//
//  Created by L灰灰Y on 2016/12/29.
//  Copyright © 2016年 struggle. All rights reserved.
//
#define CZBoundary @"luoyun"


#import "Upload.h"
#import "MBProgressHUD+PKX.h"
#import "sendEmail.h"
@implementation Upload
+(void)sendAttachmentFileName:(NSString *)fileName filepath:(NSString *)filePath URL:(NSURL *)url success:(void (^)(id))sucess failure:(void (^)(NSError *))error{
    NSLog(@"~~~%@,,,,%@",fileName,filePath);
    // NSURL
    
    
    // NSURLRequest
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    // 设置HTTTP的方法(POST)
    [request setHTTPMethod:@"POST"];
    
    // 告诉服务器我是上传二进制数据
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",CZBoundary] forHTTPHeaderField:@"Content-Type"];
    
    // 文件数据
    // 文件路径
    //    NSString *fileName1 = @"1.jpg";
    //    NSString *path1 = [[NSBundle mainBundle]pathForResource:fileName1 ofType:nil];
    //    NSData *fileData1 = [NSData dataWithContentsOfFile:path1];
    
    
    //    NSString *fileName2 = @"2.jpg";
    //    NSString *path2 = [[NSBundle mainBundle]pathForResource:fileName2 ofType:nil];
    //    NSData *fileData2 = [NSData dataWithContentsOfFile:path2];
    //    // 设置请求体
    //    request.HTTPBody = [sendEmail dataWithFileDatas:@{fileName1:fileData1,fileName2:fileData2}
    //                                    fileldName:@"Filedata" params:nil];
    
    NSData *fileData1 = [NSData dataWithContentsOfFile:filePath];
    //
    request.HTTPBody = [sendEmail dataWithFileData:fileData1 fieldName:@"Filedata" fileName:fileName];
    
    // NSURLConnection
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        sucess(data);
        error(connectionError);
    }];
    
 
}
@end
