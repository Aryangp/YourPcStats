//
//  DashboardGauge.swift
//  YourPcStats
//
//  Created by Aryan Gupta on 31/10/26.
//

import SwiftUI

// MARK: - Needle Shape (Pivot point is exactly at midX, midY)
struct VintageNeedleShape: Shape {
    var length: CGFloat
    var tailLength: CGFloat = 12

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cx = rect.midX
        let cy = rect.midY

        path.move(to: CGPoint(x: cx, y: cy + tailLength))
        path.addLine(to: CGPoint(x: cx - 2.0, y: cy + 2))
        path.addLine(to: CGPoint(x: cx - 0.5, y: cy - length))
        path.addLine(to: CGPoint(x: cx + 0.5, y: cy - length))
        path.addLine(to: CGPoint(x: cx + 2.0, y: cy + 2))
        path.closeSubpath()
        return path
    }
}

// MARK: - Vintage Needle Component (Fixed Frame, No GeometryReader)
struct VintageNeedle: View {
    var angle: Angle
    var length: CGFloat = 48
    var tailLength: CGFloat = 12
    var hubDiameter: CGFloat = 20
    var diameter: CGFloat = 148

    var body: some View {
        ZStack {
            // Needle shadow
            VintageNeedleShape(length: length, tailLength: tailLength)
                .fill(Color.black.opacity(0.40))
                .offset(x: 1.2, y: 1.5)
                .rotationEffect(angle, anchor: .center)

            // Orange pointer
            VintageNeedleShape(length: length, tailLength: tailLength)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.45, blue: 0.08),
                            Color(red: 0.95, green: 0.28, blue: 0.02)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .rotationEffect(angle, anchor: .center)

            // Center Silver Hub Cap
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color(white: 0.96),
                                Color(white: 0.72),
                                Color(white: 0.45)
                            ]),
                            center: .center,
                            startRadius: 1,
                            endRadius: hubDiameter / 2
                        )
                    )
                    .frame(width: hubDiameter, height: hubDiameter)

                Circle()
                    .fill(Color(white: 0.25))
                    .frame(width: 3.5, height: 3.5)
            }
        }
        .frame(width: diameter, height: diameter)
        .animation(.easeOut(duration: 0.35), value: angle)
    }
}

// MARK: - Chrome Bezel with Screws
struct VintageChromeBezel: View {
    var diameter: CGFloat = 148

    var body: some View {
        let radius = diameter / 2
        ZStack {
            // Outer polished chrome ring
            Circle()
                .strokeBorder(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color(white: 0.95),
                            Color(white: 0.55),
                            Color(white: 0.85),
                            Color(white: 0.40),
                            Color(white: 0.92),
                            Color(white: 0.60),
                            Color(white: 0.98),
                            Color(white: 0.50),
                            Color(white: 0.95)
                        ]),
                        center: .center
                    ),
                    lineWidth: 5.5
                )
                .frame(width: diameter, height: diameter)
                .shadow(color: .black.opacity(0.8), radius: 5, x: 2, y: 3)

            // Stepped dark recessed ring
            Circle()
                .strokeBorder(Color(white: 0.15), lineWidth: 1.5)
                .frame(width: diameter - 11, height: diameter - 11)

            // Inner polished bevel
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [Color(white: 0.8), Color(white: 0.3), Color(white: 0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .frame(width: diameter - 14, height: diameter - 14)

            // 6 Perimeter Screws
            ForEach(0..<6) { i in
                let angleDeg = Double(i) * 60.0
                let rad = angleDeg * .pi / 180.0
                let screwDist = radius - 3.2
                let x = radius + CGFloat(sin(rad)) * screwDist
                let y = radius - CGFloat(cos(rad)) * screwDist

                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(white: 0.92), Color(white: 0.45)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 4.5, height: 4.5)

                    Rectangle()
                        .fill(Color(white: 0.15))
                        .frame(width: 2.8, height: 0.8)
                        .rotationEffect(.degrees(angleDeg + 45))
                }
                .position(x: x, y: y)
            }
        }
        .frame(width: diameter, height: diameter)
        .allowsHitTesting(false)
    }
}

