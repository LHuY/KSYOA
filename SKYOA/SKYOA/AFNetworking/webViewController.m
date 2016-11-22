//
//  webViewController.m
//  SKYOA
//
//  Created by struggle on 16/8/16.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import "webViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "aboutViewController.h"
#import "EmailViewController.h"
#import "KYNetManager.h"
#import "path.h"
#import "personData.h"
#import "MBProgressHUD+PKX.h"
#import "IPViewController.h"
#import "changePasswordViewController.h"
#import "download.h"
#import "LXNetworking.h"

@interface webViewController ()<NSURLConnectionDataDelegate,UIWebViewDelegate,UIDocumentInteractionControllerDelegate,UIDocumentInteractionControllerDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) UIWebView *webView1;
@property (nonatomic, assign) BOOL count;
@property (weak, nonatomic) IBOutlet UILabel *title1;
@property (weak, nonatomic) IBOutlet UIButton *navBnt;
//人员列表模型数据
@property (nonatomic, strong) NSMutableArray *personData1;

//下载附件
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, assign) NSInteger length;
@property (nonatomic, assign) NSInteger currentLength;
//缓存路径
@property (nonatomic, copy) NSString *libCachePath;
//预览模式，第三方打开
@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;
//用户菜单按钮
@property (weak, nonatomic) IBOutlet UIButton *caidan;

//用来收集webView，返回的时候，删除VIew中最上层试图
@property (nonatomic, strong) NSMutableArray *ViewArr;
//用来收集跳转到页面的URL
@property (nonatomic, strong) NSMutableArray *URLArr;

@property (nonatomic,strong)LXURLSessionTask *task;
//文件路径
@property (nonatomic, copy) NSString *Path;
@end

@implementation webViewController
//隐藏状态栏
-(BOOL)prefersStatusBarHidden{
    return YES;
}


- (void)viewDidLoad {
         [super viewDidLoad];
    //隐藏导航栏
    
    self.navigationController.navigationBarHidden =  YES;
    //创建webView
    self.webView1 = [[UIWebView alloc]initWithFrame:CGRectMake(0, 35, [UIScreen mainScreen].bounds.size.width , [UIScreen mainScreen].bounds.size.height-35)];
    //静止webView下拉滑动
    self.webView1.scrollView.bounces = NO;
    [self.view addSubview:self.webView1];
    //把webview添加到数组中，到时候返回的时候，删除数组中最后一个，即父控件最上层Viwe
    [self.ViewArr addObject:self.webView1];
    self.webView1.delegate = self;
    self.title1.hidden = YES;
    self.navBnt.hidden = YES;
    //邮箱人员列表请求
    [[KYNetManager sharedNetManager]POST:[[path UstringWithURL:nil]stringByAppendingString:@"/AppHttpService?method=GetDeptLsit"] parameters:nil success:^(id result) {
        BOOL status = [[result objectForKey:@"status"] boolValue];
        if (status) {
            self.personData1 = [personData personWithArray:result[@"nextactors"]];
            
        }else{
            
        }
    } failure:^(NSError *error) {
    }];
    //添加webView后缀
    [self.URLArr addObject:@"/jsp/app/index.html"];
    //显示首页面
//    @"http://19.89.119.59:7001/oa/jsp/app/index.html"
    [self pushPageWithURL:[[path UstringWithURL:nil]stringByAppendingString:@"/jsp/app/index.html"]];
   }

- (IBAction)en:(id)sender {
//    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"sad" withExtension:@"doc"];
//    
//    if (URL) {
//        // Initialize Document Interaction Controller
//        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:URL];
//        
//        // Configure Document Interaction Controller
//        [self.documentInteractionController setDelegate:self];
//        
//        // Preview PDF
//        [self.documentInteractionController presentPreviewAnimated:YES];
//    }
    [self.webView reload];
    
}


