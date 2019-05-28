//
//  EVDataQueue.m
//  EVBarrageDemo
//
//  Created by Ever on 2019/5/24.
//  Copyright © 2019 Ever. All rights reserved.
//

#import "EVDataQueue.h"

struct EVQueueNode {
    void *value;
    struct EVQueueNode *next; 
} ;

static const dispatch_time_t EV_QUEUE_TIME_OUT = 0.5; //信号量超时时间(单位：s)

@interface EVDataQueue ()
{
    struct EVQueueNode * _front; //指向对首
    struct EVQueueNode * _rear; //指向对尾
    
    int _size; //当前已使用容量
    int _maxCapacity; //当前队列最大容量
    
    dispatch_semaphore_t _semaphore; //信号量，用来保证线程安全
}

@end

@implementation EVDataQueue

- (instancetype)initWithMaxCapacity:(int)maxCapacity {
    self = [super init];
    if (self) {
        _front = NULL;
        _rear = NULL;
        
        _size = 0;
        _maxCapacity = maxCapacity;
        
        _semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

- (BOOL)isEmpty {
    if (_size <= 0) {
        return YES;
    }
    return NO;
}

- (BOOL)isFull {
    if (_size >= _maxCapacity) {
        return YES;
    }
    return NO;
}

- (BOOL)enqueue:(id)obj {
    dispatch_semaphore_wait(_semaphore, EV_QUEUE_TIME_OUT);
    
    if ([self isFull]) {
        dispatch_semaphore_signal(_semaphore);
        return NO;
    }
    
    struct EVQueueNode *node = calloc(1, sizeof(struct EVQueueNode));
    node -> value = (__bridge_retained void *)obj;
    node -> next = NULL;
    
    if (_front == NULL) {
        _front = node;
    }
    
    if (_rear == NULL) {
        _rear = node;
    } else {
        _rear -> next = node;
        _rear = node;
    }
    
    _size++;
    
    dispatch_semaphore_signal(_semaphore);
    
    return YES;
}

- (id)dequeue {
    dispatch_semaphore_wait(_semaphore, EV_QUEUE_TIME_OUT);
    
    if ([self isEmpty]) {
        _front = NULL;
        _rear = NULL;
        dispatch_semaphore_signal(_semaphore);
        return nil;
    }
    
    id obj = (__bridge_transfer id)(_front -> value);
    struct EVQueueNode *next = _front -> next;
    free(_front);
    _front = next;
    
    _size--;
    
    dispatch_semaphore_signal(_semaphore);

    return obj;
}

- (int)size {
    return _size;
}

- (void)freeAll {
    dispatch_semaphore_wait(_semaphore, EV_QUEUE_TIME_OUT);
    
    while (_front != NULL) {
        CFRelease(_front -> value);
        void *tmp = _front;
        _front = _front -> next;
        free(tmp);
    }
    
    dispatch_semaphore_signal(_semaphore);
}

- (void)dealloc {
    [self freeAll];
}

@end