// MARK: - Glass Reflection Overlay
struct VintageGlassReflection: View {
    var diameter: CGFloat = 148

    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    stops: [
                        .init(color: .white.opacity(0.18), location: 0.0),
                        .init(color: .white.opacity(0.05), location: 0.35),
                        .init(color: .clear, location: 0.6)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: diameter - 16, height: diameter - 16)
            .allowsHitTesting(false)
    }
}

// MARK: - Mechanical Odometer Tumbler
struct OdometerTumbler: View {
    let text: String
    var highlightLastDigit: Bool = false

    var body: some View {
        HStack(spacing: 1.5) {
            ForEach(Array(text.enumerated()), id: \.offset) { index, char in
                let isLast = index == text.count - 1 && highlightLastDigit
                ZStack {
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(
                            LinearGradient(
                                colors: isLast
                                    ? [Color(white: 0.88), Color(white: 0.72), Color(white: 0.85)]
                                    : [Color(white: 0.12), Color(white: 0.05), Color(white: 0.18)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 1.5)
                                .stroke(Color(white: 0.25), lineWidth: 0.5)
                        )

                    Text(String(char))
                        .font(.system(size: 8.5, weight: .bold, design: .monospaced))
                        .foregroundColor(isLast ? .black : Color(white: 0.92))
                }
                .frame(width: 7.5, height: 11)
            }
        }
        .padding(1.5)
        .background(Color.black.opacity(0.85))
        .cornerRadius(2)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color(white: 0.35), lineWidth: 0.8)
        )
        .fixedSize()
    }
}

// MARK: - GAUGE 1 (LEFT): CPU SPEEDOMETER
struct VintageCPUGauge: View {
    let cpuUsage: Double
    let uptimeMiles: String
    let activeCores: Int
    var diameter: CGFloat = 148

    // Map 0...100% CPU to -130 deg to +130 deg
    private var needleAngle: Angle {
        let percent = min(max(cpuUsage / 100.0, 0.0), 1.0)
        return Angle(degrees: -130.0 + (percent * 260.0))
    }

    private let speeds = [0, 20, 40, 60, 80, 100, 120, 140, 160]
    private let loadSteps = [10, 25, 40, 55, 70, 85, 100, 120, 140]

