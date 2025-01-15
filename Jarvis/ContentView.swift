import SwiftUI
import Network

class NetworkMonitor: ObservableObject {
    @Published var networkStatus: String = "Unbekannt"
    
    private var monitor: NWPathMonitor?

    init() {
        self.monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitorQueue")

        monitor?.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self.networkStatus = "Verbunden"
                } else {
                    self.networkStatus = "Nicht verbunden"
                }
            }
        }
        monitor?.start(queue: queue)
    }

    deinit {
        monitor?.cancel()
    }
}

struct ContentView: View {
    @State private var command: String = ""
    @State private var response: String = "Willkommen bei G.A.B"
    @State private var isAnimating = false
    @ObservedObject private var speechRecognizer = SpeechRecognizer()
    @ObservedObject private var networkMonitor = NetworkMonitor()

    var body: some View {
        ZStack(alignment: .topTrailing) {
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            .overlay(GridBackground())

            VStack(spacing: 50) {
                Text("G.A.B")
                    .font(.system(size: 60, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)
                    .shadow(color: .blue, radius: 10, x: 0, y: 0)

                CircleStatusView()

                Text(response)
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(15)
                    .shadow(color: .blue, radius: 5)

                Text("Netzwerkstatus: \(networkMonitor.networkStatus)")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .padding()

                HStack {
                    TextField("Gib einen Befehl ein...", text: $command)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.white)

                    Button(action: executeCommand) {
                        Text("→")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.cyan)
                            .cornerRadius(30)
                            .shadow(color: .blue, radius: 10)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()

            // Mikrofon
            VStack {
                HStack {
                    MicrophoneButton(speechRecognizer: speechRecognizer)
                        .padding(.top)
                        .padding(.leading)
                    Spacer()
                }
                Spacer()
            }

            // SystemOverviewView in der rechten oberen Ecke
            SystemOverviewView()
                .frame(width: 400, height: 500) // Größere Ansicht
                .padding(.top, 30) // Abstand von oben
                .padding(.trailing, 30) // Abstand von rechts
                .zIndex(1) // Sicherstellen, dass es über anderen Views liegt
        }
        .onAppear {
            isAnimating = true
        }
    }

    func executeCommand() {
        if command.lowercased() == "wetter" {
            response = "Es ist sonnig bei 25°C."
        } else if command.lowercased() == "zeit" {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            response = "Es ist \(formatter.string(from: Date()))."
        } else {
            response = "Ich verstehe den Befehl '\(command)' nicht."
        }

        command = ""
    }
}

// Weitere Views bleiben unverändert, z.B. MicrophoneButton, CircleStatusView, SystemOverviewView, GridBackground

// Animiertes Mikrofon-Icon mit futuristischem Effekt
struct MicrophoneButton: View {
    @ObservedObject var speechRecognizer: SpeechRecognizer

    @State private var isRecording = false // Zustand, ob gerade aufgenommen wird
    @State private var scale: CGFloat = 1.0 // Skalierungsfaktor für Animation

    var body: some View {
        ZStack {
            // Pulsierender Lichtkreis hinter dem Mikrofon
            Circle()
                .strokeBorder(Color.cyan.opacity(0.7), lineWidth: 2)
                .frame(width: 80, height: 80)
                .scaleEffect(isRecording ? 1.2 : 1)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isRecording)
            
            // Mikrofon-Icon
            Image(systemName: isRecording ? "mic.fill" : "mic")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(isRecording ? .green : .white)
                .animation(.easeInOut(duration: 0.3), value: isRecording)
        }
        .onTapGesture {
            if isRecording {
                speechRecognizer.stopListening() // Beendet die Sprachaufnahme
            } else {
                speechRecognizer.startListening() // Startet die Sprachaufnahme
            }
            isRecording.toggle() // Wechselt den Aufnahmezustand
        }
    }
}

// Animierter Kreis für den Status
struct CircleStatusView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Pulsierender äußerer Kreis
            Circle()
                .stroke(lineWidth: 4)
                .foregroundColor(.cyan.opacity(0.3))
                .frame(width: 200, height: 200)
                .scaleEffect(isAnimating ? 1.3 : 1)
                .animation(Animation.easeInOut(duration: 2).repeatForever(), value: isAnimating)

            // Fester innerer Kreis
            Circle()
                .stroke(lineWidth: 8)
                .foregroundColor(.cyan)
                .frame(width: 150, height: 150)

            // Rotierende Linien
            RotatingLines()

            // Text in der Mitte
            Text("ONLINE")
                .font(.title)
                .foregroundColor(.white)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// Rotierende Linien als Effekt
struct RotatingLines: View {
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            ForEach(0..<6) { i in
                Capsule()
                    .fill(Color.cyan)
                    .frame(width: 4, height: 40)
                    .offset(y: -100)
                    .rotationEffect(.degrees(Double(i) * 60))
            }
        }
        .rotationEffect(.degrees(rotation))
        .animation(Animation.linear(duration: 5).repeatForever(autoreverses: false), value: rotation)
        .onAppear {
            rotation = 360
        }
    }
}

// Hintergrund-Grid mit Animation
struct GridBackground: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let spacing: CGFloat = 30
                for x in stride(from: 0, through: geometry.size.width, by: spacing) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                }
                for y in stride(from: 0, through: geometry.size.height, by: spacing) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                }
            }
            .stroke(Color.blue.opacity(0.2), lineWidth: 0.5)
        }
    }
}
