# RMWKWebView
###学习native和web的交互

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
