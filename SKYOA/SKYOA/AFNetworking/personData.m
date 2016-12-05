//
//  personData.m
//  SKYOA
//
//  Created by struggle on 16/9/18.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import "personData.h"


@implementation personData

- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
+ (instancetype)personWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
+(NSMutableArray *)personWithArray:(NSArray *)arr{
    int count = 0;
    //创建一个总数组，用来装分数组和sestion数组
    NSMutableArray * arrM =[NSMutableArray array];
    //创建一个分数组，用来装cell数组，
    NSMutableArray * arrM1 = [NSMutableArray array];
    //创建一个section数组
    NSMutableArray * section = [NSMutableArray array];
    //创建一个cell数组
    NSMutableArray * cell = [NSMutableArray array];
    for (int i = 0; i < arr.count; ++i) {
        NSDictionary * dic = arr[i];
        if (dic[@"deptName"]) {
            if (count == 0) {
                count = 1;
            }else{
                
                //说明有三级
                [section removeLastObject];
            }
            [section addObject:dic[@"deptName"]];
            
            if (cell.count) {
                [arrM1 addObject:cell];
                //                [cell  removeAllObjects];
                cell = [NSMutableArray array];
            }
            continue;
        }
        count = 0;
        [cell addObject:[personData personWithDict:dic]];
    }
    
    //到最后一次的时候，在添加一次cell
    [arrM1 addObject:cell];
    [arrM addObject:section];
    [arrM addObject:arrM1];
    return arrM;
}
@end
