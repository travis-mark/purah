//  Purah - VitalsView.swift
//  Created by Travis Luckenbaugh on 6/3/23.

import SwiftUI
import HealthKit

// TODO: Vitals View
struct VitalsView: View {
    private let healthStore = HKHealthStore()
    @State private var samples: [HKQuantitySample] = []
    
    var body: some View {
        List(samples, id: \.uuid) { sample in
            Text("Weight")
            Text("\(sample.quantity.doubleValue(for: .pound()))")
        }.onAppear {
            requestAuthorization()
        }
    }
    
    private func requestAuthorization() {
        let typesToRead: Set<HKObjectType> = [HKObjectType.quantityType(forIdentifier: .bodyMass)!]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                fetchWeightMeasurements()
            } else if let error = error {
                print("Error requesting authorization: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchWeightMeasurements() {
        guard let weightType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
            print("Weight type is not available.")
            return
        }
        
        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { query, results, error in
            if let error = error {
                print("Error querying weight measurements: \(error.localizedDescription)")
                return
            }
            
            if let samples = results as? [HKQuantitySample] {
                DispatchQueue.main.async {
                    self.samples = samples
                }
            }
        }
        
        healthStore.execute(query)
    }
}
