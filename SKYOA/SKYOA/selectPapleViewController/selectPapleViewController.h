//
//  selectPapleViewController.h
//  移动办公
//
//  Created by L灰灰Y on 2017/1/3.
//  Copyright © 2017年 struggle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "personData.h"
#import "ShowDataModel.h"

@interface selectPapleViewController : UIViewController
//要显示的人员数据
@property (nonatomic, strong) NSMutableArray *papleDatas;
@property (nonatomic, strong) NSMutableArray *arr;

//  被选择的人员model,传给setEmailViewController控制器
@property (nonatomic, copy) void (^blockName)(personData * model);
@end
