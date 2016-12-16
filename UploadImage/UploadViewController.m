//
//  UploadViewController.m
//  UploadImage
//
//  Created by aDu on 2016/12/14.
//  Copyright © 2016年 DuKaiShun. All rights reserved.
//

#import "UploadViewController.h"
#import "SYUploadImageManager.h"
#import "SYNetworkTool.h"

@interface UploadViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) SYUploadImageManager *manager;
@property (nonatomic, strong) NSData *data;

@end

@implementation UploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"上传图片";
    self.view.backgroundColor = [UIColor whiteColor];
}

//选择图片
- (IBAction)choiceBtn:(id)sender {
    __weak __typeof(self) ws = self;
    self.manager = [[SYUploadImageManager alloc] initWithCustomController:self targetSize:CGSizeMake(300, 300) callBack:^(UIImage *image, id data) {
        ws.imageView.image = image;
        ws.data = data;
    }];
}

//上传图片
- (IBAction)uploadBtn:(id)sender {
    self.manager = [[SYUploadImageManager alloc] initWithCustomController:self targetSize:CGSizeMake(200, 200) callBack:^(UIImage *image, id data) {
        [SYNetworkTool uploadImageWithUrl:@"http://192.168.1.22:8080/robot-web/demo/upload!uploadFile.do" parameters:nil imageData:data progress:^(float progress) {
            float plan = 0.00f;
            plan = progress;
            NSInteger teger = plan * 100;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"上传进度%@", @(teger));
            });
        } success:^(NSDictionary *data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"上传成功");
            });
            NSLog(@"%@", data);
        } failure:^(NSError *error) {
            NSLog(@"失败");
        }];
    }];
}

@end
