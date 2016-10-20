//
//  data.h
//  SKYOA
//
//  Created by struggle on 16/9/9.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface data : NSObject
/**
 *  收件人
 */
@property (nonatomic, copy) NSString *partyName;
/**
 *  时间
 */
@property (nonatomic, copy) NSString *SEND_TIME;


/**
 *  发送人 
 */
@property (nonatomic, copy) NSString *SENDER;

//邮件标题
@property (nonatomic, copy) NSString *title;
//邮件状态  2为已读，一为未读，0 无状态
@property (nonatomic, copy) NSString *STAT;
//邮件ID
@property (nonatomic, copy) NSString *MSG_ID;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)heroWithDict:(NSDictionary *)dict;
+ (NSMutableArray *)dataWithDic:(NSArray *)arr;

@end
