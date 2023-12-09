//
//  AllNotesController.swift
//  NoteTaker
//
//  Created by Duke Bartholomew on 12/6/23.
//

import UIKit
import CoreData

class AllNotesController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    var notes: [Note] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize NoteManager
        let noteManager = NoteManager.shared
        
        noteManager.addNote(title: "New Note", body: "This is the body of the new note.")

        setupTableView()
        fetchNotes()
    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NoteCell")
    }

    func fetchNotes() {
        // Specify the file path where your notes are stored
        let folderName = "VoicePadPro"
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error getting document directory.")
            return
        }

        let voicePadFolderUrl = documentDirectory.appendingPathComponent(folderName, isDirectory: true)

        // Ensure that the VoicePad folder exists
        do {
            try FileManager.default.createDirectory(at: voicePadFolderUrl, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating VoicePadPro folder: \(error)")
            return
        }

        do {
            // Get the enumerator for the VoicePad folder
            if let enumerator = FileManager.default.enumerator(atPath: voicePadFolderUrl.path) {
                // Iterate through each file in the folder
                for case let file as String in enumerator {
                    // Construct the full file URL
                    let fileUrl = voicePadFolderUrl.appendingPathComponent(file)

                    do {
                        // Ensure that fileUrl represents a file
                        var isDirectory: ObjCBool = false
                        if FileManager.default.fileExists(atPath: fileUrl.path, isDirectory: &isDirectory) && !isDirectory.boolValue {
                            // Read the content of each file
                            let data = try Data(contentsOf: fileUrl)
                            let decoder = JSONDecoder()
                            let note = try decoder.decode(Note.self, from: data)
                            notes.append(note)
                        }
                    } catch {
                        print("Error reading content of file \(fileUrl): \(error)")
                        // Handle the error as needed
                    }
                }
            }
        } catch let error {
            print("Error fetching data: \(error)")
        }

        tableView.reloadData() // Reload the table view after fetching data

        print("Fetched \(notes.count) objects.")

        if notes.isEmpty {
            print("Fetched nothing for titles.")
        } else {
            for note in notes {
                print("Fetched title: \(note.title), body: \(note.body), date created: \(note.dateCreated)")
            }
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.isEmpty ? 1 : notes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        
        if notes.isEmpty {
            cell.textLabel?.text = "Empty Notepad"
        } else {
            let note = notes[indexPath.row]
            cell.textLabel?.text = note.title // Access the 'title' property directly
            // Configure the cell with other properties if needed
        }
        
        return cell
    }
}
