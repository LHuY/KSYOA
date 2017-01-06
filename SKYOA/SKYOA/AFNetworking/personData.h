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
//部门id
@property (nonatomic, copy) NSString *StruId;

//组织类型。 2认为只组织，其他数字则是人员
@property (nonatomic, copy) NSString *OrganType;
//人员数据转模型

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)personWithDict:(NSDictionary *)dict;
//跳转到选择人员页面时候请求的数据
+(NSMutableArray *)personWithData:(NSArray *)data;
+(NSMutableArray *)personWithArray:(NSArray *)arr;
@end
