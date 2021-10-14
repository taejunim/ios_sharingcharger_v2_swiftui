//
//  EmailHelper.swift
//  SharingCharger_V2
//
//  Created by tjlim on 2021/10/11.
//

import Foundation
import MessageUI

class EmailHelper: NSObject, MFMailComposeViewControllerDelegate {
    public static let shared = EmailHelper()
    
    @Published var isSent: Bool = false
    
    private override init() {
        //
    }
    
    func sendEmail(subject:String, body:String, to:String){
        
        if !MFMailComposeViewController.canSendMail() {
            
            let dialog = UIAlertController(title:"", message : "메일 앱에 로그인 되어 있지 않습니다.\n로그인 후 다시 시도해주세요.", preferredStyle: .alert)
            
            dialog
                .addAction(
                    UIAlertAction(title: "닫기", style: UIAlertAction.Style.destructive) { (action:UIAlertAction) in
                        return
                    }
                )
            
            UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.rootViewController?.present(dialog, animated: true, completion: nil)
            
        } else {
            let picker = MFMailComposeViewController()
            
            picker.setSubject(subject)
            picker.setMessageBody(body, isHTML: true)
            picker.setToRecipients([to])
            picker.mailComposeDelegate = self
            
            EmailHelper.getRootViewController()?.present(picker, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        EmailHelper.getRootViewController()?.dismiss(animated: true, completion: nil)
        
        var dialogMessage = ""
        
        switch result {
        case MFMailComposeResult.cancelled :
            dialogMessage = "이메일 문의가 취소되었습니다."
        case MFMailComposeResult.saved :
            dialogMessage = "작성중인 내용이 메일앱에 저장되었습니다."
        case MFMailComposeResult.sent :
            dialogMessage = "이메일 문의가 전송되었습니다.\n빠른 시일내로 답변드리겠습니다."
        case MFMailComposeResult.failed :
            dialogMessage = "이메일 문의 전송에 실패하였습니다.\n다시 시도해주세요."
        }
        
        let dialog = UIAlertController(title:"", message : dialogMessage, preferredStyle: .alert)
        
        dialog
            .addAction(
                UIAlertAction(title: "닫기", style: UIAlertAction.Style.destructive) { (action:UIAlertAction) in
                    return
                }
            )
        
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.rootViewController?.present(dialog, animated: true, completion: nil)
    }
    
    static func getRootViewController() -> UIViewController? {
        UIApplication.shared.windows.first?.rootViewController
        
        // OR If you use SwiftUI 2.0 based WindowGroup try this one
        // UIApplication.shared.windows.first?.rootViewController
    }
}
