//
//  GlucoseAPI.swift
//  meals
//
//  Created by aclowkey on 09/07/2022.
//

import Foundation

protocol GlucoseAPI {
    func getGlucoseSamples(event:Event,
                           hours:TimeInterval,
                           debug:Bool,
                           _ completion: @escaping (Result<[MetricSample], Error>) -> Void )
}
