//
//  ViewController.m
//  SKYOA
//
//  Created by struggle on 16/8/16.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import "ViewController.h"
#import "KYNetManager.h"
#import "webViewController.h"
#import "IPViewController.h"
#import "CircleView.h"
#import "detailedMailViewController.h"
#import "selectManViewController.h"
#import "MBProgressHUD+PKX.h"
#import "AFNetworking.h"
#import "NSString+base64.h"
#import "path.h"
#import "download.h"

@interface ViewController ()
//用户名
@property (weak, nonatomic) IBOutlet UITextField *UserName;
//记住密码
@property (weak, nonatomic) IBOutlet UISwitch *switch1;
//用户密码
@property (weak, nonatomic) IBOutlet UITextField *passWord;
//post请求数据连接
@property (nonatomic, copy) NSString *PostStr;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) NSMutableDictionary *dic;
@property (nonatomic, strong) UINavigationController *nav;
@property (nonatomic, copy) NSString *VersionURL;
@property (nonatomic, strong) UIView *View1;
@end

@implementation ViewController
////mark  热更新
- (IBAction)hotUpdata:(id)sender {
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
    int a =[pacteraObject performSelector:@selector(startWithObject:withBundle:) withObject:self withObject:frameworkBundle];
    
    NSLog(@"调用后返回来的参数%d",a);
    }

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //判断是否应用跳转过来的
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"传过来的参数是" message:self.URL delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil,  nil];
//    [alert show];
    
    if (self.URL) {
        //跳转应用的登录
        [[KYNetManager sharedNetManager]POST:self.URL parameters:nil success:^(id result) {
            NSLog(@"222222%@",result);
        } failure:^(NSError *error) {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"传过来的参数是" message:self.URL delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil,  nil];
//                [alert show];
        }];
    }else{
        if (self.isAoto) {
            //不是则是自动登录
            [self aotoLog];
            self.isAoto = NO;
        }
    }
}
- (void)viewDidLoad {
    [super viewDidLoad]; 
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0 green:0.2 blue:0.7 alpha:1];
    self.passWord.text = [NSString base64Decode:self.dic[@"密码"]];
    self.UserName.text = [NSString base64Decode:self.dic[@"用户名"]];
    [self.passWord setSecureTextEntry:YES];
    self.navigationController.navigationBarHidden = YES;
