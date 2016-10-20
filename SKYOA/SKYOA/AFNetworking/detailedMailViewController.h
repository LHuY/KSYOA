//
//  detailedMailViewController.h
//  SKYOA
//
//  Created by struggle on 16/9/12.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "data.h"
#import "personData.h"

@interface detailedMailViewController : UIViewController
@property (nonatomic, strong) data * model;
@property (nonatomic, copy) NSString *mail_ID;
//判断是否通过搜索跳转的，还是直接点击列表跳转到这个页面的
//yes表示通过搜索跳转的；
//no表示直接搜索跳转的，
@property (nonatomic, assign) BOOL isSearch;
//记录是草稿箱，还是发件箱，还是收件箱
@property (nonatomic, copy) NSString *num;
//block传值，传给EmailViewController控制器,如果是草稿箱，返回的是0，如果是发送箱，则返回去的是1，如果是草稿箱，返回的是2，
@property (nonatomic, copy) void (^blockName)(NSString * count);
//全部人员选择  数组
@property (nonatomic, strong)  NSMutableArray *personData1;
@end
