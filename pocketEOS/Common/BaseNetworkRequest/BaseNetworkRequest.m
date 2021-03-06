//
//  BaseNetworkRequest.m
//  pocketEOS
//
//  Created by oraclechain on 2017/11/29.
//  Copyright © 2017年 oraclechain. All rights reserved.
//

#define REQUEST_APIPATH [NSString stringWithFormat: @"%@", [self requestUrlPath]]

#import "BaseNetworkRequest.h"

@interface BaseNetworkRequest()

@property(nonatomic, strong) AFHTTPSessionManager *networkingManager;


@end


@implementation BaseNetworkRequest

- (AFHTTPSessionManager *)networkingManager{
    if (!_networkingManager) {
        _networkingManager = [AFHTTPSessionManager manager];
    }
    return _networkingManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.showActivityIndicator = YES;
    }
    return self;
}

+ (NSString *)requestBaseUrl{
    return @"";
}

- (NSString *)requestUrlPath{
    return @"";
}




- (id)parameters{
    return @{};
}

- (BOOL)validateRequestParameters{
    return YES;
}

- (BOOL)validateResponseData:(id)returnData HttpURLResponse:(NSURLResponse *)response{
    // 获取 http 状态码
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSLog(@"HttpCode: %ld", (long)httpResponse.statusCode );
    if (httpResponse.statusCode > 300) {
        return NO;
    }
    return YES;
}

// 配置请求
- (BOOL)buildRequestConfigInfo{
    if (![self validateRequestParameters]) {
        [SVProgressHUD dismiss];
        return NO;
    }
    
    if (self.showActivityIndicator) {
        [SVProgressHUD show];
    }
    
    [self configTimeOut:self.networkingManager];
    self.networkingManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json", @"text/javascript", @"text/plain", nil];
    
    return YES;
}


- (void)AFJSONRequestSerializerpostDataSuccess:(RequestSuccessBlock)success failure:(RequestFailedBlock)failure{
    if (![self buildRequestConfigInfo]) {
        return;
    }
    
    id parameters = [self parameters];
    NSLog(@"parameters = %@" , parameters);
    NSLog(@"REQUEST_APIPATH = %@",  REQUEST_APIPATH);
    WS(weakSelf);
    
    self.sessionDataTask = [self.networkingManager POST: REQUEST_APIPATH parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([self validateResponseData:responseObject HttpURLResponse:task.response]) {
            if (IsNilOrNull(success)) {
                return ;
            }
            success(weakSelf.networkingManager , responseObject);
        }else{
            failure(weakSelf.networkingManager , nil);
        }
        
        [SVProgressHUD dismiss];
    
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        if (IsNilOrNull(failure)) {
            return ;
        }
        
        if(error.code == -1001){
            [TOASTVIEW showWithText:@"请求超时, 请稍后再试!"];
        }
        failure(task , error);
        
    }];
    
}


- (void)getDataSusscess:(RequestSuccessBlock)success failure:(RequestFailedBlock)failure{
    if (![self buildRequestConfigInfo]) {
        return;
    }
    
    WS(weakSelf);
    id parameters = [self parameters];
    NSLog(@"REQUEST_APIPATH = %@", REQUEST_APIPATH);
    NSLog(@"parameters = %@", parameters);
    self.sessionDataTask = [self.networkingManager GET:REQUEST_APIPATH parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([self validateResponseData:responseObject HttpURLResponse:task.response]) {
            if (IsNilOrNull(success)) {
                return ;
            }
            success(weakSelf.networkingManager, responseObject);
        }
        
        if(self.showActivityIndicator){
            [SVProgressHUD dismiss];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        if (IsNilOrNull(failure)) {
            return ;
        }
        if(error.code == -1001){
            [TOASTVIEW showWithText:@"请求超时, 请稍后再试!"];
        }
        failure(weakSelf.networkingManager, error);
        
    }];
    
}

