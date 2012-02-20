//
//  ViewController.h
//  Tegakiloid
//
//  Created by  on 12/02/10.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
	int sock;
	struct sockaddr_in addr;
	
}

- (void)openSocket;

- (void)closeSocket;

@end
