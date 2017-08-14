//
//  QueryTaskResult.h
//  Let
//
//  Created by yzm on 16/5/17.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "BLBaseResult.h"

/**
 *  定时任务信息
 */
@interface BLTimerInfo : NSObject
/**
 *  位标
 */
@property (nonatomic, assign, getter=getIndex) NSUInteger index;

/**
 *  使能标志
 */
@property (nonatomic, assign, getter=isEnable) Boolean enable;

/**
 *  年
 */
@property (nonatomic, assign, getter=getYear) NSUInteger year;

/**
 *  月
 */
@property (nonatomic, assign, getter=getMonth) NSUInteger month;

/**
 *  日
 */
@property (nonatomic, assign, getter=getDay) NSUInteger day;

/**
 *  时
 */
@property (nonatomic, assign, getter=getHour) NSUInteger hour;

/**
 *  分
 */
@property (nonatomic, assign, getter=getMinute) NSUInteger minute;

/**
 *  秒
 */
@property (nonatomic, assign, getter=getSeconds) NSUInteger seconds;

@end


/**
 *  周期任务信息
 */
@interface BLPeriodInfo : NSObject

/**
 *  位标
 */
@property (nonatomic, assign, getter=getIndex) NSUInteger index;

/**
 *  使能标志
 */
@property (nonatomic, assign, getter=isEnable) Boolean enable;

/**
 *  时
 */
@property (nonatomic, assign, getter=getHour) NSUInteger hour;

/**
 *  分
 */
@property (nonatomic, assign, getter=getMinute) NSUInteger minute;

/**
 *  秒
 */
@property (nonatomic, assign, getter=getSeconds) NSUInteger seconds;

/**
 *  Week repeat list. 1:Monday 2:Tuesday 3:Wednesday 4:Thursday 5:Friday 6:Saturday 7:Sunday
 */
@property (nonatomic, strong, getter=getRepeat) NSArray<NSNumber *> *repeat;

@end


/**
 Query Task Result
 */
@interface BLQueryTaskResult : BLBaseResult

/**
 Timer task list
 */
@property (nonatomic, strong, getter=getTimer) NSArray<BLTimerInfo *> *timer;

/**
 Period task list
 */
@property (nonatomic, strong, getter=getPeriod) NSArray<BLPeriodInfo *> *period;

@end
