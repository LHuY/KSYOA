//
//  CusThirdTableView.m
//  ThirdView
//
//  Created by 冷求慧 on 16/9/12.
//  Copyright © 2016年 leng. All rights reserved.
//

#import "CusThirdTableView1.h"
#import "ShowDataModel.h"
#import "path.h"
#import "KYNetManager.h"
#import "personData.h"

@interface CusThirdTableView1 ()<UITableViewDataSource,UITableViewDelegate>{
    ShowDataModel *selectSuperModel;
    
}
/**
 *  所有的数据模型数组
 */
@property (nonatomic,strong)NSMutableArray *allArrData;
/**
 *  显示的模型数据数组
 */
@property (nonatomic,strong)NSMutableArray *showArrData;
/**
 *  用来添加选中的模型数据数组
 */
@property (nonatomic,strong)NSMutableArray *arrAddSelectModel;

//二级或者三级数据模型   personData
@property (nonatomic, strong) NSMutableArray *personData1;
//一级父类数据模型  personData
@property (nonatomic, strong) NSMutableArray *superData1;
//添加已经选择cell获取数据模型
@property (nonatomic,strong)NSMutableArray *inserModelArr;
//记录点击的上一个cell位置
@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) UITableView* tableView;

//记录是否是第一次点击
@property (nonatomic, assign) BOOL isOneClik;

//记录是否是第一次点击 二级
@property (nonatomic, assign) BOOL isOneClik2;

//记录点击的上一个cell位置 二级
@property (nonatomic, assign) NSInteger index2;

//添加已经选择cell获取数据模型  二级
@property (nonatomic,strong)NSMutableArray *inserModelArr2;

@end
@implementation CusThirdTableView1

static NSString *cellID=@"cellID";


-(NSMutableArray *)inserModelArr{
    if (_inserModelArr==nil) {
        _inserModelArr=[NSMutableArray array];
    }
    return _inserModelArr;
}
-(NSMutableArray *)personData1{
    if (_personData1==nil) {
        _personData1=[NSMutableArray array];
    }
    return _personData1;
}
-(NSMutableArray *)superData1{
    if (_superData1==nil) {
        _superData1=[NSMutableArray array];
    }
    return _superData1;
}
-(NSMutableArray *)allArrData{
    if (_allArrData==nil) {
        _allArrData=[NSMutableArray array];
    }
    return _allArrData;
}
-(NSMutableArray *)showArrData{
    if (_showArrData==nil) {
        _showArrData=[NSMutableArray array];
    }
    return _showArrData;
}
-(NSMutableArray *)arrAddSelectModel{
    if (_arrAddSelectModel==nil) {
        _arrAddSelectModel=[NSMutableArray array];
    }
    return _arrAddSelectModel;
}
-(instancetype)initWithFrame:(CGRect)frame dataArr:(NSArray *)arr personData:(NSMutableArray *)personData{
    if (self=[super initWithFrame:frame style:UITableViewStylePlain]) {
        self.superData1 = personData;
        [self dealData:arr]; // 处理数据
        [self someUISet];   // 一些设置
    }
    return self;
}

+(instancetype)cusThiedTableView:(CGRect)frame dataArr:(NSArray *)arr personData:(NSMutableArray *)personData{
    return [[self alloc]initWithFrame:frame dataArr:arr personData:personData];
}

