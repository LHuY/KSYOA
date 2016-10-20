//
//  searchData.m
//  SKYOA
//
//  Created by struggle on 16/9/12.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import "searchData.h"

@implementation searchData
//获取到的数据给搜索用的，犹豫去搜索的时候要重新排列，以免错乱模型，所以以_分别拼接，等重新排列之后，在把他取出来赋值给Cell

+(NSMutableArray *)searchWithArray:(NSArray *)arr{
    NSMutableArray *allArr = [NSMutableArray array];
    for (NSDictionary * dic in arr) {
        NSString *connect = [NSString stringWithFormat:@"%@LhhY%@LhhY%@LhhY%@",dic[@"title"],dic[@"SENDER"],dic[@"sendTime"],dic[@"MSG_ID"]];
        [allArr addObject:connect];
    }
    return allArr;
}
@end
