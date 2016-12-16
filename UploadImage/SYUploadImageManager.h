//
//  SYUploadImageManager.h
//  UploadImage
//
//  Created by aDu on 2016/12/14.
//  Copyright © 2016年 DuKaiShun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^BackWithData)(UIImage *image, id data);
@interface SYUploadImageManager : NSObject<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

- (id)initWithCustomController:(UIViewController *)controller targetSize:(CGSize)targetSize callBack:(BackWithData)callBack;

@end
