//
//  selectManViewController.h
//  SKYOA
//
//  Created by struggle on 16/9/19.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YUFoldingTableView.h"
#import "personData.h"

@interface selectManViewController : UIViewController
@property (nonatomic, assign) YUFoldingSectionHeaderArrowPosition arrowPosition;
//要显示的人员数据
@property (nonatomic, strong) NSMutableArray *arr;

//  被选择的人员model,传给setEmailViewController控制器
@property (nonatomic, copy) void (^blockName)(personData * model);
@end
