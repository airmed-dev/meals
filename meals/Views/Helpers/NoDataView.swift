//
//  NoDataView.swift
//  meals
//
//  Created by aclowkey on 19/11/2022.
//

import SwiftUI

struct NoDataView: View {
    
    var title: String
    var titleFont:Font = .title3
    
    var prompt: String?
    var prompFont:Font = .body
    
    var iconSize: CGFloat = 40
    
    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .center) {
                Spacer()
                Image(systemName: "tray.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.secondary.opacity(0.5))
                    .font(.system(size: iconSize, weight: .ultraLight))
                    .frame(width: iconSize)
                
                Text(title)
                    .font(titleFont)
                
                if let prompt = prompt {
                    HStack(alignment: .center) {
                        Spacer()
                        Text(prompt)
                            .font(prompFont)
                        Spacer()
                    }
                }
                Spacer()
            }
            Spacer()
        }
    }
}

struct NoDataView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NoDataView(title: "No health data")
            NoDataView(title: "No events", prompt: "Create an event")
        }
    }
}
