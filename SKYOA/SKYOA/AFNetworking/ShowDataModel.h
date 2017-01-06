//
//  ShowDataModel.h
//  ThirdView
//
//  Created by 冷求慧 on 16/9/11.
//  Copyright © 2016年 leng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "personData.h"

@interface ShowDataModel : NSObject
/**
 * 父级的ID 下标
 */
@property (nonatomic,assign)int     superID;
/**
 * 我的ID  下标
 */
@property (nonatomic,assign)int     myID;
/**
 *  缩放等级 (第一级别:0 第二级别:1 第三级别:2)
 */
@property (nonatomic,assign)int     grade;
/**
 *  是否展开
 */
@property (nonatomic,assign)BOOL    isOpen;

/**
 *  显示的数据
 */
@property (nonatomic,copy)NSString  *showName;
/**
 *  右边显示的数据
 */
@property (nonatomic,copy)NSString  *rightShowName;

//用户id
@property (nonatomic, copy) NSString *organId;
//用户名字
@property (nonatomic, copy) NSString *organName;
//部门id
@property (nonatomic, copy) NSString *StruId;
//组织类型。 2认为只组织，其他数字则是人员
@property (nonatomic, copy) NSString *OrganType;


-(instancetype)initWithDataModel:(int)superID myID:(int)myID grade:(int)grade isOpen:(BOOL)isOpen showName:(NSString *)showName rightShowName:(NSString *)rightShowName personMOdel:(personData *)persionModel ;

+(instancetype)showDataModel:(int)superID myID:(int)myID grade:(int)grade isOpen:(BOOL)isOpen showName:(NSString *)showName rightShowName:(NSString *)rightShowName personMOdel:(personData *)persionModel;

@end
