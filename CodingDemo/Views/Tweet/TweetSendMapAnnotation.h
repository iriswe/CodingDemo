//
//  TweetSendMapAnnotation.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/29.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface TweetSendMapAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title; //title值
@property (nonatomic, copy) NSString *subtitle;
- (id)initWithTitle:(NSString *)atitle latitue:(float)alatitude longitude:(float)alongitude;
- (id)initWithTitle:(NSString *)atitle andCoordinate:(CLLocationCoordinate2D)location;

@end

