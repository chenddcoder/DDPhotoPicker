//
//  DDPhotoPickerController.h
//  DDTakePhoto
//
//  Created by 陈丁丁 on 2018/6/5.
//  Copyright © 2018年 陈丁丁. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDPhotoPickerController : UIViewController
@property (nonatomic, assign) UIImageOrientation orientation;//默认UIImageOrientationLeft
@property (nonatomic, copy) void (^takePhotoCallback)(UIImage * image);
@end
