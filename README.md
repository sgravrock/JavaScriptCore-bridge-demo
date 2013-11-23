JavaScriptCore Bridge Demo
==========================

This demo shows how JavaScriptCore can be used to call back and forth between Objective-C and Javascript code. This approach has several advantages over bridges like PhoneGap that rely on ```webViewDidFinishLoad:```.

* Synchronous calls can be made in both directions.
* Values can be returned in both directions.
* Function parameters are actual object references rather than stringifications.
* Closures can be passed in either direction and are callable from the other side.
* Performance is likely to be better, particularly for calls with large arguments where the overhead of stringification and escaping can be a significant bottleneck.

There are also a couple of key drawbacks. It only works on iOS 7. And although JavaScriptCore is documented, the method of accessing the the Javascript context isn't. Some people have reported getting apps published that use the method shown here, but that doesn't mean that it will always get past App Store review or that future iOS versions won't break it.

See also:
* http://blog.bignerdranch.com/3784-javascriptcore-and-ios-7/
* http://blog.impathic.com/post/64171814244/true-javascript-uiwebview-integration-in-ios7
* https://github.com/TomSwift/UIWebView-TS_JavaScriptContext
