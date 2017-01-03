
//
//  returnMailViewController.m
//  SKYOA
//
//  Created by struggle on 16/9/23.
//  Copyright © 2016年 struggle. All rights reserved.
//

//#define KNumCount 8   // 九宫格总个数
#define KMargin 0   // 间距
#define KNumberOfColumns 4   // 列数
#define KNumberOfRows 2  // 行数
#define KStatusBarHeight 20  // 状态栏高度


#import "returnMailViewController.h"
#import "personData.h"
#import "selectManViewController.h"
#import "KYNetManager.h"
#import "MBProgressHUD+PKX.h"
#import "path.h"
#import "EmailViewController.h"
#import "UIButton+baritembtn.h"
#import "sendEmail.h"
#import "Upload.h"

@interface returnMailViewController ()<UITextFieldDelegate,UIScrollViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
//九宫格
@property (weak, nonatomic) IBOutlet UIView *nice;
//标
@property (weak, nonatomic) IBOutlet UITextField *headTitle;
@property (weak, nonatomic) IBOutlet UIView *attachmenView;
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
//记录是否按了附件按钮
@property (nonatomic, assign) BOOL isTunch;
//附件按钮
@property (weak, nonatomic) IBOutlet UIButton *attachmentBtn;
@property (nonatomic, strong) NSMutableArray *UUIDArr;
@property (nonatomic, copy) NSString *UUID;
@property (nonatomic, copy) NSString *filePath;




@end

@implementation returnMailViewController

