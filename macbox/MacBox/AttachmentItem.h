//
//  AttachmentItem.h
//  Strongbox
//
//  Created by Mark on 15/11/2018.
//  Copyright © 2018 Mark McGuill. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface AttachmentItem : NSCollectionViewItem

@property (weak) IBOutlet NSTextField *labelFileSize;

@end

NS_ASSUME_NONNULL_END
