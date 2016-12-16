//
//  SYNetworkTool.m
//  UploadImage
//
//  Created by aDu on 2016/12/14.
//  Copyright © 2016年 DuKaiShun. All rights reserved.
//

#import "SYNetworkTool.h"
#import "AFNetworking.h"

@implementation SYNetworkTool

/**
 *  上传图片
 *
 *  @param urlString     请求的网址字符串
 *  @param parameters    请求的参数
 *  @param imageData     请求的参数，二进制数据
 *  @param progressBlock 上传进度
 *  @param successBlock  请求成功的回调
 *  @param failureBlock  请求失败的回调
 */
+ (void)uploadImageWithUrl:(NSString *)urlString
                parameters:(id)parameters
                 imageData:(NSData *)imageData
                  progress:(ProgressBlock)progressBlock
                   success:(SuccessBlock)successBlock
                   failure:(FailureBlock)failureBlock
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 5;
    [manager POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        //定义图片名称
        NSString *fileName = [NSString stringWithFormat:@"%@.png",[formatter stringFromDate:[NSDate date]]];
        //上传
        [formData appendPartWithFileData:imageData name:@"upload" fileName:fileName mimeType:@"image/png"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progressBlock(uploadProgress.fractionCompleted);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successBlock) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            successBlock(dic);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failureBlock) {
            failureBlock(error);
            NSLog(@"网络异常 - T_T%@", error);
        }
    }];
}

@end
