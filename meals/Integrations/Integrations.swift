//
// Created by aclowkey on 25/09/2022.
//

import Foundation

enum DatasourceType: String, Identifiable, Encodable, Decodable, CaseIterable {
    case HealthKit = "HealthKit"
    case NightScout = "NightScout"
    case Debug = "Debug"

    var id: DatasourceType {
        self
    }
}
