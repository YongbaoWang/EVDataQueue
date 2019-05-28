//
//  EVDataQueue.h
//  EVBarrageDemo
//
//  Created by Ever on 2019/5/24.
//  Copyright © 2019 Ever. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 使用单链表实现的一个队列；
 在 内存占用、入队耗时、出队耗时、线程安全 等方面，有较好性能；
 
 与其他方案相比较：
 1，使用数组 NSMutableArray，如果出队后，不移除对象，即实现为 循环队列的方式，则 入队出队性能较好，但内存占用较高（因为所有的对象，都在数组中保存，出队后，并没有实际移除）；
 2，使用数组 NSMutableArray，如果出队后，移除对象，则内存占用较少，但入队出队性能特别差（因为数组特性：移除某个元素后，其后面的所有元素，都需要前移）；
 3，使用弱引用数组 NSPointerArray，当对象移除后，内存自动释放；但是 NSPointerArray 的添加元素、移除元素 方法，性能较差； 且因为是弱引用对象，还需要借助其他方式，来持有对象（如果队列不持有对象，则入队后，对象就立即释放掉了）；
 4，使用二级指针的形式，来保存所有对象的指针，该方案入队出队性能较好，但需要单独编码，来实现队列内存的扩容、缩容；出队后，及时手动释放内存；不然同样存在内存占用过高的问题；与单链表实现相比，二级指针的方式入队出队性能稍微优越一点，但考虑到内存占用问题，还需要更多的编码来实现内存管理，且因为内存管理带来的性能损耗，故 单链表的实现方式 更优；
     //    void **arr = calloc(100, sizeof(void *));
     //    id obj = @"";
     //    void *p = (__bridge void *)(obj);
     //    arr[0] = p;
 */
@interface EVDataQueue<ElementType> : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 默认初始化方法

 @param maxCapacity 队列最大容量（超出最大容量后，入队 会返回失败）
 @return 实例
 */
- (instancetype)initWithMaxCapacity:(int)maxCapacity NS_DESIGNATED_INITIALIZER;

/**
 入队

 @param obj 入队对象
 @return 入队是否成功（目前：只有队列打到最大容量时，会导致入队失败）
 */
- (BOOL)enqueue:(ElementType)obj;

/**
 出队

 @return 出队对象
 */
- (ElementType)dequeue;

/**
 队列是否为空

 @return 是否为空
 */
- (BOOL)isEmpty;

/**
 队列是否已达到最大容量

 @return 是否已满
 */
- (BOOL)isFull;

/**
 当前队列中的对象个数

 @return 对象个数
 */
- (int)size;

/**
 释放整个队列
 */
- (void)freeAll;

@end

