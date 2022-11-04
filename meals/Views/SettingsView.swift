//
// Created by aclowkey on 24/09/2022.
//

import SwiftUI
import Foundation
import HealthKit

struct SettingsView: View {
    @EnvironmentObject var settingsStore: SettingsStore
    @State var devClickCount: Int = 0
    var requiredDevClickCount = 7
    
    @State var healthKitAuthorized: Bool = false
    @State var authorizeRequested: Bool = false
    @State var showSuccessAlert:Bool = false
    
    @State var showErrorAlert:Bool = false
    @State var errorMessage: String = ""
    
    @State
    var settingsDraft: Settings = Settings(
        dataSourceType: .HealthKit,
        nightScoutSettings: NightscoutSettings(URL: "", Token: "")
    )
    
    var body: some View {
        VStack {
            List {
                Section("Data") {
                    HStack {
                        Text("Datasource")
                        Spacer()
                        Picker("Datasource type", selection: $settingsDraft.dataSourceType) {
                            ForEach(DatasourceType.allCases.filter{
                                settingsDraft.developerMode || $0 != DatasourceType.Debug
                            }) { datasourceType in
                                Text(datasourceType.rawValue)
                                    .tag(datasourceType)
                            }
                        }
                        .pickerStyle(.menu)
                        
                    }
                }
                switch settingsDraft.dataSourceType {
                case .HealthKit:
                    Section("HealthKit") {
                        HStack {
                            Toggle(isOn: $healthKitAuthorized) {
                                if authorizeRequested {
                                    Text("Authorizing..")
                                } else {
                                    Text("Authorized")
                                }
                            }
                            
                        }
                    }
                    .onChange(of: healthKitAuthorized) { bool in
                        if bool {
                            authorizeRequested = true
                            authorizeHealthKit { authorized, error in
                                authorizeRequested = false
                                healthKitAuthorized = authorized
                                if let error = error {
                                    showErrorAlert = true
                                    errorMessage = error.localizedDescription
                                }
                            }
                        }
                    }
                case .NightScout:
                    Section("NightScout") {
                        TextField(
                            "URL",
                            text: $settingsDraft.nightScoutSettings.URL
                        )
                        TextField(
                            "Token",
                            text: $settingsDraft.nightScoutSettings.Token
                        )
                    }
                case .Debug:
                    Section("Debug"){
                        Text("Debug mode is enabled, all data is random!")
                    }
                    
                }
                
                Section("About") {
                    HStack {
                        Button(action: {
                            devClickCount+=1
                            if devClickCount >= requiredDevClickCount {
                                settingsDraft.developerMode = true
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
                        do {
                            try settingsStore.saveSettings(settings: settingsDraft)
                            settingsStore.settings = settingsDraft
                        } catch {
                            showErrorAlert = true
                            errorMessage = "Failed saving settings: \(error)"
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
            // When the ViewModel available copy the values to the draft
            settingsDraft.dataSourceType = settingsStore.settings.dataSourceType
            settingsDraft.nightScoutSettings = settingsStore.settings.nightScoutSettings
            settingsDraft.developerMode = settingsStore.settings.developerMode
            devClickCount = settingsDraft.developerMode ? requiredDevClickCount : 0
            healthKitAuthorized = isHealthKitAuthorized()
        }
        .alert(isPresented: $settingsDraft.developerMode){
            Alert(title: Text("Developer mode enabled"))
        }
        .alert(isPresented: $showSuccessAlert){
            Alert(title: Text("Saved"))
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .cancel())
        }
        
        
    }
    
    func isHealthKitAuthorized() -> Bool {
        let hkStore = HKHealthStore()
        let glucoseQuantityType = HKSampleType.quantityType(forIdentifier: .bloodGlucose)
        let insulinQuantityType = HKSampleType.quantityType(forIdentifier: .insulinDelivery)
        
        guard let glucoseQuantityType = glucoseQuantityType,
              let  insulinQuantityType=insulinQuantityType else { return false
        }
        
        if !HKHealthStore.isHealthDataAvailable() {
            return false
        }
        
        
        let glucoseAuthStatus = hkStore.authorizationStatus(for: glucoseQuantityType)
        let insulinAuthStatus = hkStore.authorizationStatus(for: insulinQuantityType)
        
        return glucoseAuthStatus == .sharingAuthorized &&
        insulinAuthStatus == .sharingAuthorized
    }
    
    
    func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthkitError.notAvailableOnDevice)
            return
        }
        
        guard
            let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
            let glucose = HKSampleType.quantityType(forIdentifier: .bloodGlucose),
            let insulin = HKSampleType.quantityType(forIdentifier: .insulinDelivery)
        else {
            
            completion(false, HealthkitError.dataTypeNotAvailable)
            return
        }
        
        
        let healthKitTypesToRead: Set<HKObjectType> = [dateOfBirth, glucose, insulin]
        
        HKHealthStore().requestAuthorization(toShare: [], read: healthKitTypesToRead) { (success, error) in
            completion(success, error)
        }
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(Store.init(
                meals: [],
                events: [],
                settings: Settings(dataSourceType: .HealthKit)
            )
            )
    }
}
