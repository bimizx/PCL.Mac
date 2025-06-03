//
//  CodableAppStorage.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/6/3.
//

import SwiftUI

@propertyWrapper
public struct CodableAppStorage<T: Codable>: DynamicProperty {
    @State private var value: T?
    private let key: String
    private let store: UserDefaults

    public var wrappedValue: T? {
        get { value }
        nonmutating set {
            value = newValue
            if let newValue = newValue {
                if let data = try? JSONEncoder().encode(newValue) {
                    store.set(data, forKey: key)
                }
            } else {
                store.removeObject(forKey: key)
            }
        }
    }

    public init(wrappedValue: T?, _ key: String, store: UserDefaults = .standard) {
        self.key = key
        self.store = store
        if let data = store.data(forKey: key),
           let decoded = try? JSONDecoder().decode(T.self, from: data) {
            self._value = State(initialValue: decoded)
        } else {
            self._value = State(initialValue: wrappedValue)
            if let wrappedValue = wrappedValue,
               let data = try? JSONEncoder().encode(wrappedValue) {
                store.set(data, forKey: key)
            }
        }
    }
}
