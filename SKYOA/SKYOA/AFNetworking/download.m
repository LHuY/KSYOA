//
//  download.m
//  移动办公
//
//  Created by L灰灰Y on 2016/11/22.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import "download.h"
#import "path.h"
#import "LXNetworking.h"


@interface download ()<NSURLConnectionDataDelegate,UIDocumentInteractionControllerDelegate>
@property (nonatomic,strong)LXURLSessionTask *task;
@end
@implementation download

-(void)downloadWithURl:(NSString *)url fileName:(NSString *)name  success:(void (^)(id result))filePath{
    
    NSString * postStr = [NSString stringWithFormat:@"%@/%@",[path UstringWithURL:nil],url];
    // NSURL
    NSString * documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    NSString * filePath1 = [NSString stringWithFormat:@"%@/oa",documentPath];
    //拼接要下载在那个地方的路径
    if (![[NSFileManager defaultManager]fileExistsAtPath:filePath1]) {
        
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath1 withIntermediateDirectories:YES attributes:nil error:nil];
        
    }else{
        NSLog(@"有这个文件了");
    }
    filePath1 = [NSString stringWithFormat:@"%@/%@",filePath1,name];
    NSString *URLStr = postStr;
    _task = [LXNetworking downloadWithUrl:URLStr saveToPath:filePath1 progress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
        //封装方法里已经回到主线程，所有这里不用再调主线程了
        //        _progressLab.text=[NSString stringWithFormat:@"进度==%.2f",1.0 * bytesProgress/totalBytesProgress];
        
    } success:^(id response) {
        //下载成功了，进行预览
        filePath(filePath1);
        //        [self lookFile:dic[@"fileName"]];
        
        
        //        _progressLab.text=@"下载完成";
    } failure:^(NSError *error) {
        NSLog(@"失败");
        
    } showHUD:NO];
    
}

@end
