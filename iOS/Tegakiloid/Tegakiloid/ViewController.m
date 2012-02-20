//
//  ViewController.m
//  Tegakiloid
//
//  Created by  on 12/02/10.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSArray *objects = [NSArray arrayWithObjects:@"127.0.0.1", @"3939", nil];
		NSArray *keys = [NSArray arrayWithObjects:@"ipaddr_preference", @"port_preference", nil];
		NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
		[defaults registerDefaults:dict];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}

#pragma mark - Socket Controller

- (void)openSocket
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *ipaddr = [defaults stringForKey:@"ipaddr_preference"];
	NSString *port = [defaults stringForKey:@"port_preference"];
	
	NSLog(@"IP Address = %@", ipaddr);
	NSLog(@"Port = %@", port);
	
	if(ipaddr == nil || port == nil)
	{
		// エラーログ出す
	}
	else if([ipaddr isEqualToString:@"127.0.0.1"])
	{
		NSLog(@"設定を見直して下さい。");
	}
	else
	{
		sock = socket(AF_INET, SOCK_DGRAM, 0);
		addr.sin_family = AF_INET;
		addr.sin_addr.s_addr = inet_addr([ipaddr UTF8String]);
		addr.sin_port = htons([port intValue]);
	}
}

- (void)closeSocket
{
	if(0 != sock) {
		NSLog(@"close(sock)");
		close(sock);
	}
}

#pragma mark - Touches Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// タッチ開始時に表示サイズを通知すればいいのでは？
	[self openSocket];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint point = [[touches anyObject] locationInView:self.view];
	
	NSString *str = [NSString stringWithFormat:@"%lf %lf", point.x, point.y];
	char *message = (char *)[str UTF8String];
	int length = str.length;
	sendto(sock, message, length, 0, (struct sockaddr *)&addr, sizeof(addr));
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self closeSocket];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self closeSocket];
}

#pragma mark - Shake Motion

// シェイクモーション検出の為にファーストレスポンダになる必要がある。
- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
	[self openSocket];
	NSString *str = @"end";
	char *message = (char *)[str UTF8String];
	int length = str.length;
	sendto(sock, message, length, 0, (struct sockaddr *)&addr, sizeof(addr));
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
	[self closeSocket];
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
	[self closeSocket];
}

@end