//返回
- (IBAction)fanhui:(id)sender {
    if (self.ViewArr.count ==1) {
        //如果只有一个webVIew什么也不干；
        
        return;
    }
    if (self.ViewArr.count == 2) {
        self.navBnt.hidden = YES;
        self.title1.hidden = NO;
        //如果webView只有一层，则显示
        self.caidan.hidden = NO;
    }
   UIWebView * view = self.ViewArr.lastObject;
    [view removeFromSuperview];
    //返回的时候，把最顶端的webVIew除去
    [self.ViewArr removeLastObject];
    //也把对应的url去掉
    [self.URLArr removeLastObject];
    self.webView1 = self.ViewArr.lastObject;
}


#pragma mark--UIWebview-代理
- (void)webViewDidStartLoad:(UIWebView *)webView{
   
    
}
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
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    //判断webView是否唯一
    if (self.ViewArr.count >1) {
        self.caidan.hidden = YES;
    }
    JSContext *context = [self.webView1 valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //定义好给js调用跳转web页面
    context[@"iosGoforward"] = ^() {
        NSArray *args = [JSContext currentArguments];
        for (JSValue *jsVal in args) {
            self.webView1 = [[UIWebView alloc]initWithFrame:CGRectMake(0, 35, [UIScreen mainScreen].bounds.size.width , [UIScreen mainScreen].bounds.size.height-35)];
            //静止下拉效果
            self.webView1.scrollView.bounces = NO;
            [self.view addSubview:self.webView1];
            self.webView1.delegate = self;
            [self.ViewArr addObject:self.webView1];
            NSString * url1 = [path UstringWithURL:nil];
            
            url1 = [url1 stringByAppendingString:jsVal.toString];
            
            [self.URLArr addObject:[[jsVal.toString componentsSeparatedByString:@"?"]firstObject]];
            [self pushPageWithURL:[url1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        
    };
    //提供js调用提示框
    context[@"iosShowToast"] = ^(){
        NSArray *args = [JSContext currentArguments];
        for (JSValue *jsVal in args) {
            //需要提示的文字
            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"" message:jsVal.toString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alter show];
        }
    };
   
    context[@"iosDownload"] = ^(){
        NSArray *args = [JSContext currentArguments];
        [[download new] downloadWithURl:args.firstObject fileName:args.lastObject success:^(id result) {
            [self lookFile:args.lastObject];
        }];
    };
    //返回 时候调用
    context[@"iosBack"] = ^(){
        

        NSArray *args = [JSContext currentArguments];
        for (int i = 0; i < args.count; ++i) {
            
            //第一个参数传过来的是URL，判断是否与self.URLarr数组中包含有，如果有包含，就把url的上层WebView都除去
            JSValue * jsVal = args[i];
            if (i == 0) {
                //判断是否包含有这个URL
                if([self.URLArr containsObject:jsVal.toString]){
                    //计算url对应的webview上面的View有几个
                 NSUInteger count = self.URLArr.count-[self.URLArr indexOfObject:jsVal.toString]-1;
                    for (int i = 0; i < count; ++i) {
                        //依次删除URL上面的webview如层
                        
                        [self.URLArr removeLastObject];
                        UIView * view = self.ViewArr.lastObject;
                        [view removeFromSuperview];
                        [self.ViewArr removeLastObject];
                                            }
                }
            }
            self.webView1 = self.ViewArr.lastObject;
            //第二个参数是要调用js的参数
            if (i == 1) {
                //判断传过来的是否有值
                if (![jsVal isNull]) {
                    if ([jsVal.toString isEqualToString:@"reload"]) {
                        [self.webView1 reload];
                    }else{

                        //不是空，则肯定，有值传过来要调用js的方法名
                        [self CallJsShow:jsVal.toString];
                    }
                }
            }
        }
    };
    //注销账号
    context[@"cancel"] = ^(){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
        
    };
    context[@"about"] = ^(){
        NSLog(@"about");
        [self about];
    };
    context[@"newEdition"] = ^(){
        NSLog(@"newEdition检测新版本");
        [self newEdition];
    };
    //清楚缓存
    context[@"clearBuffer"] = ^(){
        //清楚页面缓存，
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        //清楚原生的缓存
        [MBProgressHUD showSuccess:@"清理成功"];
    };
    //跳转到
    context[@"mail"] = ^(){
        
        [self pushiMail];
    };
    //修改密码
    context[@"revisePassword"] = ^(){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"修改密码");
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"changePassword" bundle:nil];
            changePasswordViewController * vc = [sb instantiateInitialViewController];
            [self.navigationController pushViewController:vc animated:YES];
        });
    };
    

    
    NSString * currentURL = self.webView1.request.URL.absoluteString;
    
    if ([currentURL isEqualToString:[[path UstringWithURL:nil]stringByAppendingString:@"/jsp/app/index.html"]]) {
        //获取当前页的titile
        self.title1.hidden = NO;
        self.title1.text = [self.webView1 stringByEvaluatingJavaScriptFromString:@"document.title"];
        self.navBnt.hidden = YES;
    }else{
        self.navBnt.hidden = NO;
        self.title1.hidden = YES;
        
    }
}




- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"" message:@"网页加载失败！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alter show];
    
    if ([error code] == NSURLErrorCancelled) {
        
        return;
    }
}
#pragma mark------菜单栏
//弹出菜单栏
- (IBAction)nottifi:(id)sender {
//    [self about];
    if (!self.count) {
        [self CallJsShow:@"showmenu()"];
        self.count = YES;
    }else{
        [self CallJsShow:@"hidemenu()"];
        self.count = NO;
    }
}
-(void)pushiMail{
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"mail" bundle:nil];
    EmailViewController * vc = [sb instantiateInitialViewController];
    if (self.personData1 == nil) {
        [MBProgressHUD showError:@"网络不给力，稍后"];
    }else{
        vc.personData1 = self.personData1;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//调用js方法的方法
-(void)CallJsShow:(NSString * )show{
    JSContext *context = [self.webView1 valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    [context evaluateScript:show];
}
//版本检测
-(void)newEdition{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // 当前应用软件版本  比如：1.0.1
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSLog(@"当前应用软件版本:%@",appCurVersion);
    // 当前应用版本号码   int类型
    NSString *appCurVersionNum = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSLog(@"当前应用版本号码：%@",appCurVersionNum);
    //当前app版本号
    //获取后台的版本号
            //表示已经是最新版本
            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"当前版本！" message:[NSString stringWithFormat:@"版本号:%@",appCurVersion]delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alter show];
}

//关于
- (void)about{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"about" bundle:nil];
        aboutViewController * vc = [sb instantiateInitialViewController];
        
        [self.navigationController pushViewController:vc animated:YES];
    });
    
}


//显示受页面
-(void)pushPageWithURL:(NSString *)urlString{
    //跳转页面之前，先记录URL，self.URLArr跟self.ViewArr一一对应；
    
    //清空webVIew缓存数据
//    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURL *url =[[NSURL alloc] initWithString:urlString];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [self.webView1 loadRequest:request];
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
    NSArray * array = [[NSArray alloc]initWithArray:[[NSFileManager defaultManager]contentsOfDirectoryAtPath:[self.Path stringByDeletingLastPathComponent] error:&error]];
    NSLog(@"%@",array);
    
}
#pragma mark----懒加载
-(NSMutableArray *)URLArr{
    if (_URLArr == nil) {
        _URLArr = [NSMutableArray array];
    }
    return _URLArr;
}
-(NSString *)libCachePath{
    if (_libCachePath == nil) {
        NSString * paths = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)lastObject];
        return [paths stringByAppendingString:@"/Caches"];
    }
    return _libCachePath;
}
- (NSMutableData *)data {
    if (_data == nil) {
        _data = [NSMutableData data];
    }
    return _data;
}
-(NSMutableArray *)ViewArr{
    if (_ViewArr == nil) {
        _ViewArr = [NSMutableArray array];
    }
    
    return _ViewArr;
}

@end
