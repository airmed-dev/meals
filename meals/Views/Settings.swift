//
// Created by aclowkey on 24/09/2022.
//

import SwiftUI
import Foundation
import HealthKit

struct SettingsView: View {
    @EnvironmentObject var viewModel: ContentViewViewModel
    @State var devClickCount: Int = 0

    var healthKitAuthorized: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    @State var authorizeRequested: Bool = false
    @State var showSuccessAlert:Bool = false

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
                            if healthKitAuthorized {
                                Toggle(isOn: $authorizeRequested) {
                                    Text("Authorized")
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
                            if devClickCount >= 3{
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
                        viewModel.saveSettings(settings: settingsDraft)
                        showSuccessAlert = true
                    }) {
                        Text("Save")
                    }
                    Spacer()
                }
            }
                    .listStyle(.insetGrouped)
        }
                .alert(isPresented: $settingsDraft.developerMode){
                    Alert(title: Text("Developer mode enabled"))
                }
                .alert(isPresented: $showSuccessAlert){
                    Alert(title: Text("Saved"))
                }
                .onAppear {
                    // When the ViewModel available copy the values to the draft
                    settingsDraft.dataSourceType = viewModel.settings.dataSourceType
                    settingsDraft.nightScoutSettings = viewModel.settings.nightScoutSettings
                }

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
            .environmentObject(ContentViewViewModel.init(
                meals: [],
                events: [],
                settings: Settings(dataSourceType: .HealthKit)
            )
        )
    }
}
