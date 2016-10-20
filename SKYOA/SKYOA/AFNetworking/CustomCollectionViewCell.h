//
//  CustomCollectionViewCell.h
//  UICollectionViewText
//
//  Created by sunbk on 16/7/8.
//  Copyright © 2016年 xingyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic,strong) NSMutableArray* dataArray;
@property (nonatomic, strong) UINavigationController *nav;
//记录当前页面是收件箱0，发件箱1，草稿箱2，
@property (nonatomic, copy) NSString *count1;
//人员列表模型数据
@property (nonatomic, strong) NSMutableArray *personData1;


@end