#pragma mark The Post method request data
- (void)postDataSuccess:(RequestSuccessBlock)success failure:(RequestFailedBlock)failure{
    //The basic configuration information build request
    if(![self buildRequestConfigInfo]){
        return;
    }
    
    //Start a Post request data interface
    id parameters = [self parameters];
    NSLog(@"parameters = %@", parameters);
    NSLog(@"REQUEST_APIPATH = %@", REQUEST_APIPATH);
    WS(weakSelf);
    self.sessionDataTask = [self.networkingManager POST: REQUEST_APIPATH parameters: parameters progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([self validateResponseData: responseObject HttpURLResponse: task.response]) {
            if(IsNilOrNull(success)){
                return;
            }
            success(weakSelf.networkingManager, responseObject);
        }
        else{
            failure(weakSelf.networkingManager, nil);
        }
        
        //dismiss loading view
        [SVProgressHUD dismiss];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //dismiss loading view
        [SVProgressHUD dismiss];
        //failure block
        if(IsNilOrNull(failure)){
            return;
        }
        failure(task, error);
    }];
}

- (void)putDataSuccess:(RequestSuccessBlock)success failure:(RequestFailedBlock)failure{
    if (![self buildRequestConfigInfo]) {
        return;
    }
    
    id parameters = [self parameters];
    NSLog(@"REQUEST_APIPATH = %@", REQUEST_APIPATH);
    NSLog(@"parameters = %@", parameters);
    WS(weakSelf);
    
    self.sessionDataTask = [self.networkingManager PUT:REQUEST_APIPATH parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([self validateResponseData:responseObject HttpURLResponse:task.response]) {
            if (IsNilOrNull(success)) {
                return ;
            }
            success(weakSelf.networkingManager , responseObject);
        }
        
        if (self.showActivityIndicator) {
            [SVProgressHUD dismiss];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        if (IsNilOrNull(failure)) {
            return ;
        }
        if(error.code == -1001){
            [TOASTVIEW showWithText:@"请求超时, 请稍后再试!"];
        }
        failure(weakSelf.networkingManager , error);
    }];
    
}

- (void)deleteDataSuccess:(RequestSuccessBlock)success failure:(RequestFailedBlock)failure{
    
    if (![self buildRequestConfigInfo]) {
        return;
    }
    
    id parameters = [self parameters];
    NSLog(@"REQUEST_APIPATH = %@", REQUEST_APIPATH);
    WS(weakSelf);
    [self.networkingManager.requestSerializer setHTTPMethodsEncodingParametersInURI:[NSSet setWithObjects:@"GET", @"HEAD", nil]];
    self.sessionDataTask = [self.networkingManager DELETE:REQUEST_APIPATH parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (IsNilOrNull(success)) {
            return ;
        }
        success(weakSelf.networkingManager , responseObject);
        
        if (self.showActivityIndicator) {
            [SVProgressHUD dismiss];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        if (IsNilOrNull(failure)) {
            return ;
        }
        if(error.code == -1001){
            [TOASTVIEW showWithText:@"请求超时, 请稍后再试!"];
        }
        failure(weakSelf.networkingManager , error);
    }];
}

