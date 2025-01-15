//
//  RemindersView 2.swift
//  Jarvis
//
//  Created by Gabriel Winkler on 1/14/25.
//


import SwiftUI
import EventKit

struct RemindersView: View {
  @State private var reminders: [EKReminder] = []
  @State private var errorMessage: String?

  var body: some View {
    VStack {
      Text("Deine Erinnerungen")
        .font(.title)
        .padding()

      if let errorMessage = errorMessage {
        Text("Fehler: \(errorMessage)")
          .foregroundColor(.red)
          .padding()
      } else if reminders.isEmpty {
        Text("Keine Erinnerungen gefunden")
          .font(.subheadline)
          .foregroundColor(.gray)
      } else {
        List(reminders, id: \.calendarItemIdentifier) { reminder in
          Text(reminder.title)
        }
      }
    }
    .onAppear {
      requestReminderAccess()
    }
  }

  func requestReminderAccess() {
    let eventStore = EKEventStore()

    eventStore.requestFullAccessToReminders { success, error in
      if success {
        fetchReminders(from: eventStore)
      } else if let error = error {
        DispatchQueue.main.async {
          self.errorMessage = "Fehler: \(error.localizedDescription)"
        }
      } else {
        DispatchQueue.main.async {
          self.errorMessage = "Zugriff verweigert"
        }
      }
    }
  }

  func fetchReminders(from eventStore: EKEventStore) {
    let predicate = eventStore.predicateForReminders(in: nil)

    eventStore.fetchReminders(matching: predicate) { fetchedReminders in
      DispatchQueue.main.async {
        self.reminders = fetchedReminders ?? []
      }
    }
  }
}
