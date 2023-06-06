//  Purah - VitalsView.swift
//  Created by Travis Luckenbaugh on 6/3/23.

import SwiftUI
import HealthKit

struct HKQuantityViewModel {
    let quantityTypeLocalizedString: String
    let quantityValue: Double
    let quantityUnitLocalizedString: String
    let uuid: UUID
}

extension HKQuantitySample {
    var quantityViewModel: HKQuantityViewModel {
        switch quantityType {
        case HKQuantityType.quantityType(forIdentifier: .bodyMass):
            return HKQuantityViewModel(quantityTypeLocalizedString: NSLocalizedString("Weight", comment: "Body mass"), quantityValue: quantity.doubleValue(for: .pound()), quantityUnitLocalizedString: NSLocalizedString("lbs", comment: "pounds"), uuid: uuid)
        case HKQuantityType.quantityType(forIdentifier: .bodyFatPercentage):
            return HKQuantityViewModel(quantityTypeLocalizedString: NSLocalizedString("Body Fat", comment: "Body fat"), quantityValue: quantity.doubleValue(for: .count()) * 100, quantityUnitLocalizedString: NSLocalizedString("%", comment: "percent"), uuid: uuid)
        default:
            return HKQuantityViewModel(quantityTypeLocalizedString: quantityType.identifier, quantityValue: quantity.doubleValue(for: .count()), quantityUnitLocalizedString: NSLocalizedString("each", comment: "each"), uuid: uuid)
        }
    }
}

struct VitalsView: View {
    private let healthStore = HKHealthStore()
    @State private var samples: [HKQuantitySample] = []
    
    var body: some View {
        List(samples.map({ $0.quantityViewModel }), id: \.uuid) { vm in
            HStack {
                Text(vm.quantityTypeLocalizedString)
                Spacer()
                Text("\(vm.quantityValue) \(vm.quantityUnitLocalizedString)")
            }
        }.onAppear {
            requestAuthorization()
        }
    }
    
    private func requestAuthorization() {
        // TODO: More sample types
        let typesToRead: Set<HKSampleType> = [HKSampleType.quantityType(forIdentifier: .bodyMass)!, HKSampleType.quantityType(forIdentifier: .bodyFatPercentage)!]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                for sampleType in typesToRead {
                    fetchMeasurements(for: sampleType)
                }
            } else if let error = error {
                print("Error requesting authorization: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchMeasurements(for sampleType: HKSampleType) {
        let query = HKSampleQuery(sampleType: sampleType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { query, results, error in
            if let error = error {
                print("Error querying measurements: \(error.localizedDescription)") // TODO: console.error
                return
            }
            
            if let samples = results as? [HKQuantitySample] {
                DispatchQueue.main.async {
                    self.samples = self.samples.filter({ $0.sampleType != sampleType }) + samples
                }
            }
        }
        
        healthStore.execute(query)
    }
}