#pragma mark 处理数据
-(void)dealData:(NSArray *)arr{
    
    [self.allArrData addObjectsFromArray:arr];
    
    for (ShowDataModel *model in self.allArrData) {
        if (model.isOpen) {
            [self.showArrData addObject:model]; // 第一次初始化 添加展开的数据模型
        }
    }
}
#pragma mark 一些UI设置
-(void)someUISet{
    self.index = 10000;
    self.index2 = 10000;
    self.isOneClik2 = NO;
    self.delegate=self;
    self.dataSource=self;
    self.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    self.tableHeaderView=[[UIView alloc]initWithFrame:CGRectZero];
    self.showsHorizontalScrollIndicator=self.showsVerticalScrollIndicator=NO;
}
#pragma mark -TableView的数据源
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.showArrData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *strCellID=@"cellID";
    UITableViewCell *cellWithSystem=[tableView dequeueReusableCellWithIdentifier:strCellID];
    if (cellWithSystem==nil) {
        cellWithSystem=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:strCellID];
    }
    cellWithSystem.selectionStyle=UITableViewCellSelectionStyleNone;
    
    ShowDataModel *modelWithIndex=self.showArrData[indexPath.row];
    cellWithSystem.textLabel.text=modelWithIndex.showName;
    cellWithSystem.detailTextLabel.text=modelWithIndex.rightShowName;
    cellWithSystem.detailTextLabel.font=[UIFont systemFontOfSize:12.0];
    
    cellWithSystem.indentationWidth=30;   // 缩放宽度
    cellWithSystem.indentationLevel=modelWithIndex.grade;  // 缩放等级
    
    [self setCellIsSelectAndNor:cellWithSystem modelData:modelWithIndex tableView:tableView];  // 设置cell是打钩还是箭头
    
    return cellWithSystem;

}
#pragma mark -TableView的代理
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
#pragma mark 点击了Cell的处理
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ShowDataModel * superData = self.showArrData[indexPath.row];
    //先判断一级是否一级打开，如果打开，不需要再加载数据
    // 选中的父模型
//    ShowDataModel * superData = self.allArrData[indexPath.row];
    //判断是否是组织
    if (![superData.OrganType isEqualToString:@"8"]) {
        //表示组织，单位
    if (superData.isOpen) {
        //表示还没打开二级cell
        superData.isOpen = NO;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            [[KYNetManager sharedNetManager]POST:[[path UstringWithURL:nil]stringByAppendingString:[NSString stringWithFormat:@"/AppHttpService?method=GetStruLsit&struId=%@",superData.StruId]] parameters:nil success:^(id result) {
//                NSLog(@"%@",result);
                BOOL status = [[result objectForKey:@"status"] boolValue];
                if (status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.personData1 = [personData personWithData:result[@"data"]];
                        //判断列表中是否包含已经请求的数据，如果包含，则终止操作
                        personData * model = self.personData1.firstObject;
                        for (ShowDataModel * showModel in self.showArrData) {
                            if ([showModel.organId isEqualToString:model.organId]) {
                                NSLog(@"相同，终止操作");
                                return ;
                                
                            }
                        }
//                        NSLog(@"加载数量%lu",(unsigned long)self.personData1.count);
                        self.inserModelArr = nil;
                        //记录点击的一级
                        self.index = indexPath.row;
                        
                        
                        for (personData * model in self.personData1) {
                            
                            [self.inserModelArr addObject:[ShowDataModel showDataModel:superData.myID myID:5 grade:superData.grade+1 isOpen:NO showName:model.organName rightShowName:nil personMOdel:model]];
                        }
                        [self dealWithClickData:superData index:indexPath.row tableView:self.tableView];// 删除和添加对应的数据,返回最终的下标
                    });
                }else{
                    //加载错误；
                }
            } failure:^(NSError *error) {
            }];
        });
    }else{
//        收回二级cell
        //删除对应的数据
        [self dealWithClickData:superData index:indexPath.row tableView:self.tableView];
    }
    }else{
        self.arrAddSelectModel = nil;
        //说明点击的是人员,需要传值到邮件去
        [self.arrAddSelectModel addObject:self.showArrData[indexPath.row]];
        if ([self.cusDelegate respondsToSelector:@selector(cusThirdTableView:arrModelData:)])
        { //同时代理传值
            [self.cusDelegate cusThirdTableView:self arrModelData:self.arrAddSelectModel];
        }
    }
}
#pragma mark  处理点击后的操作,返回结束的下标
-(NSInteger)dealWithClickData:(ShowDataModel *)modelData index:(NSInteger)index tableView:(UITableView *)tableView{
        BOOL isSelectAndHideView=modelData.grade==1; //选中第三级,
    
//        if (isSelectAndHideView) {
//            modelData.rightShowName=@"打钩";     //   测试用这个
////            modelData.rightShowName=@"";        //   正式用这个
//            [self.arrAddSelectModel addObject:modelData];
//            self.hidden=YES;
//            [self reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone]; //刷新对于的选中的Cell
//            if ([self.cusDelegate respondsToSelector:@selector(cusThirdTableView:arrModelData:)]) { //同时代理传值
//                [self.cusDelegate cusThirdTableView:self arrModelData:self.arrAddSelectModel];
//            }
//        }
    NSInteger nextIndex=index+1;   // 下一个下标
    NSInteger endIndex=nextIndex; // 结束的下标
    
    ShowDataModel *selectModel=modelData;                  //选中的模型数据
    BOOL isOpenSection=NO;
    for (NSInteger i=0;i<self.inserModelArr.count;i++) {
        ShowDataModel *nextModel=self.inserModelArr[i];
        //        if(selectModel.myID==nextModel.superID){ // 选择的cell的ID=所有数据中模型的父节点
        
        if (!nextModel.isOpen) {
            
            nextModel.isOpen=!nextModel.isOpen;
            [self.allArrData insertObject:nextModel atIndex:endIndex];
            [self.showArrData insertObject:nextModel atIndex:endIndex];
            // 添加到数组中
            endIndex++;
            isOpenSection=YES;
        }
        else{
            modelData.isOpen = YES;
            endIndex=[self deleteDataInShaowDataArr:selectModel]; // 删除对应的数据(只需要删除一次)
            isOpenSection=NO;
            break;
        }
        //        }
    }
    NSMutableArray *indexPathArray = [NSMutableArray array];
    for (NSUInteger i=nextIndex; i<endIndex; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0]; //获得需要修正的indexPath
        [indexPathArray addObject:indexPath];
    }
    
    if (isOpenSection) {
        [self insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone]; //插入或者删除相关节点
    }else{
        [self deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
    }
    //    NSLog(@"开始位置：%zi 和 结束位置:%zi",nextIndex,endIndex);
    return endIndex;
}
/**
 *  设置Cell是打钩还是箭头
 *
 *  @param indexNum  下标
 *  @param modelData 模型数据
 *  @param tableView TableView对象
 */
