//
//  selectPapleViewController.m
//  移动办公
//
//  Created by L灰灰Y on 2017/1/3.
//  Copyright © 2017年 struggle. All rights reserved.
//

#import "selectPapleViewController.h"
#import "CusThirdTableView1.h"
#import "ZYPinYinSearch.h"
#import "ChineseString.h"
#import "KYNetManager.h"
#import "path.h"

#define kScreenWidth        [UIScreen mainScreen].bounds.size.width
#define kScreenHeight       [UIScreen mainScreen].bounds.size.height
#define kColor          [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1];

#define screenWidthW  [[UIScreen mainScreen] bounds].size.width
#define screenHeightH [[UIScreen mainScreen] bounds].size.height

@interface selectPapleViewController ()<CusThirdTableViewDelegate,UITableViewDelegate,UITableViewDataSource,UITabBarDelegate,UISearchBarDelegate>{
    NSString *linkThird;
}
/**
 *  三级视图
 */
@property (nonatomic,strong)CusThirdTableView1 *thirdView;
/**
 *  添加商品分类数据
 */
@property (nonatomic,strong)NSMutableArray *addChoiceModel;

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

@implementation selectPapleViewController

-(CusThirdTableView1 *)thirdView{
    if (_thirdView==nil) {
        _thirdView=[CusThirdTableView1 cusThiedTableView:CGRectMake(0,108,screenWidthW,screenHeightH-108) dataArr:self.addChoiceModel personData:self.arr  ];
        _thirdView.cusDelegate=self;
        _thirdView.hidden = YES;
        [self.view addSubview:_thirdView];
    }
    return _thirdView;
}
-(NSMutableArray *)addChoiceModel{
    if (_addChoiceModel==nil) {
        _addChoiceModel=[NSMutableArray array];
    }
    return _addChoiceModel;
}
//-(BOOL)prefersStatusBarHidden{
//    return YES;
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self getPapleDAtas:^(id result) {
        BOOL status = [[result objectForKey:@"status"] boolValue];
        if (status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.arr = [personData personWithData:result[@"data"]];
                [self addDataWith:self.arr];
                self.thirdView.hidden=!self.thirdView.hidden;
                //搜索部分
                self.navigationItem.title = @"选择要收件的人";
                self.view.backgroundColor = [UIColor whiteColor];
                [self initData];
                [self.view addSubview:self.friendTableView];
                [self.view addSubview:self.searchBar];
                self.friendTableView.alpha = 0;
            });
        }else{
            //获取人员失败
        }

    } failure:^(NSError *error) {
        //请求数据失败
    }];
}
//获取人员数据
-(void)getPapleDAtas:(void(^)( id result))success failure:(void(^)(NSError *error))failure{
    //邮箱人员列表请求
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[KYNetManager sharedNetManager]POST:[[path UstringWithURL:nil]stringByAppendingString:@"/AppHttpService?method=GetStruLsit&struId="] parameters:nil success:^(id result) {
            success(result);
        } failure:^(NSError *error) {
            failure(error);
        }];
    });
}
#pragma mark - Init
- (void)initData {
    NSMutableArray* arr =[NSMutableArray array];
    NSMutableDictionary * dic = [NSMutableDictionary dictionary ];
    NSLog(@"%@",self.arr.lastObject);
    for (NSArray * array in self.papleDatas.lastObject) {
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
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 64, kScreenWidth, 44)];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"搜索";
        _searchBar.showsCancelButton = NO;
    }
    return _searchBar;
}

#pragma mark 加载模型数据
-(void)addDataWith:(NSArray *)personModel{
    NSMutableArray * arrayM = [NSMutableArray array ];
    for (personData * model in personModel) {
        ShowDataModel *num0=[ShowDataModel showDataModel:0 myID:0 grade:0 isOpen:YES showName:model.organName rightShowName:nil personMOdel:model];
        [arrayM addObject:num0];
    }
    [self.addChoiceModel addObjectsFromArray:arrayM];
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
-(void)dealloc{
    NSLog(@"~~释放");
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
    NSArray *ary= [ZYPinYinSearch searchWithOriginalArray:_dataSource andSearchText:searchText andSearchByPropertyName:@"name"];
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
        _thirdView.frame = CGRectMake(0,50,screenWidthW,screenHeightH-58);
    }];
    self.navigationController.navigationBarHidden = NO;
    _searchBar.showsCancelButton = NO;
    [_searchBar resignFirstResponder];
    _searchBar.text = @"";
    _isSearch = NO;
    [_friendTableView reloadData];
}

#pragma mark 代理方法
-(void)cusThirdTableView:(CusThirdTableView1 *)cusTV arrModelData:(NSArray<ShowDataModel *> *)arrModelData{
    //转换model
    personData * persionModel = [personData new];
    for (ShowDataModel *model in arrModelData) {
        persionModel.organId = model.organId;
        persionModel.organName = model.organName;
        persionModel.OrganType = model.OrganType;
    }
    if (self.blockName) {
        self.blockName(persionModel);
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}@end
