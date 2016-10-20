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

- (void)GET:(NSString *)URLString parameters:(id)parameters success:(void (^)(id result))success failure:(void (^)(NSError *error))failure{
    
    [self.manager GET:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        failure(error);
    }];
}


- (void)POST:(NSString *)URLString parameters:(id)parameters success:(void (^)(id result))success failure:(void (^)(NSError *error))failure{
    
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        failure(error);
    }];
}


@end
