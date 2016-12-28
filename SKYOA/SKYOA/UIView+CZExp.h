//
//  UIView+CZExp.h
//  网易彩票
//
//  Created by gzxzmac on 16/1/20.
//  Copyright © 2016年 gzxzmac. All rights reserved.
//

#import <UIKit/UIKit.h>

// 分类：不能添加属性 (使用runtime可以实现添加属性)
@interface UIView (CZExp)
// 所有都只是声明了setter 和 getter 方法，并没有新增属性
@property (nonatomic, assign) CGFloat x; // 声明setter 和 getter
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@end
