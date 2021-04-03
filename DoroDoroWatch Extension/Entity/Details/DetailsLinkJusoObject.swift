//
//  DetailsLinkJusoObject.swift
//  DoroDoroWatch Extension
//
//  Created by Jinwoo Kim on 3/6/21.
//

import WatchKit
import DoroDoroWatchAPI

internal final class DetailsLinkJusoObject: NSObject {
    @IBOutlet weak var primaryLabel: WKInterfaceLabel!
    @IBOutlet weak var secondaryLabel: WKInterfaceLabel!
    
    internal func configure(data: AddrLinkJusoData, idx: DetailsLinkJusoIndex?) {
        switch idx {
        case .roadAddr:
            setLabelsText(primary: "전체 도로명주소", secondary: data.roadAddr.wrappedNoData())
        case .roadAddrPart1:
            setLabelsText(primary: "도로명주소", secondary: data.roadAddrPart1.wrappedNoData())
        case .roadAddrPart2:
            setLabelsText(primary: "도로명주소 참고항목", secondary: data.roadAddrPart2.wrappedNoData())
        case .jibunAddr:
            setLabelsText(primary: "지번주소", secondary: data.jibunAddr.wrappedNoData())
        case .zipNo:
            setLabelsText(primary: "우편번호", secondary: data.zipNo.wrappedNoData())
        case .admCd:
            setLabelsText(primary: "행정구역코드", secondary: data.admCd.wrappedNoData())
        case .rnMgtSn:
            setLabelsText(primary: "도로명코드", secondary: data.rnMgtSn.wrappedNoData())
        case .bdMgtSn:
            setLabelsText(primary: "건물관리번호", secondary: data.bdMgtSn.wrappedNoData())
        case .detBdNmList:
            setLabelsText(primary: "상세건물명", secondary: data.detBdNmList.wrappedNoData())
        case .bdNm:
            setLabelsText(primary: "건물명", secondary: data.bdNm.wrappedNoData())
        case .bdKdcd:
            setLabelsText(primary: "공동주택여부", secondary: data.bdKdcd.wrappedBdKdcd())
        case .siNm:
            setLabelsText(primary: "시도명", secondary: data.siNm.wrappedNoData())
        case .sggNm:
            setLabelsText(primary: "시군구명", secondary: data.sggNm.wrappedNoData())
        case .emdNm:
            setLabelsText(primary: "읍면동명", secondary: data.emdNm.wrappedNoData())
        case .liNm:
            setLabelsText(primary: "법정리명", secondary: data.liNm.wrappedNoData())
        case .rn:
            setLabelsText(primary: "도로명", secondary: data.rn.wrappedNoData())
        case .udrtYn:
            setLabelsText(primary: "지하여부", secondary: data.udrtYn.wrappedUdrtYn())
        case .buldMnnm:
            setLabelsText(primary: "건물본번", secondary: data.buldMnnm.wrappedNoData())
        case .buldSlno:
            setLabelsText(primary: "건물부번", secondary: data.buldSlno.wrappedNoData())
        case .mtYn:
            setLabelsText(primary: "산여부", secondary: data.mtYn.wrappedMtYn())
        case .lnbrMnnm:
            setLabelsText(primary: "지번본번(번지)", secondary: data.lnbrMnnm.wrappedNoData())
        case .lnbrSlno:
            setLabelsText(primary: "지번부번(호)", secondary: data.lnbrSlno.wrappedNoData())
        case .emdNo:
            setLabelsText(primary: "읍면동일련번호", secondary: data.emdNo.wrappedNoData())
        case .relJibun:
            setLabelsText(primary: "관련지번", secondary: data.relJibun.wrappedNoData())
        case .hemdNm:
            setLabelsText(primary: "관할주민센터(참고정보)", secondary: data.hemdNm.wrappedNoData())
        default:
            setLabelsText(primary: nil, secondary: nil)
        }
    }
    
    private func setLabelsText(primary primaryText: String?, secondary secondaryText: String?) {
        primaryLabel.setText(primaryText)
        secondaryLabel.setText(secondaryText)
    }
}
