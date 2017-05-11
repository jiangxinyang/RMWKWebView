//
//  ViewController.m
//  WKWebView
//
//  Created by rm on 2017/5/10.
//  Copyright © 2017年 rm. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>



@interface ViewController ()<WKScriptMessageHandler,WKUIDelegate,WKNavigationDelegate>

@property (nonatomic, strong)WKWebView *wkwebView;

- (IBAction)clearBtn:(id)sender;
- (IBAction)clickBtnItem:(UIButton *)sender;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customViewConfig];
    
}
-(void)customViewConfig{
    
    /*设置configur对象的WKUserContentController属性的信息，也就是设置js可与webview内容交互配置
     1、通过这个对象可以注入js名称，在js端通过window.webkit.messageHandlers.自定义的js名称.postMessage(如果有参数可以传递参数)方法来发送消息到native；
     2、我们需要遵守WKScriptMessageHandler协议，设置代理,然后实现对应代理方法(userContentController:didReceiveScriptMessage:);
     3、在上述代理方法里面就可以拿到对应的参数以及原生的方法名，我们就可以通过NSSelectorFromString包装成一个SEL，然后performSelector调用就可以了
     4、以上内容是WKWebview和UIWebview针对JS调用原生的方法最大的区别(UIWebview中主要是通过是否允许加载对应url的那个代理方法，通过在js代码里面写好特殊的url，然后拦截到对应的url，进行字符串的匹配以及截取操作，最后包装成SEL，然后调用就可以了)
     */
    
    /*
     上述是理论说明，结合下面的实际代码再做一次解释，保你一看就明白
     1、通过addScriptMessageHandler:name:方法，我们就可以注入js名称了,其实这个名称最好就是跟你的方法名一样，这样方便你包装使用，我这里自己写的就是openBigPicture，对应js中的代码就是window.webkit.messageHandlers.openBigPicture.postMessage()
     2、因为我的方法是有参数的，参数就是图片的url，因为点击网页中的图片，要调用原生的浏览大图的方法，所以你可以通过字符串拼接的方式给"openBigPicture"拼接成"openBigPicture:"，我这里没有采用这种方式，我传递的参数直接是字典，字典里面放了方法名以及图片的url，到时候直接取出来用就可以了
     3、我的js代码中关于这块的代码是
     window.webkit.messageHandlers.openBigPicture.postMessage({methodName:"openBigPicture:",imageSrc:imageArray[this.index].src});
     4、js和原生交互这块内容离不开
     - (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{}这个代理方法，这个方法以及参数说明请到下面方法对应处
     
     */
    
    //wkwebiw的相关配置
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
    //设置configur对象的preferences属性的信息
    config.preferences.minimumFontSize = 18;
    
    WKWebView *wkView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, 414, 735/2) configuration:config];
    wkView.navigationDelegate=self;
    [self.view addSubview:wkView];
    self.wkwebView = wkView;
    
    
    NSString *filePath=[[NSBundle mainBundle] pathForResource:@"myindex" ofType:@"html"];
    NSURL *baseUrl=[[NSBundle mainBundle] bundleURL];
    [self.wkwebView loadHTMLString:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] baseURL:baseUrl];
    
    WKUserContentController *userController=config.userContentController;
    
    //JS调用OC 添加处理脚本
    [userController addScriptMessageHandler:self name:@"showMobile"];
    [userController addScriptMessageHandler:self name:@"showName"];
    [userController addScriptMessageHandler:self name:@"showSendMsg"];
    
}
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        NSLog(@"%@",response);
    }];
}
//js调用oc，通过这个代理方法进行拦截
/*
 1、js调用原生的方法就会走这个方法
 2、message参数里面有2个参数我们比较有用，name和body，
 2.1 :其中name就是之前已经通过addScriptMessageHandler:name:方法注入的js名称
 2.2 :其中body就是我们传递的参数了，比如说我在js端传入的是一个字典，所以取出来也是字典
 */

-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if ([message.name isEqualToString:@"showMobile"]) {
        [self alertMessage:@"这是下面的小红帽 手机号 123333333"];
    }
    if ([message.name isEqualToString:@"showName"]) {
        NSString *info=[NSString stringWithFormat:@"%@",message.body];
        [self alertMessage:info];
    }
    if ([message.name isEqualToString:@"showSendMsg"]) {
        NSArray *arr=message.body;
        NSString *info=[NSString stringWithFormat:@"%@%@",arr.firstObject,arr.lastObject];
        [self alertMessage:info];
    }
}
-(void)alertMessage:(NSString *)msg{
    
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"信息" message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)clearBtn:(id)sender {
    [self.wkwebView evaluateJavaScript:@"clear()" completionHandler:nil];
}
//oc调用js，通过evaluateJavaScript：注入方法名
- (IBAction)clickBtnItem:(UIButton *)sender {
    switch (sender.tag) {
        case 100:
        {
            [self.wkwebView evaluateJavaScript:@"alertMobile()" completionHandler:nil];
        }
            break;
            
        case 101:
        {
            [self.wkwebView evaluateJavaScript:@"alertName('小红毛')" completionHandler:nil];
        }
            break;
            
        case 102:
        {
            [self.wkwebView evaluateJavaScript:@"alertSendMsg('18870707070','周末爬山真是件愉快的事情')" completionHandler:nil];
        }
            break;
            
        default:
            break;
    }
}


@end
