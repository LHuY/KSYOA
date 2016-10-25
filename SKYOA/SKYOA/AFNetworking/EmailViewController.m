//
//  ViewController.m
//  UICollectionViewText
//
//  Created by sunbk on 16/7/8.
//  Copyright © 2016年 xingyuan. All rights reserved.
//

#import "EmailViewController.h"
#import "CustomCollectionViewCell.h"
#import "ChineseString.h"
#import "ZYPinYinSearch.h"
#import "setEmailViewController.h"
#import "data.h"
#import "KYNetManager.h"
#import "detailedMailViewController.h"

#import "path.h"
#import "MBProgressHUD+PKX.h"
#import "UIButton+baritembtn.h"

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define kColor          [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1];
@interface EmailViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
//属性列表路径
@property (nonatomic, copy) NSString *path;
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (strong ,nonatomic)   UICollectionView * collectionView;
@property (strong ,nonatomic) UIScrollView * scrollView;
@property (assign,nonatomic) float  oldOffsetX;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) NSMutableArray * dataSource;
//收件箱数据
@property (nonatomic,strong) NSMutableArray * arrIn;
//发件箱数据
@property (nonatomic,strong) NSMutableArray * arrSend;
//草稿箱数据
@property (nonatomic,strong) NSMutableArray * arrDraft;
//总数据
@property (nonatomic,strong) NSMutableDictionary * allDic;
//@property (nonatomic, strong) NSMutableArray *allArray;
////判断是已经搜索，还是只是有光标，并没有在搜索烂中搜索
@property (nonatomic, assign) BOOL Search;

//收件箱搜索数据源
@property (nonatomic, strong) NSArray *searchArrIn;
//发件箱搜索数据源
@property (nonatomic, strong) NSArray *searchArrSend;
//草稿箱搜索数据源
@property (nonatomic, strong) NSArray *searchArrDraft;
//记录要跳转到详细页面时候的草稿箱，收发件箱
@property (nonatomic, copy) NSString *num;

//收件箱cell
@property (nonatomic, strong) CustomCollectionViewCell *CustomCollectionViewCell1;
//发件箱cell
@property (nonatomic, strong) CustomCollectionViewCell *CustomCollectionViewCell2;
//草稿箱cell
@property (nonatomic, strong) CustomCollectionViewCell *CustomCollectionViewCell3;

//搜索部分
@property (strong, nonatomic) UITableView *friendTableView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *allDataSource;/**<排序后的整个数据源*/
@property (strong, nonatomic) NSMutableArray *searchDataSource;/**<搜索结果数据源*/
@property (strong, nonatomic) NSArray *indexDataSource;/**<索引数据源*/
@property (assign, nonatomic) BOOL isSearch;

@end

