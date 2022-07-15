//
//  LoadingButton.swift
//  meals
//
//  Created by aclowkey on 15/07/2022.
//

import SwiftUI

enum ButtonStatus {
   case Initial
   case Clicked
   case Saved
}

struct LoadingButton: View {
    var status: ButtonStatus
    var role: ButtonRole = .cancel
    var label: String
    var loadingLabel: String = "Loading..."
    var doneLabel: String = "Done"
    var action: () -> Void
    
    var body: some View {
        Button(role: role, action: action){
            HStack {
                switch status {
                case .Clicked:
                    ProgressView()
                        .padding(5)
                    Text(loadingLabel)
                case .Saved:
                    Image(systemName: "checkmark")
                        .frame(height: 20)
                    Text(doneLabel)
                case .Initial:
                    Text(label)
                }
            }
        }
    }
}

struct LoadingButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoadingButton(status: .Initial, label: "Save", action: {})
            LoadingButton(status: .Clicked, label: "Save", action: {})
            LoadingButton(status: .Saved, label: "Save", action: {})
        }
    }
}
