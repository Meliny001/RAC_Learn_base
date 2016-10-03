//
//  ViewController.m
//  RAC_pod
//
//  Created by Zhuge_Mac on 16/10/3.
//  Copyright © 2016年 Magic. All rights reserved.
//

#import "ViewController.h"
#import "GlobalHeader.h"
#import "ZGButton.h"
#import "Flags.h"
#import "RACReturnSignal.h"

@interface ViewController ()
@property (nonatomic,strong) id<RACSubscriber> subscriber;
@property (weak, nonatomic) IBOutlet ZGButton *viewBtn;
@property (nonatomic,strong) Flags * model;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UITextField *textF;
@property (weak, nonatomic) IBOutlet UILabel *labelView;
@property (weak, nonatomic) IBOutlet UITextField *passwordF;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end
extern NSString * const ZGbuttonKey;

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self skipDemo];

}
//MARK:RAC过滤
- (void)skipDemo
{
    RACSubject * subject = [RACSubject subject];
    // skip跳过n个值执行
    RACSignal * skipSignal = [subject skip:1];
    
    [skipSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    [subject sendNext:@"name"];
    [subject sendNext:@"age"];
    [subject sendNext:@"score"];
}

- (void)distinctUntilChangedDemo
{
    RACSubject * subject = [RACSubject subject];
    // distinctUntilChanged只有数据不相同时才继续执行
    RACSignal * distinctSignal = [subject distinctUntilChanged];
    
    [distinctSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    [subject sendNext:@"name"];
    [subject sendNext:@"age"];
    [subject sendNext:@"age"];
}

- (void)takeDemo
{
    RACSubject * subject = [RACSubject subject];
    RACSubject * subjectB = [RACSubject subject];
    /*
     take:只拿前面n个数据
     takeLast:只拿后面n个数据,必须发送完毕
     takeUntil:信号B完毕后,A不再执行
     */
    RACSignal * ignoreSignal = [subject takeUntil:subjectB];
    
    [ignoreSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    [subject sendNext:@"name"];
    [subjectB sendCompleted];
    [subject sendNext:@"age"];
    [subject sendNext:@"sex"];
    [subject sendCompleted];
}

- (void)ignoreDemo
{
    RACSubject * subject = [RACSubject subject];
    // ignoreValues忽略所有值
    RACSignal * ignoreSignal = [subject ignore:@"name"];

    [ignoreSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    [subject sendNext:@"name"];
    [subject sendNext:@"age"];
}
- (void)racFilterDemo
{
    [[self.textF.rac_textSignal filter:^BOOL(id value) {
        return self.textF.text.length > 5;
    }] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

//MARK:RAC组合
- (void)combineReduceDemo
{
    // 先组合再 聚合
    [self.textF.rac_textSignal subscribeNext:^(id x) {
        
    }];
    [self.passwordF.rac_textSignal subscribeNext:^(id x) {
        
    }];
    // 同时满足时 触发.可多个条件
    RACSignal *combineSignal = [RACSignal combineLatest:@[self.textF.rac_textSignal,self.passwordF.rac_textSignal] reduce:^id(NSString * account,NSString * password){
        return @(account.length && password.length);
    }];
    
//    [combineSignal subscribeNext:^(id x) {
//        self.loginBtn.enabled = [x boolValue];
//    }];
    
    RAC(self.loginBtn,enabled) = combineSignal;
    
}

- (void)ZipDemo
{
    // 界面中多个请求,当所有数据均拿到的时候更新UI
    RACSubject *signalA = [RACSubject subject];
    RACSubject *signalB = [RACSubject subject];
    
    // 组合信号
    RACSignal * zipSignal = [signalA zipWith:signalB];
    // 订阅信号
    [zipSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    // 发送信号
    [signalB sendNext:@"send second part data"];
//    [signalA sendNext:@"send first part data"];
}

- (void)mergeDemo
{
    // 任意信号发送均可调用,无限制条件
    RACSubject *signalA = [RACSubject subject];
    RACSubject *signalB = [RACSubject subject];
    
    // 组合信号
    RACSignal * mergeSignal = [signalA merge:signalB];
    // 订阅信号
    [mergeSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    // 发送信号
    [signalB sendNext:@"send second part data"];
    [signalA sendNext:@"send first part data"];
    [signalB sendNext:@"send second part data"];

}

- (void)thenDemo
{
    RACSignal * signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"request first part data");
        [subscriber sendNext:@"send first part data"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal * signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"request second part data");
        [subscriber sendNext:@"send second part data"];
        return nil;
    }];
    
    // 按顺序执行 A->B 且会忽略掉第一个数据
    RACSignal * thenSignal = [signalA then:^RACSignal *{
        return signalB;
    }];
    
    [thenSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

- (void)concatDemo
{
    RACSignal * signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"request first part data");
        [subscriber sendNext:@"send first part data"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal * signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"request second part data");
        [subscriber sendNext:@"send second part data"];
        return nil;
    }];
    
    // 按顺序执行 A->B 两个数据均可拿到
    RACSignal * concatSignal = [signalA concat:signalB];
    
    [concatSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
}

- (void)signalOfSignalDemo
{
    RACSubject * signalofsignal = [RACSubject subject];
    RACSubject * signal = [RACSubject subject];
    
//    [signalofsignal subscribeNext:^(id x) {
//        [x subscribeNext:^(id x) {
//            NSLog(@"%@",x);
//        }];
//    }];
    
    [[signalofsignal flattenMap:^RACStream *(id value) {
        
        // 原始信号中的内容(只能直接返回)
        return value;
    }] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    [signalofsignal sendNext:signal];
    [signal sendNext:@"signalOfSignalDemo"];
}

// 一般绑定
- (void)mapDemo
{
    RACSubject * subject = [RACSubject subject];
    RACSignal * mapSignal = [subject map:^id(id value) {
        // 处理信号
        value = [NSString stringWithFormat:@"magic_%@",value];
        return value;
    }];
    
    [mapSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    [subject sendNext:@"123"];
    [subject sendNext:@"456"];
    
}

//MARK:flattenMap映射,用于信号中的信号
- (void)flattenMapDemo
{
    RACSubject * subject = [RACSubject subject];
    [[subject flattenMap:^RACStream *(id value) {
        // 原始信号中的信号处理信号
        value = [NSString stringWithFormat:@"magic_%@",value];
        return [RACReturnSignal return:value];
    }] subscribeNext:^(id x) {
        // 输出结果
        NSLog(@"%@",x);
    }];
    [subject sendNext:@"map"];
}

// MARK:bind(可以直接对原始数据处理后包装返回)
- (void)rac_bindDemo
{
    // 1.创建信号
    RACSubject * subject = [RACSubject subject];
    // 2.绑定信号
    RACSignal * bindSignal = [subject bind:^RACStreamBindBlock{
        // 不操作该block
        return ^RACSignal *(id value, BOOL *stop)
        {
            // 在该block中处理数据 返回处理后的结果
            value = [NSString stringWithFormat:@"C_%@",value];
            return [RACReturnSignal return:value];
        };
    }];
    
    // 3.订阅信号
    [bindSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    // 4.发送信号
    [subject sendNext:@"NMB"];
}

// MARK:RACCommandDemo(传入数据->处理数据返回-可监听是否完成)
- (void)RACCommandDemo
{
    // 1.创建
    RACCommand * command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        // 传入待处理数据
        NSLog(@"%@",input);
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"createSignal");
            // 执行数据处理 后发送结果
            [subscriber sendNext:@"finished signal"];
            
            // 如果使用command executing 需主动调用执行完毕指令
            [subscriber sendCompleted];
            
            return nil;
        }];
    }];
    // 2.订阅(拿到信号中的信号)
    // 方式1
    [command.executionSignals subscribeNext:^(RACSignal * signal) {
        [signal subscribeNext:^(id x) {
            NSLog(@"%@",x);
        }];
    }];
    
    // 方式2
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    // 3.执行命令
    RACSignal * signal = [command execute:@"AHH"];
    // 方式3
    [signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    // 4.监听事件有无完成
    [command.executing subscribeNext:^(id x) {
        if ([x boolValue] == YES) {
            NSLog(@"正在执行");
        }else
        {
            NSLog(@"未开始/执行完成");
        }
    }];
}

// RACMulticastConnection
- (void)RACMulticastConnectionDemo
{
    // 多个订阅者 数据只请求一次
    RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // request data
        NSLog(@"request data");
        [subscriber sendNext:@"load data"];
        return nil;
    }];
    
    // 转换
    RACMulticastConnection * connection = [signal publish];
    // 订阅
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"订阅者1_%@",x);
    }];
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"订阅者2_%@",x);
    }];
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"订阅者3_%@",x);
    }];
    
    // 建立连接
    [connection connect];
}

