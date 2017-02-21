//
//  RemoteAnalysisFilter.h
//  Push the image to a remote server for analysis
//
//  Created by davidcox 2017-02-19
//  Copyright (c) 2017 DeepHealth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OsiriXAPI/PluginFilter.h"

@interface RemoteAnalysisFilter : PluginFilter {

}

- (long) filterImage:(NSString*) menuName;

@end
