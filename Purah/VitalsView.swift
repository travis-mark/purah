//  Purah - VitalsView.swift
//  Created by Travis Luckenbaugh on 6/3/23.

import SwiftUI
import HealthKit

struct HKQuantityViewModel {
    let dateString: String
    let quantityTypeLocalizedString: String
    let quantityValue: Double
    let quantityUnitLocalizedString: String
    let uuid: UUID
    
    init(_ sample: HKQuantitySample) {
        dateString = string(fromStartDate: sample.startDate, to: sample.endDate)
        uuid = sample.uuid
        switch sample.quantityType {
        case HKQuantityType.quantityType(forIdentifier: .bodyMass):
            quantityTypeLocalizedString = NSLocalizedString("Weight", comment: "Body mass")
            quantityValue = sample.quantity.doubleValue(for: .pound())
            quantityUnitLocalizedString =  NSLocalizedString("lbs", comment: "pounds")
        case HKQuantityType.quantityType(forIdentifier: .bodyFatPercentage):
            quantityTypeLocalizedString = NSLocalizedString("Body Fat", comment: "Body fat")
            quantityValue = sample.quantity.doubleValue(for: .count()) * 100
            quantityUnitLocalizedString =  NSLocalizedString("%", comment: "percent")
        default:
            quantityTypeLocalizedString = sample.quantityType.identifier
            quantityValue = sample.quantity.doubleValue(for: .count())
            quantityUnitLocalizedString = NSLocalizedString("each", comment: "each")
        }
    }
}

struct VitalsView: View {
    private let healthStore = HKHealthStore()
    @State private var samples: [HKQuantitySample] = []
    
    var body: some View {
        List(samples.map({ HKQuantityViewModel($0) }), id: \.uuid) { vm in
            HStack {
                VStack(alignment: .leading) {
                    Text(vm.quantityTypeLocalizedString)
                        .font(.headline)
                    Text(vm.dateString)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("\(vm.quantityValue) \(vm.quantityUnitLocalizedString)")
                    
            }
        }.onAppear {
            requestAuthorization()
        }
    }
    
    private func requestAuthorization() {
        // TODO: More sample types
        let typesToRead: Set<HKSampleType> = [HKSampleType.quantityType(forIdentifier: .bodyMass)!, HKSampleType.quantityType(forIdentifier: .bodyFatPercentage)!, HKWorkoutType.workoutType()]
        
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
