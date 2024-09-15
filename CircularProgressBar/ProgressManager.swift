//
//  ProgressManager.swift
//  CircularProgressBar
//
//  Created by Mithilesh on 11/09/24.
//

import Foundation
protocol ProgressManaging{
    var progress: Double { get }
    func startTask(with duration: Double)
    func cancelTask()
}
class ProgressManager: ProgressManaging{
    var progress: Double = 0.0
    var timer: Timer?
    var onProgressUpdate: ((Double) -> Void)?
    
    func startTask(with duration: Double)
    {
        timer?.invalidate()
        progress = 0.0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.progress += 0.1 / duration
            self.onProgressUpdate?(self.progress)
            if self.progress >= 1.0{
                self.timer?.invalidate()
            }
        }
    }
    
    func cancelTask() {
        timer?.invalidate()
        progress = 0.0
        onProgressUpdate?(progress)
    }
//    func createVideoFromImages(){
//
//    }
}
