//
//  setEmailViewController.m
//  SKYOA
//
//  Created by struggle on 16/9/8.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import "setEmailViewController.h"
#import "KYNetManager.h"
#import "data.h"
#import "path.h"
#import "personData.h"
#import "selectManViewController.h"
#import "MBProgressHUD+PKX.h"
#import "UIButton+baritembtn.h"

//#define KNumCount 8   // 九宫格总个数
#define KMargin 0   // 间距
#define KNumberOfColumns 4   // 列数
#define KNumberOfRows 2  // 行数
#define KStatusBarHeight 20  // 状态栏高度

@interface setEmailViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *nice;
@property (weak, nonatomic) IBOutlet UITextField *textFile1;
//标题Label
@property (weak, nonatomic) IBOutlet UITextField *textFile2;
//内容
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, copy) NSString *path;
//附件按钮
@property (weak, nonatomic) IBOutlet UIButton *attachmentBtn;
//记录是否按了附件按钮
@property (nonatomic, assign) BOOL isTunch;
//要显示附件内容的View
@property (weak, nonatomic) IBOutlet UIView *attachmentView;

//要显示的九宫格数组
@property (nonatomic, strong) NSMutableArray *arrayM;
//用来显示要发送的附件内容数组
@property (nonatomic, strong) NSArray *attachmentArr;
//选择附件picker
@property (nonatomic, strong) UIPickerView *pickerVIew;
//用来记录已经选好的文件
@property (nonatomic, strong) NSMutableArray *didSelectArr;
//已经选好的文件字符串名字
@property (nonatomic, copy) NSString *name;
//判断是否滑动了picker
@property (nonatomic, assign) BOOL isPicker;
@end

