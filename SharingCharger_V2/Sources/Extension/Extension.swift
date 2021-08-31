//
//  Extension.swift
//  SharingCharger_V2
//
//  Created by KJ on 2021/08/09.
//

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
    
    //MARK: - Date(일자) 포맷
    /// 일자 포맷팅 함수 - 사용 방법 : "yyyymmdd".dateFormatter(formatDate: Date())
    /// - Parameter formatDate: 포맷팅 형식 - ex) "yyyymmdd", "HH : mm : ss"
    /// - Returns: 포맷팅된 Date
    func dateFormatter(formatDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self
        
        return dateFormatter.string(from: formatDate)
    }
    
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
}
