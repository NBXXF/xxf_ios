//
//  StringTrackerConverter.swift
//  xxf_ios
//
//  Created by xxf on 7/12.
//

public class StringTrackerConverter: TrackerConverter {
    public func convert(data: Any, extra _: inout [AnyHashable: Any]) -> String? {
        if let str = data as? String {
            return str
        }
        return String(describing: data)
    }
}
