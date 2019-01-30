//
//  CYMainView.m
//  caiyunInterpreter
//
//  Created by 阿拉斯加的狗 on 2019/1/15.
//  Copyright © 2019 北京彩彻区明科技有限公司. All rights reserved.
//

#import "CYMainView.h"
#import "CYText_VoiceTranslateViewController.h"
#import "CYDocumentTranslateViewController.h"
#import "CYMainTranslateBtn.h"
#import "CYMainTableView.h"
#import "CYThirdPlarformUserModel.h"
#import "CYUserDataManager.h"
#import "CYLoginViewController.h"
#import "CYOpenScreenAdModel.h"

@interface CYMainView() <UITextFieldDelegate,CYLoginViewControllerDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView            * logoImageView;
@property (nonatomic, strong) UIView                 * serarchView;
@property (nonatomic, strong) UIView                 * translateView;
@property (nonatomic, strong) UIView                 * moreView;
@property (nonatomic, strong) UIImageView            * moreImageView;
@property (nonatomic, strong) UILabel                * moreLabel;
@property (nonatomic, strong) UITextField            * mainTextField;
@property (nonatomic, strong) UIButton               * searchBtn;
@property (nonatomic, strong) UIView                 * lineView;
@property (nonatomic, strong) CYMainTableView        * newsTableview;
@property (nonatomic, strong) CYOpenScreenAdModel    * adModel;
@property (nonatomic, copy  ) NSString               * searchContentString;
@property (nonatomic, strong) UIScrollView           * mainScrollView;
@property (nonatomic, strong) UIView                 * mainSuperView;

@end

