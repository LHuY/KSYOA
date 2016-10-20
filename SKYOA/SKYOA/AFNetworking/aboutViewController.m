//
//  aboutViewController.m
//  SKYOA
//
//  Created by struggle on 16/8/25.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import "aboutViewController.h"

@interface aboutViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation aboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0 green:0.2 blue:0.7 alpha:1];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // 当前应用软件版本  比如：1.0.1
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    self.label.text = [NSString stringWithFormat:@"当前的版本：%@",appCurVersion];
}
//联系我们
- (IBAction)lianxi:(id)sender {
    [self CallPhone];
}
//关注我们
- (IBAction)guanzhu:(id)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)getback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)CallPhone{
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",@"07522833727"];
    UIWebView * callWebview = [[UIWebView alloc] init];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
    [self.view addSubview:callWebview];
    
    
}

@end
