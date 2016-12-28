//
//  changePasswordViewController.m
//  SKYOA
//
//  Created by struggle on 16/9/27.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import "changePasswordViewController.h"
#import "KYNetManager.h"
#import "MBProgressHUD+PKX.h"
#import "path.h"

@interface changePasswordViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *oldPassword;
@property (weak, nonatomic) IBOutlet UITextField *setPassword;
@property (weak, nonatomic) IBOutlet UITextField *certainPassword;


@end

@implementation changePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.title = @"修改密码";
    self.oldPassword.delegate = self;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"首页" style:UIBarButtonItemStylePlain target:self action:@selector(topPage)];//为导航栏添加右侧按钮
    
}
-(void)topPage{
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.oldPassword resignFirstResponder];
    [self.setPassword resignFirstResponder];
    [self.certainPassword resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)certain:(id)sender {

    if (![self.certainPassword.text isEqualToString:self.setPassword.text]) {
        [MBProgressHUD showError:@"密码输入不一致"];
        return;
    }
    NSString * a = [NSString stringWithFormat:@"%@/AppHttpService?method=UpPassWord&oldpw=%@&newpw=%@",[path UstringWithURL:nil],self.oldPassword.text,self.certainPassword.text];
    
    [[KYNetManager sharedNetManager]POST:a parameters:nil success:^(id result) {
        BOOL status = [[result objectForKey:@"status"] boolValue];
        if (!status) {
            [MBProgressHUD showError:@"密码修改失败"];
        }else{
            //说明密码修改成功
            [MBProgressHUD showSuccess:@"密码修改成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    } failure:^(NSError *error) {
        [MBProgressHUD showError:@"请输入正确的密码"];
    }];
}


@end
