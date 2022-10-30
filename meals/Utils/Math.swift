//
//  Math.swift
//  meals
//
//  Created by aclowkey on 30/10/2022.
//

import Foundation

func rounded(_ val: Double, toPlaces places:Int) -> Double {
    let divisor = pow(10.0, Double(places))
    return (val * divisor).rounded() / divisor
}