#pragma mark -- 影藏状态栏
-(BOOL)prefersStatusBarHidden{
    return YES;
}
-(void)dealloc{
    NSLog(@"~~释放");
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.isTunch = NO;
    self.isPicker= NO;
    //    self.attachmentBtn.hidden = YES;
    //左边的导航栏按钮
    UIButton * doBack = [UIButton BarButtonItemWithTitle:@"返回" addImage:[UIImage imageNamed:@"return"]];
    //给返回按钮添加点击事件
    [doBack addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:doBack];
    UIButton * createEmail = [UIButton BarButtonItemWithTitle:@"发送" addImage:[UIImage imageNamed:@"se"]];
    [createEmail addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:createEmail];
    self.headTitle.text  = self.relay.firstObject;
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[self.relay.lastObject dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    self.textView.attributedText  = attributedString;
    //    self.textView.text = [NSString stringWithFormat:@"\n\n%@",self.relay.lastObject];
    //成为第一响应者
    [self.textView becomeFirstResponder];
    //设置光标位置
    _textView.selectedRange=NSMakeRange(0,0) ;   //起始位置
    self.headTitle.delegate = self;
    [self neceWitharr:self.arrayM];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.textView resignFirstResponder];
    [self.headTitle resignFirstResponder];
}
- (IBAction)AddAttachment:(id)sender {
    if (!self.attachmentArr.count) {
        [MBProgressHUD showError:@"没有站内附件"];
        return;
    }
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
        for (UIView * view in self.attachmenView.subviews) {
            [view removeFromSuperview];
        }
        [self.didSelectArr addObject:self.name];
        [self.attachmentBtn setTitle:@"添加附件" forState:UIControlStateNormal];
        [self.pickerVIew removeFromSuperview];
        [self fujian:self.didSelectArr];
        
        [MBProgressHUD showMessage:@"上传中。。。"];
         NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/AppUploadService?biz=webmailattachment&processid=%@&encryption=&bizclass=&creatorid=",[path UstringWithURL:nil],self.UUID]];
        [Upload sendAttachmentFileName:self.name filepath:[NSString stringWithFormat:@"%@/%@",self.filePath,self.name] URL:url success:^(id result) {
            result = [NSJSONSerialization JSONObjectWithData:result options:0 error:NULL];
            
            BOOL status = [[result objectForKey:@"status"] boolValue];
            [MBProgressHUD hideHUD];
            if (status) {
                NSLog(@"%@",result);
                //文件上传之后，对文件UUID进行记录，添加到数组当中去
                NSDictionary * dic = result[@"file"];
                [self.UUIDArr addObject:dic[@"fileId"]];
                NSLog(@"上传文件添加uuid%@",self.UUIDArr);
            }else{
                [MBProgressHUD showError:@"上传失败"];
            }
        } failure:^(NSError *error) {
            
        }];
//        [self sendAttachmentFileName:self.name filepath:[NSString stringWithFormat:@"%@/%@",self.filePath,self.name] URL:url];
    }else{
        self.isTunch = YES;
        self.name =nil;
        [self.attachmentBtn setTitle:@"确定" forState:UIControlStateNormal];
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
}//绘制附件
-(void)fujian:(NSMutableArray *)didSelectArr{
    for (int i = 0; i < didSelectArr.count; ++i) {
        UIButton * btn = [[UIButton alloc]init];
        UIButton * delete = [[UIButton alloc]init];
        delete.tag = 2001+i;
        delete.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width-55, 21 * i,50, 21);
        [delete setTitle:@"删除" forState:UIControlStateNormal ];
        [delete addTarget:self action:@selector(bnts:) forControlEvents:UIControlEventTouchDown];
        [delete setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.attachmenView addSubview:delete];
        btn.tag = 1001+i;
        btn.frame = CGRectMake(0, 21 * i, [[UIScreen mainScreen] bounds].size.width-60, 21);
        
        [btn setTitle:self.didSelectArr[i] forState:UIControlStateNormal ];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(bnts:) forControlEvents:UIControlEventTouchDown];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.attachmenView addSubview:btn];
        
    }
    
}
//点击附件，用来查阅
-(void)bnts:(UIButton *)btn{
    long int count = btn.tag - 1000;
    if (count<10) {
    }else{
        //说明点击了删除键
        [self.didSelectArr removeObjectAtIndex:btn.tag-2001];
        
        //已经上传的文件要删除掉，
        //        NSLog(@"点击了%ld~~~~%@",btn.tag-2001,self.UUIDArr1);
        NSString  * str = [NSString stringWithFormat:@"%@/AppHttpService?method=DelAtt&attId=%@",[path UstringWithURL:nil],self.UUIDArr[btn.tag-2001]];
        [[KYNetManager sharedNetManager]POST:str parameters:nil success:^(id result) {
            //删除成功之后，删除self.UUIDArr对应的UUID
            [MBProgressHUD showSuccess:@"删除成功"];
            [self.UUIDArr removeObjectAtIndex:btn.tag-2001];
            NSLog(@"~~~~~%@,,,,%@",result,self.UUIDArr);
        } failure:^(NSError *error) {
            
        }];
        
        //view子试图全部清掉
        for (UIView * view in self.attachmenView.subviews) {
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
-(void)back{
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
        [self saveMail];
    }];
    [alercontroller addAction:cancelAction];
    [alercontroller addAction:otherAction];
    [self presentViewController:alercontroller animated:YES completion:^{
    }];
}
//发送邮件呢
-(void)send{
    NSLog(@"发送文件");
    
    //取消键盘的第一响应者
    [self.textView resignFirstResponder];
    NSString  * str = [NSString stringWithFormat:@"%@/AppHttpService?method=SendEmail&emailId=%@&receiverId=",[path UstringWithURL:nil],self.UUID];
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
    if ([self.headTitle.text isEqualToString:@"" ]||!self.arrayM.count) {
        [MBProgressHUD showError:@"收件人or标题不能为空"];
        return;
    }else{
        //        NSArray * arr = [self.textView.text componentsSeparatedByString:@"发件人"];
        //        NSString * head = arr.firstObject;
        //
        //        head = [NSString stringWithFormat:@"<div style=\"PADDING-BOTTOM: 8px; PADDING-LEFT: 8px; PADDING-RIGHT: 8px;PADDING-TOP: 10px\">%@</div>",head];
        //        head =[NSString stringWithFormat:@"%@%@",head,self.relay.lastObject];
        //        NSLog(@"%@",head);
        NSArray * arr = [self.textView.text componentsSeparatedByString:@"~"];
        NSString * he = [NSString stringWithFormat:@"%@<br/>%@",arr.firstObject,self.relay.lastObject];
        NSLog(@"%@",he);
        str = [NSString stringWithFormat:@"%@&title=%@&content=%@",str,[self.headTitle.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[he stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSLog(@"～转码前%@",str);
    NSLog(@"·转码后%@",[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    [[KYNetManager sharedNetManager]POST:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(id result) {
        //        NSArray * arr = [data dataWithDic:result[@"data"]];
        //        data * data1 = arr.lastObject;
        UIImage * image = [UIImage imageNamed:@"airplane.png"];
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-60, self.view.frame.size.height/2-60, 60, 60)];
        imageView.image = image;
        [self.view addSubview:imageView];
        [UIView animateWithDuration:1.2 animations:^{
            imageView.transform = CGAffineTransformTranslate(imageView.transform, self.view.frame.size.width*0.7, -100);
        }];
        [self performSelector:@selector(sendSuccess) withObject:nil afterDelay:1];
        [self performSelector:@selector(pushEmail) withObject:nil afterDelay:1.5];
        NSLog(@"成功：!~~~~~%@",result);
    } failure:^(NSError *error) {
        NSLog(@"失败%@",error);
    }];
}

-(void)sendSuccess{
    [MBProgressHUD showSuccess:@"发送成功"];
}
-(void)pushEmail{
    if (self.blockName) {
        self.blockName(@"1");
    }
    
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2] animated:YES];
}
-(void)saveMail{
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
    
    str = [NSString stringWithFormat:@"%@&title=%@&content=%@",str,[self.headTitle.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[self.textView.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"!!!!!!!!!!%@",str);
    [[KYNetManager sharedNetManager]POST:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(id result) {
        //        NSArray * arr = [data dataWithDic:result[@"data"]];
        //        data * data1 = arr.lastObject;
        
        NSLog(@"成功：!~~~~~%@",result);
        if (self.blockName) {
            self.blockName(@"2");
        }
        NSArray * controllers = self.navigationController.viewControllers;
        [self.navigationController popToViewController:controllers[2] animated:YES];
    } failure:^(NSError *error) {
        NSLog(@"失败%@",error);
    }];
    
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
//-(void)sendAttachmentFileName:(NSString *)fileName filepath:(NSString *)filePath URL:(NSURL *)url{
//    NSLog(@"~~~%@,,,,%@",fileName,filePath);
//    // NSURL
//   
//    
//    // NSURLRequest
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    // 设置HTTTP的方法(POST)
//    [request setHTTPMethod:@"POST"];
//    
//    // 告诉服务器我是上传二进制数据
//    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",CZBoundary] forHTTPHeaderField:@"Content-Type"];
//    
//    // 文件数据
//    // 文件路径
//    //    NSString *fileName1 = @"1.jpg";
//    //    NSString *path1 = [[NSBundle mainBundle]pathForResource:fileName1 ofType:nil];
//    //    NSData *fileData1 = [NSData dataWithContentsOfFile:path1];
//    
//    
//    //    NSString *fileName2 = @"2.jpg";
//    //    NSString *path2 = [[NSBundle mainBundle]pathForResource:fileName2 ofType:nil];
//    //    NSData *fileData2 = [NSData dataWithContentsOfFile:path2];
//    //    // 设置请求体
//    //    request.HTTPBody = [sendEmail dataWithFileDatas:@{fileName1:fileData1,fileName2:fileData2}
//    //                                    fileldName:@"Filedata" params:nil];
//    
//    NSData *fileData1 = [NSData dataWithContentsOfFile:filePath];
//    //
//    request.HTTPBody = [sendEmail dataWithFileData:fileData1 fieldName:@"Filedata" fileName:fileName];
//    
//    // NSURLConnection
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
//        id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
//        
//        BOOL status = [[result objectForKey:@"status"] boolValue];
//        [MBProgressHUD hideHUD];
//        if (status) {
//            NSLog(@"%@",result);
//            //文件上传之后，对文件UUID进行记录，添加到数组当中去
//            NSDictionary * dic = result[@"file"];
//            [self.UUIDArr addObject:dic[@"fileId"]];
//            NSLog(@"上传文件添加uuid%@",self.UUIDArr);
//        }else{
//            [MBProgressHUD showError:@"上传失败"];
//            
//        }
//    }];
//    
//}

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
            itemX = KMargin + (i % KNumberOfColumns) * (KMargin + itemW);
            itemY = KMargin + (i / KNumberOfColumns) * (KMargin + itemH) ;
            UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(itemX, itemY, itemW, itemH)];
            label.userInteractionEnabled = YES;
            UITapGestureRecognizer *recoginzer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(delete1:)];
            label.tag = 100+i;
            [label addGestureRecognizer:recoginzer];
            
            UIButton * delete = [[UIButton alloc]initWithFrame:CGRectMake(itemW-20, 0, 15, 15)];
            delete.tag =100+i;
            [delete addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchDown];
            
            [label addSubview:delete];
            
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
//删除已经选择人员  label 点击事件按钮
-(void) delete1:(UITapGestureRecognizer *)recognizer{
    UILabel *label=(UILabel*)recognizer.view;
    //删除后要重绘九宫格
    [self.arrayM removeObjectAtIndex:label.tag-100];
    [self neceWitharr:self.arrayM];
}

//删除已经选择人员
-(void)delete:(UIButton *)btn{
    //删除后要重绘九宫格
    [self.arrayM removeObjectAtIndex:btn.tag-100];
    [self neceWitharr:self.arrayM];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //取消第一响应者
    [self.textView resignFirstResponder];
    [self.headTitle resignFirstResponder];
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
#pragma mark----懒加载
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
-(NSMutableArray *)UUIDArr{
    if (_UUIDArr == nil) {
        _UUIDArr = [NSMutableArray array];
    }
    return _UUIDArr;
}
-(NSString *)UUID{
    if (_UUID ==nil) {
        _UUID =[[self uuidString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    return _UUID;
}
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