//
//  download.h
//  移动办公
//
//  Created by L灰灰Y on 2016/11/22.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LXNetworking.h"
#import "path.h"

@interface download : NSData
-(void)downloadWithURl:(NSString *)url fileName:(NSString *)name  success:(void (^)(id result))filePath;
@end
