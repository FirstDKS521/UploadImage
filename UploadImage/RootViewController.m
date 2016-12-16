//
//  RootViewController.m
//  UploadImage
//
//  Created by aDu on 2016/12/13.
//  Copyright © 2016年 DuKaiShun. All rights reserved.
//

#import "RootViewController.h"
#import "UIImage+Extras.h"
#import "SYUploadImageManager.h"
#import "UploadViewController.h"

@interface RootViewController ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *pickerVC;

@property (weak, nonatomic) IBOutlet UIImageView *firstImage;
@property (weak, nonatomic) IBOutlet UIImageView *secondImage;
@property (nonatomic, strong) SYUploadImageManager *manager;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"上传照片";
    self.navigationController.navigationBar.translucent = NO;
}

- (IBAction)choeceImage:(id)sender {
    [self.navigationController pushViewController:[[UploadViewController alloc] init] animated:YES];
    
//    self.manager = [[SYUploadImageManager alloc] initWithCustomController:self callBack:^(UIImage *image) {
//        self.firstImage.image = image;
//    }];
    
//    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册中选择", nil];
//    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: { // 拍照
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) return;
            self.pickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
            // 显示控制器
            [self presentViewController:self.pickerVC animated:YES completion:nil];
            break;
        }
        case 1: { // 相册
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) return;
            self.pickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            // 显示控制器
            [self presentViewController:self.pickerVC animated:YES completion:nil];
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
    
    image = [image imageByScalingToSize:self.firstImage.frame.size];
    
//    image = [self imageWithImageSimple:image scaledToSize:self.secondImage.frame.size];
//    self.secondImage.contentMode = UIViewContentModeScaleAspectFit;
//    self.secondImage.clipsToBounds = YES;
    
    self.firstImage.image = image;
}

#pragma mark - 图片处理

/**
 * “压” 是指文件体积变小，但是像素数不变，长宽尺寸不变，那么质量可能下降。
 * “缩” 是指文件的尺寸变小，也就是像素数减少，而长宽尺寸变小，文件体积同样会减小。
 * percent 最好是0.3~0.7，过小则可能会出现黑边等
 */
//压缩图片质量
-(UIImage *)reduceImage:(UIImage *)image percent:(float)percent
{
    NSData *imageData = UIImageJPEGRepresentation(image, percent);
    UIImage *newImage = [UIImage imageWithData:imageData];
    return newImage;
}

//压缩图片尺寸
- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    newSize.height = image.size.height * (newSize.width / image.size.width);
    
    UIGraphicsBeginImageContext(newSize);
    
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

/*!
 *  @author 黄仪标, 15-12-01 16:12:01
 *
 *  压缩图片至目标尺寸
 *
 *  @param sourceImage 源图片
 *  @param targetWidth 图片最终尺寸的宽
 *
 *  @return 返回按照源图片的宽、高比例压缩至目标宽、高的图片
 */
- (UIImage *)compressImage:(UIImage *)sourceImage toTargetWidth:(CGFloat)targetWidth
{
    CGSize imageSize = sourceImage.size;
    
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetHeight = (targetWidth / width) * height;
    
    UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

/**
 *  图片上传压缩
 *  @param sourceImage    原图片
 *  @param compressQuality 压缩系数 0-1
 *  默认参考大小30kb,一般用该方法可达到要求，压缩系数可根据压缩后的清晰度权衡，项目里我用的0.2😆
 */
- (UIImage *)resetSizeOfImage:(UIImage *)sourceImage compressQuality:(CGFloat)compressQuality
{
    return [self resetSizeOfImage:sourceImage referenceSize:30 compressQuality:compressQuality];
}

/**
 *  图片上传压缩
 *  @param sourceImage    原图片
 *  @param maxSize 上传的参考大小 KB
 *  @param compressQuality 压缩系数 0.3 - 0.7
 *  @return imageData  二进制数据
 */
- (UIImage *)resetSizeOfImage:(UIImage *)sourceImage referenceSize:(NSInteger)maxSize compressQuality:(CGFloat)compressQuality
{
    //先调整分辨率
    CGSize newSize = CGSizeMake(sourceImage.size.width, sourceImage.size.height);
    NSInteger tempHeight = newSize.height / 1024;
    NSInteger tempWidth = newSize.width / 1024;
    
    if (tempWidth > 1.0 && tempWidth > tempHeight) {
        newSize = CGSizeMake(sourceImage.size.width / tempWidth, sourceImage.size.height / tempWidth);
    } else if (tempHeight > 1.0 && tempWidth < tempHeight) {
        newSize = CGSizeMake(sourceImage.size.width / tempHeight, sourceImage.size.height / tempHeight);
    }
    UIGraphicsBeginImageContext(newSize);
    [sourceImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //调整大小
    //    NSData *imageData = UIImageJPEGRepresentation(newImage, 1.0);
    //    NSUInteger sizeOrigin = [imageData length];
    //    NSUInteger sizeOriginKB = sizeOrigin / 1024;
    //    if (sizeOriginKB > maxSize) {
    //        NSData *finallImageData = UIImageJPEGRepresentation(newImage, compressQuality);
    //        return finallImageData;
    //    }
    //    return imageData;
    return newImage;
}

#pragma mark - 上传

- (IBAction)uploadImage:(id)sender {
    
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
