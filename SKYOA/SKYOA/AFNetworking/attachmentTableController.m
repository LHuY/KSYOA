//
//  attachmentTableController.m
//  移动办公
//
//  Created by L灰灰Y on 2016/12/29.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import "attachmentTableController.h"

@interface attachmentTableController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSArray *attachmentArr;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) int didSelectRow;

@end

@implementation attachmentTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.title = @"站内文件";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.attachmentArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"att" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"att"];
    }
    cell.imageView.image = [UIImage imageNamed:@"Upload"];
    cell.textLabel.text = self.attachmentArr[indexPath.row];
    // Configure the cell...
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定要上传吗" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",  nil];
                    [alert show];
    self.didSelectRow = (int)indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0){
    if(buttonIndex == 1){
        if (self.didSelect) {
            self.didSelect(self.attachmentArr[self.didSelectRow]);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(NSArray *)attachmentArr{
    if (_attachmentArr == nil) {
        NSString * documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
        NSString * filePath = [NSString stringWithFormat:@"%@/oa",documentPath];
        self.filePath = filePath;
        NSError * error =[[NSError alloc]init];
        NSArray * array = [[NSArray alloc]initWithArray:[[NSFileManager defaultManager]contentsOfDirectoryAtPath:filePath error:&error]];
        //获取站内的文件夹
        _attachmentArr = array;
    }
    return _attachmentArr;
}
@end
