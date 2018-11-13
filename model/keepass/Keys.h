//
//  Keys.h
//  Strongbox
//
//  Created by Mark on 05/11/2018.
//  Copyright © 2018 Mark McGuill. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Keys : NSObject

@property NSData* compositeKey;
@property NSData* transformKey;
@property NSData* masterKey;
@property NSData *hmacKey;

@end

NS_ASSUME_NONNULL_END
