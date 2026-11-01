//
//  SystemMonitor.swift
//  YourPcStats
//
//  Created by Aryan Gupta on 31/10/26.
//

import AppKit
import Combine
import Darwin
import Foundation
import SwiftUI

@MainActor
final class SystemMonitor: ObservableObject {
    @Published var cpuUsage: Double = 0.0
    @Published var memoryUsage: Double = 0.0
    @Published var usedMemoryGB: Double = 0.0
    @Published var totalMemoryGB: Double = 0.0
    @Published var menuBarImage: NSImage?

    // Vintage car dashboard telemetry
    @Published var uptimeSeconds: TimeInterval = 0.0
    @Published var uptimeHours: Int = 0
    @Published var uptimeMilesFormatted: String = "00000"
    @Published var tripMilesFormatted: String = "000"
    @Published var thermalState: ProcessInfo.ThermalState = .nominal
    @Published var activeCoreCount: Int = ProcessInfo.processInfo.activeProcessorCount
    @Published var loadAverage1Min: Double = 0.0
    @Published var machineName: String = Host.current().localizedName ?? "Mac"
    @Published var cpuTemperature: Double = 42.0 // In Celsius
    @Published var thermalLoadPercent: Double = 20.0 // 0 to 100%

    private var previousCPUTicks: host_cpu_load_info?
    private var timerTask: Task<Void, Never>?

    init() {
        totalMemoryGB = Double(ProcessInfo.processInfo.physicalMemory) / (1024 * 1024 * 1024)
        activeCoreCount = ProcessInfo.processInfo.activeProcessorCount
        updateStats()
        startMonitoring()
    }

    deinit {
        timerTask?.cancel()
    }

    func startMonitoring() {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { break }
                self?.updateStats()
            }
        }
    }

    func stopMonitoring() {
        timerTask?.cancel()
        timerTask = nil
    }

    func updateStats() {
        cpuUsage = fetchCPUUsage()
        fetchMemoryUsage()
        fetchSystemTelemetry()
        renderMenuBarImage()
    }

    private func fetchSystemTelemetry() {
        let uptime = ProcessInfo.processInfo.systemUptime
        uptimeSeconds = uptime
        uptimeHours = Int(uptime / 3600)

        // Car odometer style miles counter (e.g. 5 digits: 00057)
        let totalMiles = Int(uptime / 60) // 1 mile per minute of uptime
        uptimeMilesFormatted = String(format: "%05d", min(totalMiles, 99999))

        // Trip counter (e.g. 3 digits: 133)
        let tripVal = Int((uptime.truncatingRemainder(dividingBy: 3600) / 3600) * 1000)
        tripMilesFormatted = String(format: "%03d", min(tripVal, 999))

        thermalState = ProcessInfo.processInfo.thermalState

        // Derive responsive system temperature in Celsius (°C)
        let baseTemp: Double
        switch thermalState {
        case .nominal:
            baseTemp = 38.0
            thermalLoadPercent = 15.0 + (cpuUsage * 0.35)
        case .fair:
            baseTemp = 58.0
            thermalLoadPercent = 45.0 + (cpuUsage * 0.30)
        case .serious:
            baseTemp = 75.0
            thermalLoadPercent = 75.0 + (cpuUsage * 0.15)
        case .critical:
            baseTemp = 90.0
            thermalLoadPercent = 90.0 + (cpuUsage * 0.10)
        @unknown default:
            baseTemp = 40.0
            thermalLoadPercent = 20.0
        }
        let dynamicHeat = (cpuUsage / 100.0) * 26.0
        cpuTemperature = min(max(baseTemp + dynamicHeat, 32.0), 105.0)
        thermalLoadPercent = min(max(thermalLoadPercent, 0.0), 100.0)

        var load = [Double](repeating: 0.0, count: 3)
        if getloadavg(&load, 3) > 0 {
            loadAverage1Min = load[0]
        }
    }

    private func renderMenuBarImage() {
        let labelView = MenuBarLabelView(
            cpuUsage: cpuUsage,
            memoryUsage: memoryUsage,
            cpuTemperature: cpuTemperature
        )
        let renderer = ImageRenderer(content: labelView)
        renderer.scale = NSScreen.main?.backingScaleFactor ?? 2.0

        if let image = renderer.nsImage {
            image.isTemplate = true
            self.menuBarImage = image
        }
    }

    private func fetchCPUUsage() -> Double {
        var loadInfo = host_cpu_load_info()
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &loadInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else { return cpuUsage }

        defer {
            previousCPUTicks = loadInfo
        }

        guard let prev = previousCPUTicks else {
            return cpuUsage
        }

        let userDelta = Double(loadInfo.cpu_ticks.0 &- prev.cpu_ticks.0)
        let systemDelta = Double(loadInfo.cpu_ticks.1 &- prev.cpu_ticks.1)
        let idleDelta = Double(loadInfo.cpu_ticks.2 &- prev.cpu_ticks.2)
        let niceDelta = Double(loadInfo.cpu_ticks.3 &- prev.cpu_ticks.3)

        let totalDelta = userDelta + systemDelta + idleDelta + niceDelta
        guard totalDelta > 0 else { return cpuUsage }

        let activeDelta = userDelta + systemDelta + niceDelta
        let percentage = (activeDelta / totalDelta) * 100.0
        return min(max(percentage, 0.0), 100.0)
    }

    private func fetchMemoryUsage() {
        var vmStats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &vmStats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else { return }

        let pageSize = UInt64(vm_kernel_page_size)
        let activeBytes = UInt64(vmStats.active_count) * pageSize
        let wiredBytes = UInt64(vmStats.wire_count) * pageSize
        let compressedBytes = UInt64(vmStats.compressor_page_count) * pageSize
        let usedBytes = activeBytes + wiredBytes + compressedBytes

        let totalBytes = ProcessInfo.processInfo.physicalMemory
        guard totalBytes > 0 else { return }

        usedMemoryGB = Double(usedBytes) / (1024 * 1024 * 1024)
        memoryUsage = min(max((Double(usedBytes) / Double(totalBytes)) * 100.0, 0.0), 100.0)
    }
}

private struct MenuBarLabelView: View {
    let cpuUsage: Double
    let memoryUsage: Double
    let cpuTemperature: Double

    var body: some View {
        HStack(spacing: 8) {
            // CPU Section
            HStack(spacing: 3) {
                Image(systemName: "cpu")
                    .font(.system(size: 12, weight: .semibold))
                Text(String(format: "%.0f%%", cpuUsage))
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
            }

            // RAM Section
            HStack(spacing: 3) {
                Image(systemName: "memorychip")
                    .font(.system(size: 12, weight: .semibold))
                Text(String(format: "%.0f%%", memoryUsage))
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
            }

            // TEMP Section
            HStack(spacing: 3) {
                Image(systemName: "thermometer.medium")
                    .font(.system(size: 12, weight: .semibold))
                Text(String(format: "%.0f°C", cpuTemperature))
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
            }
        }
        .padding(.horizontal, 2)
        .fixedSize()
    }
}
