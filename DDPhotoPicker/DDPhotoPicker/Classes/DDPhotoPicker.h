//
//  DDPhotoPicker.h
//  DDPhotoPicker
//
//  Created by 陈丁丁 on 2018/4/19.
//  Copyright © 2018年 陈丁丁. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface DDPhotoPicker : NSObject
/**
 判断权限使用，调用组件前先调用此方法
 */
+(void)getAuthorization:(void (^)(BOOL flag))callback;
/**
 shutterImageView需要在preView中，否则将得不到image
 */
-(instancetype)initWithPreView:(UIView *)preView andShutterImageView:(UIImageView *)shutterImageView;
-(void)startCap;
-(void)shutterCamera;
-(void)stopCap;
@end
