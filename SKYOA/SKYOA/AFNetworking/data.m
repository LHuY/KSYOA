//
//  data.m
//  SKYOA
//
//  Created by struggle on 16/9/9.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import "data.h"

@implementation data
- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
+ (instancetype)heroWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}

+ (NSMutableArray *)dataWithDic:(NSArray *)arr{
    // 创建模型数组
    NSMutableArray *heros = [NSMutableArray array];
    for (NSDictionary *dict in arr) {
        [heros addObject:[data heroWithDict:dict]];
    }

    return heros;
}
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
@end
