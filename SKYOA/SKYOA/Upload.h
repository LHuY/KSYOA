//
//  Upload.h
//  移动办公
//
//  Created by L灰灰Y on 2016/12/29.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Upload : NSObject
+(void)sendAttachmentFileName:(NSString *)fileName filepath:(NSString *)filePath URL:(NSURL *)url success:(void(^)(id result))sucess failure:(void(^)(NSError * error))error;
@end
