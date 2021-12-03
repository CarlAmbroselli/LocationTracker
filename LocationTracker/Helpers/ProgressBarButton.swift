//
//  ProgressBar.swift
//  LocationTracker
//
//  Created by Carl on 03.12.21.
//

import SwiftUI

struct ProgressBarButton: View {
    @Binding var value: Double
    let tapAction: () -> Void
    @State var pressing = false
    let icon: String?
    let text: String
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                
                if (value < 1.0) {
                    Rectangle().frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                        .foregroundColor(Color(UIColor.systemBackground))
                        .opacity(0.3)
                        .animation(.linear(duration: 1.0), value: value)
                }
                
                if (pressing) {
                    Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                        .foregroundColor(.primary)
                        .opacity(0.2)
                        .cornerRadius(10)
                }
                
                HStack {
                    Spacer()
                    if (icon != nil ) {
                        Image(systemName: icon!)
                    }
                    Text(text)
                    Spacer()
                }
                .foregroundColor(.white)
            }
            .onTapGesture {
                tapAction()
            }
        }
        ._onButtonGesture { pressing in
                        self.pressing = pressing
                    } perform: {}
    }
}