@implementation setEmailViewController
-(BOOL)prefersStatusBarHidden{
    return YES;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.isTunch = NO;
    self.isPicker= NO;
    self.attachmentBtn.hidden = YES;
    
    self.name =[[NSString alloc]init];
    
    //左边的导航栏按钮
    UIButton * returnController = [UIButton BarButtonItemWithTitle:@"邮件箱" addImage:[UIImage imageNamed:@"return"]];
    //给返回按钮添加点击事件
    [returnController addTarget:self action:@selector(returnController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:returnController];
    
    UIButton * send = [UIButton BarButtonItemWithTitle:@"发送" addImage:[UIImage imageNamed:@"se"]];
    [send addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:send];
    
    
    
    
    //判断是否是转发
    //如果转发数组有内容，则是转发的
    if (self.relay.count == 2) {
        self.textView.text = self.relay.lastObject;
        self.textFile2.text = self.relay.firstObject;
    }
    //绘制收件人的九宫格
   [self neceWitharr:self.arrayM];
    //判断是否草稿箱跳转过来的
    if (self.isTempMail) {
        //是
        //发送请求，获取相信内容
        NSString * postStr = [NSString stringWithFormat:@"%@/AppHttpService?method=GetEmail&emailId=%@",[path UstringWithURL:nil],self.model.MSG_ID];
        [[KYNetManager sharedNetManager]POST:postStr parameters:nil success:^(id result) {
            BOOL status = [[result objectForKey:@"status"] boolValue];
            if (!status) {
                [MBProgressHUD showError:@"请求数据失败"];
                return ;
            }
            NSDictionary * dic = result[@"data"];
            NSLog(@"草稿箱跳转来的数据～～%@",dic);
            //收件人名称
            NSString * addressee = dic[@"receiver"];
            //收件人id
              NSString * add_ID = dic[@"receiverOrganId"];
            NSArray * arrAddressee = [addressee componentsSeparatedByString:@";"];
            NSArray * arrAdd_ID = [add_ID componentsSeparatedByString:@","];
            NSLog(@"!!!%@,  %@;",arrAddressee,arrAdd_ID);
            //将前面数据字典转模型
//            self.arrayM = [NSMutableArray array];
            for (int i = 0; i < arrAdd_ID.count; ++i) {
                personData *model = [[personData alloc]init];
                model.organName = arrAddressee[i];
                 model.organId = arrAdd_ID[i];
                [self.arrayM  addObject:model];
                
            }
            //重绘九宫格
            [self neceWitharr:self.arrayM];
            self.textFile2.text = dic[@"subject"];
            self.textView.text = dic[@"content"];
        } failure:^(NSError *error) {
        }];
    }
    self.navigationController.navigationBarHidden =  NO;
}
- (IBAction)attachment:(id)sender {
    if (self.isTunch) {
        self.isTunch = NO;
        //把选好的附件添加到数组中；
        if (self.name == nil||!self.isPicker) {
            [MBProgressHUD showError:@"请选择附件"];
            [self.pickerVIew removeFromSuperview];
            return;
        }else if (self.didSelectArr.count == 3){
            [MBProgressHUD showError:@"最多只能传三个附件"];
            [self.pickerVIew removeFromSuperview];
            return;
        }
        //添加选择的文件之前，先判断数组中是否包含，如果包含，不做任何操作
        if ([self.didSelectArr containsObject:self.name]) {
            [self.pickerVIew removeFromSuperview];
            return;
        }
        for (UIView * view in self.attachmentView.subviews) {
            [view removeFromSuperview];
        }
        [self.didSelectArr addObject:self.name];
        [self.attachmentBtn setTitle:@"添加附件" forState:UIControlStateNormal];
        [self.pickerVIew removeFromSuperview];
        [self fujian:self.didSelectArr];
    }else{
        self.isTunch = YES;
        self.name =nil;
        [self.attachmentBtn setTitle:@"确定" forState:UIControlStateNormal];
        
        NSString * documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
        NSString * filePath = [NSString stringWithFormat:@"%@/oa",documentPath];
        NSError * error =[[NSError alloc]init];
        NSArray * array = [[NSArray alloc]initWithArray:[[NSFileManager defaultManager]contentsOfDirectoryAtPath:filePath error:&error]];
        //获取站内的文件夹
        self.attachmentArr = array;
        //创建UIPickerView对象
        UIPickerView *pickerView = [[UIPickerView alloc] init];
        //设置frame
        pickerView.backgroundColor = [UIColor whiteColor];
        pickerView.frame = CGRectMake(0, 200, self.view.frame.size.width, 216);
        self.isPicker = NO;
        //添加到View
        [self.view addSubview:pickerView];
        self.pickerVIew =pickerView;
        //设置数据源
        pickerView.dataSource = self;
        //设置代理
        pickerView.delegate = self;
    }
    
}
//绘制附件
-(void)fujian:(NSMutableArray *)didSelectArr{
    for (int i = 0; i < didSelectArr.count; ++i) {
        UIButton * btn = [[UIButton alloc]init];
        UIButton * delete = [[UIButton alloc]init];
        delete.tag = 2001+i;
        delete.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width-55, 21 * i,50, 21);
        [delete setTitle:@"删除" forState:UIControlStateNormal ];
        [delete addTarget:self action:@selector(bnts:) forControlEvents:UIControlEventTouchDown];
        [delete setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.attachmentView addSubview:delete];
        btn.tag = 1001+i;
        btn.frame = CGRectMake(0, 21 * i, [[UIScreen mainScreen] bounds].size.width-60, 21);
        
        [btn setTitle:self.didSelectArr[i] forState:UIControlStateNormal ];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(bnts:) forControlEvents:UIControlEventTouchDown];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.attachmentView addSubview:btn];
        
    }

}
    //点击附件，用来查阅
-(void)bnts:(UIButton *)btn{
   long int count = btn.tag - 1000;
    if (count<10) {
    }else{
        //说明点击了删除键
                [self.didSelectArr removeObjectAtIndex:btn.tag-2001];
        //view子试图全部清掉
        for (UIView * view in self.attachmentView.subviews) {
            [view removeFromSuperview];
        }
        //重新绘制附件
        [self fujian:self.didSelectArr];
        }
        
    }
#pragma mark----
//指定组
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

//指定组行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.attachmentArr.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return self.attachmentArr[row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component __TVOS_PROHIBITED{
//    是否滑动了
    self.isPicker = YES;
    self.name = self.attachmentArr[row];
}





