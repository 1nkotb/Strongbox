//
//  KeePassXmlModelAdaptor.h
//  Strongbox-iOS
//
//  Created by Mark on 16/10/2018.
//  Copyright © 2018 Mark McGuill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"
#import "SerializationData.h"
#import "KeePassGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface XmlStrongboxNodeModelAdaptor : NSObject

- (nullable KeePassGroup*)fromModel:(Node*)rootNode error:(NSError**)error;
- (nullable Node*)toModel:(nullable KeePassGroup*)existingXmlRoot error:(NSError**)error;

@end

NS_ASSUME_NONNULL_END
