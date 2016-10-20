//
//  CircleView.m
//  SKYOA
//
//  Created by struggle on 16/9/2.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import "CircleView.h"

@implementation CircleView
-(void)drawRect:(CGRect)rect{
    //获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextAddArc(ctx, rect.size.width/2, rect.size.height/2, 65, 0, M_PI * 2, 1);
    
    [[UIColor whiteColor] set];
    
    CGContextFillPath(ctx);
    
}
@end
