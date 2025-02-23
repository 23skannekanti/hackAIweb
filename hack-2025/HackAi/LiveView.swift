import SwiftUI
import Charts

struct LiveView: View {
    @State private var vitalsHistory: [VitalsReading] = []
    @State private var timer: Timer?

    var body: some View {
        NavigationView {
            ZStack {
                // Gradient Background
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)]),
                    startPoint: .top, endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    // **Live Vitals Heading**
                    Text("Live Vitals")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, -50) // Moves title higher
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    // **Heart Rate Gauge**
                    if let latest = vitalsHistory.last {
                        HeartRateGauge(currentHR: latest.heartRate)
                            .frame(height: 200)

                        // **Vitals Summary (O2 Sat & BP)**
                        HStack(spacing: 40) {
                            VStack {
                                Text("O2 Sat")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("\(latest.oxygen)%")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            VStack {
                                Text("BP (mmHg)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("\(latest.systolicBP)/\(latest.diastolicBP)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                        }
                    } else {
                        Text("No vitals yet...")
                    }

                    // **Blood Pressure Chart**
                    if #available(iOS 16.0, *) {
                        Chart(vitalsHistory) { reading in
                            LineMark(
                                x: .value("Time", reading.timestamp),
                                y: .value("Systolic", reading.systolicBP)
                            )
                            .foregroundStyle(.red)
                            
                            LineMark(
                                x: .value("Time", reading.timestamp),
                                y: .value("Diastolic", reading.diastolicBP)
                            )
                            .foregroundStyle(.blue)
                        }
                        .frame(height: 150)
                        .padding(.horizontal)
                    } else {
                        Text("Blood Pressure chart requires iOS 16+")
                            .foregroundColor(.gray)
                    }

                    // **Vitals Log (Recent Readings)**
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(vitalsHistory.reversed()) { reading in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(reading.timestamp, style: .time)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("HR: \(reading.heartRate) bpm | O2: \(reading.oxygen)% | BP: \(reading.systolicBP)/\(reading.diastolicBP)")
                                        .font(.subheadline)
                                        .padding(10)
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(8)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .frame(maxHeight: 200) // Ensures the history is always visible
                    .padding(.bottom, 20)
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("") // Hides default navigation title
            .onAppear(perform: startSimulatedUpdates)
            .onDisappear(perform: stopSimulatedUpdates)
        }
    }
    
    // Simulated timer for real-time updates
    private func startSimulatedUpdates() {
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            let newReading = VitalsReading(
                timestamp: Date(),
                heartRate: Int.random(in: 75...85),
                oxygen: Int.random(in: 94...100),
                systolicBP: Int.random(in: 110...140),
                diastolicBP: Int.random(in: 70...90)
            )
            vitalsHistory.append(newReading)
        }
        timer?.fire()
    }

    private func stopSimulatedUpdates() {
        timer?.invalidate()
        timer = nil
    }
}

// Heart Rate Circular Gauge
struct HeartRateGauge: View {
    let currentHR: Int
    
    var body: some View {
        ZStack {
            // **Outer Circle**
            Circle()
                .trim(from: 0, to: 1)
                .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .rotationEffect(.degrees(-90))

            // **Progress Circle (HR)**
            Circle()
                .trim(from: 0, to: gaugeFraction)
                .stroke(Color.red, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: gaugeFraction)

            // **Text in Center**
            VStack {
                Text("\(currentHR) bpm")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Heart Rate")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
    
    private var gaugeFraction: CGFloat {
        let fraction = Double(currentHR) / 200.0
        return min(max(fraction, 0), 1)
    }
}

// Data Model for Vitals
struct VitalsReading: Identifiable {
    let id = UUID()
    let timestamp: Date
    let heartRate: Int
    let oxygen: Int
    let systolicBP: Int
    let diastolicBP: Int
}

#Preview {
    LiveView()
}
