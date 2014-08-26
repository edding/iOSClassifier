//
//  DJRSocket.m
//  Intern2
//
//  Created by JIARUI DING on 8/11/14.
//  Copyright (c) 2014 JIARUI DING. All rights reserved.
//

#import "DJRSocket.h"

@implementation DJRSocket

//
//Setup Socket Connection
//
- (NSInteger)setupConnection:(NSString*)ipAddr{
    
    client_addr.sin_family = AF_INET;
    client_addr.sin_addr.s_addr = htons(INADDR_ANY); // INADDR_ANY is used to get local ip
    client_addr.sin_port = htons(0);
    
    // Socket based on TCP
    client_socket = socket(AF_INET, SOCK_STREAM, 0);
    if (client_socket < 0){
        NSLog(@"Create socket failed");
        return (-1);
    }
    
    // Binding socket with address
    if (bind(client_socket, (struct sockaddr*)&client_addr, sizeof(client_addr))) {
        NSLog(@"Client Bind Port Failed");
        return (-1);
    }
    
    // Set a structure to save ip address and port
    server_addr.sin_family = AF_INET;
    if (inet_aton([ipAddr UTF8String], &server_addr.sin_addr) == 0) {
        NSLog(@"Invalid IP address");
        return (-2);
    }
    server_addr.sin_port = htons(HELLO_WORLD_SERVER_PORT);
    socklen_t server_addr_length = sizeof(server_addr);
    
    // Set the socket as non-blocking mode
    // So that can set the timeout from sys defined 75s to 5s
    unsigned long ul = 1;
    ioctl(client_socket, FIONBIO, &ul); // Set Non-blocking
    
    // Send Connect request
    if (connect(client_socket, (struct sockaddr*)&server_addr, server_addr_length) < 0) {
        struct timeval tm;
        tm.tv_sec = TIME_OUT;
        tm.tv_usec = 0;
        
        fd_set set;
        FD_ZERO(&set);
        FD_SET(client_socket, &set);
        
        if (select(client_socket + 1, NULL, &set, NULL, &tm) > 0) {
            int error = -1;
            int len = sizeof(int);
            getsockopt(client_socket, SOL_SOCKET, SO_ERROR, &error, (socklen_t *)&len);
            if (error == 0) {
                ul = 0;
                ioctl(client_socket, FIONBIO, &ul);
                return 0;
            } else {
                NSLog(@"Connect error in time out block");
                return -1;
            }
        } else {
            NSLog(@"Connect timeout");
            return -1;
        }
        
        
        NSLog(@"Connect to the server failed");
        return (-1);
    }
    ul = 0;
    ioctl(client_socket, FIONBIO, &ul);
    return 0;
}

-(void)releaseConnection {
    close(client_socket);
}

-(ssize_t)send:(char *)buf{
    return (send(client_socket, buf, BUFFER_SIZE, 0));
}

-(size_t)recv:(char *)buf{
    return (recv(client_socket, buf, BUFFER_SIZE, 0));
}

-(size_t)send:(char *)buf withSize:(int)size {
    return (send(client_socket, buf, size, 0));
}

@end