@implementation EmailViewController
-(BOOL)prefersStatusBarHidden{
    return YES;
    
}
- (UIActivityIndicatorView *)activityIndicatorView{
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        [_activityIndicatorView setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
        _activityIndicatorView.color =[UIColor whiteColor];
        _activityIndicatorView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
        [self.view addSubview:_activityIndicatorView];
    }
    return _activityIndicatorView;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     [self btnOne];
    //每次pop回来的时候，让光标定位在收件箱中
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
        self.friendTableView.alpha = 0;
        [self.view addSubview:self.friendTableView];
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(TempMail) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(sendMail) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(QueryinBoxList) userInfo:nil repeats:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _CustomCollectionViewCell1 = self.CustomCollectionViewCell1;
    //左边的导航栏按钮
    UIButton * doBack = [UIButton BarButtonItemWithTitle:@"返回" addImage:[UIImage imageNamed:@"return"]];
    //给返回按钮添加点击事件
    [doBack addTarget:self action:@selector(doBack) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:doBack];
    
    UIButton * createEmail = [UIButton BarButtonItemWithTitle:@"创建" addImage:[UIImage imageNamed:@"set_up"]];
    [createEmail addTarget:self action:@selector(createEmail) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:createEmail];
//为导航栏添加右侧按钮
    
    self.navigationController.navigationBarHidden = NO;
    [self slideBnt];
//    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.pagingEnabled = YES;
    _collectionView.delegate = self;
    _collectionView.dataSource =self;
    [_collectionView registerNib:[UINib nibWithNibName:@"CustomCollectionViewCell"bundle:nil] forCellWithReuseIdentifier:@"CustomCollectionViewCell"];
    [self.view addSubview:_collectionView];

    
    
    _arrIn = [NSMutableArray array];
    _arrSend = [NSMutableArray array];
    _arrDraft = [NSMutableArray array];
    _allDic = [NSMutableDictionary dictionary];
    _searchArrDraft = [NSMutableArray array];
    _searchArrIn = [NSMutableArray array];
    _searchArrSend = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    //发件箱qingqiuu
    [self TempMail];
    //收件箱的请求
    [self sendMail];
    //草稿箱的请求
    [self QueryinBoxList];
    });
    //搜索部分
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.searchBar];
    
}
//发件箱qingqiuu
-(void)sendMail{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //发件箱
        //    @"http://19.89.119.59:7001/oa/AppHttpService?method=QuerySentBoxList&start=0&end=10"
        [[KYNetManager sharedNetManager]POST:[[path UstringWithURL:nil]stringByAppendingString:@"/AppHttpService?method=QueryinBoxList&start=0&end=100"] parameters:nil success:^(id result) {
            BOOL status = [[result objectForKey:@"status"] boolValue];
            if (!status) {
                //说明请求错误；
                [MBProgressHUD showError:@"服务器连接失败"];
                return ;
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                _arrSend = [data dataWithDic:result[@"data"]];
                
                //搜索部分数据
                self.searchArrSend = [searchData searchWithArray:result[@"data"]];
                [_allDic setObject:_arrSend forKey:@"发件箱"];
                [self.collectionView reloadData];
            });
        } failure:^(NSError *error) {
            NSLog(@"失败%@",error);
        }];
    });

}
//草稿箱的请求
-(void)QueryinBoxList{
    //收件箱
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //    @"http://19.89.119.59:7001/oa/AppHttpService?method=QueryinBoxList&start=0&end=10"
        [[KYNetManager sharedNetManager]POST:[[path UstringWithURL:nil]stringByAppendingString:@"/AppHttpService?method=QuerySentBoxList&start=0&end=100"] parameters:nil success:^(id result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL status = [[result objectForKey:@"status"] boolValue];
                if (!status) {
                    //说明请求错误；
                    [MBProgressHUD showError:@"服务器连接失败"];
                    return ;
                }

                _arrIn = [data dataWithDic:result[@"data"]];
                //搜索部分数据
                self.searchArrIn = [searchData searchWithArray:result[@"data"]];
                [_allDic setObject:_arrIn forKey:@"收件箱"];
                [self.collectionView reloadData];
            });
        } failure:^(NSError *error) {
            NSLog(@"失败%@",error);
        }];

    });
    }
//草稿箱
-(void)TempMail{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //草稿纸
        //        @"http://19.89.119.59:7001/oa/AppHttpService?method=QueryTempBoxList&start=0&end=10"
        [[KYNetManager sharedNetManager]POST:[[path UstringWithURL:nil]stringByAppendingString:@"/AppHttpService?method=QueryTempBoxList&start=0&end=10"] parameters:nil success:^(id result) {
            BOOL status = [[result objectForKey:@"status"] boolValue];
            if (!status) {
                //说明请求错误；
                [MBProgressHUD showError:@"服务器连接失败"];
                return ;
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                _arrDraft = [data dataWithDic:result[@"result"]];
                //搜索部分数据
                self.searchArrDraft = [searchData searchWithArray:result[@"result"]];
                
                [_allDic setObject:_arrDraft forKey:@"草稿箱"];
                [self.collectionView reloadData];
            });
            
        } failure:^(NSError *error) {
            NSLog(@"失败%@",error);
        }];

    });
   }
