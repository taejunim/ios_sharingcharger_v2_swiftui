//
//  Extension.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/09.
//

//MARK: - String Extention
extension String {
    //MARK: - 텍스트 라벨 출력
    /// - Localizable.strings -  "String".localized()
    /// - Parameters:
    ///   - bundle: Bundle = .main
    ///   - tableName: Localizable.strings
    /// - Returns: Text String
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }
    
    //MARK: - 메시지 출력
    /// - Message.strings - "String".message()
    /// - Parameters:
    ///   - bundle: Bundle = .main
    ///   - tableName: Message.strings
    /// - Returns: Text String
    func message(bundle: Bundle = .main, tableName: String = "Message") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }
    
    //MARK: - Date(일자) 형식을 String 형식 일자로 변경
    /// 일자 포맷팅 함수 - 사용 방법 : "yyyy-MM-dd".dateFormatter(formatDate: Date())
    /// - Parameter formatDate: 포맷팅 형식 - ex) "yyyy-MM-dd", "HH:mm:ss"
    /// - Returns: String
    func dateFormatter(formatDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self
        
        return dateFormatter.string(from: formatDate)
    }
    
    //MARK: - String 형식 일자를 Date(일자) 형식으로 변경
    /// 일자 포맷팅 함수 - 사용 방법 : "yyyy-mm-dd".toDateFormatter(formatString: String)
    /// - Parameter formatString: String 형식 일자의 포맷 형식
    /// - Returns: Date
    func toDateFormatter(formatString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self
        
        if let date = dateFormatter.date(from: formatString) {
            return date
        }
        else {
            return nil
        }
    }
    
    //MARK: - 포인트 텍스트를 천자리 콤마 형식으로 변환
    /// 사용 방법: "1000".pointFormatter()
    /// - Returns: 변환 포인트 텍스트 - 1,000p (String)
    func pointFormatter() -> String {
        let numberFormmatter = NumberFormatter()
        
        numberFormmatter.numberStyle = .decimal
        let numberValue = Int(self) ?? 0    //값이 빈 값이거나 null인 경우 0으로 처리
        
        let pointString = numberFormmatter.string(from: NSNumber(value: numberValue))! + "p"
        
        return pointString
    }
}

//MARK: - UIImage Extension
extension UIImage {
    //MARK: - 이미지 사이즈 조절
    /// UIImage 사이즈 조절
    /// - Parameter width: 넓이
    /// - Returns: UIImage
    func resize(width: CGFloat) -> UIImage {
        let scale = width / self.size.width
        let height = self.size.height * scale
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let renderImage = renderer.image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        
        return renderImage
    }
}
