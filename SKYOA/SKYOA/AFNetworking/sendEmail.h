//
//  sendEmail.h
//  移动办公
//
//  Created by L灰灰Y on 2016/11/21.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface sendEmail : NSData
+ (NSData *)dataWithFileDatas:(NSDictionary *)fileDatas fileldName:(NSString *)fieldName params:(NSDictionary *)params ;

+ (NSData *)dataWithFileData:(NSData *)fileData fieldName:(NSString *)fieldName fileName:(NSString *)fileName ;
@end
