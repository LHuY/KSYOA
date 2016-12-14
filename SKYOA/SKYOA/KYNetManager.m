//
//  KYNetManager.m
//  4-10网络工具类封装
//
//  Created by 石学谦 on 16/4/10.
//  Copyright © 2016年 guahaofeishangwan. All rights reserved.
//

#import "KYNetManager.h"
#import "AFNetworking.h" 
@interface KYNetManager ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;


@end

@implementation KYNetManager

+ (instancetype)sharedNetManager {
    static KYNetManager *instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[self alloc] init];
        instance.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:KYBaseURL sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        instance.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", @"text/plain", nil];
        //由于服务器方面需要json参数，故需要这行代码
        instance.manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
    });
    
    
    return instance;
}

//配置https请求
- (AFSecurityPolicy*)customSecurityPolicy
{
    // /先导入证书
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"clientSSL.cer" ofType:@""];//证书的路径
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];

    // AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
    
    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    // 如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = NO;
    
    
    securityPolicy.pinnedCertificates = [NSSet setWithObject:certData];
    
    return securityPolicy;
}
- (void)GET:(NSString *)URLString parameters:(id)parameters success:(void (^)(id result))success failure:(void (^)(NSError *error))failure{
//    self.manager.securityPolicy = [self customSecurityPolicy];
    [self.manager GET:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        failure(error);
    }];
}


- (void)POST:(NSString *)URLString parameters:(id)parameters success:(void (^)(id result))success failure:(void (^)(NSError *error))failure{
//    self.manager.securityPolicy = [self customSecurityPolicy];
//    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"text" ofType:@"cer"];
//    NSData * certData =[NSData dataWithContentsOfFile:cerPath];
//    NSSet * certSet = [[NSSet alloc] initWithObjects:certData, nil];
//    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
//    // 是否允许,NO-- 不允许无效的证书
//    [securityPolicy setAllowInvalidCertificates:YES];
//    // 设置证书
//    [securityPolicy setPinnedCertificates:certSet];
//    self.manager.securityPolicy = securityPolicy;
//    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        failure(error);
    }];
}


@end
