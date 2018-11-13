//
//  CustomIconList.h
//  Strongbox
//
//  Created by Mark on 11/11/2018.
//  Copyright © 2018 Mark McGuill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseXmlDomainObjectHandler.h"
#import "CustomIcon.h"

NS_ASSUME_NONNULL_BEGIN

@interface CustomIconList : BaseXmlDomainObjectHandler

- (instancetype)initWithContext:(XmlProcessingContext*)context;

@property NSMutableArray<CustomIcon*>* icons;

@end

NS_ASSUME_NONNULL_END
