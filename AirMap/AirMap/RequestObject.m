//
//  RequestObject.m
//  AirMap
//
//  Created by Mijeong Jeon on 7/7/16.
//  Copyright © 2016 FCSProjectAirMap. All rights reserved.
//

#import "RequestObject.h"

@interface RequestObject ()

@property (strong, nonatomic) NSString *JWTToken;
@property (strong, nonatomic) NSString *travelTitle;
@property (strong, nonatomic) NSString *idNumber;

@end

@implementation RequestObject

static NSString * const imageUploadURL = @"https://airmap.travel-mk.com/api/travel/create_image/";
static NSString * const metadataUploadURL = @"https://airmap.travel-mk.com/api/travel/create/";
static NSString * const listRequestURL = @"https://airmap.travel-mk.com/api/travel/list/";
static NSString * const detailRequestURL = @"https://airmap.travel-mk.com/api/travel/detail/";

// 이미지 네트워킹 싱글톤 생성
+ (instancetype)sharedInstance {
    
    static RequestObject *object = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object = [[RequestObject alloc] init];
    });
    
    return object;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 현재 로그인 중인 회원의 아이디값 가져오기
        KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"AppLogin" accessGroup:nil];
        NSString *keyChainUser_id = [keychainItem objectForKey: (__bridge id)kSecAttrAccount];
        //현재 로그인 중인 회원의 토큰값 가져오기
        RLMResults *resultArray = [UserInfo objectsWhere:@"user_id == %@", keyChainUser_id];
        UserInfo *userInfo = resultArray[0];
        self.JWTToken = [@"JWT " stringByAppendingString:userInfo.user_token];
        NSLog(@"%@", self.JWTToken);
        // 현재 사용중인 여행경로 이름 가져오기
        TravelActivation *activatedTravel = [TravelActivation defaultInstance];
        self.travelTitle = activatedTravel.travelList.travel_title_unique;
        NSLog(@"%@", self.travelTitle);
    }
    return self;
}

// 이미지 업로드 리퀘스트
- (void)uploadImages:(NSMutableArray *)selectedImages {
    
    NSLog(@"Start Image Upload");
    
    // 업로드 parameter
    NSDictionary *parameters =  @{@"travel_title":self.travelTitle};
    
    // global queue 생성
//    dispatch_queue_t uploadQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // 네트워킹을 위한 AFHTTPSettion Manager 생성, JWTToken 값으로 접근 권한 설정
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:self.JWTToken forHTTPHeaderField:@"Authorization"];
    
    // 선택된 사진 수만큼 사진 전송
    NSInteger count = [[MultiImageDataCenter sharedImageDataCenter] callSelectedImages].count;
    
    for (NSInteger i = 0; i < count; i++) {
        // 이미지 파일
        UIImage *image = [[MultiImageDataCenter sharedImageDataCenter] callSelectedImages][i];
        // 파일 이름을 travel_title_unique_timestamp.jpeg로 저장
        NSString *fileName = [NSString stringWithFormat:@"test_%@_%@.jpeg", self.travelTitle,
                              [[MultiImageDataCenter sharedImageDataCenter] callSelectedData][i][@"timestamp"]];
        
//        dispatch_async(uploadQueue, ^{
            // 큐내에서 POST로 이미지 한장씩 비동기로 전달
            [manager POST:imageUploadURL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.8)
                                            name:@"image_data"
                                        fileName:fileName
                                        mimeType:@"image/jepg"];
                NSLog(@"%@", fileName);

            } progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"Image Uploade Success");
                [self requestDetailMetadatas];
                [[MultiImageDataCenter sharedImageDataCenter] resetSelectedFiles];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"Image Upload Error: %@",error);
                [[MultiImageDataCenter sharedImageDataCenter] resetSelectedFiles];

            }];
//        });
    };
}

// 메타데이터 업로드 리퀘스트
- (void)uploadMetaDatas:(NSMutableArray *)selectedDatas withSelectedImages:(NSMutableArray *)selectedImages {
    
    NSLog(@"Start Metadata Upload");
    //    __block NSInteger i = 0;
    
    NSDictionary *metadataDic = @{@"travel_title":self.travelTitle, @"image_metadatas":selectedDatas};
    
    NSLog(@"%@", metadataDic);
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:self.JWTToken forHTTPHeaderField:@"Authorization"];
    
    [manager POST:metadataUploadURL parameters:metadataDic
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSLog(@"Metadata Post success!");
              [self uploadImages:selectedImages];
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Metadata Post error: %@", error);
              
              //              if (i < 3) {
              //                  [self uploadMetaDatas:selectedDatas withSelectedImages:selectedImages];
              //                  i ++;
              //              }
          }];
    [self requestMetadatas];
}


// 여행경로 리스트 받는 메소드
- (void)requestMetadatas {
    
    NSLog(@"Start get metadatas");
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:self.JWTToken forHTTPHeaderField:@"Authorization"];
    
    [manager GET:listRequestURL parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
#warning     NSLog(@"%@", downloadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"get list success!");
        NSLog(@"%@", responseObject);
        self.idNumber = [[responseObject firstObject] objectForKey:@"id"];
        NSLog(@"%@", self.idNumber);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"get list Error:%@", error);
    }];
    
}

// 세부 메타데이터 받는 메소드
- (void)requestDetailMetadatas {
    
    NSLog(@"Start get detail metadatas");
    NSString *numberString = [NSString stringWithFormat:@"%@/", self.idNumber];
    NSString *urlString = [detailRequestURL stringByAppendingString:numberString];
    NSLog(@"%@",urlString);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:self.JWTToken forHTTPHeaderField:@"Authorization"];
    
    [manager GET:urlString  parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"get detail success!");
        NSLog(@"%@", responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"get detail Error:%@", error);
    }];
}

@end
