//
//  personData.h
//  SKYOA
//
//  Created by struggle on 16/9/18.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface personData : NSObject
//用户id
@property (nonatomic, copy) NSString *organId;
//用户名字
@property (nonatomic, copy) NSString *organName;
//人员数据转模型

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)personWithDict:(NSDictionary *)dict;

+(NSMutableArray *)personWithArray:(NSArray *)arr;
@end