    var body: some View {
        let radius = diameter / 2
        ZStack {
            // Dial Background
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(white: 0.16),
                            Color(white: 0.09),
                            Color(white: 0.04)
                        ]),
                        center: .center,
                        startRadius: 20,
                        endRadius: radius
                    )
                )
                .frame(width: diameter - 12, height: diameter - 12)

            // Inner Shadow
            Circle()
                .stroke(Color.black.opacity(0.7), lineWidth: 6)
                .frame(width: diameter - 14, height: diameter - 14)
                .blur(radius: 2)

            // Ticks
            Path { path in
                for i in 0...40 {
                    let angleDeg = -130.0 + (Double(i) / 40.0 * 260.0)
                    let rad = angleDeg * .pi / 180.0
                    let isMajor = (i % 5 == 0)
                    let tickLen: CGFloat = isMajor ? 6.0 : 3.5
                    let rOuter = radius - 10
                    let rInner = rOuter - tickLen

                    let x1 = radius + CGFloat(sin(rad)) * rInner
                    let y1 = radius - CGFloat(cos(rad)) * rInner
                    let x2 = radius + CGFloat(sin(rad)) * rOuter
                    let y2 = radius - CGFloat(cos(rad)) * rOuter

                    path.move(to: CGPoint(x: x1, y: y1))
                    path.addLine(to: CGPoint(x: x2, y: y2))
                }
            }
            .stroke(Color(white: 0.85), lineWidth: 1.2)

            // Speedometer Numerals (0 to 160)
            ForEach(Array(speeds.enumerated()), id: \.offset) { index, speed in
                let angleDeg = -130.0 + (Double(index) / 8.0 * 260.0)
                let rad = angleDeg * .pi / 180.0
                let rNum = radius - 23
                let x = radius + CGFloat(sin(rad)) * rNum
                let y = radius - CGFloat(cos(rad)) * rNum

                Text("\(speed)")
                    .font(.system(size: 8.5, weight: .bold, design: .rounded))
                    .foregroundColor(Color(white: 0.92))
                    .position(x: x, y: y)
            }

            // Inner Amber Secondary Scale
            ForEach(Array(loadSteps.enumerated()), id: \.offset) { index, val in
                let angleDeg = -115.0 + (Double(index) / 8.0 * 230.0)
                let rad = angleDeg * .pi / 180.0
                let rStep = radius - 33
                let x = radius + CGFloat(sin(rad)) * rStep
                let y = radius - CGFloat(cos(rad)) * rStep

                Text("\(val)")
                    .font(.system(size: 5.5, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color(red: 0.95, green: 0.65, blue: 0.25).opacity(0.85))
                    .position(x: x, y: y)
            }

            // Odometers Window (Vintage Tumblers)
            VStack(spacing: 3) {
                // Total Uptime Miles
                OdometerTumbler(text: uptimeMiles, highlightLastDigit: true)

                // Active Cores Trip Tumbler
                OdometerTumbler(text: String(format: "%03d", activeCores), highlightLastDigit: false)

                // Gauge Labels
                VStack(spacing: 0.5) {
                    Text("CORES")
                        .font(.system(size: 5.5, weight: .semibold))
                        .foregroundColor(Color(red: 0.95, green: 0.65, blue: 0.25).opacity(0.9))
                    Text("CPU")
                        .font(.system(size: 8.0, weight: .black, design: .serif))
                        .foregroundColor(Color(white: 0.92))
                    Text("% LOAD")
                        .font(.system(size: 5.5, weight: .bold))
                        .foregroundColor(Color(white: 0.6))
                }
            }
            .offset(y: 8)

            // Trip Reset Stem at 7 o'clock
            ZStack {
                Circle()
                    .fill(Color(white: 0.12))
                    .frame(width: 6, height: 6)
                Circle()
                    .stroke(Color(white: 0.35), lineWidth: 0.8)
                    .frame(width: 6, height: 6)
                Circle()
                    .fill(Color(white: 0.5))
                    .frame(width: 2, height: 2)
                    .offset(x: -1, y: -1)
            }
            .position(
                x: radius + CGFloat(sin(-135.0 * .pi / 180.0)) * (radius - 22),
                y: radius - CGFloat(cos(-135.0 * .pi / 180.0)) * (radius - 22)
            )

            // Orange Needle
            VintageNeedle(angle: needleAngle, length: radius - 24, hubDiameter: 22, diameter: diameter)

            // Domed Glass Reflection
            VintageGlassReflection(diameter: diameter)

            // Chrome Outer Bezel
            VintageChromeBezel(diameter: diameter)
        }
        .frame(width: diameter, height: diameter)
    }
}

// MARK: - GAUGE 2 (CENTER): MEMORY TACHOMETER
struct VintageMemoryGauge: View {
    let memoryUsage: Double // 0.0 to 100.0%
    let usedMemoryGB: Double
    let totalMemoryGB: Double
    var diameter: CGFloat = 148

    // Map 0...100% RAM to -130 deg to +130 deg (0 to 8 x 10%)
    private var needleAngle: Angle {
        let percent = min(max(memoryUsage / 100.0, 0.0), 1.0)
        return Angle(degrees: -130.0 + (percent * 260.0))
    }

