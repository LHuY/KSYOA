//
//  SplashScreenView.m
//  移动办公
//
//  Created by L灰灰Y on 2016/12/28.
//  Copyright © 2016年 struggle. All rights reserved.
//
#define kSplashScreenImage @"SplashScreenImage"
#define kImagesSavedFolder @"YFSplashScreenView"

#define fileManager [NSFileManager defaultManager]


#import "SplashScreenView.h"


@interface SplashScreenView()<NSURLSessionDownloadDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *defaultImage;//默认图片
@property (nonatomic, copy) NSString *imageUrl;//显示图片

@end
@implementation SplashScreenView

//抽屉效果   每次新的都去请求
-(instancetype)initWithFrame:(CGRect)frame
                defaultImage:(UIImage *)defaultImage{
    if(self == [super initWithFrame:frame]){
        self.defaultImage = defaultImage;
        self.imageUrl = nil;
        [self layout];
    }
    return self;
}

-(void)layout{
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
    
    NSString *imageName = [self getCurrentLaunchImageNameForOrientation:orientation];
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:imageName]];
    
    //Add Animatable UIImageView
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.contentMode = UIViewContentModeScaleToFill;
    self.imageView.alpha = 0;
    [self addSubview:self.imageView];
    
    
    //The Location of Logo and Name is the same as the Current LaunchScreen's
    //add App Logo
    CGFloat loginWidth = self.bounds.size.width / 6;
    CGFloat loginHeight = loginWidth;
    CGFloat loginX = (self.bounds.size.width - loginWidth) / 2;
    CGFloat loginY = self.bounds.size.height / 7;
    UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(loginX,loginY, loginWidth, loginHeight)];
    //增加图标效果
    logoView.image = [UIImage imageNamed:@"lgo.png"];
    [self addSubview:logoView];
    
    //add App Name
    NSString *appName = @"";//[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    CGSize nameLabelSize = [appName sizeWithAttributes: @{
                                                          NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.bounds.size.width - nameLabelSize.width) / 2, CGRectGetMaxY(logoView.frame) + 10, nameLabelSize.width, nameLabelSize.height)];
    nameLabel.text = appName;
    nameLabel.font = [UIFont systemFontOfSize:15];
    nameLabel.textColor = [UIColor colorWithRed:93/255.0 green:40/255.0 blue:4/255.0 alpha:1];
    [self addSubview:nameLabel];
    
    NSString *path = [self pathToSave];
    if([fileManager fileExistsAtPath:path]){
        NSData *data = [NSData dataWithContentsOfFile:path options:0 error:nil];
        if(data){
            self.imageView.image = [UIImage imageWithData:data];
        }
    }else{
        self.imageView.image = self.defaultImage;
    }
    [self startAnimation:(self.imageView.image == nil) ? 0 : 1];
}


-(void)startAnimation:(CGFloat)duration{
    self.imageView.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:duration delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.imageView.transform = CGAffineTransformMakeScale(1.3,1.3);
        self.imageView.alpha = 1;
        if(_animationStartBlock){
            _animationStartBlock();
        }
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration + 0.5 animations:^{
            self.imageView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            //Remove
            [self removeFromSuperview];
            if(_animationCompletedBlock){
                _animationCompletedBlock();
            }
        }];
    }];
}

-(void)setImage:(NSString *)imageUrl{
    if(imageUrl == nil) return;
    self.imageUrl = imageUrl;
    [self createHttpRequestForImage:imageUrl];
}


-(void)createHttpRequestForImage:(NSString *)imageUrl{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    NSURLSessionDownloadTask *pictureDownloadTask = [session downloadTaskWithRequest:request];
    [pictureDownloadTask resume];
}

-(NSString *)pathToSave{
    
    //get Documents Path
    NSString  *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [libraryPath stringByAppendingPathComponent:kImagesSavedFolder];
    
    [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return [path stringByAppendingPathComponent:kSplashScreenImage];
}

#pragma -m NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    
    NSString *path = [self pathToSave];
    
    [fileManager removeItemAtPath:path error:nil];
    
    [fileManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:path] error:nil];
    
    NSLog(@"Download Success!");
    
    [session invalidateAndCancel];
}

//- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
//      didWriteData:(int64_t)bytesWritten
// totalBytesWritten:(int64_t)totalBytesWritten
//totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
//
//}
//
//- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
// didResumeAtOffset:(int64_t)fileOffset
//expectedTotalBytes:(int64_t)expectedTotalBytes{
//
//}

-(void)clearImageSavedFolder{
    NSError *error;
    [fileManager removeItemAtPath:[self pathToSave] error:&error];
    NSLog(@"The Folder is already Cleared");
}


//["UILaunchImageMinimumOSVersion"] = "8.0",
//["UILaunchImageName"] = ""LaunchImage-800-Portrait-736h",
//["UILaunchImageOrientation"] = "Portrait",
//["UILaunchImageSize"] = "{414, 736}"
-(NSString *)getCurrentLaunchImageNameForOrientation:(UIInterfaceOrientation)orientation{
    NSString *currentImageName = nil;
    
    CGSize viewSize = self.bounds.size;
    NSString* viewOrientation = @"Portrait";
    
    if(UIInterfaceOrientationIsLandscape(orientation)){
        viewSize = CGSizeMake(viewSize.height, viewSize.width);
        viewOrientation = @"Landscape";
    }
    
    NSArray *imageDicts = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary * dic in imageDicts) {
        CGSize imageSize = CGSizeFromString(dic[@"UILaunchImageSize"]);
        NSString *orientation = dic[@"UILaunchImageOrientation"];
        if(CGSizeEqualToSize(viewSize, imageSize) && [orientation isEqualToString:viewOrientation]){
            currentImageName = dic[@"UILaunchImageName"];
        }
    }
    
    return currentImageName;
}
@end