@implementation CYMainView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self getNetworkToMainLogoImage];
        [self setupUI];
        [self initLayout];
    }
    return self;
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    if ([self.nextResponder.nextResponder respondsToSelector:@selector(touchesBegan:withEvent:)]) {
//        [self.nextResponder.nextResponder touchesBegan:touches withEvent:event];
//    }
//}
//
//- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    if ([self.nextResponder.nextResponder respondsToSelector:@selector(touchesMoved:withEvent:)]) {
//        [self.nextResponder.nextResponder touchesMoved:touches withEvent:event];
//    }
//}
//
//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    if ([self.nextResponder.nextResponder respondsToSelector:@selector(touchesEnded:withEvent:)]) {
//        [self.nextResponder.nextResponder touchesEnded:touches withEvent:event];
//    }
//}

- (void)getNetworkToMainLogoImage {
    
    CYThirdPlarformUserModel *userForDB = [CYUserDataManager getLastUser];
    
    NSMutableDictionary *parame = [NSMutableDictionary dictionary];
    parame[@"lonlat"] = @"";
    parame[@"deviceId"] = [UUIDTool getUUIDInKeychain];
    if (userForDB) {
        parame[@"userId"] = userForDB.user_id;
    } else {
        parame[@"userId"] = @"";
    }
    parame[@"ostype"] = @"ios";
    parame[@"version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];;
    parame[@"code"] = @"Y003";
    NSString *urlString = @"https://ad.caiyunapp.com/v1/imgad";
    
    [[YYNetworkTool sharedNetworkTool] request:POST urlString:urlString parameters:parame finished:^(id result, NSError *error) {
            
            if ([result[@"status"] isEqualToString:@"ok"]) {
                
                self.adModel = [CYOpenScreenAdModel modelWithDict:result[@"result"]];
                [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:self.adModel.img] placeholderImage:[UIImage imageNamed:@"主页LOGO"]];
            } else {
                
                CYLog(@"%@",error);
            }
        }];
}


- (void)setupUI {
    
    self.mainScrollView = [[UIScrollView alloc] init];
    self.mainScrollView.frame = self.bounds;
    [self addSubview:self.mainScrollView];
    self.mainScrollView.showsVerticalScrollIndicator = NO;
    self.mainScrollView.showsHorizontalScrollIndicator = NO;
    self.mainScrollView.bounces = NO;
    self.mainScrollView.delegate = self;
    self.mainScrollView.contentSize = CGSizeMake(0, self.height * 2);
    if (@available(iOS 11.0, *)) {
        self.mainScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    self.mainSuperView = [[UIView alloc] initWithFrame:self.mainScrollView.bounds];
    [self.mainScrollView addSubview:self.mainSuperView];
    
    self.logoImageView = [[UIImageView alloc] init];
    [self.mainSuperView addSubview:self.logoImageView];
    
    self.serarchView = [[UIView alloc] init];
    [self.mainSuperView addSubview:self.serarchView];
    
    self.translateView = [[UIView alloc] init];
    [self.mainSuperView addSubview:self.translateView];
    
    self.lineView = [[UIView alloc] init];
    [self.mainSuperView addSubview:self.lineView];
    self.lineView.backgroundColor = CYCOLOR(0xF6F6F6);
    
    self.newsTableview = [[CYMainTableView alloc] init];
    self.newsTableview.backgroundColor = [UIColor whiteColor];
    [self.mainSuperView addSubview:self.newsTableview];
    
    self.moreView = [[UIView alloc] init];
    [self.mainSuperView addSubview:self.moreView];
    
    self.moreImageView = [[UIImageView alloc] init];
    [self.moreView addSubview:self.moreImageView];
    self.moreImageView.image = [UIImage imageNamed:@"上滑更多"];
    
    self.moreLabel = [[UILabel alloc] init];
    [self.moreView addSubview:self.moreLabel];
    self.moreLabel.text = @"上滑查看更多";
    self.moreLabel.textColor = CYCOLOR(0x999999);
    self.moreLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    [self setupTransBtn];
    
    self.mainTextField = [[UITextField alloc] init];
    self.mainTextField.returnKeyType = UIReturnKeySearch;
    self.mainTextField.delegate = self;
    [self.serarchView addSubview:self.mainTextField];
    self.mainTextField.backgroundColor = CYCOLOR(0xF0F0F0);
    self.mainTextField.layer.cornerRadius = 18;
    self.mainTextField.placeholder = @"  输入网址、文字";
    self.mainTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(10, 1, 20, 26)];
    self.mainTextField.leftViewMode = UITextFieldViewModeAlways;
    self.mainTextField.tintColor = [UIColor blackColor];
    
    self.searchBtn = [[UIButton alloc] init];
    [self.serarchView addSubview:self.searchBtn];
    [self.searchBtn addTarget:self action:@selector(searchContentAction) forControlEvents:UIControlEventTouchUpInside];
    [self.searchBtn setImage:[UIImage imageNamed:@"首页搜索"] forState:UIControlStateNormal];
    
}


- (void)setupTransBtn {
    
    NSMutableArray *arrayMut = [NSMutableArray array];
    
    NSArray *titleArray = @[@"文字翻译",@"语音翻译",@"文档翻译"];
    NSArray *imageArray = @[@"文字翻译",@"语音同传",@"文档翻译"];
    for (int i = 0; i < 3; i++) {
        
        CYMainTranslateBtn *btn = [[CYMainTranslateBtn alloc] init];
        btn.adjustsImageWhenHighlighted = NO;
        btn.margin = 9;
        btn.tag = 1000+i;
        [btn setTitle:titleArray[i] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:imageArray[i]] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(translateButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.translateView addSubview:btn];
        [arrayMut addObject:btn];
    }
    
    if (arrayMut.count <= 0) {
        return;
    }
    
    [arrayMut mas_distributeViewsAlongAxis:MASAxisTypeHorizontal
                          withFixedSpacing:57   //item间距
                               leadSpacing:45   //起始间距
                               tailSpacing:45]; //结尾间距
    [arrayMut mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.bottom.equalTo(@0);
    }];
}

