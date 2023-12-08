//
//  NoteManager.swift
//  NoteTaker
//
//  Created by Duke Bartholomew on 12/7/23.
//

import Foundation

struct Note: Codable {
    var title: String
}

class NoteManager {
    static let shared = NoteManager()

    private var notes: [Note] = []
    private let fileName = "notes.json"

    private init() {
        loadNotes()
    }

    func add(note: Note) {
        notes.append(note)
        saveNotes()
    }

    func getAllNotes() -> [Note] {
        return notes
    }

    private func saveNotes() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(notes)

            if let filePath = filePath() {
                try data.write(to: filePath)
            }
        } catch {
            print("Error encoding notes: \(error)")
        }
    }

    private func loadNotes() {
        guard let filePath = filePath(), FileManager.default.fileExists(atPath: filePath.path) else {
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
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return documentsDirectory?.appendingPathComponent(fileName)
    }
}

