//
//  selectManViewController.m
//  SKYOA
//
//  Created by struggle on 16/9/19.
//  Copyright © 2016年 struggle. All rights reserved.
//

#import "selectManViewController.h"
#import "YUFoldingTableView.h"
#import "KYNetManager.h"
#import "path.h"
#import "ZYPinYinSearch.h"
#import "ChineseString.h"
#import "UIButton+baritembtn.h"

#define kScreenWidth        [UIScreen mainScreen].bounds.size.width
#define kScreenHeight       [UIScreen mainScreen].bounds.size.height
#define kColor          [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1];
@interface selectManViewController ()<YUFoldingTableViewDelegate,UITableViewDelegate,UITableViewDataSource,UITabBarDelegate,UISearchBarDelegate>

@property (nonatomic, weak) YUFoldingTableView *foldingTableView;


//搜索部分
@property (strong, nonatomic) UITableView *friendTableView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *allDataSource;/**<排序后的整个数据源*/
@property (strong, nonatomic) NSMutableArray *searchDataSource;/**<搜索结果数据源*/
@property (strong, nonatomic) NSArray *indexDataSource;/**<索引数据源*/
@property (strong, nonatomic) NSArray *dataSource;/**<排序前的整个数据源*/
@property (assign, nonatomic) BOOL isSearch;
//字典中，以人名为键名organName，人 邮件id为值 organid
@property (nonatomic, strong) NSDictionary *dic;
//判断是已经搜索，还是只是有光标，并没有在搜索烂中搜索
@property (nonatomic, assign) BOOL Search;
@end

@implementation selectManViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //左边的导航栏按钮
    UIButton * doBack = [UIButton BarButtonItemWithTitle:@"返回" addImage:[UIImage imageNamed:@"return"]];
    //给返回按钮添加点击事件
    [doBack addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:doBack];
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    // 创建tableView
    [self setupFoldingTableView];
    //搜索部分
    
    self.navigationItem.title = @"选择要收件的人";
    self.view.backgroundColor = [UIColor whiteColor];
    [self initData];
    [self.view addSubview:self.friendTableView];
    [self.view addSubview:self.searchBar];
    self.friendTableView.alpha = 0;
    //搜索部分
}
#pragma mark --- 隐藏状态栏
-(BOOL)prefersStatusBarHidden{
    return YES;
}
-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Init
- (void)initData {
    NSMutableArray* arr =[NSMutableArray array];
    NSMutableDictionary * dic = [NSMutableDictionary dictionary ];
    for (NSArray * array in self.arr.lastObject) {
        for (personData * model in array) {
            [arr addObject:model.organName];
            [dic setObject:model.organId forKey:model.organName];
        }
    }
    self.dic = dic;
    _dataSource = arr;
    _searchDataSource = [NSMutableArray new];
    //获取索引的首字母
    _indexDataSource = [ChineseString IndexArray:_dataSource];
    //对原数据进行排序重新分组
    _allDataSource = [ChineseString LetterSortArray:_dataSource];
}

- (UITableView *)friendTableView {
    if (!_friendTableView) {
        _friendTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight-330) style:UITableViewStylePlain];
        _friendTableView.backgroundColor = kColor;
        _friendTableView.delegate = self;
        _friendTableView.dataSource = self;
    }
    return _friendTableView;
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 44, kScreenWidth, 44)];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"搜索";
        _searchBar.showsCancelButton = NO;
    }
    return _searchBar;
}

