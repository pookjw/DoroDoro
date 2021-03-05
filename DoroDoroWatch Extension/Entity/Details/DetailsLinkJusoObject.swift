//
//  DetailsLinkJusoObject.swift
//  DoroDoroWatch Extension
//
//  Created by Jinwoo Kim on 3/6/21.
//

import WatchKit

internal final class DetailsLinkJusoObject: NSObject {
    @IBOutlet weak var primaryLabel: WKInterfaceLabel!
    @IBOutlet weak var secondaryLabel: WKInterfaceLabel!
    
    internal func configure(data: AddrLinkJusoData, idx: DetailsLinkJusoIndex?) {
        switch idx {
        case .roadAddr:
            setLabelsText(primary: "전체 도로명주소", secondary: wrappedNoData(data.roadAddr))
        case .roadAddrPart1:
            setLabelsText(primary: "도로명주소", secondary: wrappedNoData(data.roadAddrPart1))
        case .roadAddrPart2:
            setLabelsText(primary: "도로명주소 참고항목", secondary: wrappedNoData(data.roadAddrPart2))
        case .jibunAddr:
            setLabelsText(primary: "지번주소", secondary: wrappedNoData(data.jibunAddr))
        case .zipNo:
            setLabelsText(primary: "우편번호", secondary: wrappedNoData(data.zipNo))
        case .admCd:
            setLabelsText(primary: "행정구역코드", secondary: wrappedNoData(data.admCd))
        case .rnMgtSn:
            setLabelsText(primary: "도로명코드", secondary: wrappedNoData(data.rnMgtSn))
        case .bdMgtSn:
            setLabelsText(primary: "건물관리번호", secondary: wrappedNoData(data.bdMgtSn))
        case .detBdNmList:
            setLabelsText(primary: "상세건물명", secondary: wrappedNoData(data.detBdNmList))
        case .bdNm:
            setLabelsText(primary: "건물명", secondary: wrappedNoData(data.bdNm))
        case .bdKdcd:
            setLabelsText(primary: "공동주택여부", secondary: wrappedBdKdcd(data.bdKdcd))
        case .siNm:
            setLabelsText(primary: "시도명", secondary: wrappedNoData(data.siNm))
        case .sggNm:
            setLabelsText(primary: "시군구명", secondary: wrappedNoData(data.sggNm))
        case .emdNm:
            setLabelsText(primary: "읍면동명", secondary: wrappedNoData(data.emdNm))
        case .liNm:
            setLabelsText(primary: "법정리명", secondary: wrappedNoData(data.liNm))
        case .rn:
            setLabelsText(primary: "도로명", secondary: wrappedNoData(data.rn))
        case .udrtYn:
            setLabelsText(primary: "지하여부", secondary: wrappedUdrtYn(data.udrtYn))
        case .buldMnnm:
            setLabelsText(primary: "건물본번", secondary: wrappedNoData(data.buldMnnm))
        case .buldSlno:
            setLabelsText(primary: "건물부번", secondary: wrappedNoData(data.buldSlno))
        case .mtYn:
            setLabelsText(primary: "산여부", secondary: wrappedMtYn(data.mtYn))
        case .lnbrMnnm:
            setLabelsText(primary: "지번본번(번지)", secondary: wrappedNoData(data.lnbrMnnm))
        case .lnbrSlno:
            setLabelsText(primary: "지번부번(호)", secondary: wrappedNoData(data.lnbrSlno))
        case .emdNo:
            setLabelsText(primary: "읍면동일련번호", secondary: wrappedNoData(data.emdNo))
        case .relJibun:
            setLabelsText(primary: "관련지번", secondary: wrappedNoData(data.relJibun))
        case .hemdNm:
            setLabelsText(primary: "관할주민센터(참고정보)", secondary: wrappedNoData(data.hemdNm))
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
