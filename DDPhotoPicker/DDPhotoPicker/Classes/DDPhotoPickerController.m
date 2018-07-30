//
//  DDPhotoPickerController.m
//  DDTakePhoto
//
//  Created by 陈丁丁 on 2018/6/5.
//  Copyright © 2018年 陈丁丁. All rights reserved.
//

#import "DDPhotoPickerController.h"
#import "DDPhotoPickerMaskView.h"
#import "DDPhotoPicker.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#define kScreenWidth UIScreen.mainScreen.bounds.size.width
#define kScreenHeight UIScreen.mainScreen.bounds.size.height
@interface DDPhotoPickerController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (strong, nonatomic)  DDPhotoPickerMaskView *maskView;
@property (nonatomic, strong) DDPhotoPicker * photoPicker;
@property (nonatomic, assign) BOOL currentNavHidden;
@end

@implementation DDPhotoPickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.maskView=[[DDPhotoPickerMaskView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    self.orientation=UIImageOrientationLeft;
    [self.view addSubview:self.maskView];
    self.photoPicker=  [[DDPhotoPicker alloc]initWithPreView:self.maskView andShutterImageView:self.maskView.placeIV];
    //添加点按聚焦手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScreen:)];
    [self.maskView addGestureRecognizer:tapGesture];

    __weak typeof(self) weakSelf=self;
    self.maskView.takePhotoClicked = ^{
        [weakSelf.photoPicker shutterCamera];
    };
    self.maskView.takePhotoReTake = ^{
        weakSelf.maskView.placeIV.image=nil;
        [weakSelf.photoPicker startCap];
    };
    self.maskView.takePhotoCancle = ^{
        [weakSelf.photoPicker stopCap];
        if (weakSelf.navigationController) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else{
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
        
    };
    self.maskView.takePhotoSubmit = ^{
        if (weakSelf.navigationController) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else{
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
        if (weakSelf.takePhotoCallback) {
            //旋转90度
            UIImage * oriImage=weakSelf.maskView.placeIV.image;
            UIImage * rotateImage=[weakSelf rotateImage:oriImage rotation:weakSelf.orientation];
            weakSelf.takePhotoCallback(rotateImage);
        }
    };
    self.maskView.photoLibPick = ^{
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            switch (status) {
                case PHAuthorizationStatusAuthorized:
                    NSLog(@"PHAuthorizationStatusAuthorized");
                    break;
                case PHAuthorizationStatusDenied:
                    NSLog(@"PHAuthorizationStatusDenied");
                    break;
                case PHAuthorizationStatusNotDetermined:
                    NSLog(@"PHAuthorizationStatusNotDetermined");
                    break;
                case PHAuthorizationStatusRestricted:
                    NSLog(@"PHAuthorizationStatusRestricted");
                    break;
            }
        }];
        UIImagePickerController * picker=[[UIImagePickerController alloc]init];
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        picker.delegate=weakSelf;
        [weakSelf presentViewController:picker animated:YES completion:nil];
    };
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //获取当前导航栏状态，当消失时恢复
    if (self.navigationController) {
        self.currentNavHidden=self.navigationController.navigationBarHidden;
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.photoPicker stopCap];
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:self.currentNavHidden animated:YES];
    }
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.photoPicker startCap];
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
- (void)tapScreen:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self.maskView];
    [self.photoPicker focus:point];
    
}

- (UIImage *)rotateImage:(UIImage *)image rotation:(UIImageOrientation)orientation
{
    CGRect bnds = CGRectZero;
    UIImage* copy = nil;
    CGContextRef ctxt = nil;
    CGImageRef imag = image.CGImage;
    CGRect rect = CGRectZero;
    CGAffineTransform tran = CGAffineTransformIdentity;
    
    rect.size.width = CGImageGetWidth(imag);
    rect.size.height = CGImageGetHeight(imag);
    
    bnds = rect;
    
    switch (orientation)
    {
        case UIImageOrientationUp:
            return image;
            
        case UIImageOrientationUpMirrored:
            tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown:
            tran = CGAffineTransformMakeTranslation(rect.size.width,
                                                    rect.size.height);
            tran = CGAffineTransformRotate(tran, M_PI);
            break;
            
        case UIImageOrientationDownMirrored:
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
            tran = CGAffineTransformScale(tran, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeft:
            bnds = [self swapWidthAndHeight:bnds];
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.width);
            tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeftMirrored:
            bnds = [self swapWidthAndHeight:bnds];
            tran = CGAffineTransformMakeTranslation(rect.size.height,
                                                    rect.size.width);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRight:
            bnds = [self swapWidthAndHeight:bnds];
            tran = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
            tran = CGAffineTransformRotate(tran, M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored:
            bnds = [self swapWidthAndHeight:bnds];
            tran = CGAffineTransformMakeScale(-1.0, 1.0);
            tran = CGAffineTransformRotate(tran, M_PI / 2.0);
            break;
            
        default:
            return image;
    }
    
    UIGraphicsBeginImageContext(bnds.size);
    ctxt = UIGraphicsGetCurrentContext();
    
    switch (orientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextScaleCTM(ctxt, -1.0, 1.0);
            CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
            break;
            
        default:
            CGContextScaleCTM(ctxt, 1.0, -1.0);
            CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
            break;
    }
    
    CGContextConcatCTM(ctxt, tran);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, imag);
    
    copy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return copy;
}
-(CGRect)swapWidthAndHeight:(CGRect)rect
{
    CGFloat swap = rect.size.width;
    rect.size.width = rect.size.height;
    rect.size.height = swap;
    return rect;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    //获取图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    if (self.takePhotoCallback) {
        self.takePhotoCallback(image);
    }
    
}

//用户取消选择
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