-(void)doBack{
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)dealloc{
    NSLog(@"释放");
}
//搜索部分
#pragma mark - Init
- (void)initData {
    //获取收发件箱，草稿的索引
        int count = _oldOffsetX/SCREEN_WIDTH;
//    [self curPagData:count];
     _searchDataSource = [NSMutableArray new];
    //获取当前页面的数据
    NSArray * arr =[self curPagData:count];

        //获取索引的首字母
    _indexDataSource = [ChineseString IndexArray:arr];
    
////    对原数据进行排序重新分组

    _allDataSource = [ChineseString LetterSortArray:arr];
}
//输入当前页面索引  ，返回当前页面数据
-(NSArray *)curPagData:(int)count{
    if (count == 0) {
        return self.searchArrIn;
    }
    if (count == 1) {
        return self.searchArrSend;
    }
    if (count == 2) {
        return self.searchArrDraft;
    }
    return nil;
}
- (UITableView *)friendTableView {
    if (!_friendTableView) {
        _friendTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 80, SCREEN_WIDTH, SCREEN_HEIGHT-359) style:UITableViewStylePlain];
        _friendTableView.backgroundColor = kColor;
        _friendTableView.delegate = self;
        _friendTableView.dataSource = self;
    }
    return _friendTableView;
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!_isSearch) {
       
        return _indexDataSource.count;
    }else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!_isSearch) {
        return [_allDataSource[section] count];
    }else {
        return _searchDataSource.count;
    }
}
//头部索引标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (!_isSearch) {
        return _indexDataSource[section];
    }else {
        return nil;
    }
}
//右侧索引列表
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (!_isSearch) {
        return _indexDataSource;
    }else {
        return nil;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
//        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    if (!_isSearch) {
//       对模型进行分解
        NSArray * resolve = [_allDataSource[indexPath.section][indexPath.row] componentsSeparatedByString:@"LhhY"];
//        _allDataSource[indexPath.section][indexPath.row];
        cell.imageView.image = [UIImage imageNamed:@"logo"];
        cell.textLabel.text = resolve.firstObject;
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@                      %@",resolve[1],resolve[2]];
    }else{
        NSLog(@"~~~~~~%@",_searchDataSource[indexPath.row]);
        cell.textLabel.text = _searchDataSource[indexPath.row];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard  * SB = [UIStoryboard storyboardWithName:@"detailedMail" bundle:nil];
    detailedMailViewController * VC = [SB  instantiateInitialViewController];
    if (self.Search) {
        //表示已经在编辑
         int count = _oldOffsetX/SCREEN_WIDTH;
        NSArray * arr =[self curPagData:count];
        
        for (NSString * str in arr) {
                if ([str rangeOfString:_searchDataSource[indexPath.row]].location == NSNotFound) {
//
                }else{
//                    NSLog(@"表示包含");
                    NSArray * arr = [str componentsSeparatedByString:@"LhhY"];
//                    NSLog(@"%@,~~%@",arr,arr.lastObject);
                    VC.mail_ID = arr.lastObject;
                }
            
        }
        
    }else{
//        NSLog(@"没查询，直接点击");
//        对模型进行分解
        NSArray * resolve = [_allDataSource[indexPath.section][indexPath.row] componentsSeparatedByString:@"LhhY"];
        VC.mail_ID = resolve.lastObject;
    }
    VC.isSearch = YES;
    [self.navigationController pushViewController:VC animated:YES];
    
    //退出，没查询标识
    self.Search = NO;
    [UIView animateWithDuration:0.3 animations:^{
        int count = _oldOffsetX/SCREEN_WIDTH;
        NSLog(@"name = %d",count);
        self.friendTableView.alpha = 0;
        _searchBar.frame = CGRectMake(0, 78, SCREEN_WIDTH, 44);
        _searchBar.showsCancelButton = NO;
    }];
    [_searchBar resignFirstResponder];
    _searchBar.text = @"";
    _isSearch = NO;
    [_friendTableView reloadData];
}
//索引点击事件
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    return index;
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if ([searchText isEqualToString:@""]) {
        NSLog(@"为空");
        //没有搜索
        self.Search = NO;
        
    }else{
        //正在搜索
        NSLog(@"正在搜索");
        self.Search = YES;
    }
    [_searchDataSource removeAllObjects];
    NSArray *ary = [NSArray new];
    int count = _oldOffsetX/SCREEN_WIDTH;
    NSMutableArray * arrM = [NSMutableArray array];
    for (NSString * str in [self curPagData:count]) {
        NSArray * arr = [str componentsSeparatedByString:@"LhhY"];
        [arrM addObject:arr.firstObject];
    }
    ary = [ZYPinYinSearch searchWithOriginalArray:arrM andSearchText:searchText andSearchByPropertyName:@"name"];
    if (searchText.length == 0) {
        _isSearch = NO;
        [_searchDataSource addObjectsFromArray:_allDataSource];
    }else {
        _isSearch = YES;
        [_searchDataSource addObjectsFromArray:ary];
    }
    [self.friendTableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    [self initData];
    [UIView animateWithDuration:0.3 animations:^{
        int count = _oldOffsetX/SCREEN_WIDTH;
        NSLog(@"name = %d",count);
        [self.friendTableView reloadData];
        self.friendTableView.alpha = 1;
//        self.navigationController.navigationBarHidden = YES;
        _searchBar.frame = CGRectMake(0, 42, SCREEN_WIDTH, 44);
        _searchBar.showsCancelButton = YES;
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    //退出，没查询标识
    self.Search = NO;
        [UIView animateWithDuration:0.3 animations:^{
            int count = _oldOffsetX/SCREEN_WIDTH;
            NSLog(@"name = %d",count);
            self.friendTableView.alpha = 0;
    _searchBar.frame = CGRectMake(0, 78, SCREEN_WIDTH, 44);
    _searchBar.showsCancelButton = NO;
        }];
    [_searchBar resignFirstResponder];
    _searchBar.text = @"";
    _isSearch = NO;
    [_friendTableView reloadData];
}


//搜索部分
//收发邮件按钮滑动
-(void)slideBnt{
    UIView * btnBgView =[[UIView alloc]initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 60)];
//        btnBgView.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:btnBgView];
    UIButton * btn1 =[[UIButton alloc]initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH/3.0, 44)];
    [btn1 setImage:[UIImage imageNamed:@"getMail"] forState:UIControlStateNormal];
    [btn1 setTitle:@"收件箱" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(btnOne) forControlEvents:UIControlEventTouchUpInside];
    [btnBgView addSubview:btn1];
    
    
    UIButton * btn2 =[[UIButton alloc]initWithFrame:CGRectMake( CGRectGetMaxX(btn1.frame),20, SCREEN_WIDTH/3.0, 44)];
    [btn2 setImage:[UIImage imageNamed:@"send"] forState:UIControlStateNormal];
    [btn2 setTitle:@"发件箱" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(btnTwo) forControlEvents:UIControlEventTouchUpInside];
    [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnBgView addSubview:btn2];
    
    UIButton * btn3 =[[UIButton alloc]initWithFrame:CGRectMake( CGRectGetMaxX(btn2.frame),20, SCREEN_WIDTH/3.0, 44)];
    [btn3 setImage:[UIImage imageNamed:@"tempMail"] forState:UIControlStateNormal];
    [btn3 setTitle:@"草稿箱" forState:UIControlStateNormal];
    [btn3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(btnThree) forControlEvents:UIControlEventTouchUpInside];
    [btnBgView addSubview:btn3];
    //线的滑动范围
    _scrollView =[[ UIScrollView alloc]initWithFrame:CGRectMake(0, 55, SCREEN_WIDTH, 2)];
    
    //滑动线
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, btn1.frame.size.width, 2)];
        line.backgroundColor = [UIColor blueColor];
    [_scrollView addSubview:line];
    [btnBgView addSubview:_scrollView];
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    layout.itemSize = CGSizeMake(SCREEN_WIDTH,SCREEN_HEIGHT-100);
    layout.minimumInteritemSpacing  = 0.0 ;
    layout.minimumLineSpacing = 0.0;
    _collectionView  = [[UICollectionView alloc]initWithFrame:CGRectMake(0,90, SCREEN_WIDTH, SCREEN_HEIGHT-140) collectionViewLayout:layout];
    _collectionView.frame = CGRectMake(0, 90, SCREEN_WIDTH, SCREEN_HEIGHT-120);
