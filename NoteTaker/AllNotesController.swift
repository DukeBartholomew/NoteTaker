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
        let filePath = "/path"
        
        do {
            // Read the content of the file
            let content = try String(contentsOfFile: filePath, encoding: .utf8)
            
            // Split the content into an array of lines
            let titles = content.components(separatedBy: .newlines)
            
            // Remove any empty lines
            let nonEmptyTitles = titles.filter { !$0.isEmpty }
            
            // Update your notes array with the titles
            notes = nonEmptyTitles.map { title in
                // Assuming your Note struct has an initializer that takes a title
                return Note(title: title)
            }
            
            tableView.reloadData() // Reload the table view after fetching data
            
            print("Fetched \(notes.count) objects.")
            
            if notes.isEmpty {
                print("Fetched nothing for titles.")
            } else {
                for note in notes {
                    print("Fetched title: \(note.title)")
                }
            }
        } catch let error {
            print("Error fetching data: \(error)")
        }
    }




    // MARK: - UITableViewDataSource

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

