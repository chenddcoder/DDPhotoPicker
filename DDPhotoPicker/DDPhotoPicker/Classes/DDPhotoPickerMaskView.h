//
//  DDPhotoPickerMaskView.h
//  DDPhotoPicker
//
//  Created by 陈丁丁 on 2018/6/5.
//  Copyright © 2018年 陈丁丁. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDPhotoPickerMaskView : UIView

@property (strong, nonatomic) UIImageView *placeIV;
@property (nonatomic, assign) BOOL isTakePhoto;
@property (nonatomic, copy) void(^takePhotoClicked)(void);
@property (nonatomic, copy) void(^takePhotoCancle)(void);
@property (nonatomic, copy) void(^takePhotoReTake)(void);
@property (nonatomic, copy) void(^takePhotoSubmit)(void);
@property (nonatomic, copy) void(^photoLibPick)(void);
@end
