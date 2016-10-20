//
//  NSDictionary+Log.m
//  01-掌握-多值参数和中文输出
//

#import <Foundation/Foundation.h>

// 重写系统的打印方法，
// 需要知道的是NSDictionary和NSArray各自都有打印方法
// 也就是说，你重写了NSArray打印重写方法，打印NSArray对象才会执行重写的方法

// 如果是通过子类来重写父类系统的方法，那么使用的时候就需要导入这个子类
// 但是通过类别重写系统方法，就不需要import导入，因为系统中导入了已经有了同名的被重写的方法了，系统会优先加载类别里的重写的方法，连.h声明文件都可以不用了，因为系统中已经有.h声明文件

@implementation NSDictionary (Log)

//控制输出:对字典或者是数组进行排版
-(NSString *)descriptionWithLocale:(id)locale
{
    NSMutableString *string = [NSMutableString string];
    //设置开始
    [string appendString:@"{\n"];
    
    //设置key-value
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [string appendFormat:@"%@:",key];
        [string appendFormat:@"%@,\n",obj];
    }];
    //设置结尾
    [string appendString:@"}"];
    
    //删除最后的逗号
    NSRange range = [string rangeOfString:@"," options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        [string deleteCharactersInRange:range];
    }
    return string;
}

/*
 -(NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
 {
 NSMutableString *string = [NSMutableString string];
 //设置开始
 [string appendString:@"{"];
 
 //设置key-value
 [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
 
 [string appendFormat:@"%@:",key];
 [string appendFormat:@"%@",obj];
 }];
 //设置结尾
 [string appendString:@"}"];
 return string;
 }
 */
@end


@implementation NSArray (Log)

//控制输出:对字典或者是数组进行排版
-(NSString *)descriptionWithLocale:(id)locale
{
    NSMutableString *string = [NSMutableString string];
    //设置开始
    [string appendString:@"["];
    
    //设置key-value
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [string appendFormat:@"%@,",obj];
        
    }];
    //设置结尾
    [string appendString:@"]"];
    
    NSRange range = [string rangeOfString:@"," options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        [string deleteCharactersInRange:range];
    }
    
    return string;
}

@end