- (void)translateButtonClick: (UIButton *)translateBtn {
    switch (translateBtn.tag) {
        case 1000:
        {
            CYText_VoiceTranslateViewController *textTranslateVC = [[CYText_VoiceTranslateViewController alloc] init];
            textTranslateVC.currentType = CYCurrentTypeText;
            textTranslateVC.translateType = CYTranslateTypeText;
            CYNavigationController *Nav = (CYNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
            [Nav pushViewController:textTranslateVC animated:YES];
        }
            break;
        case 1001:
        {
            CYText_VoiceTranslateViewController *voiceTranslateVC = [[CYText_VoiceTranslateViewController alloc] init];
            voiceTranslateVC.currentType = CYCurrentTypeSpeech;
            voiceTranslateVC.translateType = CYTranslateTypeSpeech;
            CYNavigationController *Nav = (CYNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
            [Nav pushViewController:voiceTranslateVC animated:YES];
        }
            
            break;
        case 1002:
        {
            
            CYThirdPlarformUserModel *model = [CYUserDataManager getLastUser];
            if (model) {
                CYDocumentTranslateViewController *documentTransVC = [[CYDocumentTranslateViewController alloc] init];
                CYNavigationController *Nav = (CYNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                [Nav pushViewController:documentTransVC animated:YES];
            } else {
                [SMAlert setTouchToHide:YES];
                [SMAlert setAlertBackgroundColor:[UIColor colorWithWhite:0 alpha:0.75]];
                [SMAlert setConfirmBtBackgroundColor:CYColor(0, 185, 119)];
                [SMAlert setConfirmBtTitleColor:[UIColor whiteColor]];
                [SMAlert setCancleBtBackgroundColor:[UIColor whiteColor]];
                [SMAlert setCancleBtTitleColor:CYColor(0, 185, 119)];
                [SMAlert setContentTextAlignment:NSTextAlignmentCenter];
                [SMAlert setContentFont:[UIFont fontWithName:@"PingFangSC-Regular" size:15]];
                
                NSString *title = NSLocalizedString(@"file_alert_waring", nil);
                
                [SMAlert showContent:title confirmButton:[SMButton initWithTitle:NSLocalizedString(@"loginBtn", nil) clickAction:^{
                    //取出根视图控制器
                    CYNavigationController *Nav = (CYNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                    
                    CYLoginViewController *loginVC = [[CYLoginViewController alloc] init];
                    loginVC.delegate = self;
                    
                    if (Nav) {
                        [Nav presentViewController:loginVC animated:YES completion:nil];
                        [SMAlert hide];
                    }
                    
                }] cancleButton:[SMButton initWithTitle:NSLocalizedString(@"Keep_it", nil) clickAction:^{
                    [SMAlert hide];
                }]];
            }
        }
            break;
        default:
            break;
    }
}

- (void)initLayout {
    
//    [self.mainSuperView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_offset(0);
//        make.left.mas_offset(0);
//        make.width.mas_equalTo(self.mainScrollView.mas_width);
//        make.height.mas_equalTo(self.mainScrollView.mas_height);
//    }];
    
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(CYSafeAreaTopHeight + 30);
        make.centerX.mas_equalTo(self.mainScrollView.mas_centerX);
        make.width.mas_equalTo(180 * CYSCREENWIDTHSCALE);
        make.height.mas_equalTo(80 * CYSCREENWIDTHSCALE);
    }];
    
    [self.serarchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.logoImageView.mas_bottom).mas_offset(31);
        make.left.mas_offset(37.5);
        make.right.mas_offset(-37.5);
        make.height.mas_equalTo(37);
    }];

    [self.translateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.serarchView.mas_bottom).mas_offset(30);
        make.left.mas_offset(0);
        make.right.mas_offset(0);
        make.height.mas_equalTo(96);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.translateView.mas_bottom).mas_offset(20);
        make.left.offset(0);
        make.right.mas_offset(0);
        make.height.mas_equalTo(5);
    }];
    
    [self.moreView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.mas_equalTo(self.width);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.height.mas_equalTo(42);
        make.bottom.mas_offset(- CYSafeAreaBottomHeight - 6);
    }];
    
    [self.moreImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(0);
        make.centerX.mas_equalTo(self.moreView.mas_centerX);
        make.width.mas_equalTo(15);
        make.height.mas_equalTo(17);
    }];
    
    [self.moreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_offset(0);
        make.centerX.mas_equalTo(self.moreView.mas_centerX);
        make.top.mas_equalTo(self.moreImageView.mas_bottom).mas_offset(8.5);
        make.height.mas_equalTo(16.5);
    }];
    
    [self.newsTableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.lineView.mas_bottom).mas_offset(0);
        make.left.mas_offset(0);
        make.right.mas_offset(0);
        make.bottom.mas_equalTo(self.moreView.mas_top).mas_offset(-40);
    }];
    
    [self.mainTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(0);
        make.bottom.mas_offset(0);
        make.left.mas_offset(0);
        make.right.mas_offset(0);
    }];
    
    [self.searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self.serarchView.mas_centerY);
        make.right.mas_offset(-8.25);
    }];
}

