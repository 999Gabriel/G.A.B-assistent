//
//  SystemInfo.swift
//  Jarvis
//
//  Created by Gabriel Winkler on 1/14/25.
//

import Foundation
import Network

// MARK: - SystemInfo

struct SystemInfo {
    // CPU Usage
    static func getCPUUsage() -> Double {
        var info = host_cpu_load_info()
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info>.size / MemoryLayout<integer_t>.size)
        
        let result = withUnsafeMutablePointer(to: &info) {
            host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, UnsafeMutableRawPointer($0).assumingMemoryBound(to: integer_t.self), &count)
        }
        
        guard result == KERN_SUCCESS else { return -1 }

        let totalTicks = Double(info.cpu_ticks.0 + info.cpu_ticks.1 + info.cpu_ticks.2 + info.cpu_ticks.3)
        let idleTicks = Double(info.cpu_ticks.3)
        
        return 100 * (1 - (idleTicks / totalTicks))
    }

    // RAM Usage
    static func getRAMUsage() -> Double {
        var size = Int32(0)
        sysctlbyname("hw.memsize", &size, nil, nil, 0)
        let totalMemory = Double(size) / 1_073_741_824 // Convert to GB

        var vmStats = vm_statistics_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics_data_t>.size) / 4
        // Hier korrigieren wir den Typ des Zeigers, um integer_t zu verwenden
        let result = withUnsafeMutablePointer(to: &vmStats) {
            host_statistics(mach_host_self(), HOST_VM_INFO, UnsafeMutableRawPointer($0).assumingMemoryBound(to: integer_t.self), &count)
        }

        guard result == KERN_SUCCESS else { return -1 }

        let freeMemory = Double(vmStats.free_count) * Double(vm_page_size) / 1_073_741_824 // Convert to GB
        return totalMemory - freeMemory
    }

    // Network Status
    static func getNetworkStatus() -> String {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        var networkStatus = "Unbekannt"
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                networkStatus = "Verbunden"
            } else {
                networkStatus = "Nicht verbunden"
            }
        }
        
        monitor.start(queue: queue)
        
        return networkStatus
    }
}
