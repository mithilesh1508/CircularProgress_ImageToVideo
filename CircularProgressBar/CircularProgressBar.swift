//
//  CircularProgressBarView.swift
//  CircularProgressBar
//
//  Created by Mithilesh on 11/09/24.
//

import UIKit
class CircularProgressBar: UIView
{
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    private let percentageLabel = UILabel()
    
    var progress: Double = 0{
        didSet{
            percentageLabel.text = "\(Int(progress * 100))%"
            progressLayer.strokeEnd = CGFloat(progress)
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView()
    {
        setupTrackLayer()
        setupProgressLayer()
        setupPercentageLabel()
    }
    private func setupTrackLayer(){
        let circularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: -CGFloat.pi / 2, endAngle: 3 * CGFloat.pi / 2, clockwise: true)
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)
    }
    
    private func setupProgressLayer()
    {
        let circularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: -CGFloat.pi / 2, endAngle: 3 * CGFloat.pi / 2, clockwise: true)
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = UIColor.systemRed.cgColor
        progressLayer.lineWidth = 10
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeEnd  = 0
        layer.addSublayer(progressLayer)
    }
    private func setupPercentageLabel(){
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        percentageLabel.center = center
        percentageLabel.text = "0%"
        percentageLabel.textAlignment = .center
        percentageLabel.font = UIFont.systemFont(ofSize: 18,weight: .bold)
        addSubview(percentageLabel)
    }
}
