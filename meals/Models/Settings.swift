//
// Created by aclowkey on 25/09/2022.
//

import Foundation

struct Settings: Encodable, Decodable {
    var dataSourceType: DatasourceType
    var nightScoutSettings: NightscoutSettings = NightscoutSettings(URL: "", Token: "")
    var developerMode: Bool = false
}

struct NightscoutSettings: Encodable, Decodable {
    var URL: String
    var Token: String
}