    var body: some View {
        let radius = diameter / 2
        ZStack {
            // Dial Background
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(white: 0.14),
                            Color(white: 0.08),
                            Color(white: 0.03)
                        ]),
                        center: .center,
                        startRadius: 20,
                        endRadius: radius
                    )
                )
                .frame(width: diameter - 12, height: diameter - 12)

            // Inner Shadow
            Circle()
                .stroke(Color.black.opacity(0.7), lineWidth: 6)
                .frame(width: diameter - 14, height: diameter - 14)
                .blur(radius: 2)

            // Ticks (White for 0..6, Red for 6..8 redline zone)
            Path { path in
                for i in 0...40 {
                    let angleDeg = -130.0 + (Double(i) / 40.0 * 260.0)
                    let rad = angleDeg * .pi / 180.0
                    let isMajor = (i % 5 == 0)
                    let tickLen: CGFloat = isMajor ? 6.0 : 3.5
                    let rOuter = radius - 10
                    let rInner = rOuter - tickLen

                    let x1 = radius + CGFloat(sin(rad)) * rInner
                    let y1 = radius - CGFloat(cos(rad)) * rInner
                    let x2 = radius + CGFloat(sin(rad)) * rOuter
                    let y2 = radius - CGFloat(cos(rad)) * rOuter

                    path.move(to: CGPoint(x: x1, y: y1))
                    path.addLine(to: CGPoint(x: x2, y: y2))
                }
            }
            .stroke(Color(white: 0.85), lineWidth: 1.2)

            // Redline Zone Ticks Overlay (6.5 to 8.0 = indices 30 to 40)
            Path { path in
                for i in 30...40 {
                    let angleDeg = -130.0 + (Double(i) / 40.0 * 260.0)
                    let rad = angleDeg * .pi / 180.0
                    let isMajor = (i % 5 == 0)
                    let tickLen: CGFloat = isMajor ? 6.0 : 3.5
                    let rOuter = radius - 10
                    let rInner = rOuter - tickLen

                    let x1 = radius + CGFloat(sin(rad)) * rInner
                    let y1 = radius - CGFloat(cos(rad)) * rInner
                    let x2 = radius + CGFloat(sin(rad)) * rOuter
                    let y2 = radius - CGFloat(cos(rad)) * rOuter

                    path.move(to: CGPoint(x: x1, y: y1))
                    path.addLine(to: CGPoint(x: x2, y: y2))
                }
            }
            .stroke(Color(red: 0.95, green: 0.25, blue: 0.1), lineWidth: 1.4)

            // Radial Numerals (0 to 8 x 10%)
            ForEach(0..<9) { num in
                let angleDeg = -130.0 + (Double(num) / 8.0 * 260.0)
                let rad = angleDeg * .pi / 180.0
                let rNum = radius - 23
                let x = radius + CGFloat(sin(rad)) * rNum
                let y = radius - CGFloat(cos(rad)) * rNum
                let isRedline = num >= 6

                Text("\(num)")
                    .font(.system(size: 10.0, weight: .bold, design: .rounded))
                    .foregroundColor(isRedline ? Color(red: 0.95, green: 0.3, blue: 0.15) : Color(white: 0.92))
                    .position(x: x, y: y)
            }

            // Brushed Gunmetal Center Plate
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.36, green: 0.35, blue: 0.33),
                                Color(red: 0.44, green: 0.42, blue: 0.38),
                                Color(red: 0.28, green: 0.27, blue: 0.25)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: diameter * 0.50, height: diameter * 0.50)
                    .overlay(
                        Circle()
                            .stroke(Color(white: 0.20), lineWidth: 1.0)
                    )

                // Screws at 9 and 3 o'clock
                HStack {
                    ZStack {
                        Circle().fill(Color(white: 0.18)).frame(width: 4.5, height: 4.5)
                        Rectangle().fill(Color.black).frame(width: 3.0, height: 0.8)
                    }
                    Spacer()
                    ZStack {
                        Circle().fill(Color(white: 0.18)).frame(width: 4.5, height: 4.5)
                        Rectangle().fill(Color.black).frame(width: 3.0, height: 0.8)
                    }
                }
                .frame(width: diameter * 0.36)

                // Dedicated Memory / RAM Labels
                VStack(spacing: 1.5) {
                    Spacer().frame(height: 18)
                    Text("RAM")
                        .font(.system(size: 9.0, weight: .black, design: .serif))
                        .foregroundColor(Color(white: 0.95))
                    Text("MEMORY")
                        .font(.system(size: 9.5, weight: .heavy, design: .serif))
                        .foregroundColor(Color(white: 0.95))
                    Text(String(format: "%.1f GB", usedMemoryGB))
                        .font(.system(size: 6.5, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 0.95, green: 0.65, blue: 0.25))
                    Text("x 10 %")
                        .font(.system(size: 5.0, weight: .semibold))
                        .foregroundColor(Color(white: 0.60))
                }
            }

            // Orange Needle
            VintageNeedle(angle: needleAngle, length: radius - 24, hubDiameter: 22, diameter: diameter)

            // Domed Glass Reflection
            VintageGlassReflection(diameter: diameter)

            // Chrome Outer Bezel
            VintageChromeBezel(diameter: diameter)
        }
        .frame(width: diameter, height: diameter)
    }
}

