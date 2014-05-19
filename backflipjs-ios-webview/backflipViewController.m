//
//  backflipViewController.m
//  backflipjs-ios-webview
//
//  Created by Eric Fernberg on 5/18/14.
//  Copyright (c) 2014 Eric Fernberg. All rights reserved.
//

#import "backflipViewController.h"
#import "Reachability.h"
#import "STHTTPRequest.h"
#import "WebViewProxy.h"

@interface backflipViewController ()

@end

@implementation backflipViewController

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	[self _setupProxy];
	
	self.baseURL = @"http://192.168.1.137:3000";
	
	Reachability *reach = [Reachability reachabilityForInternetConnection];
	reach.reachableOnWWAN = YES;
	
	[reach startNotifier];
	
	// Internet is reachable
	reach.reachableBlock = ^(Reachability*reach) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSLog(@"Yayyy, we have the interwebs!");
		});
	};
	
	// Internet is not reachable
	reach.unreachableBlock = ^(Reachability*reach) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSLog(@"Someone broke the internet :(");
		});
	};
	
	NSURL *loadURL = [NSURL URLWithString:self.baseURL];
	NSURLRequest *loadURLRequest = [NSURLRequest requestWithURL:loadURL cachePolicy:NSURLCacheStorageAllowed timeoutInterval:50];
	
	[self.mobileWebView setDelegate:self];
	[[self.mobileWebView scrollView] setBounces:NO];
	
	if ( [reach isReachable] ) {
		self.isReachable = YES;
		NSLog(@"Notification Says Reachable");
		[self.mobileWebView loadRequest:loadURLRequest];
	} else {
		NSLog(@"Notification Says Unreachable");
		self.isReachable = NO;
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"index.html"];
		NSString *htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
		
//		NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
//		NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
		[self.mobileWebView loadHTMLString:htmlString baseURL:nil];
	}

}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	
	dispatch_async(dispatch_get_global_queue(0,0), ^{
		[self interceptPage];
		[self interceptPageCSS];
	});
}

- (void)interceptPage {
	STHTTPRequest *r = [STHTTPRequest requestWithURLString:self.baseURL];

	r.completionBlock = ^(NSDictionary *headers, NSString *body) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"index.html"];
		
		[body writeToFile:filePath atomically:TRUE encoding:NSUTF8StringEncoding error:NULL];
	};
	
	r.errorBlock = ^(NSError *error) {
		NSLog(@" Error %@", error);
    // ...
	};
	
	if ( self.isReachable ) {
		[r startAsynchronous];
	}
}
- (void)interceptPageCSS {
	STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://192.168.1.137:3000/build/css/main.css"];
	
	r.completionBlock = ^(NSDictionary *headers, NSString *body) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"main.css"];
		
		[body writeToFile:filePath atomically:TRUE encoding:NSUTF8StringEncoding error:NULL];
	};
	
	r.errorBlock = ^(NSError *error) {
		NSLog(@" Error %@", error);
    // ...
	};
	
	if ( self.isReachable ) {
		[r startAsynchronous];
	}
}
- (void) _setupProxy {
	NSOperationQueue* queue = [[NSOperationQueue alloc] init];
	[queue setMaxConcurrentOperationCount:5];
	
	UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Hello World!"
																										message:@"This is your first UIAlertview message."
																									 delegate:nil
																					cancelButtonTitle:@"OK"
																					otherButtonTitles:nil];
	
//	[WebViewProxy handleRequestsWithHost:@"www.google.com" path:@"/images/srpr/logo3w.png" handler:^(NSURLRequest* req, WVPResponse *res) {
//		[NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:req.URL] queue:queue completionHandler:^(NSURLResponse *netRes, NSData *data, NSError *netErr) {
//			if (netErr || ((NSHTTPURLResponse*)netRes).statusCode >= 400) { return [res respondWithError:500 text:@":("]; }
//			[res respondWithData:data mimeType:@"image/png"];
//		}];
//	}];
//	[WebViewProxy handleRequestsWithHost:@"192.168.1.137" handler:^(NSURLRequest* req, WVPResponse *res) {
//		NSLog(@"???");
//    [res respondWithText:@"Hi!"];
//	}];
	[WebViewProxy handleRequestsWithHost:@"192.168.1.137" path:@"/build/css/main.css" handler:^(NSURLRequest* req, WVPResponse *res) {
//		NSString* filePath = [[NSBundle mainBundle] pathForResource:@"/build/css/main" ofType:@"css"];
//		NSString* mainCSS = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
		
		if ( self.isReachable ) {
			[NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:req.URL] queue:queue completionHandler:^(NSURLResponse *netRes, NSData *data, NSError *netErr) {
				if (netErr || ((NSHTTPURLResponse*)netRes).statusCode >= 400) { return [res respondWithError:500 text:@":("]; }
				NSLog(@"responding from server");
				[res respondWithData:data mimeType:@"text/css"];
			}];
		} else {
			[message show];
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *documentsDirectory = [paths objectAtIndex:0];
			NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"main.css"];
			NSString *mainCSS = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
			
			NSData* data = [mainCSS dataUsingEncoding:NSUTF8StringEncoding];
			NSLog(@"responding with data");
			[res respondWithData:data mimeType:@"text/css"];
		}
		
	}];
	
//	[WebViewProxy handleRequestsWithHost:@"example.proxy" handler:^(NSURLRequest *req, WVPResponse *res) {
//		NSString* proxyUrl = [req.URL.absoluteString stringByReplacingOccurrencesOfString:@"example.proxy" withString:@"example.com"];
//		NSURLRequest* proxyReq = [NSURLRequest requestWithURL:[NSURL URLWithString:proxyUrl]];
//		[NSURLConnection connectionWithRequest:proxyReq delegate:res];
//	}];
}

- (BOOL) prefersStatusBarHidden {
	return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
