//
//  UIView+CZExp.m
//  网易彩票
//
//  Created by gzxzmac on 16/1/20.
//  Copyright © 2016年 gzxzmac. All rights reserved.
//

#import "UIView+CZExp.h"

@implementation UIView (CZExp)
// 有没有新增属性名为x的属性？
- (void)setX:(CGFloat)x {
    // 如果有x 属性存在
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)x {
    CGFloat x = self.frame.origin.x;
    return x;
}

- (void)setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}
@end
