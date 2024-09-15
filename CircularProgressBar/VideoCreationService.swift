//
//  VideoServices.swift
//  CircularProgressBar
//
//  Created by Mithilesh on 14/09/24.
//

import UIKit
import AVFoundation
class VideoCreationService
{
    private let images: [UIImage]
    private let outputURL: URL
    //private let progressHandler: (Float) -> Void
    
    private let fps: Int = 30
    private let oneImageDuration = 5
    private var videoDuration = 0
    private var isCancelled = false
    
    init(images: [UIImage], outputURL: URL) {
        self.images = images
        self.outputURL = outputURL
        print("outputURL==",outputURL)
    }
    
    func createVideo(progressHandler: @escaping (Float) -> Void, completion: @escaping (Bool) -> Void) {
        //Update progress based on number of image processed
        let totalImages = self.images.count
        videoDuration = (totalImages * oneImageDuration)
        let frameCount = (videoDuration * (fps))
        
        let framesPerImage = frameCount / totalImages // Divide frames equally among images
        
        guard totalImages > 0 else {
            completion(false)
            return
        }
        
        let videoSize = images.first!.size
        do {
            try FileManager.default.removeItem(at: outputURL)
        }
        catch {}
        let writer = try! AVAssetWriter(outputURL: outputURL, fileType: .mp4)
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: videoSize.width,
            AVVideoHeightKey: videoSize.height
        ]
        let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput)
        writer.add(writerInput)
        writer.startWriting()
        writer.startSession(atSourceTime: .zero)
        let queue = DispatchQueue(label: "videoQueue")
        
        //video frame insertion logic here...
        var frameIndex = 0
        var currentImageIndex = 0 // Track the current image index
                
        writerInput.requestMediaDataWhenReady(on: queue)
        { [weak self] in
            guard let self = self else { return }
            while writerInput.isReadyForMoreMediaData && frameIndex < frameCount && !self.isCancelled {
              
                // Get the correct image for the current frame based on framesPerImage
                if frameIndex / framesPerImage != currentImageIndex && currentImageIndex < totalImages - 1 {
                    currentImageIndex += 1
                }
                if let buffer = self.pixelBuffer(from: self.images[currentImageIndex], size: videoSize) {
                    let frameTime = CMTime(value: CMTimeValue(frameIndex), timescale: CMTimeScale(self.fps))
                    adaptor.append(buffer, withPresentationTime: frameTime)
                    frameIndex += 1
                }
                
                // Update progress
                let progress = Float(frameIndex) / Float(frameCount)
                progressHandler(progress)
            }
            if self.isCancelled {
                writer.cancelWriting()
                print("Video creation canceled.")
                completion(false)
                return
            }
            if frameIndex >= frameCount {
                writerInput.markAsFinished()
                writer.finishWriting {
                    print("Video created successfully.")
                    completion(true)
                }
            }
        }
    }
    
    /// Cancel the video creation process
    func cancelVideoCreation() {
        isCancelled = true
    }
    /// Convert UIImage to CVPixelBuffer for video writing
    private func pixelBuffer(from image: UIImage, size: CGSize) -> CVPixelBuffer? {
        let attributes: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32ARGB, attributes as CFDictionary, &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        guard let cgImage = image.cgImage else { return nil }
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return buffer
    }
}
