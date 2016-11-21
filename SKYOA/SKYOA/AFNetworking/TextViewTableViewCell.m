//
//  TextViewTableViewCell.m
//  字符串识别
//
//  Created by cshl on 16/5/13.
//  Copyright © 2016年 cshl. All rights reserved.
//

#import "TextViewTableViewCell.h"
#define kDeviceWidth [UIScreen mainScreen].bounds.size.width
#define kDeviceHeight [UIScreen mainScreen].bounds.size.height

@implementation TextViewTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        _contextView = [[UITextView alloc] initWithFrame:CGRectMake(10,0,kDeviceWidth-20, 20)];
        _contextView.font = [UIFont systemFontOfSize:18];
        _contextView.scrollEnabled = NO;//是否可以拖动
        _contextView.editable = NO; //是否可以编辑
        /*
            设置识别类型（电话 网址 邮箱 等） All 为全部
           _contextView.dataDetectorTypes = UIDataDetectorTypePhoneNumber;
           _contextView.dataDetectorTypes = UIDataDetectorTypeLink;
         */
        _contextView.dataDetectorTypes = UIDataDetectorTypeAll;
        
        [self.contentView addSubview:_contextView];
   
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    NSString *nickName = _dataDic[@"nickName"];
    NSString *contentStr = _dataDic[@"content"];
    NSString *timeStr = _dataDic[@"time"];
    
    NSString *allContentStr = [NSString stringWithFormat: @"%@: %@ %@",nickName,contentStr,timeStr];
    _contextView.attributedText = [self setLabelTextColor:allContentStr nick:nickName time:timeStr];
    
    float textViewHeight = [self heightForString:_contextView andWidth:kDeviceWidth -20];

    _contextView.frame = CGRectMake(10,0,kDeviceWidth-20,textViewHeight);


}

//计算textView的高度
- (float) heightForString:(UITextView *)textView andWidth:(float)width{
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    
    return sizeToFit.height;
}

//改变字符串大小 颜色  字符串的大小一定要在这个方法里面设置 不能在layoutSubviews里面试着font 否则textView高度会有偏差
- (NSMutableAttributedString *)setLabelTextColor:(NSString *)string nick:(NSString *)nickName time:(NSString *)time
{
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:string];
    
    NSRange range = [string rangeOfString:nickName];
    [attributedStr addAttributes:@{NSForegroundColorAttributeName:[UIColor blueColor],NSFontAttributeName:[UIFont systemFontOfSize:18]} range:NSMakeRange(0, range.length )];
    NSRange range1 = [string rangeOfString:time];
    [attributedStr addAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor],NSFontAttributeName:[UIFont systemFontOfSize:12]} range:NSMakeRange(range1.location,range1.length)];
    
    [attributedStr addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} range:NSMakeRange(range.location+range.length,string.length-range1.length-range.length)];
    

    
    return attributedStr;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end














