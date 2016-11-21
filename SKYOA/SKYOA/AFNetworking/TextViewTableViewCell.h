//
//  TextViewTableViewCell.h
//  字符串识别
//
//  Created by cshl on 16/5/13.
//  Copyright © 2016年 cshl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextViewTableViewCell : UITableViewCell

@property(nonatomic,strong)UITextView *contextView;

@property(nonatomic,strong)NSMutableDictionary *dataDic;

@end
