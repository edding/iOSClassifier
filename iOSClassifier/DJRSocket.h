//
//  DJRSocket.h
//  Intern2
//
//  Created by JIARUI DING on 8/11/14.
//  Copyright (c) 2014 JIARUI DING. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <netinet/in.h>
#import <sys/socket.h>
#import <sys/types.h>
#import <arpa/inet.h>
#import <sys/ioctl.h>

#define BUFFER_SIZE                  8192
//  BUFFER_SIZE indicate the size of a socket buffer

//  Here you can modify the settings on you own
#define IP_ADDR                      "159.226.179.239"
#define HELLO_WORLD_SERVER_PORT      10000
#define TIME_OUT                     5

//
//  DJRSocket Class
@interface DJRSocket : NSObject {
    struct sockaddr_in client_addr;
    struct sockaddr_in  server_addr;
    int client_socket;
}

//
// Setup and Release connection
- (NSInteger)setupConnection:(NSString*)ipAddr;
- (void)releaseConnection;

//
//  Send and receive
//  Returen value are the actual number of bytes been put on / get from
//  socket.
- (ssize_t)send:(char *)buf;
- (size_t)recv:(char *)buf;
- (size_t)send:(char *)buf withSize:(int)size;

@end