//
//  IPViewController.m
//  SKYOA
//
//  Created by struggle on 16/8/16.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import "IPViewController.h"
#import "webViewController.h"
#import "ViewController.h"
#import "MBProgressHUD+PKX.h"
//#import "NSString+base64.h"

@interface IPViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textFile1;
@property (weak, nonatomic) IBOutlet UITextField *textFile2;
@property (weak, nonatomic) IBOutlet UITextField *textFile3;
@property (nonatomic, strong) NSMutableDictionary *dic;
//保存路径
@property (nonatomic, copy) NSString *filePath;
@end

@implementation IPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textFile1.delegate = self;
    NSMutableDictionary * dic = [[NSMutableDictionary alloc]initWithContentsOfFile:self.filePath];
    if (dic == nil ) {
        NSMutableDictionary* arrM = [NSMutableDictionary dictionary];
        [arrM setObject:@"http://oa.hzti.net" forKey:@"服务器"];
        [arrM setObject:@"7001" forKey:@"端口号"];
        [arrM setObject:@"oa" forKey:@"oa"];
        [arrM setObject:@"" forKey:@"密码"];
        [arrM setObject:@"" forKey:@"用户名"];
        [arrM writeToFile:self.filePath atomically:YES];
        self.textFile1.text = @"http://oa.hzti.net";
        self.textFile2.text = @"7001" ;
        self.textFile3.text = @"oa";
    }else{
        //解密
        //        self.textFile1.text = [NSString base64Decode:dic[@"服务器"]];
        //        self.textFile2.text = [NSString base64Decode:dic[@"端口号"]];
        //        self.textFile3.text = [NSString base64Decode:dic[@"oa"]];
        self.textFile1.text = dic[@"服务器"];
        self.textFile2.text = dic[@"端口号"];
        self.textFile3.text = dic[@"oa"];
    }
}
//确定
- (IBAction)tureBnt:(id)sender {
    //加密
    
    //    [self.dic setValue:[NSString base64Encode:self.textFile1.text] forKey:@"服务器"];
    //    [self.dic setValue:[NSString base64Encode:self.textFile2.text] forKey:@"端口号"];
    //    [self.dic setValue:[NSString base64Encode:self.textFile3.text] forKey:@"oa"];
    [self.dic setValue:self.textFile1.text forKey:@"服务器"];
    [self.dic setValue:self.textFile2.text forKey:@"端口号"];
    [self.dic setValue:self.textFile3.text forKey:@"oa"];
    [self.dic writeToFile:self.filePath atomically:YES];
    [MBProgressHUD showMessage:@""];
    [self performSelector:@selector(returnPag) withObject:nil afterDelay:0.5];
    //跳转到跟控制器
    
    
}
-(void)returnPag{
    [MBProgressHUD hideHUD];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
//取消要进行判断
- (IBAction)cancel:(id)sender {
}
//跳转到跟控制器
- (IBAction)PushViewController:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.textFile1 resignFirstResponder];
    [self.textFile2 resignFirstResponder];
    [self.textFile3 resignFirstResponder];
}

#pragma mark --- textFile
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}
-(NSMutableDictionary *)dic{
    if (_dic == nil) {
        NSMutableDictionary * dic = [[NSMutableDictionary alloc]initWithContentsOfFile:self.filePath];
        _dic = dic;
    }
    return _dic;
}
-(NSString *)filePath{
    if (_filePath == nil) {
        NSString * documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
        NSLog(@"%@",documentPath);
        NSString * filePath = [documentPath stringByAppendingPathComponent:@"IP.plist"];
        
        _filePath = filePath;
    }
    return _filePath;
}
@end
