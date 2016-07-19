//
//  ImageMetaData.h
//  AirMap
//
//  Created by juhyun seo on 2016. 7. 14..
//  Copyright © 2016년 FCSProjectAirMap. All rights reserved.
//

#import <Realm/Realm.h>

@interface ImageData : RLMObject

@property NSString *creation_date;
@property float latitude;
@property float longitude;
@property float timestamp;
@property NSDate *timezone_date;
@property NSString *country;
@property NSString *city;
@property NSString *thumbnail_url;
@property NSString *image_url;
@property NSData *image;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<ImageData>
RLM_ARRAY_TYPE(ImageData)