- (IBAction)pushPerson:(id)sender {
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"selectMan" bundle:nil];
    selectManViewController * vc = [sb instantiateInitialViewController];
    vc.arr = self.personData1;
    vc.blockName = ^(personData * model){
        if (self.arrayM.count) {
            //用来判断是否包含有model，类型
            NSMutableArray * arr1 = [NSMutableArray array];
            for (personData* model1 in self.arrayM) {
                [arr1  addObject:model1.organName];
            }
            if (![arr1 containsObject:model.organName]) {
                [self.arrayM addObject:model];
                //重绘九宫格;
                [self neceWitharr:self.arrayM];
            }
        }else{
            [self.arrayM addObject:model];
            //重绘九宫格;
            [self neceWitharr:self.arrayM];
        }
        
    };
    
    
    [self.navigationController pushViewController:vc animated:YES];
}
//绘制九宫格
-(void)neceWitharr:(NSArray *)arr{
    //删除子控件---九宫格
    for(UIView *view in [self.nice subviews])
    {
        [view removeFromSuperview];
    }
    CGFloat itemX = 0;
    CGFloat itemY = 0;
    
    // 每个单元格的宽度 = 总宽度 / (列数 + 1)个间距，再除以列数
    CGFloat itemW = (self.nice.frame.size.width- (KNumberOfColumns + 1) * KMargin) / KNumberOfColumns;
    // 每个单元格的高度 = 总高度 / (行数 + 1)个间距，再除以行数
    CGFloat itemH = (self.nice.frame.size.height - (KNumberOfRows -1) * KMargin ) / KNumberOfRows;
    
    for (int i = 0; i < arr.count+1; i++) {
        if (i<arr.count) {
            UIGestureRecognizer * recoginzer = [[UIGestureRecognizer alloc]initWithTarget:self action:@selector(delete:)];
            UILabel * label = [[UILabel alloc]init];
            label.tag = 100+i;
            [label addGestureRecognizer:recoginzer];
            label.userInteractionEnabled = YES;
//            UIButton * delete = [[UIButton alloc]initWithFrame:CGRectMake(itemW-20, 0, 15, 15)];
//            [delete setImage:[UIImage imageNamed:@"hao"] forState:UIControlStateNormal];
//            delete.tag =100+i;
//            [delete addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchDown];
//            
//            [label addSubview:delete];
            itemX = KMargin + (i % KNumberOfColumns) * (KMargin + itemW);
            itemY = KMargin + (i / KNumberOfColumns) * (KMargin + itemH) ;
            
            label.frame = CGRectMake(itemX, itemY, itemW, itemH);
            personData * model = self.arrayM[i];
            label.text = model.organName;
            [self.nice addSubview:label];
        }
        
        if (arr.count<8&&i == arr.count) {
            
            //创建一个添加的按钮
            UIButton * bnt = [[UIButton alloc]init];
            
            itemX = KMargin+2 + (i % KNumberOfColumns) * (KMargin + itemW);
            itemY = KMargin+2 + (i / KNumberOfColumns) * (KMargin + itemH) ;
            bnt.frame = CGRectMake(itemX, itemY, 23, 23);
            [self.nice addSubview:bnt];
            [bnt setBackgroundImage:[UIImage imageNamed:@"and"] forState:UIControlStateNormal];
            [bnt addTarget:self action:@selector(pushPerson:) forControlEvents:UIControlEventTouchDown];
        }
        
    }
}
//删除已经选择人员
-(void)delete:(UIButton *)btn{
    //删除后要重绘九宫格
    [self.arrayM removeObjectAtIndex:btn.tag-100];
    [self neceWitharr:self.arrayM];
}

