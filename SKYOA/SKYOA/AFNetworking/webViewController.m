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
#import <objc/runtime.h>
#import <objc/message.h>
#import "ZipArchive.h"
#import "attachmentTableController.h"
#import "Upload.h"

#define Radius 20
@interface webViewController ()<NSURLConnectionDataDelegate,UIWebViewDelegate,UIDocumentInteractionControllerDelegate>
//加载动画显示
@property(strong,nonatomic) UIView * centerCir;
@property(strong,nonatomic) UIView * leftCir;
@property(strong,nonatomic) UIView * rightCir;
@property(strong,nonatomic) NSTimer * timer;
//~~~~~~~~~~~
@property (weak, nonatomic) IBOutlet UIView *contentView;
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
//记录一下版本更新URL
@property (nonatomic, copy) NSString *VersionURL;
@property (nonatomic, strong) NSMutableArray *titleArr;
//判断是否要自动登录
@property (nonatomic, assign) bool  isAoto;
//文件上传的参数值。
@property (nonatomic, strong) NSArray *uploadVal;

@end

@implementation webViewController
//隐藏状态栏
-(BOOL)prefersStatusBarHidden{
    return YES;
}
-(void)hotUpdataWithURL:(NSString *)URL{
    [[download new]downloadWithURl:URL fileName:@"Test1.framework.zip" success:^(id result) {
        //成功之后，先判断原先是否
        NSString * zipPath = [NSString stringWithFormat:@"%@/Documents/oa/Test1.framework.zip",NSHomeDirectory()];
        NSString * path = [NSString stringWithFormat:@"%@/Documents/",NSHomeDirectory()];
        NSLog(@"~~~~~~~~~%@",path);
         ZipArchive* zip = [[ZipArchive alloc] init];
        if( [zip UnzipOpenFile:zipPath] ){
            BOOL result = [zip UnzipFileTo:path overWrite:YES];
            if( NO==result ){
                //添加代码
            }
            [zip UnzipCloseFile];
            //解压成功之后，把压缩包去掉，
            NSError * errer;
            [[NSFileManager defaultManager]removeItemAtPath:zipPath error:&errer];
            if (errer) {
                NSLog(@"解压失败：：%@",errer);
            }
        }
    }];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //一开始先先测是否要侧更新
    [self examineHotUpada];
    //隐藏导航栏
    self.navigationController.navigationBarHidden =  YES;
    //创建webView
    self.webView1 = [[UIWebView alloc]initWithFrame:self.view.bounds];
    self.isAoto = NO;
    //静止webView下拉滑动
    self.webView1.scrollView.bounces = NO;
    [self.view addSubview:self.webView1];
    [self.view bringSubviewToFront:self.contentView];
    self.contentView.hidden = YES;
    //把webview添加到数组中，到时候返回的时候，删除数组中最后一个，即父控件最上层Viwe
    [self.ViewArr addObject:self.webView1];
    self.webView1.delegate = self;
    self.title1.hidden = YES;
    self.navBnt.hidden = YES;
    //邮箱人员列表请求
         [self paple];
    //添加webView后缀
    [self.URLArr addObject:@"/jsp/app/index.html"];
    //显示首页面
    //    @"http://19.89.119.59:7001/oa/jsp/app/index.html"
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self pushPageWithURL:[[path UstringWithURL:nil]stringByAppendingString:@"/jsp/app/index.html"]];
    });
    [self addThreeCir];
    [self timer];
}
- (void)addThreeCir
{
    UIView * centerCir = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Radius, Radius)];
    centerCir.center = self.view.center;
    centerCir.layer.cornerRadius = Radius * 0.5;
    centerCir.layer.masksToBounds = YES;
    centerCir.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:centerCir];
    self.centerCir = centerCir;
    
    CGPoint centerPoint = centerCir.center;
    
    UIView * leftCir = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Radius, Radius)];
    CGPoint leftCenter = leftCir.center;
    leftCenter.x = centerPoint.x - Radius;
    leftCenter.y = centerPoint.y;
    leftCir.center = leftCenter;
    leftCir.layer.cornerRadius = Radius * 0.5;
    leftCir.layer.masksToBounds = YES;
    leftCir.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:leftCir];
    self.leftCir = leftCir;
    
    UIView * rightCir = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Radius, Radius)];
    CGPoint rightCenter = rightCir.center;
    rightCenter.x = centerPoint.x + Radius;
    rightCenter.y = centerPoint.y;
    rightCir.center = rightCenter;
    rightCir.layer.cornerRadius = Radius * 0.5;
    rightCir.layer.masksToBounds = YES;
    rightCir.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:rightCir];
    self.rightCir = rightCir;
    
}
//邮箱人员列表请求
-(void)paple{
    //邮箱人员列表请求
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[KYNetManager sharedNetManager]POST:[[path UstringWithURL:nil]stringByAppendingString:@"/AppHttpService?method=GetDeptLsit"] parameters:nil success:^(id result) {
            BOOL status = [[result objectForKey:@"status"] boolValue];
            if (status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.personData1 = [personData personWithArray:result[@"nextactors"]];
                });
            }else{
                
            }
        } failure:^(NSError *error) {
        }];
    });
    
}
-(void)dealloc{
    NSLog(@"释放");
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
    [self.titleArr removeLastObject];
    self.title1.text = self.titleArr.lastObject ;
    //也把对应的url去掉
    [self.URLArr removeLastObject];
    self.webView1 = self.ViewArr.lastObject;
    //如果只有一页，那么导航栏影藏
    if (self.titleArr.count == 1) {
        self.contentView.hidden = YES;
    }
}


