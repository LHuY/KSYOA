//
//  setEmailViewController.h
//  SKYOA
//
//  Created by struggle on 16/9/8.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "data.h"

@interface setEmailViewController : UIViewController
//@property (nonatomic, strong) NSArray * personData;
//全部人员选择  数组
@property (nonatomic, strong)  NSMutableArray *personData1;
//block传值，传给EmailViewController控制器,如果是发送，则返回去的是1，如果保存，返回的是草稿箱，
@property (nonatomic, copy) void (^blockName)(NSString * count);
//草稿箱 信息，在重新编辑
@property (nonatomic, strong) data *model;
//是否草稿箱编辑
@property (nonatomic, assign) BOOL isTempMail;
//转发的数据
@property (nonatomic, strong) NSArray *relay;
//用来监听草稿箱是否发送了，发送了就删除草稿箱对应的邮件
@property (nonatomic, copy) void (^tempMail)();
@end