// MARK: - GAUGE 3 (RIGHT): COMPUTER TEMPS GAUGE (Single Top Needle)
struct VintageTempGauge: View {
    let cpuTemperature: Double    // e.g. 30 to 110°C
    var diameter: CGFloat = 148

    // Single Top needle: 30°C (-60 deg) to 110°C (+60 deg)
    private var needleAngle: Angle {
        let clampedTemp = min(max(cpuTemperature, 30.0), 110.0)
        let percent = (clampedTemp - 30.0) / (110.0 - 30.0)
        return Angle(degrees: -60.0 + (percent * 120.0))
    }

    var body: some View {
        let radius = diameter / 2
        ZStack {
            // Dial Background
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(white: 0.14),
                            Color(white: 0.08),
                            Color(white: 0.03)
                        ]),
                        center: .center,
                        startRadius: 20,
                        endRadius: radius
                    )
                )
                .frame(width: diameter - 12, height: diameter - 12)

            // Inner Shadow
            Circle()
                .stroke(Color.black.opacity(0.7), lineWidth: 6)
                .frame(width: diameter - 14, height: diameter - 14)
                .blur(radius: 2)

            // Top Arc Ticks (-60 to +60 deg)
            Path { path in
                for i in 0...10 {
                    let angleDeg = -60.0 + (Double(i) / 10.0 * 120.0)
                    let rad = angleDeg * .pi / 180.0
                    let tickLen: CGFloat = (i == 0 || i == 5 || i == 10) ? 6.5 : 4.0
                    let rOuter = radius - 10
                    let rInner = rOuter - tickLen

                    let x1 = radius + CGFloat(sin(rad)) * rInner
                    let y1 = radius - CGFloat(cos(rad)) * rInner
                    let x2 = radius + CGFloat(sin(rad)) * rOuter
                    let y2 = radius - CGFloat(cos(rad)) * rOuter

                    path.move(to: CGPoint(x: x1, y: y1))
                    path.addLine(to: CGPoint(x: x2, y: y2))
                }
            }
            .stroke(Color(white: 0.85), lineWidth: 1.2)

            // Top Redline Tick at High Temp (indices 8, 9, 10 = 94°C to 110°C)
            Path { path in
                for i in 8...10 {
                    let angleDeg = -60.0 + (Double(i) / 10.0 * 120.0)
                    let rad = angleDeg * .pi / 180.0
                    let tickLen: CGFloat = (i == 10) ? 6.5 : 4.5
                    let rOuter = radius - 10
                    let rInner = rOuter - tickLen

                    let x1 = radius + CGFloat(sin(rad)) * rInner
                    let y1 = radius - CGFloat(cos(rad)) * rInner
                    let x2 = radius + CGFloat(sin(rad)) * rOuter
                    let y2 = radius - CGFloat(cos(rad)) * rOuter

                    path.move(to: CGPoint(x: x1, y: y1))
                    path.addLine(to: CGPoint(x: x2, y: y2))
                }
            }
            .stroke(Color(red: 0.95, green: 0.25, blue: 0.1), lineWidth: 1.5)

            // Top Scale Labels: "C" (Cold) and "H" (Hot)
            Text("C")
                .font(.system(size: 9.5, weight: .black, design: .serif))
                .foregroundColor(Color(white: 0.9))
                .position(
                    x: radius + CGFloat(sin(-60.0 * .pi / 180.0)) * (radius - 23),
                    y: radius - CGFloat(cos(-60.0 * .pi / 180.0)) * (radius - 23)
                )

            Text("H")
                .font(.system(size: 9.5, weight: .black, design: .serif))
                .foregroundColor(Color(red: 0.95, green: 0.3, blue: 0.15))
                .position(
                    x: radius + CGFloat(sin(60.0 * .pi / 180.0)) * (radius - 23),
                    y: radius - CGFloat(cos(60.0 * .pi / 180.0)) * (radius - 23)
                )

            // Brushed Gunmetal Center Plate
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.36, green: 0.35, blue: 0.33),
                                Color(red: 0.44, green: 0.42, blue: 0.38),
                                Color(red: 0.28, green: 0.27, blue: 0.25)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: diameter * 0.50, height: diameter * 0.50)
                    .overlay(
                        Circle()
                            .stroke(Color(white: 0.20), lineWidth: 1.0)
                    )

                // Screws at 9 and 3 o'clock
                HStack {
                    ZStack {
                        Circle().fill(Color(white: 0.18)).frame(width: 4.5, height: 4.5)
                        Rectangle().fill(Color.black).frame(width: 3.0, height: 0.8)
                    }
                    Spacer()
                    ZStack {
                        Circle().fill(Color(white: 0.18)).frame(width: 4.5, height: 4.5)
                        Rectangle().fill(Color.black).frame(width: 3.0, height: 0.8)
                    }
                }
                .frame(width: diameter * 0.36)

                // Dedicated Computer Temps Labels
                VStack(spacing: 2) {
                    Text("TF")
                        .font(.system(size: 8.0, weight: .bold, design: .serif))
                        .foregroundColor(Color(white: 0.8))

                    Spacer().frame(height: 14)

                    Text("TEMP")
                        .font(.system(size: 10.0, weight: .heavy, design: .serif))
                        .foregroundColor(Color(white: 0.95))

                    Text(String(format: "%.0f°C", cpuTemperature))
                        .font(.system(size: 8.0, weight: .black, design: .monospaced))
                        .foregroundColor(Color(red: 0.95, green: 0.45, blue: 0.2))

                    Text("CELSIUS")
                        .font(.system(size: 5.0, weight: .semibold))
                        .foregroundColor(Color(white: 0.60))
                }
            }

            // Single Top Needle (Pointing UP to Temperature)
            VintageNeedle(angle: needleAngle, length: radius - 26, hubDiameter: 22, diameter: diameter)

            // Domed Glass Reflection
            VintageGlassReflection(diameter: diameter)

            // Chrome Outer Bezel
            VintageChromeBezel(diameter: diameter)
        }
        .frame(width: diameter, height: diameter)
    }
}

// MARK: - Vintage Jewel Warning & Indicator Lights
struct VintageJewelLight: View {
    let iconName: String
    let color: Color
    let isActive: Bool
    var diameter: CGFloat = 18

    var body: some View {
        ZStack {
            // Chrome bezel ring
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [Color(white: 0.9), Color(white: 0.4), Color(white: 0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .frame(width: diameter, height: diameter)

            // Dark jewel lens base
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            isActive ? color : Color(white: 0.14),
                            isActive ? color.opacity(0.8) : Color(white: 0.06)
                        ]),
                        center: .center,
                        startRadius: 1,
                        endRadius: diameter / 2
                    )
                )
                .frame(width: diameter - 3, height: diameter - 3)

            // Inner bulb glow
            Circle()
                .fill(color.opacity(0.6))
                .frame(width: diameter - 4, height: diameter - 4)
                .blur(radius: 2)
                .opacity(isActive ? 1.0 : 0.0)

            // Icon / Symbol
            Image(systemName: iconName)
                .font(.system(size: diameter * 0.42, weight: .bold))
                .foregroundColor(isActive ? .white : Color(white: 0.35))
        }
        .frame(width: diameter, height: diameter)
    }
}
