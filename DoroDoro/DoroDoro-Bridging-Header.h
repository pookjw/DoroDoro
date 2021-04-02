//
//  DoroDoro-Bridging-Header.h
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

#ifndef DoroDoro_Bridging_Header_h
#define DoroDoro_Bridging_Header_h

#include <TargetConditionals.h>
#if (TARGET_OS_IOS && __arm64__ && (!TARGET_OS_SIMULATOR) && (!TARGET_OS_UIKITFORMAC)) || (TARGET_OS_SIMULATOR && (__x86_64__))
#import <DaumMap/MTMapView.h>
#endif

#endif /* DoroDoro_Bridging_Header_h */

/*
 iOS (arm64) - O
 iOS (x86_64) - X
 iOS + Simulator (arm64) - X
 iOS + Simulator (x86_64) - O
 Catalyst (arm64) - X
 Catalyst (x86_64) - X
 */