-(void)setCellIsSelectAndNor:(UITableViewCell *)changeCell modelData:(ShowDataModel *)modelData tableView:(UITableView *)tableView{
    
    //    NSLog(@"数据:%@ 右边数据:%@",modelData.showName,modelData.rightShowName);
    
    if(modelData.rightShowName){
        changeCell.accessoryType=UITableViewCellAccessoryNone; // 没有箭头
        changeCell.accessoryView=nil;
        changeCell.accessoryType=UITableViewCellAccessoryNone;
        UIImageView *choiceImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0,15,12)];
        choiceImage.image=[UIImage imageNamed:@"sureChoice"];
        changeCell.accessoryView=choiceImage;
    }
    else{
        if (modelData.grade==2) {
            changeCell.accessoryView=nil;
            changeCell.accessoryType=UITableViewCellAccessoryNone; // 没有箭头
        }
        else{
            changeCell.accessoryView=nil;
            changeCell.accessoryType=UITableViewCellAccessoryDisclosureIndicator; // 有箭头
        }
    }
}

//
///**
// *  删除该父节点下的所有子节点（包括孙子节点）
// *
// *  @param selectModel 选中的模型
// *
// *  @return 该父节点下一个相邻的统一级别的节点的位置
// */
//
-(NSUInteger)deleteDataInShaowDataArr:(ShowDataModel *)selectModel{
    
    NSInteger startIndex=[self.showArrData indexOfObject:selectModel]+1;
    NSInteger endIndex=startIndex;
    for (NSInteger i=startIndex; i<self.showArrData.count; i++) {
        ShowDataModel *model=self.showArrData[i];
        if (model.grade>selectModel.grade) { // 通过判断 缩放级别来 要删除的数组下标(删除的缩放级别一定大于选中的缩放级别)
            endIndex++;
        }
        else break;
    }
    NSRange deleteWithRang={startIndex,endIndex-(startIndex)};
    [self.showArrData removeObjectsInRange:deleteWithRang];
    [self.allArrData removeObjectsInRange:deleteWithRang];
    // 通过区间删除数据中的元素
    
    return endIndex;
}


@end
