//
//  CustomCollectionViewCell.m
//  UICollectionViewText
//
//  Created by sunbk on 16/7/8.
//  Copyright © 2016年 xingyuan. All rights reserved.
//

#import "CustomCollectionViewCell.h"
#import "data.h"
#import "SWTableViewCell.h"
#import "detailedMailViewController.h"
#import "KYNetManager.h"
#import "path.h"
#import "setEmailViewController.h"

@interface CustomCollectionViewCell () <UITableViewDelegate,UITableViewDataSource,SWTableViewCellDelegate>
@property (nonatomic, strong) data *model;

@property (nonatomic, strong) NSMutableArray *testArray;;
@end

@implementation CustomCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"love"];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.dataArray = [NSMutableArray array];
    
    
    
    
    
    self.myTableView.rowHeight = 50;
    self.myTableView.allowsSelection = NO; // We essentially implement our own selection
    self.myTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    // Add test data to our test array
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count+1;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        //        NSMutableArray *leftUtilityButtons = [NSMutableArray new];
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        
        
        [rightUtilityButtons addUtilityButtonWithColor:
         [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                 title:@"删除"];
        //        [rightUtilityButtons addUtilityButtonWithColor:
        //         [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
        //                                                 title:@"More"];
        
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier
                                  containingTableView:_myTableView // Used for row height and selection
                                   leftUtilityButtons:nil
                                  rightUtilityButtons:rightUtilityButtons];
        cell.delegate = self;
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
        cell.imageView.image = nil;
        return cell;
    }
    
    self.model =  self.dataArray[indexPath.row-1];
    //判断详细页面 是否已读   //邮件状态  2为已读，一为未读，0 无状态
    if ([self.model.STAT isEqualToString:@"1"]) {
        //标识为未读
        cell.imageView.image = [UIImage imageNamed:@"NOread"];
    }else if ([self.model.STAT isEqualToString:@"2"]){
        cell.imageView.image = [UIImage imageNamed:@"didRead"];
    }else{
        //无状态
        cell.imageView.image = [UIImage imageNamed:@"didRead"];
    }
    cell.textLabel.text =    self.model.title;
    NSString * detailStr = self.model.SENDER;
    if ([self.count1 isEqualToString: @"2"]) {
        detailStr = self.model.partyName;
    }
    detailStr = [NSString stringWithFormat:@"%@           时间:%@",detailStr,self.model.SEND_TIME];
    cell.detailTextLabel.text = detailStr;
    return cell;
}

-(void)setDataArray:(NSMutableArray *)dataArray{
    _dataArray = dataArray;
    [self.myTableView reloadData];
}



//增加
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.count1 isEqualToString:@"2"]) {
        //是草稿箱。跳转到编辑界面
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"setEmail" bundle:nil];
        setEmailViewController * vc = [sb instantiateInitialViewController];
        vc.model = self.dataArray[indexPath.row-1];
        vc.personData1 = self.personData1;
        vc.isTempMail = YES;
        //如果是草稿箱发送了，会回调这个函数，然后删除草稿箱已经发送的那个文件
        vc.tempMail = ^(){
            //删除草稿箱对应的邮件
            self.model= self.dataArray[indexPath.row-1];
            
            [[KYNetManager sharedNetManager]POST:[NSString stringWithFormat:@"%@/AppHttpService?method=DelEmail&emailId=%@&type=%@",[path UstringWithURL:nil],self.model.MSG_ID,self.count1] parameters:nil success:^(id result) {
                NSLog(@"成功!!~@@@@@@@%@ ～～～%@",result   ,[NSString stringWithFormat:@"%@/AppHttpService?method=DelEmail&emailId=%@&type=%@",[path UstringWithURL:nil],self.model.MSG_ID,self.count1]);
            } failure:^(NSError *error) {
                NSLog(@"错误!!~@@@@@@@%@",error);
            }];
            // Delete button was pressed
            
            [self.dataArray removeObjectAtIndex:indexPath.row-1];
            [self.myTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        };
        [self.nav pushViewController:vc animated:YES];
        return;
    }
    
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"detailedMail" bundle:nil];
    detailedMailViewController * vc = [sb instantiateInitialViewController];
    vc.model = self.dataArray[indexPath.row-1];
    vc.personData1 = self.personData1;
    vc.isSearch = NO;
    vc.num = self.count1;
    [self.nav pushViewController:vc animated:YES];
    
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"scroll view did begin dragging");
}
#pragma mark - SWTableViewDelegate

//- (void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
//    switch (index) {
//        case 0:
//            NSLog(@"left button 0 was pressed");
//            break;
//        case 1:
//            NSLog(@"left button 1 was pressed");
//            break;
//        case 2:
//            NSLog(@"left button 2 was pressed");
//            break;
//        case 3:
//            NSLog(@"left btton 3 was pressed");
//        default:
//            break;
//    }
//}

- (void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 1:
        {
            NSLog(@"More button was pressed");
            UIAlertView *alertTest = [[UIAlertView alloc] initWithTitle:@"Hello" message:@"More more more" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles: nil];
            [alertTest show];
            
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        case 0:
        {
            NSIndexPath *cellIndexPath = [self.myTableView indexPathForCell:cell];
            self.model= self.dataArray[cellIndexPath.row-1];
            
            [[KYNetManager sharedNetManager]POST:[NSString stringWithFormat:@"%@/AppHttpService?method=DelEmail&emailId=%@&type=%@",[path UstringWithURL:nil],self.model.MSG_ID,self.count1] parameters:nil success:^(id result) {
                NSLog(@"成功!!~@@@@@@@%@ ～～～%@",result   ,[NSString stringWithFormat:@"%@/AppHttpService?method=DelEmail&emailId=%@&type=%@",[path UstringWithURL:nil],self.model.MSG_ID,self.count1]);
            } failure:^(NSError *error) {
                NSLog(@"错误!!~@@@@@@@%@",error);
            }];
            // Delete button was pressed
            
            [self.dataArray removeObjectAtIndex:cellIndexPath.row-1];
            [self.myTableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
        }
        default:
            break;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

@end
