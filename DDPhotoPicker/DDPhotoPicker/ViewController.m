//
//  ViewController.m
//  DDPhotoPicker
//
//  Created by 陈丁丁 on 2018/4/19.
//  Copyright © 2018年 陈丁丁. All rights reserved.
//

#import "ViewController.h"
#import "DDPhotoPicker.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *preView;
@property (weak, nonatomic) IBOutlet UIImageView *placeIV;
@property (nonatomic, strong) DDPhotoPicker * phonePicker;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [DDPhotoPicker getAuthorization:^(BOOL flag) {
        if (flag) {
            self.phonePicker=  [[DDPhotoPicker alloc]initWithPreView:self.preView andShutterImageView:self.placeIV];
        }else{
            NSLog(@"需要开启摄像权限");
        }
    }];
  
}
- (IBAction)start:(id)sender {
    [self.phonePicker startCap];
}
- (IBAction)shutter:(id)sender {
    [self.phonePicker shutterCamera];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
