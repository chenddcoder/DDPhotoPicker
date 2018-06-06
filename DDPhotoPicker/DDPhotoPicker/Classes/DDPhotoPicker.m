//
//  DDPhotoPicker.m
//  DDPhotoPicker
//
//  Created by 陈丁丁 on 2018/4/19.
//  Copyright © 2018年 陈丁丁. All rights reserved.
//

#import "DDPhotoPicker.h"
#import <UIKit/UIKit.h>
#define kScreenWidth UIScreen.mainScreen.bounds.size.width
#define kScreenHeight UIScreen.mainScreen.bounds.size.height
@interface DDPhotoPicker()
@property (nonatomic, strong) AVCaptureSession * session;
@property (nonatomic, strong) UIView * preView;
@property (nonatomic, strong) UIImageView * shutterImageView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer  * previewLayer;
@property (nonatomic, strong) AVCaptureDeviceInput * videoInput;
@end
@implementation DDPhotoPicker
-(instancetype)initWithPreView:(UIView *)preView andShutterImageView:(UIImageView *)shutterImageView;{
    self=[super init];
    if (self) {
        self.preView=preView;
        self.shutterImageView=shutterImageView;
    }
    return self;
}
- (void)shutterCamera
{
    AVCaptureStillImageOutput * stillImageOutput=self.session.outputs[0];
    AVCaptureConnection * videoConnection = [stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        NSLog(@"take photo failed!");
        return;
    }
    __weak typeof(self) weakSelf=self;
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            return;
        }
        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage * image = [UIImage imageWithData:imageData];
        UIImage * fixImg=[self fixOrientation:image];
        CGRect rectIn=[self.shutterImageView.layer convertRect:self.shutterImageView.frame toLayer:self.previewLayer];
        CGFloat placeW=fixImg.size.width*self.shutterImageView.frame.size.width/self.preView.bounds.size.width;
        CGFloat originX=fixImg.size.width/self.preView.bounds.size.width*rectIn.origin.x;
        CGFloat originY=fixImg.size.height/(self.preView.bounds.size.width/kScreenWidth*kScreenHeight)*rectIn.origin.y;
        CGRect cutFrame= CGRectMake(originX,originY,placeW , placeW/self.shutterImageView.bounds.size.width*self.shutterImageView.bounds.size.height);
        UIImage * finalImg=[self cutImage:fixImg withFrame:cutFrame];
        self.shutterImageView.image=finalImg;
        [weakSelf stopCap];
    }];
}
-(void)startCap{
    [self createSession];
    if (self.session) {
        [self.session startRunning];
    }
    [self setUpCameraLayer:self.preView];
}
-(void)stopCap{
    if (self.session) {
        [self.session stopRunning];
        self.session=nil;
    }
    if (self.previewLayer) {
        [self.previewLayer removeFromSuperlayer];
        self.previewLayer = nil;
    }
}
-(void)focus:(CGPoint)point{
    //将界面point对应到摄像头point
    CGPoint cameraPoint = [self.previewLayer captureDevicePointOfInterestForPoint:point];
    
    //设置聚光点坐标
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
    
}
/**设置聚焦点*/
-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    
    AVCaptureDevice *captureDevice= [self.videoInput device];
    NSError *error = nil;
    //设置设备属性必须先解锁 然后加锁
    if ([captureDevice lockForConfiguration:&error]) {
        
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        //        //曝光
        //        if ([captureDevice isExposureModeSupported:exposureMode]) {
        //            [captureDevice setExposureMode:exposureMode];
        //        }
        //        if ([captureDevice isExposurePointOfInterestSupported]) {
        //            [captureDevice setExposurePointOfInterest:point];
        //        }
        //        //闪光灯模式
        //        if ([captureDevice isFlashModeSupported:AVCaptureFlashModeAuto]) {
        //            [captureDevice setFlashMode:AVCaptureFlashModeAuto];
        //        }
        
        //加锁
        [captureDevice unlockForConfiguration];
        
    }else{
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}

//获取授权
+(void)getAuthorization:(void (^)(BOOL flag))callback
{
    //此处获取摄像头授权
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo])
    {
        case AVAuthorizationStatusAuthorized:       //已授权，可使用    The client is authorized to access the hardware supporting a media type.
        {
            callback(YES);
            break;
        }
        case AVAuthorizationStatusNotDetermined:    //未进行授权选择     Indicates that the user has not yet made a choice regarding whether the client can access the hardware.
        {
            //则再次请求授权
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted){    //用户授权成功
                    callback(YES);
                    return;
                } else {        //用户拒绝授权
                    callback(NO);
                    return;
                }
            }];
            break;
        }
        default:          //用户拒绝授权/未授权
        {
            callback(NO);
            break;
        }
    }
    
    
}
-(void)createSession{
    if (!self.session) {
        self.session = [[AVCaptureSession alloc] init];
        self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:nil];
        AVCaptureStillImageOutput * stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
        //这是输出流的设置参数AVVideoCodecJPEG参数表示以JPEG的图片格式输出图片
        [stillImageOutput setOutputSettings:outputSettings];
        
        if ([self.session canAddInput:self.videoInput]) {
            [self.session addInput:self.videoInput];
        }
        if ([self.session canAddOutput:stillImageOutput]) {
            [self.session addOutput:stillImageOutput];
        }
    }
    
}

- (void) setUpCameraLayer:(UIView*)contentView
{
    if (self.previewLayer == nil) {
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        UIView * view = contentView;
        CALayer * viewLayer = [view layer];
        [viewLayer setMasksToBounds:YES];
        [self.previewLayer setFrame:CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.width/[UIScreen mainScreen].bounds.size.width*[UIScreen mainScreen].bounds.size.height)];
        [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
        
        [viewLayer insertSublayer:self.previewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
        
    }
}
-(UIImage*)fixOrientation:(UIImage*)aImage {
    
    if (aImage.imageOrientation == UIImageOrientationUp) return aImage;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) { case UIImageOrientationDown: case UIImageOrientationDownMirrored: transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height); transform = CGAffineTransformRotate(transform, M_PI); break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
            
    }
    
    switch (aImage.imageOrientation) { case UIImageOrientationUpMirrored: case UIImageOrientationDownMirrored: transform = CGAffineTransformTranslate(transform, aImage.size.width, 0); transform = CGAffineTransformScale(transform, -1, 1); break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
            
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height, CGImageGetBitsPerComponent(aImage.CGImage), 0, CGImageGetColorSpace(aImage.CGImage), CGImageGetBitmapInfo(aImage.CGImage)); CGContextConcatCTM(ctx, transform); switch (aImage.imageOrientation) { case UIImageOrientationLeft: case UIImageOrientationLeftMirrored: case UIImageOrientationRight: case UIImageOrientationRightMirrored:
            
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
            
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx); UIImage *img = [UIImage imageWithCGImage:cgimg]; CGContextRelease(ctx); CGImageRelease(cgimg); return img;
    
}
-(UIImage *)cutImage:(UIImage*)originImage withFrame:(CGRect)frame
{
    CGImageRef subImageRef = CGImageCreateWithImageInRect(originImage.CGImage, frame);
    if (!subImageRef) {
        return nil;
    }
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    CFRelease(subImageRef);
    UIGraphicsEndImageContext();
    return smallImage;
}
#pragma mark 辅助方法
- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}
@end
