//
//  DetailsEngJusoObject.swift
//  DoroDoroWatch Extension
//
//  Created by Jinwoo Kim on 3/6/21.
//

import WatchKit
import DoroDoroWatchAPI

internal final class DetailsEngJusoObject: NSObject {
    @IBOutlet weak var primaryLabel: WKInterfaceLabel!
    @IBOutlet weak var secondaryLabel: WKInterfaceLabel!
    
    internal func configure(data engJusoData: AddrEngJusoData, idx: DetailsEngJusoIndex?) {
        switch idx {
        case .roadAddr:
            setLabelsText(primary: "영문 도로명주소", secondary: engJusoData.roadAddr.wrappedNoData())
        case .jibunAddr:
            setLabelsText(primary: "영문 지번주소", secondary: engJusoData.jibunAddr.wrappedNoData())
        case .siNm:
            setLabelsText(primary: "영문 시도명", secondary: engJusoData.siNm.wrappedNoData())
        case .sggNm:
            setLabelsText(primary: "영문 시군구명", secondary: engJusoData.sggNm.wrappedNoData())
        case .emdNm:
            setLabelsText(primary: "영문 읍면동명", secondary: engJusoData.emdNm.wrappedNoData())
        case .liNm:
            setLabelsText(primary: "영문 법정리명", secondary: engJusoData.liNm.wrappedNoData())
        case .rn:
            setLabelsText(primary:  "영문 도로명", secondary: engJusoData.rn.wrappedNoData())
        default:
            setLabelsText(primary: nil, secondary: nil)
        }
    }
    
    private func setLabelsText(primary primaryText: String?, secondary secondaryText: String?) {
        primaryLabel.setText(primaryText)
        secondaryLabel.setText(secondaryText)
    }
}