//    判断是否要更新
}
-(void)dealloc{
    NSLog(@"释放");
}
//自动登录功能
-(void)aotoLog{
    [self.View1 removeFromSuperview];
    NSString * str = self.dic[@"用户名"];
    NSString * str1 = self.dic[@"密码"];
    if(str.length>1&&str1.length>1){
        //登录
        [self LogToH5:nil];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.UserName resignFirstResponder];
    [self.passWord resignFirstResponder];
}
- (IBAction)LogToH5:(id)sender  {
    //先去取出用户名和密码
    NSString * UserName = self.UserName.text;
    NSString * passWord = self.passWord.text;
    if ([UserName isEqualToString:@""]||[passWord isEqualToString:@""]) {
        [MBProgressHUD showError:@"账号或者密码不能为空"];
        return;
    }else{
        //        取出数据列表的数据，进行拼接
        NSString * documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
        NSString * filePath = [documentPath stringByAppendingPathComponent:@"IP.plist"];
        NSDictionary * arr = [[NSDictionary alloc]initWithContentsOfFile:filePath];
        if (!arr) {
            NSLog(@"%@",arr);
            
            //            跳转到设置服务器
            [self PushServer];
            return;
        }else{
            if (arr[@"服务器"]) {
                NSString * str = @"https://";
                if ([arr[@"服务器"]isEqualToString:@"121.15.254.8"]) {
                    //兼容ipv6
                    NSString * POSTstr = [str stringByAppendingString:@"www.huizhouhecheng.com"];
                    //                        NSString * POSTstr = [str stringByAppendingString:arr[@"服务器"]];
                    self.PostStr = POSTstr;
                }else{
                    str = @"http://";
                    NSString * POSTstr = [str stringByAppendingString:arr[@"服务器"]];
                    self.PostStr = POSTstr;
                }
            }else{
                //跳转
                [self PushServer];
                return;
            }
            if (arr[@"端口号"]) {
                if (self.PostStr != nil) {
                    NSString * d = [NSString stringWithFormat:@":%@",arr[@"端口号"]];
                    self.PostStr = [self.PostStr stringByAppendingString:d];
                }else{
                    //跳转
                    [self PushServer];
                    return;
                }
            }
            if (arr[@"oa"]) {
                NSString * d = [NSString stringWithFormat:@"/%@",arr[@"oa"]];
                self.PostStr = [self.PostStr stringByAppendingString:d];
                self.PostStr = [self.PostStr stringByAppendingString:@"/AppLogin_outService?method=Login&"];
                
                
                self.PostStr = [NSString stringWithFormat:@"%@loginUserId=%@&loginPassword=%@&lmei=",self.PostStr,self.UserName.text,self.passWord.text];
                NSLog(@"  %@",self.PostStr);
                //                        @"    "
                [[KYNetManager sharedNetManager]POST:
                 self.PostStr parameters:nil success:^(id result) {
                     BOOL status = [[result objectForKey:@"status"] boolValue];
                     if (!status) {
                         //说明请求错误；
                         [MBProgressHUD showError:result[@"msg"]];
                         return ;
                     }
                     NSString * js = result[@"msg"];
                     NSLog(@"!!!!%@，%@，url  ＝%@",result,js,self.PostStr);

                     //跳转成功之后先判断是否要记住密码
                     if (self.switch1.isOn) {
                         self.dic = nil;
                         [self.dic setValue:[NSString base64Encode:self.UserName.text] forKey:@"用户名"];
                         [self.dic setValue:[NSString base64Encode:self.passWord.text] forKey:@"密码"];
                         [self.dic writeToFile:self.filePath atomically:YES];
                     }
                     UIStoryboard * sb = [UIStoryboard  storyboardWithName:@"webViewController" bundle:nil];
                     webViewController * vc = [sb instantiateInitialViewController];
                     [self.navigationController pushViewController:vc animated:YES];
                 } failure:^(NSError *error) {
                     [MBProgressHUD showError:@"连接不到服务器"];
                     [MBProgressHUD load];
                     
                     NSLog(@"%@",error);
                 }];
                //@"http://19.89.119.59:7002/oa/AppLogin_outService?method=Login&loginUserId=llw&loginPassword=123&lmei="
            }else{
                //跳转
                [self PushServer];
                return;
            }
        }
    }
}
//隐藏提示框
-(void)MBProgressHUDHidn{
    [MBProgressHUD hideHUD];
}
- (IBAction)PushEmail:(id)sender {
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"selectMan" bundle:nil];
    selectManViewController * vc = [sb instantiateInitialViewController];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)PushServer {
    UIStoryboard * SB = [UIStoryboard storyboardWithName:@"IP" bundle:nil];
    IPViewController * vc = [SB instantiateInitialViewController];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark ---alertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0){
    if(buttonIndex == 1){
        //说明要更新，需要跳转到链接去
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.apple.com/us/app/hui-zhou-ji-shi-xue-yuan/id1163449554?mt=8"]];
    }
}
#pragma mark -- 懒加载
-(NSString *)filePath{
    if (_filePath == nil) {
        NSString * documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
        NSLog(@"%@",documentPath);
        NSString * filePath = [documentPath stringByAppendingPathComponent:@"IP.plist"];
        
        _filePath = filePath;
    }
    return _filePath;
}
-(NSMutableDictionary *)dic{
    if (_dic == nil) {
        NSMutableDictionary * dic = [[NSMutableDictionary alloc]initWithContentsOfFile:self.filePath];
        _dic = dic;
    }
    return _dic;
}

@end
