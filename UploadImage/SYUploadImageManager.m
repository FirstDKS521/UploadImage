//
//  SYUploadImageManager.m
//  UploadImage
//
//  Created by aDu on 2016/12/14.
//  Copyright © 2016年 DuKaiShun. All rights reserved.
//

#import "SYUploadImageManager.h"

@interface SYUploadImageManager ()

@property (nonatomic, strong) UIImagePickerController *pickerVC;
@property (nonatomic, strong) UIViewController *fatherController;
@property (nonatomic, assign) CGSize targetSize; //目标尺寸

@property (nonatomic, copy) BackWithData backData;

@end

@implementation SYUploadImageManager

- (id)initWithCustomController:(UIViewController *)controller targetSize:(CGSize)targetSize callBack:(BackWithData)callBack
{
    self = [super init];
    if (self) {
        self.backData = callBack;
        self.fatherController = controller;
        self.targetSize = targetSize;
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册中选择", nil];
        [sheet showInView:controller.view];
    }
    return self;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: { // 拍照
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) return;
            self.pickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
            // 显示控制器
            [self.fatherController presentViewController:self.pickerVC animated:YES completion:nil];
            break;
        }
        case 1: { // 相册
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) return;
            self.pickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            // 显示控制器
            [self.fatherController presentViewController:self.pickerVC animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

#pragma mark - UIImagePickerControllerDelegate

//获取图片的方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [self.pickerVC dismissViewControllerAnimated:YES completion:nil];
    //获取图片，固定方向
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    //获取图片的尺寸
    image = [self reduceImage:image percent:0.5];
    image = [self compressWithImage:image byScalingToSize:self.targetSize];
    
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    self.backData(image, data);
}

#pragma mark - 图片处理

/**
 * “压” 是指文件体积变小，但是像素数不变，长宽尺寸不变，那么质量可能下降。
 * “缩” 是指文件的尺寸变小，也就是像素数减少，而长宽尺寸变小，文件体积同样会减小。
 * percent 压缩图片质量(分辨率),最好是0.3~0.7，过小则可能会出现黑边等
 */
-(UIImage *)reduceImage:(UIImage *)image percent:(float)percent
{
    NSData *imageData = UIImageJPEGRepresentation(image, percent);
    UIImage *newImage = [UIImage imageWithData:imageData];
    return newImage;
}

/**
 * sourceImage 相机或者相册的图片
 * targetSize 目标尺寸的大小，按照比例最小的去压缩
 * return newImage 得到压缩后的图片
 */
- (UIImage *)compressWithImage:(UIImage *)sourceImage byScalingToSize:(CGSize)targetSize
{
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if (!CGSizeEqualToSize(imageSize, targetSize)) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor < heightFactor) {
            scaleFactor = widthFactor;
        } else {
            scaleFactor = heightFactor;
        }
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image 是图片居中
        if (widthFactor < heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    // this is actually the interesting part:
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (newImage == nil) {
        NSLog(@"压缩失败");
    }
    return newImage ;
}

#pragma mark - init

- (UIImagePickerController *)pickerVC
{
    if (!_pickerVC) {
        _pickerVC = [[UIImagePickerController alloc] init];
        _pickerVC.modalPresentationStyle = UIModalPresentationCurrentContext;
        _pickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
        _pickerVC.allowsEditing = YES;
        // 设置代理
        _pickerVC.delegate = self;
    }
    return _pickerVC;
}

@end