//    [self.view addSubview:_collectionView];
//    [self.view bringSubviewToFront:self.view1];
}
//收件按钮
- (void)btnOne
{
    if (_oldOffsetX  == 0) {
        return;
    }
    [_collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    _oldOffsetX = 0;
    [self.activityIndicatorView startAnimating];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //分线程做耗时操作 == 数据请求
//        sleep(2);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //回到主线程刷新UI
            
//            cell.dataArray = [self curPagData:cellpath.row];
            [self.CustomCollectionViewCell1.myTableView reloadData];
            [self.activityIndicatorView stopAnimating];
            
            
        });
    });
    
}
//发件按钮
- (void)btnTwo
{
    
    if (_oldOffsetX == SCREEN_WIDTH) {
        return;
    }
//    NSIndexPath * cellpath = [NSIndexPath indexPathForItem:(1) inSection:0];
//    CustomCollectionViewCell *cell  =    (CustomCollectionViewCell *) [_collectionView  cellForItemAtIndexPath:cellpath];
    [_collectionView setContentOffset:CGPointMake(SCREEN_WIDTH, 0) animated:YES];
    
    [_scrollView setContentOffset:CGPointMake(-SCREEN_WIDTH/3.0, 0) animated:YES];
    _oldOffsetX = SCREEN_WIDTH;
    [self.activityIndicatorView startAnimating];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //分线程做耗时操作 == 数据请求
//        sleep(2);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //回到主线程刷新UI
            
//            cell.dataArray = _allArray[cellpath.row] ;
            [self.CustomCollectionViewCell2.myTableView reloadData];
            [self.activityIndicatorView stopAnimating];
            
            
        });
    });
    
}
//草稿箱
- (void)btnThree
{
    if (_oldOffsetX == SCREEN_WIDTH*2) {
        return;
    }
//    NSIndexPath * cellpath = [NSIndexPath indexPathForItem:(2) inSection:0];
//    CustomCollectionViewCell *cell  =    (CustomCollectionViewCell *) [_collectionView  cellForItemAtIndexPath:cellpath];
    [_collectionView setContentOffset:CGPointMake(SCREEN_WIDTH*2, 0) animated:YES];
    [_scrollView setContentOffset:CGPointMake(-SCREEN_WIDTH*2/3.0, 0) animated:YES];
    _oldOffsetX = SCREEN_WIDTH*2;
    [self.activityIndicatorView startAnimating];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //分线程做耗时操作 == 数据请求
//        sleep(2);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //回到主线程刷新UI
            
//            cell.dataArray = _allArray[cellpath.row] ;
            [_CustomCollectionViewCell3.myTableView reloadData];
            [self.activityIndicatorView stopAnimating];
            
            
        });
    });
    
}
- (void)createEmail{
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"setEmail" bundle:nil];
    setEmailViewController *vc = [sb instantiateInitialViewController];
    vc.personData1 = self.personData1;
    //返回Block判断是发送还是保存。然后点击到当前的页面
    vc.blockName = ^(NSString * count){
        if([count isEqualToString:@"1"]){
            //则为发件
            //切换到发件箱
            [self btnTwo];
            //获取最新数据
            [self sendMail];
        }else{
            //则为保存
            //切换到草稿箱
            [self btnThree];
            [self TempMail];
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
    
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return 3;
    
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CustomCollectionViewCell" forIndexPath:indexPath];
    int count = _oldOffsetX/SCREEN_WIDTH;
    cell.count1 = [NSString stringWithFormat:@"%d",count];
    self.num = cell.count1;
    if (indexPath.row == 0) {
        cell.dataArray = _allDic[@"发件箱"];
        
        cell.nav = self.navigationController;
    }
    if (indexPath.row == 1) {
        cell.dataArray = _allDic[@"收件箱"];
        cell.nav = self.navigationController;
    }
    if (indexPath.row == 2) {
        cell.dataArray = _allDic[@"草稿箱"];
        cell.nav = self.navigationController;
    }
    cell.personData1 = self.personData1;
    [cell.myTableView reloadData];
    return cell;
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:_collectionView]) {
        [_scrollView setContentOffset:CGPointMake((-SCREEN_WIDTH/3.0)*(scrollView.contentOffset.x/SCREEN_WIDTH), 0) animated:YES];
        if (_oldOffsetX !=scrollView.contentOffset.x ) {
            
            [self.activityIndicatorView startAnimating];
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                //分线程做耗时操作 == 数据请求
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //回到主线程刷新UI
                    
                    [self.activityIndicatorView stopAnimating];
                    
                });
            });
            
        }
        _oldOffsetX = scrollView.contentOffset.x;
        
    }
    
}
#pragma mark----懒加载
- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 78, SCREEN_WIDTH, 44)];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"搜索";
        _searchBar.showsCancelButton = NO;
    }
    return _searchBar;
}
-(NSString *)path{
    if (_path == nil) {
        NSString * documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
        NSString * filePath = [documentPath stringByAppendingPathComponent:@"mail.plist"];
        NSMutableArray * arr = [[NSMutableArray alloc]initWithContentsOfFile:filePath
                                ];
        if (arr == nil ) {
            NSMutableArray * arrM = [NSMutableArray array];
            [arrM writeToFile:filePath atomically:YES];
        }
        return filePath;
    }
    return nil;
}
-(CustomCollectionViewCell *)CustomCollectionViewCell1{
    if (_CustomCollectionViewCell1 == nil) {
        NSIndexPath * cellpath = [NSIndexPath indexPathForItem:(0) inSection:0];
        _CustomCollectionViewCell1  =    (CustomCollectionViewCell *) [_collectionView  cellForItemAtIndexPath:cellpath];
    }
    return _CustomCollectionViewCell1;
}
-(CustomCollectionViewCell *)CustomCollectionViewCell2{
    if (_CustomCollectionViewCell2 == nil) {
        NSIndexPath * cellpath = [NSIndexPath indexPathForItem:(1) inSection:0];
        _CustomCollectionViewCell2  =    (CustomCollectionViewCell *) [_collectionView  cellForItemAtIndexPath:cellpath];
    }
    return _CustomCollectionViewCell2;
}
-(CustomCollectionViewCell *)CustomCollectionViewCell3{
    if (_CustomCollectionViewCell3 == nil) {
        NSIndexPath * cellpath = [NSIndexPath indexPathForItem:(2) inSection:0];
        _CustomCollectionViewCell3  =    (CustomCollectionViewCell *) [_collectionView  cellForItemAtIndexPath:cellpath];
    }
    return _CustomCollectionViewCell1;
}
@end
