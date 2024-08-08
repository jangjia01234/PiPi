//
//  iMessageConnect.swift
//  PiPi
//
//  Created by Byeol Kim on 7/31/24.
//

import SwiftUI
import MessageUI

struct iMessageConnect: UIViewControllerRepresentable {
    
    let email: String

    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let vc = MFMessageComposeViewController()
        //TODO: 서버에 등록된 사용자의 이메일로 설정
        vc.recipients = [email]
        vc.body = "안녕하세요. PiPi에서 보고 연락드립니다 :) 문의사항이 있어요."
        vc.messageComposeDelegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        var parent: iMessageConnect
        
        init(_ parent: iMessageConnect) {
            self.parent = parent
        }
        
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true)
        }
    }
}

#Preview {
    iMessageConnect(email: "user@example.com")
}
