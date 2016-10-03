//
//  ModalViewController.m
//  RAC_pod
//
//  Created by Zhuge_Mac on 16/10/3.
//  Copyright © 2016年 Magic. All rights reserved.
//

#import "ModalViewController.h"
#import "GlobalHeader.h"

@interface ModalViewController ()
@property (nonatomic,strong) RACSignal * signal;

@end

@implementation ModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @weakify(self)
    RACSignal * tempSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self) // weak strong 配套使用
        NSLog(@"%@",self);
        return nil;
    }];
    self.signal = tempSignal; // 复现强引用
}
- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    NSLog(@"dealloc");
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
