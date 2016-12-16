//
//  SYNetworkTool.h
//  UploadImage
//
//  Created by aDu on 2016/12/14.
//  Copyright © 2016年 DuKaiShun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SuccessBlock)(NSDictionary *data);
typedef void (^FailureBlock)(NSError *error);
typedef void (^ProgressBlock)(float progress);

@interface SYNetworkTool : NSObject

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
                   failure:(FailureBlock)failureBlock;


@end
