//
//  Onboarding.swift
//  meals
//
//  Created by aclowkey on 05/11/2022.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var datasourceType: DatasourceType = .HealthKit
    @State var nightscoutURL: String = ""
    @State var nightscoutToken: String = ""
    
    var body: some View {
        NavigationView {
            splash
        }
        .interactiveDismissDisabled()
        
    }
    
    var splash: some View {
        VStack {
            VStack {
                Spacer()
                Image(systemName: "fork.knife.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.black.opacity(0.8))
                    .frame(height: 150)
                    .padding()
                Text("Meals is your food tracker")
                    .font(.headline)
                Spacer()
            }
            
            Spacer()
            
            NavigationLink(destination: {
                datasourceSelector
            }, label: {
                Text("Next")
            })
        }
    }
    
    
    var datasourceSelector: some View {
        VStack {
            VStack {
                Spacer()
                Text("Choose a datasource")
                    .font(.largeTitle)
                Picker("Datasource", selection: $datasourceType) {
                    ForEach(DatasourceType.allCases.filter { $0 != .Debug } ) { datasourceType in
                        Text(datasourceType.rawValue)
                            .tag(datasourceType)
                    }
                }
                .pickerStyle(.inline)
                Spacer()
            }
            
            VStack {
                NavigationLink(destination:{
                    settings
                } , label: {
                    Text("Next")
                })
            }
        }
        .navigationTitle("Datasource")
    }
    
    var settings: some View {
        VStack {
            switch datasourceType {
            case .HealthKit:
                VStack {
                    Spacer()
                    Text("HealthKit requires authorization")
                        .font(.headline)
                    Spacer()
                    Button {
                        saveHealthkit()
                    } label: {
                        Text("Authorize")
                    }
                }
            case .NightScout:
                VStack {
                    Spacer()
                    
                    Text("Configure nightscout")
                    VStack {
                        TextField("URL", text: $nightscoutURL)
                            .padding()
                        TextField("Token", text: $nightscoutToken)
                            .padding()
                    }
                    .padding()
                    
                    Spacer()
                    Button {
                        saveNightscout()
                    } label: {
                        Text("Authorize")
                    }
                }
            case .Debug:
                Text("You are a developer!")
            }
        }
        .navigationTitle("Settings")
    }
    
    func saveHealthkit() {
        HealthKitUtils.requestHKAuthorization  { shown, error in
            if error != nil {
                // TODO: What about this one?
                return
            }
            if !shown {
                // TODO: When does this happen?
                return
            }
            let defaults = UserDefaults()
            defaults.set(DatasourceType.HealthKit.rawValue, forKey: "datasource.type")
            defaults.set(true, forKey: "onboarding.done")
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    func saveNightscout() {
        // TODO: Test request to nightscout?
        // TODO: Validate empty values
        let defaults = UserDefaults()
        defaults.set(DatasourceType.NightScout.rawValue, forKey: "datasource.type")
        defaults.set(nightscoutURL, forKey: "datasource.nightscout.url")
        defaults.set(nightscoutToken, forKey: "datasource.nightscout.token")
        defaults.set(true, forKey: "onboarding.done")
        presentationMode.wrappedValue.dismiss()
    }
    
}

struct Onboarding_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
