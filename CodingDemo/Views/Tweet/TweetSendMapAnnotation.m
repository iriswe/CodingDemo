//
//  TweetSendMapAnnotation.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/29.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "TweetSendMapAnnotation.h"

@implementation TweetSendMapAnnotation
- (id)initWithTitle:(NSString *)atitle andCoordinate:(CLLocationCoordinate2D)location
{
    if(self=[super init])
    {
        _title = atitle;
        _coordinate = location;
    }
    return self;
}

- (id) initWithTitle:(NSString *)atitle latitue:(float)alatitude longitude:(float)alongitude
{
    if(self=[super init])
    {
        _title = atitle;
        _coordinate.latitude = alatitude;
        _coordinate.longitude = alongitude;
    }
    return self;
}


@end