#pragma mark - UITableViewDataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    personData * model = [[personData alloc]init];
    if (self.Search) {
        model.organName = _searchDataSource[indexPath.row];
    }else{
        //说明没所搜，直接点击
        NSArray * row = self.allDataSource[indexPath.section];
        model.organName = row[indexPath.row];
    }
    model.organId = self.dic[model.organName];
    if (self.blockName) {
        self.blockName(model);
    }
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
}
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    if (!_isSearch) {
        cell.textLabel.text = _allDataSource[indexPath.section][indexPath.row];
    }else{
        cell.textLabel.text = _searchDataSource[indexPath.row];
    }
    return cell;
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
    ary = [ZYPinYinSearch searchWithOriginalArray:_dataSource andSearchText:searchText andSearchByPropertyName:@"name"];
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
    [UIView animateWithDuration:0.3 animations:^{
        self.navigationController.navigationBarHidden = YES;
        self.friendTableView.alpha = 1;
        self.navigationController.navigationBarHidden = YES;
        _searchBar.frame = CGRectMake(0, 20, kScreenWidth, 44);
        _searchBar.showsCancelButton = YES;
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    //退出，没查询标识
    self.Search = NO;
    [UIView animateWithDuration:0.3 animations:^{
    self.friendTableView.alpha = 0;
    _searchBar.frame = CGRectMake(0, 64, kScreenWidth, 44);
         }];
    self.navigationController.navigationBarHidden = NO;
    _searchBar.showsCancelButton = NO;
    [_searchBar resignFirstResponder];
    _searchBar.text = @"";
    _isSearch = NO;
    [_friendTableView reloadData];
}










// 创建tableView
- (void)setupFoldingTableView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    YUFoldingTableView *foldingTableView = [[YUFoldingTableView alloc] initWithFrame:CGRectMake(0, 88, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 88)];
    _foldingTableView = foldingTableView;
    
    [self.view addSubview:foldingTableView];
    foldingTableView.foldingDelegate = self;
}

#pragma mark - YUFoldingTableViewDelegate / required（必须实现的代理）
// 返回箭头的位置
- (YUFoldingSectionHeaderArrowPosition)perferedArrowPositionForYUFoldingTableView:(YUFoldingTableView *)yuTableView
{
    // 没有赋值，默认箭头在左
    return self.arrowPosition ? :YUFoldingSectionHeaderArrowPositionLeft;
}
- (NSInteger )numberOfSectionForYUFoldingTableView:(YUFoldingTableView *)yuTableView
{
    NSArray * array = self.arr.firstObject;

    return array.count;
}
- (NSInteger )yuFoldingTableView:(YUFoldingTableView *)yuTableView numberOfRowsInSection:(NSInteger )section
{
    NSArray * arr = self.arr.lastObject[section];
    
    return arr.count;
}
- (CGFloat )yuFoldingTableView:(YUFoldingTableView *)yuTableView heightForHeaderInSection:(NSInteger )section
{
    return 50;
}
- (CGFloat )yuFoldingTableView:(YUFoldingTableView *)yuTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (NSString *)yuFoldingTableView:(YUFoldingTableView *)yuTableView titleForHeaderInSection:(NSInteger)section
{
    return self.arr.firstObject[section];
}
- (UIColor *)yuFoldingTableView:(YUFoldingTableView *)yuTableView backgroundColorForHeaderInSection:(NSInteger )section{
    return [UIColor lightGrayColor];
}
- (UITableViewCell *)yuFoldingTableView:(YUFoldingTableView *)yuTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [yuTableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
       
    }
    //每组的成员model
    NSArray * arr = self.arr.lastObject;
    
    NSArray * arr1 = arr[indexPath.section];
    
    NSLog(@"第%ld组，第%ld行",(long)indexPath.section,(long)indexPath.row);
    personData * model= arr1[indexPath.row];
    NSLog(@"要显示数据数组去的数据～～～～，～～%@",model.organName);

    cell.textLabel.text = model.organName;
    
    return cell;
}
- (void )yuFoldingTableView:(YUFoldingTableView *)yuTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [yuTableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.blockName) {
        //每组的成员model
        NSArray * arr = self.arr.lastObject;
        
        NSArray * arr1 = arr[indexPath.section];
        personData * model= arr1[indexPath.row];
        self.blockName(model);
    }
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
}



@end
