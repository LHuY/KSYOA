//
//  UIButton+baritembtn.m
//  SKYOA
//
//  Created by struggle on 16/9/30.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import "UIButton+baritembtn.h"

@implementation UIButton (baritembtn)
//导航栏左右按钮的创建
+(UIButton *)BarButtonItemWithTitle:(NSString *)title addImage:(UIImage *)image{
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 85, 44);
    
    [backBtn setTitle:title forState:UIControlStateNormal];
    [backBtn setImage:image forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    return backBtn;
}
@end
