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
//        let noteManager = NoteManager.shared

        setupTableView()
        fetchNotes()
        notes.sort { $0.title < $1.title }

    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NoteCell")
    }

    func fetchNotes() {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error getting document directory.")
            return
        }

        let filePath = documentDirectory.appendingPathComponent("notes.json", isDirectory: false)

        do {
            let data = try Data(contentsOf: filePath)
            print("Data from file: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
            let decoder = JSONDecoder()
            notes = try decoder.decode([Note].self, from: data)
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
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         // Check if there are notes and the selected index is within bounds
         guard !notes.isEmpty, indexPath.row < notes.count else {
             return
         }

         // Get the selected note
         let selectedNote = notes[indexPath.row]

         // Perform the segue programmatically
         performSegue(withIdentifier: "showNewNote", sender: selectedNote)
     }

     // MARK: - Navigation

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "showNewNote", let newNoteController = segue.destination as? NewNoteController {
             // Check if sender is of type Note
             if let selectedNote = sender as? Note {
                 // Pass the selected note's body to the NewNoteController
                 newNoteController.initialNoteBody = selectedNote.body
             }
         }
     }
  
    @IBAction func sortByValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            // Sort by title in alphabetical order
            notes.sort { $0.title < $1.title }
        case 1:
            // Sort by date in descending order (most recent to least)
            notes.sort { $0.dateCreated > $1.dateCreated }
        default:
            break
        }

        tableView.reloadData()
    }
}
