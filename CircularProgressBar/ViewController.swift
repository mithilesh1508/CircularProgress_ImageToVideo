//
//  ViewController.swift
//  CircularProgressBar
//
//  Created by Mithilesh on 11/09/24.
//

import UIKit

class ViewController: UIViewController {

    private let progressManager: ProgressManager = ProgressManager()
    private let progressBarView = CircularProgressBar()
    private var videoCreationService: VideoCreationService?
    private let cancelButton = UIButton(type: .system)
    private let startButton = UIButton(type: .system)

    //private let progressView = UIProgressView(progressViewStyle: .default)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        setupCancelButton()
        setupProgressBar()
       
        /*
        setupCancelButton()
        setupProgressBar()
        startProgressTask()
        
        //bind progress update to UI
        progressManager.onProgressUpdate = {
            [weak self] progress in
            self?.progressBarView.progress = progress
        }
        */
    
    }
    
    private func resetUIAfterCompletion()
    {
        // Reset the progress view and hide the cancel button after the process completes
        progressBarView.progress = 0.0
    }
    
    private func setupProgressBar()
    {
        progressBarView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        progressBarView.center = CGPoint(x: view.center.x + 20, y: view.center.y)//view.center
        view.addSubview(progressBarView)
    }
    private func setupCancelButton()
    {
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTask), for: .touchUpInside)
        cancelButton.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        cancelButton.center = CGPoint(x: view.center.x - 50, y: view.center.y + 150)
        view.addSubview(cancelButton)
        
        startButton.setTitle("Start", for: .normal)
        startButton.addTarget(self, action: #selector(startTask), for: .touchUpInside)
        startButton.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        startButton.center = CGPoint(x: cancelButton.center.x + 70, y: view.center.y + 150)
        view.addSubview(startButton)
    }
   
    @objc private func cancelTask()
    {
        progressBarView.progress = 0.0
        cancelButton.isHidden = false
        videoCreationService?.cancelVideoCreation()
    }
    @objc private func startTask()
    {
        let images = [
            UIImage(named: "portrait-attractive-young.jpg")!,
            UIImage(named: "side-view-young-woman.jpg")!,
            UIImage(named: "smiling-portrait-young.jpg")!,
            UIImage(named: "pretty-girl-with.jpg")!
        ]
        
        let outPutURL = URL(fileURLWithPath: NSTemporaryDirectory().appending("MyVideo.mp4"))
        
        videoCreationService = VideoCreationService(images: images, outputURL: outPutURL)
        // Start creating the video with progress updates
        videoCreationService?.createVideo(progressHandler: { [weak self] progress in
            DispatchQueue.main.async {
                self?.progressBarView.progress = Double(progress)
               // self?.progressView.progress = progress
            }
        }, completion: { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    print("Video creation completed!")
                    self?.cancelButton.isHidden = false
                    // Handle video completion, like saving or playing the video
                } else {
                    print("Video creation canceled or failed.")
                }
                self?.resetUIAfterCompletion()
            }
        })
    }
    private func startProgressTask(){
        progressManager.startTask(with: 10)
    }
}