- (void)uploadData:(NSData *)imageData externName:(NSString *)externName success:(RequestSuccessBlock)success failure:(RequestFailedBlock)failure{
    if (![self buildRequestConfigInfo]) {
        return;
    }
    [SVProgressHUD showWithStatus:@"正在上传"];
    AFHTTPSessionManager *networkingManager = [[AFHTTPSessionManager alloc] init];
    
    [networkingManager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", nil]];
    
    networkingManager.requestSerializer = [AFJSONRequestSerializer serializer];
    networkingManager.responseSerializer = [AFJSONResponseSerializer serializer];
    [networkingManager.requestSerializer setValue:@"Multipart/form-data" forHTTPHeaderField:@"Content-type"];
    
    /**
     *  Start a Post request data interface
     */
    id parameters = [self parameters];
    NSLog(@"parameters = %@", parameters);
    NSLog(@"REQUEST_APIPATH = %@", [self requestUrlPath]);
    WS(weakSelf);
    
    [networkingManager POST:[self requestUrlPath] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:imageData name:@"file" fileName: [@"file" randomFileName :externName] mimeType:@"image/jpeg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SVProgressHUD dismiss];
        if ([weakSelf validateResponseData:responseObject HttpURLResponse:task.response]) {
            if (IsNilOrNull(success)) {
                return ;
            }
            success(networkingManager , responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        
        if (IsNilOrNull(failure)) {
            return ;
        }
        if(error.code == -1001){
            [TOASTVIEW showWithText:@"请求超时, 请稍后再试!"];
        }
        failure(networkingManager, error);
    }];
}

- (void)getOuterDataSuccess:(RequestSuccessBlock)success failure:(RequestFailedBlock)failure{
    if (![self buildRequestConfigInfo]) {
        return;
    }
    WS(weakSelf);
    id parameters = [self parameters];
    NSLog(@"REQUEST_APIPATH = %@", [self requestUrlPath]);
    NSLog(@"parameters = %@", parameters);
    
    AFHTTPSessionManager *outerNetworkingManager = [[AFHTTPSessionManager alloc] init];
    [outerNetworkingManager GET:[self requestUrlPath] parameters:[self parameters] progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (IsNilOrNull(success)) {
            return ;
        }
        [SVProgressHUD dismiss];
        success(weakSelf.networkingManager , responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        if (IsNilOrNull(failure)) {
            return ;
        }
        if(error.code == -1001){
            [TOASTVIEW showWithText:@"请求超时, 请稍后再试!"];
        }
        failure(weakSelf.networkingManager , error);
    }];
}


/**
  request Json 序列化 的 post 请求
 */
- (void)postOuterDataSuccess:(RequestSuccessBlock)success failure:(RequestFailedBlock)failure{
    if (![self buildRequestConfigInfo]) {
        return;
    }
    if (self.showActivityIndicator) {
        [SVProgressHUD show];
    }
    WS(weakSelf);
    id parameters = [self parameters];
    NSLog(@"REQUEST_APIPATH = %@", [self requestUrlPath]);
    NSLog(@"parameters = %@", parameters);
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    [self configTimeOut:manager];
    // request Json 序列化
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    [manager POST:[self requestUrlPath] parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([self validateResponseData:responseObject HttpURLResponse:task.response]) {
            if (IsNilOrNull(success)) {
                return ;
            }
            if ([responseObject isKindOfClass:[NSData class]]) {
                
            }
            
            success(weakSelf.networkingManager, responseObject);
        }
        [SVProgressHUD dismiss];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
         NSLog(@"error ==%@", [error userInfo][@"com.alamofire.serialization.response.error.string"]);
        if (IsNilOrNull(failure)) {
            return ;
        }
        if(error.code == -1001){
            [TOASTVIEW showWithText:@"请求超时, 请稍后再试!"];
        }
       
        failure(weakSelf.networkingManager , error);
    }];
}

- (void)requestOuterUrl:(NSString *)requestUrl success:(RequestSuccessBlock)success failure:(RequestFailedBlock)failure{
    
    if (![self buildRequestConfigInfo]) {
        return;
    }
    WS(weakSelf);
    AFHTTPSessionManager *outerNetworkingManager = [[AFHTTPSessionManager alloc] init];
    [outerNetworkingManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [outerNetworkingManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [outerNetworkingManager GET:requestUrl parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (IsNilOrNull(success)) {
            return ;
        }
        [SVProgressHUD dismiss];
        success(weakSelf.networkingManager , responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        if (IsNilOrNull(failure)) {
            return ;
        }
        if(error.code == -1001){
            [TOASTVIEW showWithText:@"请求超时, 请稍后再试!"];
        }
        failure(weakSelf.networkingManager , error);
    }];
}


// 请求超时时间
- (void)configTimeOut:(AFHTTPSessionManager *)manager{
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 30.0f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    ((AFJSONResponseSerializer *)self.networkingManager.responseSerializer).removesKeysWithNullValues = YES;
}




- (void)dealloc{
    if (!IsNilOrNull(self.sessionDataTask)) {
        [self.sessionDataTask cancel];
    }
}

@end
