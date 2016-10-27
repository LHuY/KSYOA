//
//  detailedMailViewController.m
//  SKYOA
//
//  Created by struggle on 16/9/12.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import "detailedMailViewController.h"
#import "KYNetManager.h"
#import "path.h"
#import "LXNetworking.h"
#import "setEmailViewController.h"
#import "returnMailViewController.h"
#import "UIButton+baritembtn.h"
#import "MBProgressHUD+PKX.h"

@interface detailedMailViewController ()<NSURLConnectionDataDelegate,UIDocumentInteractionControllerDelegate>
//回复
@property (weak, nonatomic) IBOutlet UIButton *call;
//转发
@property (weak, nonatomic) IBOutlet UIButton *zhuanfa;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//文本内容
@property (weak, nonatomic) IBOutlet UITextView *textView;
//标题
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
//收件人名称
@property (weak, nonatomic) IBOutlet UILabel *mail_Name;
//发件人名称
@property (weak, nonatomic) IBOutlet UILabel *mail_Name_send;

@property (nonatomic, strong) NSDictionary *dic;

@property (nonatomic,strong)LXURLSessionTask *task;
//附件总容器
@property (weak, nonatomic) IBOutlet UIView *attachmentView;
//要查看的按钮
//附件1
@property (nonatomic, strong) UIButton *btn1;
//附件2
@property (nonatomic, strong) UIButton *btn2;
//附件3
@property (nonatomic, strong) UIButton *btn3;
//预览模式，第三方打开

@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic, copy) NSString *filePath;
@end
@implementation detailedMailViewController

//-(BOOL)prefersStatusBarHidden{
//    return YES;
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.num isEqualToString:@"1"]) {
        self.call.hidden = YES;
        self.zhuanfa.hidden = YES;
    }
    //左边的导航栏按钮
    UIButton * back = [UIButton BarButtonItemWithTitle:@"收件箱" addImage:[UIImage imageNamed:@"return"]];
    //给返回按钮添加点击事件
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    [self SetSCrollView];
    if (self.isSearch) {
        //表示通过搜索获取详情信息
        NSLog(@"~~~~~%@",self.mail_ID);
        [self showDataMail_ID:self.mail_ID];
    }else{
        //直接点击获取
        [self  showDataMail_ID:self.model.MSG_ID];
    }
}
//返回原先的控制器
-(void)back{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
//请求要显示详细信息数据
-(void)showDataMail_ID:(NSString *)mail_ID{
    
    NSString * postStr = [NSString stringWithFormat:@"%@/AppHttpService?method=GetEmail&emailId=%@",[path UstringWithURL:nil],mail_ID];
    [[KYNetManager sharedNetManager]POST:postStr parameters:nil success:^(id result) {
        BOOL status = [[result objectForKey:@"status"] boolValue];
        if (!status) {
            [MBProgressHUD showError:@"数据请求失败"];
        }
        NSDictionary * dic = result[@"data"];
        
        self.dic = dic;
        NSLog(@"~~~~%@",dic);
        //获取所以附件
         NSArray * arr = self.dic[@"attachment"];
        //动态获取附件按钮
        
        for (int i = 0; i < arr.count; ++i) {
            UIButton * btn = [[UIButton alloc]init];
            btn.tag = 1001+i;
            btn.frame = CGRectMake(0, 21 * i, [[UIScreen mainScreen] bounds].size.width, 21);
            //获取第i个附件
            NSDictionary *attachment = arr[i];
            [btn setTitle:attachment[@"fileName"] forState:UIControlStateNormal ];
            //添加一个点击事件
            if (i == 0) {
                [btn addTarget:self action:@selector(bnt1) forControlEvents:UIControlEventTouchDown];
                self.btn1 = btn;
            }
            if (i == 1) {
                self.btn2 = btn;
                [btn addTarget:self action:@selector(bnt2) forControlEvents:UIControlEventTouchDown];
            }
            if (i == 2) {
                self.btn3 = btn;
                [btn addTarget:self action:@selector(bnt3) forControlEvents:UIControlEventTouchDown];
            }
            //让按钮文字居中
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            btn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            [self.attachmentView addSubview:btn];
        }
        self.mail_Name_send.text = dic[@"sender"];
        self.mail_Name.text = dic[@"receiver"];
        self.titleLabel.text = dic[@"subject"];
        self.textView.text = dic[@"content"];
    } failure:^(NSError *error) {
        NSLog(@"失败%@",error);
    }];
}
//附件1
-(void)bnt1{
    [self downLoad:0];
}
//附件2
-(void)bnt2{
    [self downLoad:1];
}
//附件3
-(void)bnt3{
  [self downLoad:2];
}
//关于ScrollVIew设置
-(void)SetSCrollView{
    self.navigationController.navigationBarHidden = NO;
    // 一定要设置contentSize属性，否则无法进行滚动
    self.scrollView.contentSize=CGSizeMake(0, 740);
    //去除滚动条
    self.scrollView.showsVerticalScrollIndicator=NO;
    //设置默认情况下的内间距
    self.scrollView.contentOffset=CGPointMake(0, 60);
    //    //设置弹簧效果之后的内容内间距
    self.scrollView.contentInset=UIEdgeInsetsMake(-60,0 , 0, 0);
    self.textView.editable = NO;
}
//回复邮件
- (IBAction)retureMail:(id)sender {
    //跳转到编辑界面
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"returnMail" bundle:nil];
    returnMailViewController * vc = [sb instantiateInitialViewController];
    //把要编辑的数据打包好
    //发件人ID
    NSString * senderOrganId = self.dic[@"senderOrganId"];
    //获取发件人名字
    NSString  * sender1= self.dic[@"sender"];
    NSArray * arrSenderOrganId = [senderOrganId componentsSeparatedByString:@","];
    NSArray * arrSender = [sender1 componentsSeparatedByString:@";"];
    
    //字典转模型
     vc.arrayM = [NSMutableArray array];
    for (int i = 0; i < arrSenderOrganId.count; ++i) {
        personData * model = [[personData alloc]init];
        model.organId = arrSenderOrganId[i];
        model.organName = arrSender[i];
        [vc.arrayM addObject:model];
    }
    vc.personData1 = self.personData1;
    //设置回复前的内容信息
    NSString * line = @"H~~~~~~~原始邮件~~~~~~~H\n";
    NSString * sendMan = [NSString stringWithFormat:@"  发件人:  %@\n\n",self.dic[@"sender"]];
    //发件时间
    NSString * time = [NSString stringWithFormat:@"  发件时间:  %@\n\n",self.model.SEND_TIME];
    //主题
    NSString * title = [NSString stringWithFormat:@"  主题:回复：%@\n\n",self.dic[@"subject"]];
    NSString  * content = self.textView.text;
    NSString * togetter = [NSString stringWithFormat:@"%@%@%@%@%@",line,sendMan,time,title,content];
    //标题和内容打包
    NSArray * relay = @[self.titleLabel.text,togetter];
    vc.relay = relay;
    [self.navigationController pushViewController:vc animated:YES];
}

