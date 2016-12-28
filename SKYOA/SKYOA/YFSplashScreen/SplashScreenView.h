//
//  SplashScreenView.h
//  移动办公
//
//  Created by L灰灰Y on 2016/12/28.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>

typedef void(^AnimationBlock)();
@interface SplashScreenView : UIView
@property (nonatomic, assign) AnimationBlock animationCompletedBlock;
@property (nonatomic, assign) AnimationBlock animationStartBlock;


-(instancetype)initWithFrame:(CGRect)frame
                defaultImage:(UIImage *)defaultImage;

-(void)setImage:(NSString *)imageUrl;

-(void)clearImageSavedFolder;
@end
