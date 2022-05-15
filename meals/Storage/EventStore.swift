//
//  EventStore.swift
//
//  Created by aclowkey on 15/05/2022.
//

import Foundation
import SwiftUI

class EventStore: ObservableObject {
    @Published var events: [Event] = []
    
    func save(events: [Event], completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(events)
                let outFile = try self.fileURL()
                try data.write(to: outFile)
                DispatchQueue.main.async {
                    completion(.success(events.count))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func load(completion: @escaping (Result<[Event], Error>)->Void){
        DispatchQueue.global(qos: .background).async {
            do{
                let fileURL = try self.fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }
                self.events = try JSONDecoder().decode([Event].self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(self.events))
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func fileURL() throws -> URL {
        try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
        .appendingPathComponent("event.data")
    }
}


