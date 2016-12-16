//
//  UIImage+Extras.h
//  UploadImage
//
//  Created by aDu on 2016/12/13.
//  Copyright © 2016年 DuKaiShun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extras)

/**
 * targetSize 目标尺寸的大小，按照比例最小的去压缩
 * return newImage 得到压缩后的图片
 */
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;

@end
