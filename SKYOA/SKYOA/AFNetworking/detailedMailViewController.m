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
#import "TextViewTableViewCell.h"
#import "download.h"

static NSString *cellID=@"cellID";
@interface detailedMailViewController ()<NSURLConnectionDataDelegate,UIDocumentInteractionControllerDelegate,UITableViewDelegate,UITableViewDataSource>
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


//字符串识别，添加tabel
@property (nonatomic,strong)UITableView *textTableView;
@property(nonatomic,strong)UITextView *textView1;
@end
@implementation detailedMailViewController

//-(BOOL)prefersStatusBarHidden{
//    return YES;
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    //注册cell
    [self.textTableView registerClass:[TextViewTableViewCell class] forCellReuseIdentifier:cellID];
    
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
    
    NSString * postStr = [NSString stringWithFormat:@"%@/AppHttpService?method=GetEmailHtml&emailId=%@",[path UstringWithURL:nil],mail_ID];
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
        NSLog(@"%@",dic[@"content"]);
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[dic[@"content"] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//         NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[dic[@"subject"]dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        self.textView.attributedText  = attributedString;
//        self.textView.text = dic[@"content"];
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
    CGRect rect = [[UIScreen mainScreen] bounds];
    self.scrollView.contentSize=CGSizeMake(0,rect.size.height);
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
    NSString * line = @"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n";
    NSString * sendMan = [NSString stringWithFormat:@"  发件人:  %@\n",self.dic[@"sender"]];
    //发件时间
    NSString * time = [NSString stringWithFormat:@"  发件时间:  %@\n",self.model.SEND_TIME];
    
    //主题
    NSString * title = [NSString stringWithFormat:@"  主题:回复：%@\n",self.dic[@"subject"]];
   NSString * line1 = @"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n";
    NSString  * content = self.textView.text;
    NSString * togetter = [NSString stringWithFormat:@"%@%@%@%@%@%@",line,sendMan,time,title,line1,content];
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
    [[download new]downloadWithURl:str fileName:dic[@"fileName"] success:^(id result) {
        //成功之后，预览文件
        [self lookFile:dic[@"fileName"]];
    }];
    
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



//集成进来
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    
//    return self.dataSoureArr.count;
//}
//
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    TextViewTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
//    cell.dataDic = _dataSoureArr[indexPath.row];
//    
//    
//    return cell;
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITextView *textView = [[UITextView alloc]initWithFrame:CGRectZero];
//    NSString *nickName = _dataSoureArr[indexPath.row][@"nickName"];
//    NSString *contentStr = _dataSoureArr[indexPath.row][@"content"];
//    NSString *timeStr = _dataSoureArr[indexPath.row][@"time"];
//    
//    NSString *allContentStr = [NSString stringWithFormat: @"%@: %@ %@",nickName,contentStr,timeStr];
//    textView.attributedText = [self setLabelTextColor:allContentStr nick:nickName time:timeStr];
//    [textView sizeToFit];
//    
//    //textView的高度
//    float textViewHeight = [self heightForString:textView andWidth:self.view.bounds.size.width -20];
//    
//    
//    //让cell的高度 等于textView的高度
//    return textViewHeight;
//    
//}
//
//
//- (float) heightForString:(UITextView *)textView andWidth:(float)width{
//    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
//    return sizeToFit.height;
//}
//
//
////这里主要是获取字符串大小  配合上面的方法准确计算出textView的高度 来动态设置cell的高度
//- (NSMutableAttributedString *)setLabelTextColor:(NSString *)string nick:(NSString *)nickName time:(NSString *)time
//{
//    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:string];
//    
//    NSRange range = [string rangeOfString:nickName];
//    [attributedStr addAttributes:@{NSForegroundColorAttributeName:[UIColor blueColor],NSFontAttributeName:[UIFont systemFontOfSize:18]} range:NSMakeRange(0, range.length )];
//    NSRange range1 = [string rangeOfString:time];
//    [attributedStr addAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor],NSFontAttributeName:[UIFont systemFontOfSize:12]} range:NSMakeRange(range1.location,range1.length)];
//    
//    [attributedStr addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} range:NSMakeRange(range.location+range.length,string.length-range1.length-range.length)];
//    
//    return attributedStr;
//}
//-(NSArray *)dataSoureArr{
//    if (_dataSoureArr == nil) {
//         _dataSoureArr = [[NSArray alloc] init];
//        _dataSoureArr = @[
//                    @{@"content":@"18824286088",@"time":@"2016-5-13",@"nickName":@"风中的草"},
//                          @{@"content":@"测试策划侧反馈食风坡附近破冰我偶尔偶尔玩vmfew复刻品咖啡",@"time":@"2014-12-13",@"nickName":@"hahaha"},
//                          @{@"content":@"测试策划侧反馈食风坡 vmfew复刻品咖啡配咖啡分 www.baidu.com 开拍咖算分为破发金额为平均分破而价格破耳机公婆而价格破耳机股票而价格破而价格破耳机公婆二极管 ",@"time":@"2014-12-13",@"nickName":@"苦逼的码农啊"},
//                          @{@"content":@"测试策划侧反馈食风坡vmfew复刻品咖啡配咖啡分开拍咖算 0755-86302744 分为破发金额为平均分破而价格破耳机公婆而价格破耳机股票而价格破而价格破耳机公婆二极管 ",@"time":@"2014-12-13",@"nickName":@"有用给个评论支持下"},
//                          @{@"content":@"测试策划侧反馈食风坡 的反馈配额外房客网客服 876333335@qq.com 品味咖啡配网客服皮肤科访客无法看房客网可分为罚款未开发未付款为破耳机公婆而价格破耳机股票而价格破而价格破耳机公婆二极管 ",@"time":@"2014-12-13",@"nickName":@"共同进步"}
//                          ];
//    }
//    return _dataSoureArr;
//}
//-(UITableView *)textTableView
//{
//    if (!_textTableView) {
//        _textTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
//        _textTableView.delegate = self;
//        _textTableView.dataSource =self;
//        _textTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//去掉多余的分割线
//        [self.view addSubview:_textTableView];
//    }
//    
//    return _textTableView;
//    
//}


@end
