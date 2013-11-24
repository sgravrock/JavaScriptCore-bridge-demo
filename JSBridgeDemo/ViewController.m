#import "ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	// It doesn't matter whether we tell the web view to load the page
	// before or after adding our objects. The page won't actually load
	// until after we return.
	[self loadPage];

	// Get a pointer to the JSContext that we will use to create objects and wire
	// everything up.
	UIWebView *webView = (UIWebView *)self.view;
	JSContext *ctx = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
	
	// We can create an object to serve as our "namespace", and add things to it.
	// Because the page hasn't loaded yet, these things will be immediately available
	// to JS code in the page.
	ctx[@"window"][@"jsbridge"] = @{};
	ctx[@"window"][@"jsbridge"][@"log"] = ^(JSValue *s) {
		NSLog(@"From JS: %@", s);
	};

	// We can register event handlers.
	[ctx[@"window"][@"addEventListener"] callWithArguments:@[@"load", ^{
		NSLog(@"onload");
	}]];
	
	// We can call foreign functions in both directions.
	// See calls in index.html.
	ctx[@"window"][@"jsbridge"][@"echo"] = ^(JSValue *value, JSValue *cb) {
		NSLog(@"got call to echo(%@, %@)", value, cb);
		[cb callWithArguments:@[value]];
	};
	
	// We can also return values back to JS, even closures.
	// See calls in index.html.
	ctx[@"window"][@"jsbridge"][@"makeIncrementor"] = ^() {
		__block int value = 0;
		return ^{
			return ++value;
		};
	};
	
	// We can also bridge to the JavaScriptCore C API. The C API exposes things like prototype
	// manipulation that the Objective-C API doesn't. However, it's probably better to do such
	// things in JS. The C API is a little obtuse and the terminology doesn't match up well with
	// the JS concepts that it interfaces with.
	JSObjectRef obj = JSObjectMake([ctx JSGlobalContextRef], NULL, NULL);
	ctx[@"jsbridge"][@"cCreatedObject"] = [JSValue valueWithJSValueRef:obj inContext:ctx];
	[ctx evaluateScript:@"jsbridge.log('Object created using the C API: ' + jsbridge.cCreatedObject)"];
}

- (void)loadPage {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"index"
													 ofType:@"html"];
	NSAssert(path != nil, @"Couldn't find index.html");
	NSURL *url = [NSURL fileURLWithPath:path];
	NSAssert(url != nil, @"Couldn't build URL");
	[(UIWebView *)self.view loadRequest:[NSURLRequest requestWithURL:url]];
}

@end