-(void)returnController{
    //判断收件人是否为空，
    if (!self.arrayM.count) {
        //返回原来控制器,不用提示啦
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2] animated:YES];
        return;
    }
    //提示是否保存
    NSString *title = NSLocalizedString(@"是否保存？", nil);
    NSString * cancelBntTitle = NSLocalizedString(@"Cancel", nil);
    NSString * OtherBntTitle = NSLocalizedString(@"YES", nil);
    UIAlertController *alercontroller = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    //创建退出按钮
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:cancelBntTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //返回原来控制器
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2] animated:YES];
    }];
    UIAlertAction * otherAction = [UIAlertAction actionWithTitle:OtherBntTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self save];
    }];
    [alercontroller addAction:cancelAction];
    [alercontroller addAction:otherAction];
    [self presentViewController:alercontroller animated:YES completion:^{
    }];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.textFile1 resignFirstResponder];
    [self.textFile2 resignFirstResponder];
    [self.textView resignFirstResponder];
}
//文件发送
- (void)send {
    
//    QuerySentBoxList
//    http://19.89.119.59:7002/oa
    NSString  * str = [NSString stringWithFormat:@"%@/AppHttpService?method=SendEmail&emailId=%@&receiverId=",[path UstringWithURL:nil],[[self uuidString] stringByReplacingOccurrencesOfString:@"-" withString:@""]];
    NSLog(@"!!!!!!%@",[self uuidString]);
        for (int i = 0; i < self.arrayM.count; ++i) {
        personData * model = self.arrayM[i];
            if (self.arrayM.count == 1) {
                str = [NSString stringWithFormat:@"%@%@",str,model.organId];

                            }
            if (self.arrayM.count>1) {
                if (i ==0) {
                    str = [NSString stringWithFormat:@"%@%@",str,model.organId];
                }
                str = [NSString stringWithFormat:@"%@,%@",str,model.organId];
            }

    }
    if ([self.textFile2.text isEqualToString:@"" ]||!self.arrayM.count) {
        [MBProgressHUD showError:@"收件人or标题不能为空"];
        return;
    }else{
        
        str = [NSString stringWithFormat:@"%@&title=%@&content=%@",str,[self.textFile2.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[self.textView.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSLog(@"～转码前%@",str);
    NSLog(@"·转码后%@",[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[KYNetManager sharedNetManager]POST:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(id result) {
            BOOL status = [[result objectForKey:@"status"] boolValue];
            if (!status) {
                [MBProgressHUD showError:@"请求数据失败"];
            }
            //返回主线程更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                //        NSArray * arr = [data dataWithDic:result[@"data"]];
                //        data * data1 = arr.lastObject;
                
                if (self.tempMail) {
                    //这个赋值，是给CustomCollectionViewCell中的删除功能删除草稿箱对应的文件
                    self.tempMail();
                }
                if (self.blockName) {
                    self.blockName(@"1");
                }
                NSArray * controllers = self.navigationController.viewControllers;
                [self.navigationController popToViewController:controllers[2]  animated:YES];
                NSLog(@"成功：!~~~~~%@",result);
            });
                    } failure:^(NSError *error) {
            NSLog(@"失败%@",error);
        }];

    });
    }
//生成32位UUID ，唯一标识
- (NSString *)uuidString

{
    
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    
    CFRelease(uuid_ref);
    
    CFRelease(uuid_string_ref);
    
    return [uuid lowercaseString];
    
}
- (void)save {
    NSString  * str = [NSString stringWithFormat:@"%@/AppHttpService?method=SaveEmail&emailId=%@&receiverId=",[path UstringWithURL:nil],[[self uuidString] stringByReplacingOccurrencesOfString:@"-" withString:@""]];
    for (int i = 0; i < self.arrayM.count; ++i) {
        personData * model = self.arrayM[i];
        if (self.arrayM.count == 1) {
            str = [NSString stringWithFormat:@"%@%@",str,model.organId];
            
        }
        if (self.arrayM.count>1) {
            if (i ==0) {
                str = [NSString stringWithFormat:@"%@%@",str,model.organId];
            }
            str = [NSString stringWithFormat:@"%@,%@",str,model.organId];
        }
        
    }
    str = [NSString stringWithFormat:@"%@&title=%@&content=%@",str,[self.textFile2.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[self.textView.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"!!!!!!!!!!%@",str);
    [[KYNetManager sharedNetManager]POST:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(id result) {
        BOOL status = [[result objectForKey:@"status"] boolValue];

        if (!status) {
            //说明请求错误；
            [MBProgressHUD showError:@"服务器连接失败"];
            return ;
        }

        //        NSArray * arr = [data dataWithDic:result[@"data"]];
        //        data * data1 = arr.lastObject;
        
        NSLog(@"成功：!~~~~~%@",result);
        if (self.blockName) {
            self.blockName(@"2");
        }
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        NSLog(@"失败%@",error);
    }];

    //跳转返回当前页面
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


-(NSString *)getCurTime{
    NSDate * data = [NSDate date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY/MM/dd hh:mm:ss"];
    NSString * dateString = [formatter stringFromDate:data ];
    return dateString;
}
-(NSString *)path{
    if (_path == nil) {
        NSString * documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
        NSString * filePath = [documentPath stringByAppendingPathComponent:@"mail.plist"];
        NSMutableArray * arr = [[NSMutableArray alloc]initWithContentsOfFile:filePath
                                ];
        if (arr == nil ) {
            NSMutableArray * arrM = [NSMutableArray array];
            [arrM writeToFile:filePath atomically:YES];
        }
        return filePath;
    }
    return nil;
}
-(NSMutableArray *)arrayM{
    if (_arrayM == nil) {
        _arrayM = [NSMutableArray array ];
    }
    return _arrayM;
}
-(NSString *)name{
    if (_name == nil) {
        _name =[[NSString alloc]init];
    }
    return _name;
}
-(NSMutableArray *)didSelectArr{
    if (_didSelectArr == nil) {
        _didSelectArr = [NSMutableArray array];
    }
    return _didSelectArr;
}
@end
