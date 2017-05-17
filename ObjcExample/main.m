//
// Copyright (c) 2016 deltaDNA Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[])
{
    //
    // http://stackoverflow.com/questions/15714697/unit-testing-in-xcode-does-it-run-the-app
    // Allows tests to run without starting the app, but links against app to get all the code
    //
    
    @autoreleasepool {
        BOOL runningTests = NSClassFromString(@"XCTestCase") != nil;
        if(!runningTests)
        {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
        else
        {
            return UIApplicationMain(argc, argv, nil, @"TestAppDelegate");
        }
    }
}