//转发给朋友
- (IBAction)copyMail:(id)sender {
    //跳转到编辑界面
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"setEmail" bundle:nil];
    setEmailViewController * vc = [sb instantiateInitialViewController];
    //标题和内容打包
    NSArray * relay = @[self.titleLabel.text,self.textView.text];
    vc.relay = relay;
    vc.personData1 = self.personData1;
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)downLoad:(int)sender {
    //获取所有附件
    NSArray * arr = self.dic[@"attachment"];
    //获取要下载的哪个附件
    NSDictionary * dic = arr[sender];
    NSString * str =  dic[@"fileUrl"];
    NSString * postStr = [NSString stringWithFormat:@"%@%@",[path UstringWithURL:nil],str];
    // NSURL
    NSString * documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    NSString * filePath = [NSString stringWithFormat:@"%@/oa",documentPath];
    //拼接要下载在那个地方的路径
    if (![[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
        
    }else{
        NSLog(@"有这个文件了");
    }
     filePath = [NSString stringWithFormat:@"%@/%@",filePath,dic[@"fileName"]];
    self.filePath = filePath;
    NSString *URLStr = postStr;
    _task = [LXNetworking downloadWithUrl:URLStr saveToPath:filePath progress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
        //封装方法里已经回到主线程，所有这里不用再调主线程了
//        _progressLab.text=[NSString stringWithFormat:@"进度==%.2f",1.0 * bytesProgress/totalBytesProgress];
        
    } success:^(id response) {
        //下载成功了，进行预览
        [self lookFile:dic[@"fileName"]];
        

//        _progressLab.text=@"下载完成";
    } failure:^(NSError *error) {
        
    } showHUD:NO];
    
}
    //预览
- (IBAction)lookFile:(NSString *)fileName {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *url = [[manager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSURL *pathURL = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"oa/%@",fileName]];
    
    if (pathURL) {
        // Initialize Document Interaction Controller
        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:pathURL];
        
        // Configure Document Interaction Controller
        [self.documentInteractionController setDelegate:self];
        // Preview PDF
        [self.documentInteractionController presentPreviewAnimated:YES];
    }
}
#pragma mark Document Interaction Controller Delegate Methods
- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
    return self;
}
- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller{
    //看完文件之后，把之前浏览的给删除掉
    NSError * error = [[NSError alloc]init];
//    [[NSFileManager defaultManager]removeItemAtPath:self.filePath error:&error];
    //显示已经下载好的文件，简称站内文件
    NSArray * array = [[NSArray alloc]initWithArray:[[NSFileManager defaultManager]contentsOfDirectoryAtPath:[self.filePath stringByDeletingLastPathComponent] error:&error]];
    NSLog(@"%@",array);
    
}
@end
