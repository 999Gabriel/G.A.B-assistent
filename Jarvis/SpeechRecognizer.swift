//
//  SpeechRecognizer.swift
//  Jarvis
//
//  Created by Gabriel Winkler on 1/14/25.
//

import Foundation
import Speech
import Combine

class SpeechRecognizer: ObservableObject {
    private var recognizer = SFSpeechRecognizer(locale: Locale(identifier: "de-DE"))
    private var audioEngine = AVAudioEngine()
    private var recognitionTask: SFSpeechRecognitionTask?
    
    @Published var recognizedText = ""

    func startListening() {
        guard let recognizer = recognizer, recognizer.isAvailable else {
            recognizedText = "Spracherkennung nicht verfügbar."
            return
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode

        request.shouldReportPartialResults = true

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            if let result = result {
                self?.recognizedText = result.bestTranscription.formattedString
            }

            if let error = error {
                self?.recognizedText = "Fehler bei der Spracherkennung: \(error.localizedDescription)"
                self?.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
            }
        }

        do {
            audioEngine.prepare()
            try audioEngine.start()

            inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputNode.outputFormat(forBus: 0)) { (buffer, time) in
                request.append(buffer)
            }
        } catch {
            recognizedText = "Fehler beim Starten der Audioaufnahme: \(error.localizedDescription)"
        }
    }

    func stopListening() {
        audioEngine.stop()
        recognitionTask?.cancel()
    }
}
