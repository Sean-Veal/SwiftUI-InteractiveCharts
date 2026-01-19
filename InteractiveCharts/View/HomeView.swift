//
//  HomeView.swift
//  InteractiveCharts
//
//  Created by Sean Veal on 1/19/26.
//

import SwiftUI
import Charts

struct HomeView: View {
    /// View Properties
    @State private var graphType: GraphType = .donut
    
    @State private var barSelection: String?
    @State private var pieSelection: Double?
    var body: some View {
        VStack {
            /// Segmented Picker
            Picker("", selection: $graphType) {
                ForEach(GraphType.allCases, id: \.rawValue) { type in
                    Text(type.rawValue)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            
            ZStack {
                if let highestDownloads = appDownloads.max(by: {
                    $1.downloads > $0.downloads
                }) {
                    if graphType == .bar {
                        ChartPopoverView(highestDownloads.downloads, highestDownloads.month, true)
                            .opacity(barSelection == nil ? 1 : 0)
                    } else {
                        if let barSelection, let selectedDownloads = appDownloads.findDownloads(barSelection) {
                            ChartPopoverView(selectedDownloads, barSelection, true, true)
                        } else {
                            ChartPopoverView(highestDownloads.downloads, highestDownloads.month, true)
                        }
                    }
                }
            }
            
            /// Charts
            Chart {
                ForEach(appDownloads.sorted(by: { graphType == .bar ? false : $0.downloads > $1.downloads })) { download in
                    if graphType == .bar {
                        BarMark(
                            x: .value("Month", download.month),
                            y: .value("Downloads", download.downloads)
                        )
                        .cornerRadius(8)
                        .foregroundStyle(by: .value("Month", download.month))
                    } else {
                        SectorMark(
                            angle: .value("Downloads", download.downloads),
                            innerRadius: .ratio(graphType == .donut ? 0.61 : 0),
                            angularInset: graphType == .donut ? 6 : 1
                        )
                        .cornerRadius(8)
                        .foregroundStyle(by: .value("Month", download.month))
                        /// Fading out all other content, expect for the current selection
                        .opacity(barSelection == nil ? 1 : (barSelection == download.month ? 1 : 0.4))
                    }
                }
                if let barSelection {
                    RuleMark(x: .value("Month", barSelection))
                        .foregroundStyle(.gray.opacity(0.35))
                        .zIndex(-10)
                        .offset(yStart: -10)
                        .annotation(
                            position: .top,
                            spacing: 0,
                            overflowResolution: .init(x: .fit, y: .disabled)) {
                                if let downloads = appDownloads.findDownloads(barSelection) {
                                    ChartPopoverView(downloads, barSelection)
                                }
                            }
                }
            }
            .chartXSelection(value: $barSelection)
            .chartAngleSelection(value: $pieSelection)
            .chartLegend(position: .bottom, alignment: graphType == .bar ? .leading : .center, spacing: 25)
            .frame(height: 300)
            .padding(.top, 10)
            /// Adding Animation
            .animation(graphType == .bar ? .none : .snappy, value: graphType)
            
            Spacer(minLength: 0)
        }
        .padding()
        .onChange(of: pieSelection, initial: false) { _, newValue in
            if let newValue {
                findDownload(newValue)
            } else {
                barSelection = nil
            }
        }
    }
    
    @ViewBuilder
    private func ChartPopoverView(_ downloads: Double, _ month: String, _ isTitleView: Bool = false, _ isSelection: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(isTitleView && !isSelection ? "Highest" : "App") Downloads")
                .font(.title3)
                .foregroundStyle(.gray)
            
            HStack(spacing: 4) {
                Text(String(format: "%.0f", downloads))
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(month)
                    .font(.title3)
                    .textScale(.secondary)
            }
        }
        .padding(isTitleView ? [.horizontal] : [.all])
        .background(.mint.opacity(isTitleView ? 0 : 1), in: .rect(cornerRadius: 8))
        .frame(maxWidth: .infinity, alignment: isTitleView ? .leading : .center)
    }
    
    func findDownload(_ rangeValue: Double) {
        /// Converting Download model to an array of tuples
        var initialValue: Double = 0.0
        let convertedArray = appDownloads
            .sorted(by: {
                $0.downloads > $1.downloads
            })
            .compactMap { download -> (String, Range<Double>) in
            let rangeEnd = initialValue + download.downloads
            let tuple = (download.month, initialValue..<rangeEnd)
            /// Updating initial value for next iteration
            initialValue = rangeEnd
            return tuple
        }
        
        /// Now finding the value that lies within the range
        if let download = convertedArray.first(where: {
            $0.1.contains(rangeValue)
        }) {
            /// Updating Selection
            barSelection = download.0
        }
    }
}

#Preview {
    ContentView()
}
