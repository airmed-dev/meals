//
//  GlucoseAPI.swift
//  meals
//
//  Created by aclowkey on 09/07/2022.
//

import Foundation

protocol MetricStore {
    func getGlucoseSamples(start: Date,
                           end: Date,
                           _ completion: @escaping (Result<[MetricSample], Error>) -> Void )
    
    func getInsulinSamples(start: Date,
                           end: Date,
                       _ completion: @escaping (Result<[MetricSample], Error>) -> Void )
}
