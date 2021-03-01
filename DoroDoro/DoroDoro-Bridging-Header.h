//
//  DoroDoro-Bridging-Header.h
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

#ifndef DoroDoro_Bridging_Header_h
#define DoroDoro_Bridging_Header_h

#include <TargetConditionals.h>

#if __arm64__ || TARGET_OS_SIMULATOR
#import <DaumMap/MTMapView.h>
#import <DaumMap/MTMapPOIItem.h>
#endif

#endif /* DoroDoro_Bridging_Header_h */
