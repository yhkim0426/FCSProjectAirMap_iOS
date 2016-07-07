//
//  MultiImageCollectionViewController.m
//  PhotoCollectionTest
//
//  Created by Mijeong Jeon on 7/4/16.
//  Copyright © 2016 Mijeong Jeon. All rights reserved.
//

#import "MultiImageCollectionViewController.h"

@interface MultiImageCollectionViewController ()
<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionView *imageCollectionView;
@property (strong, nonatomic) MultiImageDataCenter *imageDataCenter;

@end

@implementation MultiImageCollectionViewController

static NSString * const reuseIdentifier = @"ImageCell";
const CGFloat spacing = 2;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self creatCollectionView];
    [self navigationControllerSetUp];
    
    self.imageDataCenter = [MultiImageDataCenter sharedImageDataCenter];
}



#pragma mark - <UICollectionView>
- (void)creatCollectionView {
    
    // collectionViewFlowLayout 생성
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    // collectionView 생성_뷰 전체 사이즈 설정 및 viewLayout 설정
    self.imageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:flowLayout];
    
    [self.imageCollectionView setBackgroundColor:[UIColor whiteColor]];

    // collectionView delegate, dataSoucre 설정
    self.imageCollectionView.delegate = self;
    self.imageCollectionView.dataSource = self;
    
    [self.imageCollectionView setAllowsSelection:YES];
    [self.imageCollectionView setAllowsMultipleSelection:YES];
    
    // 메인 뷰에 collectionView 올리기
    [self.view addSubview:self.imageCollectionView];
    
    // 셀 클래스 등록(MultiImageCollectionViewCell)
    [self.imageCollectionView registerClass:[MultiImageCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
}

#pragma mark - <UICollectionViewDataSource>
// 셀 개수 설정
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.imageDataCenter callFetchResult].count;
}
// 셀 내용 설정
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // custom cell 생성
    
    MultiImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[MultiImageCollectionViewCell alloc] init];
    }
    
    // 이미지 asset 생성
    PHAsset *imageAsset = [self.imageDataCenter callFetchResult][indexPath.row];
    
    // 이미지 매니저를 통한 이미지 가져오기(
    cell.tag = indexPath.row;
    [[PHCachingImageManager defaultManager] requestImageForAsset:imageAsset
                                               targetSize:CGSizeMake(150,150)
                                              contentMode:PHImageContentModeAspectFill
                                                  options:nil
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                               
                                                if (cell.tag == indexPath.row) {
                                                cell.imageViewInCell.image = result;
                                                }
    }];
    
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"seleted");
    PHAsset *selectedAsset = [self.imageDataCenter callFetchResult][indexPath.row];
    [self.imageDataCenter addSelectedAsset:selectedAsset];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"deseleted");
//    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
//    [cell setSelected:NO];
    PHAsset *deSelectedAsset = [self.imageDataCenter callFetchResult][indexPath.row];
    [self.imageDataCenter removeSelectedAsset:deSelectedAsset];
}


#pragma mark - <UICollectionViewDelegateFlowLayout>
// 셀 크기 조절
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat lengthForItem = (self.view.frame.size.width - spacing * 2) / 3;
    
    return CGSizeMake(lengthForItem, lengthForItem);
}

// 가로 줄 간격 조절
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return spacing;
}

// 세로 줄 간격 조절
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return spacing;
}


#pragma mark - <UINavigationController>
// 네비게이션 컨트롤러 바 설정
- (void)navigationControllerSetUp {
    // 컨트롤러 바 제목 설정
    self.navigationItem.title = @"Camera Roll";
    // 컨트롤러 버튼 설정
    
    BadgeView *badgeView = [[BadgeView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    
//    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithArray:[CustomBarItemView.array]];
    
    // done button 연습(나중에 지울것)
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(doneAction:)];
    

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"나가기" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];
    
    UIBarButtonItem *badgeButton = [[UIBarButtonItem alloc] initWithCustomView:badgeView.createBadgeView];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"선택" style:UIBarButtonItemStylePlain target:self action:@selector(doneAction:)];
    
    
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:doneButton, badgeButton, nil];
}



// 네비게이션 버튼 액션
-(void)doneAction:(UIButton *)sender {
    [self.imageDataCenter extractMetadataFromImage];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)cancelAction:(UIButton *)sender {
//    [self.imageDataCenter resetSelectedAsset];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{

    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
