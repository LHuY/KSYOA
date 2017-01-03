//
//  attachmentTableController.h
//  移动办公
//
//  Created by L灰灰Y on 2016/12/29.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface attachmentTableController : UITableViewController
//选择之后，传一个文件名
@property (nonatomic, copy) void (^didSelect)(NSString * fileName);
@end
