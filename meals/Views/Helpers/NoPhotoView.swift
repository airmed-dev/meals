//
//  NoPhotoView.swift
//  meals
//
//  Created by aclowkey on 19/11/2022.
//

import SwiftUI

struct NoPhotoView: View {
    var body: some View {
        GeometryReader { geo in
            VStack {
                Image(systemName: "photo.circle")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .background(LinearGradient(
                colors: [Color(hex: 0xffd89b), Color(hex: 0x19547b)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .opacity(0.5)
        }
    }
}

struct NoPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        NoPhotoView()
    }
}
