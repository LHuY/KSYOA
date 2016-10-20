//
//  returnMailViewController.h
//  SKYOA
//
//  Created by struggle on 16/9/23.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface returnMailViewController : UIViewController
//人员列表模型数据
@property (nonatomic, strong) NSMutableArray *personData1;
//要显示的九宫格数组
@property (nonatomic, strong) NSMutableArray *arrayM;
//传送标题和内容打包
@property (nonatomic, strong) NSArray *relay;
@property (nonatomic, copy) void (^blockName)(NSString  * num);
@end
