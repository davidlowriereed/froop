//
//  FindDevicePtSize.swift
//  FroopProof
//
//  Created by David Reed on 9/28/23.
//

import UIKit



func determineScreenSizeCategory() -> ScreenSizeCategory {
    let screenSize = UIScreen.main.bounds.size
    let width = screenSize.width
    let height = screenSize.height
    
    switch (width, height) {
    case (430, 932): return .size430x932
    case (428, 926): return .size428x926
    case (414, 896): return .size414x896
    case (393, 852): return .size393x852
    case (390, 844): return .size390x844
    case (375, 812): return .size375x812
    default: return .unknown
    }
}

//MARK: Reference Sizes by Model supported
//iPhone 15 Pro Max         430x932 pt (1290x2796 px @3x)x
//iPhone 15 Plus            430x932 pt (1290x2796 px @3x)x
//iPhone 14 Pro Max         430x932 pt (1290x2796 px @3x)x
//iPhone 14 Plus            428x926 pt (1284x2778 px @3x)x
//iPhone 13 Pro Max         428x926 pt (1284x2778 px @3x)x
//iPhone 12 Pro Max         428x926 pt (1284x2778 px @3x)x
//iPhone 11                 414x896 pt (828x1792 px @2x)x
//iPhone XR                 414x896 pt (828x1792 px @2x)x
//iPhone 11 Pro Max         414x896 pt (1242x2688 px @3x)x
//iPhone XS Max             414x896 pt (1242x2688 px @3x)x
//iPhone 15 Pro             393x852 pt (1179x2556 px @3x)x
//iPhone 15                 393x852 pt (1179x2556 px @3x)x
//iPhone 14 Pro             393x852 pt (1179x2556 px @3x)x
//iPhone 14                 390x844 pt (1170x2532 px @3x)x
//iPhone 13 Pro             390x844 pt (1170x2532 px @3x)x
//iPhone 13                 390x844 pt (1170x2532 px @3x)x
//iPhone 12 Pro             390x844 pt (1170x2532 px @3x)x
//iPhone 12                 390x844 pt (1170x2532 px @3x)x
//iPhone 13 mini            375x812 pt (1125x2436 px @3x)x
//iPhone 12 mini            375x812 pt (1125x2436 px @3x)x
//iPhone 11 Pro             375x812 pt (1125x2436 px @3x)x
//iPhone XS                 375x812 pt (1125x2436 px @3x)x
//iPhone X                  375x812 pt (1125x2436 px @3x)x
