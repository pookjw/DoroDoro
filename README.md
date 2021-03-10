# DoroDoro

iOS/macOS/watchOS용 도로명 및 영문주소 검색 어플

## API Key

[gitignore](.gitignore)에 적혀 있다시피 API Key가 담긴 `Keys.swift` 파일은 Git에 업로드되지 않습니다. 따라서 아래와 같은 `Keys.swift` 파일을 [DoroDoroAPICommon](DoroDoroAPICommon)에 생성해 주셔야 하고, [DoroDoro/Info.plist](DoroDoro/Info.plist)에 본인의 `KAKAO_APP_KEY`를 써주셔야 합니다.

```swift
import Foundation

/// 도로명주소 API Keys
internal struct AddrAPIKeys {
    /// 도로명주소 API
    static internal let linkAPIKey: String = "<API_KEY>"
    
    /// 영문주소 API
    static internal let engAPIKey: String = "<API_KEY>"
    
    /// 좌표제공 API
    static internal let coordAPIKey: String = "<API_KEY>"
}

/// 카카오 API Keys
internal struct KakaoAPIKeys {
    /// 네이티브 앱 키
    static internal let nativeAppKey: String = "<API_KEY>"
    
    /// REST API 키
    static internal let restAPIKey: String = "<API_KEY>"
    
    /// JavaScript 키
    static internal let javascriptKey: String = "<API_KEY>"
}
```

API Key 발급은 [도로명주소 개발자센터](https://www.juso.go.kr/addrlink/main.do?cPath=99MM)와 [Kakao Developers](https://developers.kakao.com)에서 하실 수 있습니다.

## 에러 해결

### AcknowList-AcknowListBundle 인증 문제

![](images/1.png)

```
Signing for "AcknowList-AcknowListBundle" requires a development team. Select a development team in the Signing & Capabilities editor.
```

`AcknowList-AcknowListBundle`에서 Apple Developer 계정 선택해주면 됩니다.
