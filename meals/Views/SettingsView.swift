//
// Created by aclowkey on 24/09/2022.
//

import SwiftUI
import Foundation
import HealthKit

struct SettingsView: View {
    @State var devClickCount: Int = 0
    var requiredDevClickCount = 7
    
    @State var authorizeRequested: Bool = false
    @State var showSuccessAlert:Bool = false
    
    @State var showErrorAlert:Bool = false
    @State var errorMessage: String = ""
    
    @State var datasourceType: DatasourceType = .HealthKit
    @State var developerMode: Bool = false
    
    @State var nightscoutURL: String = ""
    @State var nightscoutToken: String = ""

    var body: some View {
        VStack {
            List {
                Section("Data") {
                    HStack {
                        Picker("Datasource", selection: $datasourceType) {
                            ForEach(DatasourceType.allCases.filter{
                                developerMode || $0 != DatasourceType.Debug
                            }) { datasourceType in
                                Text(datasourceType.rawValue)
                                    .tag(datasourceType)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                switch datasourceType {
                case .HealthKit:
                    Section("Using health kit for data"){}
                case .NightScout:
                    Section("NightScout") {
                        TextField(
                            "URL",
                            text: $nightscoutURL
                        )
                        TextField(
                            "Token",
                            text: $nightscoutToken
                        )
                    }
                case .Debug:
                    Section("Randomly generating data"){}
                }
                
                Section("About") {
                    HStack {
                        Button(action: {
                            devClickCount+=1
                            if devClickCount >= requiredDevClickCount {
                                developerMode = true
                            }
                        }){
                            Text("Version")
                                .foregroundColor(.primary)
                        }
                        Spacer()
                        Text("v0.1.0")
                    }
                }
                HStack {
                    Button(action: {
                        let defaults = UserDefaults()
                        defaults.set(datasourceType.rawValue, forKey: "datasource.type")
                        switch datasourceType {
                        case .NightScout:
                            defaults.set(nightscoutURL, forKey:  "datasource.nightscout.url")
                            defaults.set(nightscoutToken, forKey: "datasource.nightscout.token")
                        case .HealthKit:
                            HealthKitUtils.requestHKAuthorization { wasPresented, error in
                                authorizeRequested = false
                                if let error = error {
                                    showErrorAlert = true
                                    errorMessage = error.localizedDescription
                                }
                            }
                        case .Debug:
                            break
                        }
                        showSuccessAlert = true
                    }) {
                        Text("Save")
                    }
                    Spacer()
                }
            }
            .listStyle(.insetGrouped)
        }
        .onAppear {
            let defaults = UserDefaults()
            let datasourceTypeRawValue = defaults.string(forKey: "datasource.type") ?? DatasourceType.HealthKit.rawValue
            datasourceType = DatasourceType(rawValue: datasourceTypeRawValue)!
            if datasourceType == DatasourceType.NightScout {
                nightscoutURL = defaults.string(forKey: "datasource.nightscout.url") ?? ""
                nightscoutToken = defaults.string(forKey: "datasource.nightscout.token") ?? ""
            }
        }
        .alert(isPresented: $developerMode){
            Alert(title: Text("Developer mode enabled"))
        }
        .alert(isPresented: $showSuccessAlert){
            Alert(title: Text("Saved"))
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .cancel())
        }
        
        
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(Store.init(
                meals: [],
                events: []
            ) )
    }
}
