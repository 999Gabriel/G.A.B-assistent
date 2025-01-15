//
//  SystemOverviewView.swift
//  Jarvis
//
//  Created by Gabriel Winkler on 1/14/25.
//

import SwiftUI

struct SystemOverviewView: View {
    @State private var cpuUsage: Double = 30.0 // Initialer Wert
    @State private var ramUsage: Double = 4.0 // Initialer Wert in GB
    @State private var networkStatus: String = "Unbekannt"
    
    var body: some View {
        VStack(spacing: 30) {
            // Systemübersicht Titel
            Text("Systemübersicht")
                .font(.system(size: 36, weight: .bold, design: .monospaced))
                .foregroundColor(.cyan)
                .padding(.top, 20)

            // CPU Auslastung
            SystemStatCard(title: "CPU-Auslastung", value: String(format: "%.2f", cpuUsage) + "%", color: .green)

            // RAM
            SystemStatCard(title: "RAM (GB)", value: String(format: "%.2f", ramUsage) + " GB", color: .yellow)

            // Netzwerkstatus
            SystemStatCard(title: "Netzwerkstatus", value: networkStatus, color: .blue)

            Spacer() // Platz nach unten
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(20)
            .shadow(color: .blue, radius: 10)
        )
        .onAppear {
            // Systemdaten aktualisieren
            updateSystemData()
        }
    }

    func updateSystemData() {
        // CPU und RAM-Daten aktualisieren
        cpuUsage = SystemInfo.getCPUUsage()
        ramUsage = SystemInfo.getRAMUsage()

        // Netzwerkstatus
        networkStatus = SystemInfo.getNetworkStatus()
    }
}

struct SystemStatCard: View {
    var title: String
    var value: String
    var color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title2)
                .foregroundColor(.white)
            Spacer()
            Text(value)
                .font(.title3)
                .foregroundColor(color)
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(15)
        .shadow(color: .blue, radius: 5)
    }
}
