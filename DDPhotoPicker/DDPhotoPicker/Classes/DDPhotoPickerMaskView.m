//
//  DDPhotoPickerMaskView.m
//  DDPhotoPicker
//
//  Created by 陈丁丁 on 2018/6/5.
//  Copyright © 2018年 陈丁丁. All rights reserved.
//

#import "DDPhotoPickerMaskView.h"
@interface DDPhotoPickerMaskView()
@property (strong, nonatomic) UIButton *takePhotoBtn;
@property (strong, nonatomic)  UIButton *cancleBtn;
@property (strong, nonatomic)  UIButton *submitBtn;
@property (strong, nonatomic)  UIButton *retakeBtn;
@property (strong, nonatomic) UIButton * photoLibBtn;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIView *pickView;
@property (nonatomic, strong) CAShapeLayer *fillLayer ;
@property (nonatomic, assign) BOOL isTakePhoto;
@end
@implementation DDPhotoPickerMaskView
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.contentView=[[UIView alloc] init];
        self.contentView.frame=CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        [self addSubview:self.contentView];
        [self layoutV:self.contentView];
        self.isTakePhoto=YES;
        [self eventV];
    }
    return self;
}
-(void)eventV{
    [self.takePhotoBtn addTarget:self action:@selector(takePhotoClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancleBtn addTarget:self action:@selector(cancleClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.submitBtn addTarget:self action:@selector(submitClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.retakeBtn addTarget:self action:@selector(reTakeClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.photoLibBtn addTarget:self action:@selector(photoLibClicked:) forControlEvents:UIControlEventTouchUpInside];
}
-(void)layoutV:(UIView*)v{
    float width=v.bounds.size.width;
    float height=v.bounds.size.height;
    self.pickView=[[UIView alloc]init];
    [v addSubview:self.pickView];
    float pickViewY=32;
    float pickViewHeight=(height/2-50-32)*2;
    float pickViewWidth=pickViewHeight*2/3;
    float pickViewX=(width-pickViewWidth)/2;
    self.pickView.frame=CGRectMake(pickViewX, pickViewY, pickViewWidth,pickViewHeight);
    self.placeIV=[[UIImageView alloc] init];
    [self.pickView addSubview:self.placeIV];
    self.placeIV.frame=CGRectMake(0, 0, self.pickView.bounds.size.width, self.pickView.bounds.size.height);
    //功能区
    UIView * funcV=[[UIView alloc] init];
    funcV.backgroundColor=[UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1];
    funcV.frame=CGRectMake(0, height-115, width, 115);
    [v addSubview:funcV];
    self.takePhotoBtn=[[UIButton alloc]init];
    self.takePhotoBtn.frame=CGRectMake((width-63)/2, (115-63)/2, 63, 63);
    NSString * db_bundle=[[NSBundle bundleForClass:[self class]]pathForResource:@"DDPhotoPicker" ofType:@"bundle"];
    NSString * pathString = [db_bundle stringByAppendingPathComponent:@"photo.png"];
    [self.takePhotoBtn setImage:[UIImage imageNamed:pathString] forState:UIControlStateNormal];
    [funcV addSubview:self.takePhotoBtn];
    self.cancleBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    [self.cancleBtn setTitle:@"取 消" forState:UIControlStateNormal];
    self.cancleBtn.titleLabel.font=[UIFont systemFontOfSize:18];
    [self.cancleBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [funcV addSubview:self.cancleBtn];
    self.cancleBtn.frame=CGRectMake(self.takePhotoBtn.frame.origin.x-44-88, (115-44)/2, 88, 44);
    
    //相册按钮
    self.photoLibBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    [funcV addSubview:self.photoLibBtn];
    [self.photoLibBtn setTitle:@"相 册" forState:UIControlStateNormal];
    self.photoLibBtn.titleLabel.font=[UIFont systemFontOfSize:18];
    [self.photoLibBtn setTitleColor:[UIColor colorWithRed:0 green:153.00/255 blue:1 alpha:1] forState:UIControlStateNormal];
    self.photoLibBtn.frame=CGRectMake(self.takePhotoBtn.frame.origin.x+self.takePhotoBtn.frame.size.width+44, (115-44)/2, 88, 44);
    
    self.retakeBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    [self.retakeBtn setTitle:@"重新拍摄" forState:UIControlStateNormal];
    self.retakeBtn.titleLabel.font=[UIFont systemFontOfSize:18];
    [self.retakeBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [funcV addSubview:self.retakeBtn];
    self.retakeBtn.frame=self.cancleBtn.frame;
    self.submitBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    [self.submitBtn setTitle:@"使用照片" forState:UIControlStateNormal];
    self.submitBtn.titleLabel.font=[UIFont systemFontOfSize:18];
    [self.submitBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [funcV addSubview:self.submitBtn];
    self.submitBtn.frame=CGRectMake(self.takePhotoBtn.frame.origin.x+self.takePhotoBtn.frame.size.width+44, (115-44)/2, 88, 44);
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    //背景
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.contentView.frame cornerRadius:0];
    //镂空
    UIBezierPath *rectPath = [UIBezierPath bezierPathWithRoundedRect:self.pickView.frame cornerRadius:0];
    [path appendPath:rectPath];
    [path setUsesEvenOddFillRule:YES];
    
    self.fillLayer= [CAShapeLayer layer];
    self.fillLayer.path = path.CGPath;
    self.fillLayer.fillRule = kCAFillRuleEvenOdd;//中间镂空的关键点 填充规则
    self.fillLayer.fillColor = [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1].CGColor;
    self.fillLayer.opacity = 0.5;
    [self.layer insertSublayer:self.fillLayer atIndex:0];
}
-(void)cover{
    self.fillLayer.opacity=1.0;
}
-(void)uncover{
    self.fillLayer.opacity=0.5;
}
-(void)setIsTakePhoto:(BOOL)isTakePhoto{
    _isTakePhoto=isTakePhoto;
    if (isTakePhoto) {
        self.takePhotoBtn.hidden=NO;
        self.cancleBtn.hidden=NO;
        self.photoLibBtn.hidden=NO;
        self.retakeBtn.hidden=YES;
        self.submitBtn.hidden=YES;
    }else{
        self.takePhotoBtn.hidden=YES;
        self.cancleBtn.hidden=YES;
        self.photoLibBtn.hidden=YES;
        self.retakeBtn.hidden=NO;
        self.submitBtn.hidden=NO;
    }
}
- (void)takePhotoClicked:(id)sender {
    if (self.takePhotoClicked) {
        self.takePhotoClicked();
    }
    [self cover];
    self.isTakePhoto=NO;
}
- (void)reTakeClicked:(id)sender {
    if (self.takePhotoReTake) {
        self.takePhotoReTake();
    }
    [self uncover];
    self.isTakePhoto=YES;
}

- (void)cancleClicked:(id)sender {
    if (self.takePhotoCancle) {
        self.takePhotoCancle();
    }
}
- (void)submitClicked:(id)sender {
    if (self.takePhotoSubmit) {
        self.takePhotoSubmit();
    }
}
-(void)photoLibClicked:(id)sender{
    if(self.photoLibPick){
        self.photoLibPick();
    }
    
}
@end
