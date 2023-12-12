//
//  NoteManager.swift
//  NoteTaker
//
//  Created by Duke Bartholomew on 12/7/23.
//

import Foundation

struct Note: Codable {
    var title: String
    var body: String
    var dateCreated: Date
}

class NoteManager {
    static let shared = NoteManager()

    private var notes: [Note] = []
    private let fileName = "notes.json"

    private init() {
        loadNotes()

    }

    func addNote(title: String, body: String) {
        // Check if a note with the given title already exists
        if let existingNoteIndex = notes.firstIndex(where: { $0.title == title }) {
            // Note with the same title exists, update the body
            notes[existingNoteIndex].body = body
        } else {
            // Note with the title doesn't exist, create a new note
            let newNote = Note(title: title, body: body, dateCreated: Date())
            notes.append(newNote)
        }

        // Save the updated notes
        saveNotes()
    }

    func getAllNotes() -> [Note] {
        return notes
    }

    private func saveNotes() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(notes)

            guard let filePath = filePath() else {
                print("Error getting file path.")
                return
            }

            try data.write(to: filePath, options: .atomicWrite)
        } catch {
            print("Error encoding or saving notes: \(error)")
        }
    }

    private func loadNotes() {
        guard let filePath = filePath(), FileManager.default.fileExists(atPath: filePath.path) else {
            print("File doesn't exist.")
            return
        }

        do {
            let data = try Data(contentsOf: filePath)
            let decoder = JSONDecoder()
            notes = try decoder.decode([Note].self, from: data)
        } catch {
            print("Error decoding notes: \(error)")
        }
    }

    private func filePath() -> URL? {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error getting document directory.")
            return nil
        }

        return documentDirectory.appendingPathComponent(fileName, isDirectory: false)
    }
    
    func clearTable() {
       // Clear the notes array
       notes.removeAll()

       // Save the empty notes array to overwrite the existing notes.json file
       saveNotes()
    }

}
