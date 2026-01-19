//
//  AppDownloads.swift
//  InteractiveCharts
//
//  Created by Sean Veal on 1/19/26.
//

import Foundation

struct AppDownload: Identifiable {
    let id: UUID = .init()
    var date: Date
    var downloads: Double
    
    var month: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: date)
    }
}

extension [AppDownload] {
    func findDownloads(_ on: String) -> Double? {
        if let download = self.first(where: {
            $0.month == on
        }) {
            return download.downloads
        }
        
        return nil
    }
    
    func index(_ on: String) -> Int {
        if let index = self.firstIndex(where: {
            $0.month == on
        }) {
            return index
        }
        
        return 0
    }
}

var appDownloads: [AppDownload] = [
    .init(date: .createDate(day: 1, month: 1, year: 2026), downloads: 2500),
    .init(date: .createDate(day: 1, month: 2, year: 2026), downloads: 3500),
    .init(date: .createDate(day: 1, month: 3, year: 2026), downloads: 1500),
    .init(date: .createDate(day: 1, month: 4, year: 2026), downloads: 9500),
    .init(date: .createDate(day: 1, month: 5, year: 2026), downloads: 1950),
    .init(date: .createDate(day: 1, month: 6, year: 2026), downloads: 5100),
]

extension Date {
    static func createDate(day: Int, month: Int, year: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.day = day
        components.month = month
        
        let calendar = Calendar.current
        return calendar.date(from: components) ?? .init()
    }
}
