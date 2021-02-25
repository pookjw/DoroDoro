# DoroDoro

iOS/macOS/tvOS/watchOS용 도로명 및 영문주소 검색 어플

## API Key

[gitignore](.gitignore)에 적혀 있다시피 API Key가 담긴 `Keys.swift` 파일은 Git에 업로드되지 않습니다. 따라서 아래와 같은 `Keys.swift` 파일을 [DoroDoro/Models/API](DoroDoro/Models/API)에 생성해 주셔야 합니다.

```swift
import Foundation

/// API Keys
public struct Keys {
    /// 도로명주소 API
    static public let addrLinkApiKey: String = "<API_KEY>"
    
    /// 영문주소 API
    static public let addrEngApiKey: String = "<API_KEY>"
    
    /// 좌표제공 API
    static public let addrCoordApiKey: String = "<API_KEY>"
}

```

API Key 발급은 [도로명주소 개발자센터](https://www.juso.go.kr/addrlink/main.do?cPath=99MM)에서 하실 수 있습니다.