//MARK: 常用宏 RAC  RACObserve weakif strongif tuplePack and unpack
- (void)defineDemo
{
    RACTuple * tuple = RACTuplePack(@"name",@"age",@"score");
    NSLog(@"%@",tuple);
}

//MARK: rac_lift 多个数据均发送时触发
- (void)rac_liftDemo
{
    RACSignal * hotSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // request hot data
        NSLog(@"request hot data");
        [subscriber sendNext:@"request hot data"];
        return nil;
    }];
    
    RACSignal * newSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // request hot data
        NSLog(@"request new data");
        [subscriber sendNext:@"request new data"];
        return nil;
    }];
    
    // 两个信号均发送数据时触发,参数与Array一一对应
    [self rac_liftSelector:@selector(updateUIWithHotData:andNewData:) withSignalsFromArray:@[hotSignal,newSignal]];
}
- (void)updateUIWithHotData:(NSString *)hotData andNewData:(NSString *)newData
{
    NSLog(@"update UI");
}


//MARK: RAC 应用场景

// 应用场景:监听文本框
- (void)textSignalDemo
{
    // 1.base
    [self.textF.rac_textSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    // 2.使用宏
    RAC(self.labelView,text) = self.textF.rac_textSignal;
}

// 应用场景:代替通知
- (void)rac_NotificationCenter
{
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:ZGbuttonKey object:nil]subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

// 应用场景:监听事件
- (void)observeControlEvents
{
    [[self.button rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        //
        NSLog(@"按钮被点击了");
    }];
}

// 应用场景:KVO
- (void)RAC_KOVDemo
{
    Flags * model = [[Flags alloc]init];
    _model = model;
    // 1.rac_valuesForKeyPath
    [[_model rac_valuesForKeyPath:@"name" observer:nil]subscribeNext:^(id x) {
//        NSLog(@"%@",x);
    }];
    // 2.rac_observeKeyPath
    [_model rac_observeKeyPath:@"name" options:NSKeyValueObservingOptionNew observer:nil block:^(id value, NSDictionary *change, BOOL causedByDealloc, BOOL affectedOnlyLastComponent) {
//        NSLog(@"newValue:%@",change[@"new"]);
    }];
    
    // 3.RACObserve
    [RACObserve(_model,name) subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [[[UIApplication sharedApplication]keyWindow]endEditing:YES];
    static NSInteger index = 0;
    index ++;
    self.model.name = [NSString stringWithFormat:@"change_%li",index];
}

// 应用场景:作为代理
- (void)RACSubjectDemo
{
    // 1.RACSubject 可传参
    [self.viewBtn.subject subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    // 2.signalForSelector
//    [[self.viewBtn rac_signalForSelector:@selector(buttonClicked)]subscribeNext:^(id x) {
//        NSLog(@"viewBtn clicked");
//    }];
}

// RAC集合应用 转模型
- (void)RACToModel
{
    NSString * path = [[NSBundle mainBundle]pathForResource:@"flags.plist" ofType:nil];
    NSArray * tempArr = [NSArray arrayWithContentsOfFile:path];
//    NSMutableArray * arr = [NSMutableArray array];
//    [tempArr.rac_sequence.signal subscribeNext:^(NSDictionary * dict) {
//        Flags * flag = [Flags flagWithDict:dict];
//        [arr addObject:flag];
//    }];
    // 映射
    NSArray * arr = [[tempArr.rac_sequence map:^id(NSDictionary * dict) {
        return [Flags flagWithDict:dict];
    }] array];
    
    NSLog(@"%@",arr);
}

//MARK: RAC 集合类
- (void)jihe
{
    // RACTuple
    RACTuple * tuple = [RACTuple tupleWithObjectsFromArray:@[@"1",@"2",@"3"]];
    NSLog(@"%@",tuple[2]);
    
    // RACSequence 及遍历
    NSArray * arr = @[@"one",@"two",@"three"];
    RACSequence * sequence = arr.rac_sequence;
    RACSignal * signal = sequence.signal;
    [signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    NSDictionary * dict = @{@"name":@"xiaoMing",@"age":@"10",@"score":@"98"};
    [dict.rac_sequence.signal subscribeNext:^(id x) {
        RACTupleUnpack(NSString * key,NSString * value) = x;
        NSLog(@"%@ %@",key,value);
    }];
}

//MARK: RAC常用信号类
- (void)RACReplaySubjectTest
{
    // 1.创建信号
    RACReplaySubject * replaySubject = [RACReplaySubject subject];
    
    // 2.发送信号(可放于订阅前)
    [replaySubject sendNext:@"replaySubject"];
    
    // 3.订阅信号
    [replaySubject subscribeNext:^(id x) {
        //
        NSLog(@"%@",x);
    }];
}

- (void)RACSubjectTest
{
    // 1.创建信号
    RACSubject * subject = [RACSubject subject];
    // 2.订阅信号
    [subject subscribeNext:^(id x) {
        //
        NSLog(@"%@",x);
    }];
    
    // 3.发送信号
    [subject sendNext:@"信号发送"];
}

- (void)baseCreateAndDisposeSignal
{
    // 1.创建信号
    RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        _subscriber = subscriber;
        // 3.发送信号
        [subscriber sendNext:@"信号发送"];
        
        return [RACDisposable disposableWithBlock:^{
            // 信号取消的时候(默认自动取消)
            NSLog(@"信号被取消了");
        }];
    }];
    // 2.订阅信号
    RACDisposable * disposable = [signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    // 4.取消信号
    [disposable dispose];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