#pragma mark--UIWebview-代理
- (void)webViewDidStartLoad:(UIWebView *)webView{
    self.contentView.hidden = NO;
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
#pragma mark --- 去除加载页面动画
-(void)removeLoadingView{
        [self.leftCir removeFromSuperview];
        [self.centerCir removeFromSuperview];
        [self.rightCir removeFromSuperview];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    //去除加载页面动画
    [self removeLoadingView];
    //判断webView是否唯一
    if (self.ViewArr.count >1) {
        self.caidan.hidden = YES;
    }
    JSContext *context = [self.webView1 valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //定义好给js调用跳转web页面
    context[@"iosGoforward"] = ^() {
        NSArray *args = [JSContext currentArguments];
        for (JSValue *jsVal in args) {
            self.webView1 = [[UIWebView alloc]initWithFrame:CGRectMake(0, 44, [UIScreen mainScreen].bounds.size.width , [UIScreen mainScreen].bounds.size.height-44)];
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
    context[@"iosUpload"] = ^(){
        NSArray *args = [JSContext currentArguments];
        self.uploadVal = args;
        NSLog(@"%@",args);
        dispatch_async(dispatch_get_main_queue(), ^{
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"attachmentTableController" bundle:nil];
            
            attachmentTableController * vc = [sb instantiateInitialViewController];
            vc.didSelect = (^ (NSString * fileName){
                //通知公告文件上传。
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/AppUploadService?biz=%@&processid=%@&encryption=&bizclass=%@&creatorid=",[path UstringWithURL:nil],self.uploadVal[1],self.uploadVal.firstObject,self.uploadVal.lastObject]];
                [Upload sendAttachmentFileName:fileName filepath:[NSString stringWithFormat:@"%@/Documents/oa/%@", NSHomeDirectory(),fileName] URL:url success:^(id result) {
                    result = [NSJSONSerialization JSONObjectWithData:result options:0 error:NULL];
                    NSLog(@"！！！%@",result);
                    BOOL stast = [[result valueForKey:@"status"] boolValue];
                    if (stast) {
                        //上传成功
                        [MBProgressHUD showSuccess:@"上传成功"];
                        //上传成功。重新刷新
                        [self.webView1 reload];
                    }
                } failure:^(NSError *error) {
                    NSLog(@"%@",error);
                }];
            });
            self.navigationController.modalPresentationStyle = UIModalPresentationPopover;
            [self.navigationController pushViewController:vc animated:YES];
        });
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
        NSLog(@"%@",[[path UstringWithURL:nil] stringByAppendingString:@"/AppLogin_outService?method=LoginOut"] );
//        dispatch_async(dispatch_get_main_queue(), ^{
            [[KYNetManager sharedNetManager]POST:[[path UstringWithURL:nil] stringByAppendingString:@"/AppLogin_outService?method=LoginOut&loginUserId=c"] parameters:nil success:^(id result) {
                 [self.navigationController popToRootViewControllerAnimated:YES];
            } failure:^(NSError *error) {
                NSLog(@"%@",error);
            }];
//
//        });
        
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
    //跳转后续的下一个模块
    context[@"good"] = ^(){
        [self good];
    };
    context[@"communicate"] = ^(){
        [self communicate];
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
    
    //获取当前页的titile
    self.title1.hidden = NO;
    self.title1.text = [self.webView1 stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.navBnt.hidden = NO;
    [self.titleArr addObject:self.title1.text];
    if ([currentURL isEqualToString:[[path UstringWithURL:nil]stringByAppendingString:@"/jsp/app/index.html"]]) {
        self.contentView.hidden = YES;
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
    EmailViewController * vc = [sb instantiateViewControllerWithIdentifier:@"mail"];
    if (self.personData1 == nil) {
        [MBProgressHUD showError:@"网络不给力，稍后"];
        //邮箱人员列表请求
        [self paple];
    }else{
        vc.personData1 = self.personData1;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.navigationController pushViewController:vc animated:YES];
        });
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
    
    [[KYNetManager sharedNetManager]POST:[[path UstringWithURL:nil]stringByAppendingString:[NSString stringWithFormat:@"/AppHttpService?method=QueryVersion&ver=%d&dev=ios",appCurVersion.intValue]] parameters:nil success:^(id result) {
        NSLog(@"！！！！%@",result);
        BOOL status = [[result objectForKey:@"status"] boolValue];
        if (status){
            [self examineHotUpada];
            self.VersionURL = result[@"url"];
            //获取后台的版本号
            //表示已经是最新版本
            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"需要更新吗？" message:[NSString stringWithFormat:@"版本号:%@",appCurVersion]delegate:self cancelButtonTitle:@"下一次" otherButtonTitles:@"需要", nil];
            [alter show];
        }else{
            if (!self.isAoto) {
                //说明是自动登录过来的检测版本，不运行；
                self.isAoto = YES;
                return ;
            }
            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"已经是最新版本" message:[NSString stringWithFormat:@"版本号:%@",appCurVersion]delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alter show];
        }
    } failure:^(NSError *error) {
        
    }];
    
}
//检测热更新
-(void)examineHotUpada{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentDirectory = nil;
    if ([paths count] != 0)
        documentDirectory = [paths objectAtIndex:0];
    NSLog(@"documentDirectory = %@",documentDirectory);
    //拼接我们放到document中的framework路径
    NSString *libName = @"Test1.framework";
    NSString *destLibPath = [documentDirectory stringByAppendingPathComponent:libName];
    
    //判断一下有没有这个文件的存在　如果没有直接跳出
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:destLibPath]) {
        //说明没有文件，则直接去下载，
        
        //判断是否需要更新
        [[KYNetManager sharedNetManager]POST:[[path UstringWithURL:nil]stringByAppendingString:[NSString stringWithFormat:@"/AppHttpService?method=QueryVersion&ver=1&dev=ioshost"]] parameters:nil success:^(id result) {
            NSLog(@"说明没有动态库，直接下载！！！%@",result);
            BOOL status = [[result objectForKey:@"status"] boolValue];
            if (status){
                //说明热更新需要跟新,则开始下载动态库
                [self hotUpdataWithURL:result[@"url"]];
            }
        } failure:^(NSError *error) {
            
        }];
        return;
    }
    //复制到程序中
    NSError *error = nil;
    
    //加载方式二：使用NSBundle加载动态库
    NSBundle *frameworkBundle = [NSBundle bundleWithPath:destLibPath];
    if (frameworkBundle && [frameworkBundle load]) {
        NSLog(@"bundle load framework success.");
    }else {
        NSLog(@"bundle load framework err:%@",error);
        return;
    }
    Class pacteraClass = NSClassFromString(@"FrameWorkStart");
    if (!pacteraClass) {
        NSLog(@"Unable to get TestDylib class");
        return;
    }
    NSObject *pacteraObject = [pacteraClass new];
    //获取返回动态库版本号
    int CurVersionNum =[pacteraObject performSelector:@selector(examineHotUpada:withBundle:) withObject:self withObject:frameworkBundle];
    NSLog(@"调用后返回来的参数%d",CurVersionNum);
    if (CurVersionNum == 0) {
        return;
    }
    //判断是否需要更新
    [[KYNetManager sharedNetManager]POST:[[path UstringWithURL:nil]stringByAppendingString:[NSString stringWithFormat:@"/AppHttpService?method=QueryVersion&ver=%d&dev=ioshost",CurVersionNum]] parameters:nil success:^(id result) {
        NSLog(@"！！！！%@",result);
        BOOL status = [[result objectForKey:@"status"] boolValue];
        if (status){
            //说明热更新需要跟新,则开始下载动态库
            [self hotUpdataWithURL:result[@"url"]];
        }
    } failure:^(NSError *error) {
        
    }];
    }
#pragma mark ---alertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0){
    if(buttonIndex == 1){
        //说明要更新，需要跳转到链接去
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.apple.com/us/app/hui-zhou-ji-shi-xue-yuan/id1163449554?mt=8"]];
    }
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
#pragma mark  动态加载模块

-(void)communicate{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentDirectory = nil;
    if ([paths count] != 0)
        documentDirectory = [paths objectAtIndex:0];
    NSLog(@"documentDirectory = %@",documentDirectory);
    //拼接我们放到document中的framework路径
    NSString *libName = @"Test1.framework";
    NSString *destLibPath = [documentDirectory stringByAppendingPathComponent:libName];
    
    //判断一下有没有这个文件的存在　如果没有直接跳出
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:destLibPath]) {
        NSLog(@"There isn't have the file");
        return;
    }
    //复制到程序中
    NSError *error = nil;
    
    //加载方式二：使用NSBundle加载动态库
    NSBundle *frameworkBundle = [NSBundle bundleWithPath:destLibPath];
    if (frameworkBundle && [frameworkBundle load]) {
        NSLog(@"bundle load framework success.");
    }else {
        NSLog(@"bundle load framework err:%@",error);
        return;
    }
    Class pacteraClass = NSClassFromString(@"FrameWorkStart");
    if (!pacteraClass) {
        NSLog(@"Unable to get TestDylib class");
        return;
    }
    NSObject *pacteraObject = [pacteraClass new];
    [pacteraObject performSelector:@selector(callObject:withBundle:) withObject:self withObject:frameworkBundle];
}
//mark  加载动态库方法
-(void)good{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentDirectory = nil;
    if ([paths count] != 0)
        documentDirectory = [paths objectAtIndex:0];
    NSLog(@"documentDirectory = %@",documentDirectory);
    //拼接我们放到document中的framework路径
    NSString *libName = @"Test1.framework";
    NSString *destLibPath = [documentDirectory stringByAppendingPathComponent:libName];
    
    //判断一下有没有这个文件的存在　如果没有直接跳出
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:destLibPath]) {
        NSLog(@"There isn't have the file");
        return;
    }
    //复制到程序中
    NSError *error = nil;
    
    //加载方式二：使用NSBundle加载动态库
    NSBundle *frameworkBundle = [NSBundle bundleWithPath:destLibPath];
    if (frameworkBundle && [frameworkBundle load]) {
        NSLog(@"bundle load framework success.");
    }else {
        NSLog(@"bundle load framework err:%@",error);
        return;
    }
    Class pacteraClass = NSClassFromString(@"FrameWorkStart");
    if (!pacteraClass) {
        NSLog(@"Unable to get TestDylib class");
        return;
    }
    NSObject *pacteraObject = [pacteraClass new];
    [pacteraObject performSelector:@selector(startWithObject:withBundle:) withObject:self withObject:frameworkBundle];
}
- (NSTimer *)timer
{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(firstAnimation) userInfo:nil repeats:YES];
        [_timer fire];
    }
    return _timer;
}
- (void)firstAnimation
{
    [UIView animateWithDuration:1.0f animations:^{
        
        self.leftCir.transform = CGAffineTransformMakeTranslation(-Radius, 0);
        self.leftCir.transform = CGAffineTransformScale(self.leftCir.transform, 0.75, 0.75);
        self.rightCir.transform = CGAffineTransformMakeTranslation(Radius, 0);
        self.rightCir.transform = CGAffineTransformScale(self.rightCir.transform, 0.75, 0.75);
        self.centerCir.transform = CGAffineTransformScale(self.centerCir.transform, 0.75, 0.75);
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0f animations:^{
            self.leftCir.transform = CGAffineTransformIdentity;
            self.rightCir.transform = CGAffineTransformIdentity;
            self.centerCir.transform = CGAffineTransformIdentity;
            [self secondAnimation];
        }];}];
    
}
- (void)secondAnimation
{
    UIBezierPath * leftCirPath = [UIBezierPath bezierPath];
    [leftCirPath addArcWithCenter:self.view.center radius:Radius startAngle:M_PI endAngle:2 * M_PI + 2 * M_PI clockwise:NO];
    
    CAKeyframeAnimation * leftCirAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    leftCirAnimation.path = leftCirPath.CGPath;
    leftCirAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    leftCirAnimation.fillMode = kCAFillModeForwards;
    leftCirAnimation.removedOnCompletion = YES;
    leftCirAnimation.repeatCount = 2;
    leftCirAnimation.duration = 1.0f;
    
    [self.leftCir.layer addAnimation:leftCirAnimation forKey:@"cc"];
    
    
    UIBezierPath * rightCirPath = [UIBezierPath bezierPath];
    [rightCirPath addArcWithCenter:self.view.center radius:Radius startAngle:0 endAngle:M_PI + 2 * M_PI clockwise:NO];
    CAKeyframeAnimation * rightCirAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    rightCirAnimation.path = rightCirPath.CGPath;
    rightCirAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rightCirAnimation.fillMode = kCAFillModeForwards;
    rightCirAnimation.removedOnCompletion = YES;
    rightCirAnimation.repeatCount = 2;
    rightCirAnimation.duration = 1.0f;
    
    [self.rightCir.layer addAnimation:rightCirAnimation forKey:@"hh"];
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
-(NSMutableArray *)titleArr{
    if (_titleArr == nil) {
        _titleArr = [NSMutableArray array];
    }
    return _titleArr;
}
@end