#pragma mark -<UITextFieldDelegate>
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    self.searchContentString = string;
    return YES;
}

/// 所搜内容查询
- (void)searchContentAction {
    
    if ([self.delegate respondsToSelector:@selector(mainViewWithSearchMoreAction:content:)]) {
        [self.delegate mainViewWithSearchMoreAction:self content:self.searchContentString];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *searchStr = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([searchStr length] == 0) {
        [SMProgressHUD showBlackTextWithMessage:@"请输入内容"];
    } else {
        if ([self.delegate respondsToSelector:@selector(mainViewWithSearchMoreAction:content:)]) {
            [self.delegate mainViewWithSearchMoreAction:self content:searchStr];
        }
    }
    return YES;
}

#pragma mark - <CYLoginViewControllerDelegate>

- (void)loginViewControllerDidLoginWithUser:(CYUser *)user {
    CYNavigationController *Nav = (CYNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    [Nav dismissViewControllerAnimated:YES completion:nil];
    
    CYDocumentTranslateViewController *documentTransVC = [[CYDocumentTranslateViewController alloc] init];
    [Nav pushViewController:documentTransVC animated:YES];
}


#pragma mark - <UIScrollViewDelegate>

BOOL isNeedHandle;

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    isNeedHandle = YES;
    NSLog(@"scrollViewWillBeginDragging");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.mainSuperView.y = scrollView.contentOffset.y;

    if (isNeedHandle && [self.delegate respondsToSelector:@selector(mainView_scrollViewDidScroll:)]) {
        [self.delegate mainView_scrollViewDidScroll:scrollView.contentOffset.y];
    }
    NSLog(@"scrollViewDidScroll");
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSLog(@"scrollViewWillEndDragging %f", targetContentOffset->y);
//    if ([self.delegate respondsToSelector:@selector(mainView_scrollViewDidEndScroll:)]) {
//        [self.delegate mainView_scrollViewDidEndScroll:targetContentOffset->y];
//    }
    isNeedHandle = NO;
    [self scrollViewReallyEnd:scrollView contentOffsetY:targetContentOffset->y];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    NSLog(@"scrollViewWillBeginDecelerating");
    // 让 scrollView 停止滚动
    [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + 1) animated:NO];
//    if ([self.delegate respondsToSelector:@selector(mainView_scrollViewDidEndScroll:)]) {
//        [self.delegate mainView_scrollViewDidEndScroll:scrollView.contentOffset.y];
//    }
//    [self scrollViewReallyEnd:scrollView contentOffsetY:0];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidEndDecelerating");
//    [self scrollViewReallyEnd:scrollView];
    id tempDelegate = self.delegate;
    self.delegate = nil;
    [scrollView setContentOffset:CGPointZero animated:NO];
    self.delegate = tempDelegate;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSLog(@"scrollViewDidEndDragging");
    if (decelerate) {
//        [self scrollViewDidEndDecelerating:scrollView];
    } else {
        id tempDelegate = self.delegate;
        self.delegate = nil;
        [scrollView setContentOffset:CGPointZero animated:NO];
        self.delegate = tempDelegate;
    }
}

- (void)scrollViewReallyEnd:(UIScrollView *)scrollView contentOffsetY:(CGFloat)contentOffsetY {
    NSLog(@"scrollViewReallyEnd");
    if ([self.delegate respondsToSelector:@selector(mainView_scrollViewDidEndScroll:)]) {
        if (contentOffsetY != 0) {
            [self.delegate mainView_scrollViewDidEndScroll:contentOffsetY];
        } else {
            [self.delegate mainView_scrollViewDidEndScroll:scrollView.contentOffset.y];
        }
    }
    id tempDelegate = self.delegate;
    self.delegate = nil;
    [scrollView setContentOffset:CGPointZero animated:NO];
    self.delegate = tempDelegate;
}

@end
