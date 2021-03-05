//
//  DetailsEngJusoObject.swift
//  DoroDoroWatch Extension
//
//  Created by Jinwoo Kim on 3/6/21.
//

import WatchKit
import DoroDoroWatchAPI

final internal class DetailsEngJusoObject: NSObject {
    @IBOutlet weak var primaryLabel: WKInterfaceLabel!
    @IBOutlet weak var secondaryLabel: WKInterfaceLabel!
    
    internal func configure(data engJusoData: AddrEngJusoData, idx: DetailsEngJusoIndex?) {
        switch idx {
        case .roadAddr:
            setLabelsText(primary: "영문 도로명주소", secondary: wrappedNoData(engJusoData.roadAddr))
        case .jibunAddr:
            setLabelsText(primary: "영문 지번주소", secondary: wrappedNoData(engJusoData.jibunAddr))
        case .siNm:
            setLabelsText(primary: "영문 시도명", secondary: wrappedNoData(engJusoData.siNm))
        case .sggNm:
            setLabelsText(primary: "영문 시군구명", secondary: wrappedNoData(engJusoData.sggNm))
        case .emdNm:
            setLabelsText(primary: "영문 읍면동명", secondary: wrappedNoData(engJusoData.emdNm))
        case .liNm:
            setLabelsText(primary: "영문 법정리명", secondary: wrappedNoData(engJusoData.liNm))
        case .rn:
            setLabelsText(primary:  "영문 도로명", secondary: wrappedNoData(engJusoData.rn))
        default:
            setLabelsText(primary: nil, secondary: nil)
        }
    }
    
    private func setLabelsText(primary primaryText: String?, secondary secondaryText: String?) {
        primaryLabel.setText(primaryText)
        secondaryLabel.setText(secondaryText)
    }
    
    private func wrappedNoData(_ text: String?) -> String {
        guard let text: String = text else {
            return Localizable.NO_DATA.string
        }
        return text.isEmpty ? Localizable.NO_DATA.string : text
    }
    
    private func wrappedBdKdcd(_ bdKdcd: String?) -> String {
        guard let bdKdcd: String = bdKdcd else {
            return Localizable.NO_DATA.string
        }
        return (bdKdcd == "0") ? "비공동주택" : "공동주택"
    }
    
    private func wrappedUdrtYn(_ udrtYn: String?) -> String {
        guard let udrtYn: String = udrtYn else {
            return Localizable.NO_DATA.string
        }
        return (udrtYn == "0") ? "지상" : "지하"
    }
    
    private func wrappedMtYn(_ mtYn: String?) -> String {
        guard let mtYn: String = mtYn else {
            return Localizable.NO_DATA.string
        }
        return (mtYn == "0") ? "대지" : "산"
    }
}
