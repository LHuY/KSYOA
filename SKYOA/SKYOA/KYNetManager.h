//
//  KYNetManager.h
//  4-10网络工具类封装
//
//  Created by 石学谦 on 16/4/10.
//  Copyright © 2016年 guahaofeishangwan. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KYBaseURL [NSURL URLWithString:@"http://iosapi.itcast.cn/"]


/**
 *  网络工具类f封装
 */
@interface KYNetManager : NSObject
@property (nonatomic, strong) NSArray *arrayM;
///返回网络工具类单例
+ (instancetype)sharedNetManager;

/**
 *  get请求的方法
 *
 *  @param URLString  不需要baseURL的  字符串
 *  @param parameters 请求的参数
 *  @param success    成功的回调
 *  @param failure    失败的回调
 */
- (void)GET:(NSString *)URLString parameters:(id)parameters success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;


/**
 *  get请求的方法
 *
 *  @param URLString  不需要baseURL的  字符串
 *  @param parameters 请求的参数
 *  @param success    成功的回调
 *  @param failure    失败的回调
 */
- (void)POST:(NSString *)URLString parameters:(id)parameters success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
@end
