//
//  NewNoteController.swift
//  NoteTaker
//
//  Created by Duke Bartholomew on 12/6/23.
//

import UIKit
import AVFoundation
import Speech

class NewNoteController: UIViewController {
    
    @IBOutlet weak var micButton: UIButton!
    
    // MARK: Properties
    /// The speech recogniser used by the controller to record the user's speech.
  
    private var speechRecogniser = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
        
    /// The current speech recognition request. Created when the user wants to begin speech recognition
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
        
    /// The current speech recognition task. Created when the user wants to begin speech recognition.
    private var recognitionTask: SFSpeechRecognitionTask?
        
    /// The audio engine used to record input from the microphone.
    private let audioEngine = AVAudioEngine()
    

    let noteManager = NoteManager.shared

    var initialNoteBody: String?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        dictation.text = initialNoteBody

        // Set the image content mode to scale aspect fit
        micButton.imageView?.contentMode = .scaleAspectFit
        
        // Get the original image
        if let originalImage = micButton.imageView?.image {
            // Resize the image (change 2.0 to your desired scale factor)
            let resizedImage = originalImage.resized(to: CGSize(width: originalImage.size.width * 5.0, height: originalImage.size.height * 5.0))
            
            // Tint the image with orange color
            let tintedImage = resizedImage.withRenderingMode(.alwaysTemplate)
            
            // Set the tinted image to the button
            micButton.setImage(tintedImage, for: .normal)
            
            // Set the tint color to orange
            micButton.tintColor = UIColor.orange
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            view.addGestureRecognizer(tap)
        
    }
    
    func startRecording() {
        // setup recongizer
        guard speechRecogniser.isAvailable else {
            // Speech recognition is unavailable, so do not attempt to start.
            return
        }
        
        // make sure we have permission
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            SFSpeechRecognizer.requestAuthorization({ (status) in
                // Handle the user's decision
                print(status)
            })
            return
        }
        
        
        // setup audio
        let audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        }
        catch {
            fatalError("Audio engine could not be setup")
            
        }

        if recognitionRequest == nil {
            // setup reusable request (if not already)
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            
            // perform on device, if possible
            // NOTE: this will usually limit the voice analytics results
            if speechRecogniser.supportsOnDeviceRecognition {
                print("Using on device recognition, voice analytics may be limited.")
                recognitionRequest?.requiresOnDeviceRecognition = true
            }else{
                print("Using server for recognition.")
            }
        }
        
        // get a handle to microphone input handler
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            // Handle error
            return
        }
        
        // define recognition task handling
        recognitionTask = speechRecogniser.recognitionTask(with: recognitionRequest) { [unowned self] result, error in
            
            // if results is not nil, update label with transcript
            if let result = result {
                let spokenText = result.bestTranscription.formattedString
                DispatchQueue.main.async{
                    // fill in the label here
                    self.dictation.text = spokenText
                }
            }
            
            // if the result is complete, stop listening to microphone
            // this can happen if the user lifts finger from button OR request times out
            if result?.isFinal ?? (error != nil) {
                // this will remove the listening tap
                // so that the transcription stops
                inputNode.removeTap(onBus: 0)
                if(error != nil){
                    print(error)
                }
                else{
                    print(result!)
                }
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            // this is a fast operation, only adding to the audio queue
            self.recognitionRequest?.append(buffer)
        }

        // this kicks off the entire recording process, adding audio to the queue
        audioEngine.prepare()
        do{
            try audioEngine.start()
        }
        catch {
            fatalError("Audio engine could not start")
            }
        }
    
        func stopRecording() {
            if audioEngine.isRunning{
                audioEngine.stop()
                recognitionRequest?.endAudio()
            }
        }
    
        @objc func dismissKeyboard() {
            view.endEditing(true)
        }
    
    @IBAction func pickLanguage(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            speechRecogniser = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
        case 1:
            speechRecogniser = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
        default:
            break
        }

    }
    
    @IBAction func recordingPressed(_ sender: UIButton) {
        // called on "Touch Down" action
        
        
        self.startRecording()

    }
    
    
    @IBAction func recordingReleased(_ sender: UIButton) {
        //called on "Touch Up Inside" action
        self.stopRecording()
        

    }
    
    @IBOutlet weak var dictation: UITextView!
    
    @IBAction func saveNote(_ sender: UIBarItem){
        let alertController = UIAlertController(title: "New Note", message: "", preferredStyle: .alert)

        alertController.addTextField { (textField) in
            textField.placeholder = "Title"
        }
        

        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let title = alertController.textFields?.first?.text,
                  let body = self?.dictation.text,
                  !title.isEmpty,
                  !body.isEmpty else { return }

            self?.noteManager.addNote(title: title, body: body)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    
}

extension UIImage {
    func resized(to newSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}



// Extension to resize UIImage

