//
//  PopupOverlay.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/19.
//

import SwiftUI

struct PopupOverlay: View {
    public let title: String
    public let content: String
    public let buttons: [PopupButton]
    
    public init(_ title: String, _ content: String, _ buttons: [PopupButton]) {
        self.title = title
        self.content = content
        self.buttons = buttons
    }
    
    var body: some View {
        VStack {
            
        }
    }
}
