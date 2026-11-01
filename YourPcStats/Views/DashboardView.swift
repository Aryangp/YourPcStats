//
//  DashboardView.swift
//  YourPcStats
//
//  Created by Aryan Gupta on 31/10/26.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var monitor: SystemMonitor

    private var isOverheating: Bool {
        monitor.cpuTemperature > 80.0 || monitor.thermalState == .serious || monitor.thermalState == .critical
    }

    private var isHighRAM: Bool {
        monitor.memoryUsage > 80.0
    }

    var body: some View {
        VStack(spacing: 0) {
            // Main Vintage Car Dashboard Panel
            ZStack {
                // Outer Leather/Vinyl Dashboard Casing
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.13, green: 0.13, blue: 0.14),
                                Color(red: 0.08, green: 0.08, blue: 0.09),
                                Color(red: 0.05, green: 0.05, blue: 0.06)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color(white: 0.35),
                                        Color(white: 0.15),
                                        Color(white: 0.08)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 2.0
                            )
                    )

                // Recessed Instrument Cowl / Bezel
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.9),
                                Color.white.opacity(0.12)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 3
                    )
                    .padding(3)

                // The Three Main Gauges & Warning Lights
                HStack(spacing: 8) {
                    // GAUGE 1 (LEFT): CPU SPEEDOMETER (CPU Usage & Cores)
                    VintageCPUGauge(
                        cpuUsage: monitor.cpuUsage,
                        uptimeMiles: monitor.uptimeMilesFormatted,
                        activeCores: monitor.activeCoreCount,
                        diameter: 148
                    )
                    .frame(width: 148, height: 148)

                    // LEFT INDICATOR LIGHTS (Between CPU & Memory)
                    VStack(spacing: 48) {
                        // Top: Green Live System Indicator Jewel
                        VintageJewelLight(
                            iconName: "arrow.left.and.right",
                            color: Color(red: 0.2, green: 0.9, blue: 0.3),
                            isActive: true,
                            diameter: 18
                        )

                        // Bottom: Left Indicator Jewel
                        VintageJewelLight(
                            iconName: "arrow.left",
                            color: Color(red: 0.2, green: 0.8, blue: 0.35),
                            isActive: false,
                            diameter: 18
                        )
                    }
                    .frame(width: 22, height: 148)

                    // GAUGE 2 (CENTER): MEMORY TACHOMETER (RAM Usage & GB)
                    VintageMemoryGauge(
                        memoryUsage: monitor.memoryUsage,
                        usedMemoryGB: monitor.usedMemoryGB,
                        totalMemoryGB: monitor.totalMemoryGB,
                        diameter: 148
                    )
                    .frame(width: 148, height: 148)

                    // RIGHT INDICATOR LIGHTS (Between Memory & Temps)
                    VStack(spacing: 48) {
                        // Top: Vintage Engine Overheat Warning Lamp
                        VintageJewelLight(
                            iconName: "drop.triangle.fill",
                            color: Color(red: 0.95, green: 0.2, blue: 0.1),
                            isActive: isOverheating,
                            diameter: 18
                        )

                        // Bottom: Vintage High Memory / Battery Lamp
                        VintageJewelLight(
                            iconName: "bolt.fill",
                            color: Color(red: 0.95, green: 0.5, blue: 0.05),
                            isActive: isHighRAM,
                            diameter: 18
                        )
                    }
                    .frame(width: 22, height: 148)

                    // GAUGE 3 (RIGHT): COMPUTER TEMPS GAUGE (Single Top Needle)
                    VintageTempGauge(
                        cpuTemperature: monitor.cpuTemperature,
                        diameter: 148
                    )
                    .frame(width: 148, height: 148)
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 12)
            }
            .frame(width: 556, height: 174)

            // Bottom Console Strip: Stamped Spec Plate & Ignition/Quit Switch
            HStack(spacing: 12) {
                // Stamped Metal VIN / Machine Specification Badge
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color(white: 0.6))
                        .frame(width: 3.5, height: 3.5)

                    VStack(alignment: .leading, spacing: 1) {
                        HStack(spacing: 6) {
                            Text("MAC CLUSTER")
                                .font(.system(size: 7.5, weight: .black, design: .monospaced))
                                .foregroundColor(Color(white: 0.9))
                            Text("•")
                                .font(.system(size: 7))
                                .foregroundColor(Color(white: 0.4))
                            Text(monitor.machineName.uppercased())
                                .font(.system(size: 7.5, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(white: 0.75))
                        }

                        HStack(spacing: 8) {
                            Text("CPU: \(String(format: "%.1f%%", monitor.cpuUsage))")
                                .font(.system(size: 8, weight: .semibold, design: .monospaced))
                                .foregroundColor(monitor.cpuUsage > 75 ? Color(red: 1.0, green: 0.4, blue: 0.3) : Color(white: 0.7))

                            Text("RAM: \(String(format: "%.1f", monitor.usedMemoryGB))/\(String(format: "%.0f", monitor.totalMemoryGB))GB")
                                .font(.system(size: 8, weight: .semibold, design: .monospaced))
                                .foregroundColor(isHighRAM ? Color(red: 1.0, green: 0.6, blue: 0.2) : Color(white: 0.7))

                            Text("TEMP: \(String(format: "%.0f°C", monitor.cpuTemperature))")
                                .font(.system(size: 8, weight: .semibold, design: .monospaced))
                                .foregroundColor(isOverheating ? Color(red: 1.0, green: 0.35, blue: 0.25) : Color(white: 0.7))
                        }
                    }

                    Spacer()

                    Circle()
                        .fill(Color(white: 0.6))
                        .frame(width: 3.5, height: 3.5)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(white: 0.22),
                                    Color(white: 0.14),
                                    Color(white: 0.10)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(white: 0.35), lineWidth: 0.8)
                        )
                )

                // Vintage Starter / Ignition Button for "Quit"
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "power")
                            .font(.system(size: 9, weight: .black))
                        Text("IGNITION OFF")
                            .font(.system(size: 8.5, weight: .heavy, design: .rounded))
                    }
                    .foregroundColor(Color(white: 0.9))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5.5)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.45, green: 0.12, blue: 0.12),
                                        Color(red: 0.25, green: 0.05, blue: 0.05)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color(white: 0.7), Color(white: 0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.2
                                    )
                            )
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 10)
            .frame(width: 556, height: 48)
        }
        .frame(width: 556, height: 222)
        .clipped()
        .background(
            Color(red: 0.06, green: 0.06, blue: 0.07)
        )
    }
}

#Preview {
    DashboardView(monitor: SystemMonitor())
}
