//
//  PlaygroundView.swift
//  meals
//
//  Created by aclowkey on 09/10/2022.
//

import Foundation
import SwiftUI

struct Playground: View {
    @Namespace var animationNamespace:Namespace.ID
    @State var showBottomSheet: Bool = false
    
    var body: some View {
        VStack {
            image
        }
        .sheet(isPresented: $showBottomSheet) {
            OtherPlayground(animationNamespace: animationNamespace)
        }
        .onTapGesture {
            withAnimation(.easeIn){
                showBottomSheet.toggle()
            }
        }
    }
    
    var image: some View {
        Image(systemName: "photo.circle")
            .resizable()
            .frame(width: 100, height: 100)
            .padding()
            .background(.black.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(15)
            .matchedGeometryEffect(id: "photo", in: animationNamespace)
    }
}

struct OtherPlayground: View {
    var animationNamespace: Namespace.ID
    
    var body: some View {
        VStack {
            Image(systemName: "photo.circle")
                .resizable()
                .frame(width: 100, height: 100)
                .padding()
                .background(.black.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(15)
                .matchedGeometryEffect(id: "photo", in: animationNamespace)
                .padding()
            Spacer()
        }
    }
}


struct Playground_Previews: PreviewProvider {
    static var previews: some View {
        Playground(showBottomSheet: false)
    }
}
