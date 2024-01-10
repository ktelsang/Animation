//
//  DownloadAnimationView.swift
//  Animation
//
//  Created by Kavyashree Hegde on 10/01/24.
//

import Foundation
import SwiftUI

struct DownloadAnimationView : UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = DownloadAnimationViewController()
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

class DownloadAnimationViewController: UIViewController {
    lazy var containerView: UIView = {
        let view = UIView()
        view.frame = CGRect(origin: CGPoint(x: CGRectGetMidX(self.view.frame), y: CGRectGetMidY(self.view.frame)), size: CGSize(width: 200, height: 200))
        view.center = self.view.center
        return view
    }()
    
    lazy var button: UIButton = {
        let view = UIButton()
        view.frame = CGRect(origin: CGPoint(x: self.view.center.x/2, y: 100), size: CGSize(width: 80, height: 30))
        view.center.x = self.view.center.x
        view.setTitle("Play", for: .normal)
        view.setTitle("Pause", for: .selected)
        view.addTarget(self, action: #selector(handleTouchUpEvent), for: .touchUpInside)
        view.backgroundColor = .blue
        return view
    }()
    
    let downloadAnimationAttributes = DownloadAnimationAttributes(circularViewWidthAndHeight: (80,80),
                                                                  downloadImageViewWidthAndHeight: (40,40),
                                                                  circularViewColor: .blue,
                                                                  downloadImageName: "download_animation",
                                                                  pulseLayerColor: .blue)
    
    lazy var downloadAnimation = DownloadAnimation(attributes: downloadAnimationAttributes, frame: CGRect(x: 0, y: 0, width: self.containerView.frame.width, height: self.containerView.frame.height))
    
    var play: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(containerView)
        self.view.addSubview(button)
        self.containerView.addSubview(downloadAnimation)
    }
    
    @objc
    func handleTouchUpEvent(sender: UIButton) {
        play.toggle()
        if play {
            sender.isSelected = true
            downloadAnimation.play()
        } else {
            sender.isSelected = false
            downloadAnimation.pause()
        }
    }
}

public struct DownloadAnimationAttributes {
    var circularViewWidthAndHeight: (width: CGFloat, height: CGFloat)
    var downloadImageViewWidthAndHeight: (width: CGFloat, height: CGFloat)
    var circularViewColor: UIColor
    var downloadImageName: String
    var pulseLayerColor: UIColor
    var pulseLayerLineWidth: CGFloat
    var uploadAnimation: Bool
    
    public init(circularViewWidthAndHeight: (width: CGFloat, height: CGFloat) = (300, 300),
                downloadImageViewWidthAndHeight: (width: CGFloat, height: CGFloat) = (60, 60),
                circularViewColor: UIColor = UIColor(red: 72/255.0, green: 160/255.0, blue: 219/255.0, alpha: 1),
                downloadImageName: String = "",
                pulseLayerColor: UIColor = UIColor(red: 72/255.0, green: 160/255.0, blue: 219/255.0, alpha: 1),
                pulseLayerLineWidth: CGFloat = 5.0,
                uploadAnimation: Bool = false) {
        self.circularViewWidthAndHeight = circularViewWidthAndHeight
        self.downloadImageViewWidthAndHeight = downloadImageViewWidthAndHeight
        self.circularViewColor = circularViewColor
        self.downloadImageName = downloadImageName
        self.pulseLayerColor = pulseLayerColor
        self.pulseLayerLineWidth = pulseLayerLineWidth
        self.uploadAnimation = uploadAnimation
    }
}

public class DownloadAnimation: UIView {
    
    lazy var filledCircularView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var emptyView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var downloadImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    lazy var pulseLayer: CAShapeLayer = {
        let pulseLayer = CAShapeLayer()
        pulseLayer.lineCap = .round
        pulseLayer.fillColor = UIColor.clear.cgColor
        pulseLayer.frame = bounds
        return pulseLayer
    }()
    
    var animate: Bool = false
    
    var attributes = DownloadAnimationAttributes()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(attributes: DownloadAnimationAttributes, frame: CGRect) {
        super.init(frame: frame)
        
        self.attributes = attributes
        loadLayers()
        loadViews()
    }
    
    public func isPlaying() -> Bool {
        return pulseLayer.animationKeys() != nil
    }
    
    public func play() {
        DispatchQueue.main.async {
            self.animate.toggle()
            self.animateLayer()
            self.attributes.uploadAnimation ? self.animateUploadImage() : self.animateDownloadImage()
        }
    }
    
    public func pause() {
        self.animate.toggle()
        pulseLayer.removeAllAnimations()
        self.attributes.uploadAnimation ? self.animateUploadImage() : self.animateDownloadImage()
    }
    
    private func loadLayers() {
        let centerPoint = self.center
        
        let circularPath = UIBezierPath(arcCenter: centerPoint, radius: self.bounds.width / 2 - 2, startAngle: -CGFloat.pi/2,
                                        endAngle: 2 * CGFloat.pi - CGFloat.pi/2, clockwise: true)
        
        emptyView.frame = bounds
        self.addSubview(emptyView)
        
        pulseLayer.path = circularPath.cgPath
        pulseLayer.strokeColor = attributes.pulseLayerColor.cgColor
        pulseLayer.lineWidth = attributes.pulseLayerLineWidth
        self.layer.addSublayer(pulseLayer)
    }
    
    private func loadViews() {
        filledCircularView.frame = CGRect(x: frame.midX - attributes.circularViewWidthAndHeight.width/2,
                                          y: frame.midY - attributes.circularViewWidthAndHeight.height/2,
                                          width: attributes.circularViewWidthAndHeight.width,
                                          height: attributes.circularViewWidthAndHeight.height)
        filledCircularView.backgroundColor = attributes.circularViewColor
        filledCircularView.layer.cornerRadius = filledCircularView.frame.width / 2
        filledCircularView.clipsToBounds = true
        emptyView.addSubview(filledCircularView)
        
        self.mask(withRect: filledCircularView.frame, inverse: false)
        
        downloadImageView.image = UIImage(named: attributes.downloadImageName)
        downloadImageView.frame = CGRect(x: frame.midX - attributes.downloadImageViewWidthAndHeight.width/2,
                                         y: frame.midY - attributes.downloadImageViewWidthAndHeight.height/2,
                                         width: attributes.downloadImageViewWidthAndHeight.width,
                                         height: attributes.downloadImageViewWidthAndHeight.height)
        if attributes.uploadAnimation {
            downloadImageView.transform = downloadImageView.transform.rotated(by: .pi)
        }
        emptyView.addSubview(downloadImageView)
    }
    
    private func animateLayer() {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.95
        scaleAnimation.toValue = 1.1
        
        let pulseOpacityAnimation = CABasicAnimation(keyPath: "opacity")
        pulseOpacityAnimation.fromValue = 1.0
        pulseOpacityAnimation.toValue = 0.8
        
        let groupedAnimation = CAAnimationGroup()
        groupedAnimation.animations = [scaleAnimation, pulseOpacityAnimation]
        groupedAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        groupedAnimation.duration = 1.5
        groupedAnimation.repeatCount = .greatestFiniteMagnitude
        
        pulseLayer.add(groupedAnimation, forKey: "scaleAnimation")
    }
    
    private func animateDownloadImage() {
        let width = downloadImageView.frame.width
        let height = downloadImageView.frame.height
        
        downloadImageView.frame = CGRect(x: frame.midX - width/2, y: self.frame.minY - height/2, width: width, height: height)
        
        UIView.animate(withDuration: 1.5, delay: 0, options: [.repeat], animations: {
            if self.animate {
                self.downloadImageView.frame = CGRect(x: self.frame.midX - width/2, y: self.frame.maxY - height/2, width: width, height: height)
            }
            
        }, completion: nil)
    }
    
    private func animateUploadImage() {
        let width = downloadImageView.frame.width
        let height = downloadImageView.frame.height
        
        downloadImageView.frame = CGRect(x: frame.midX - width/2, y: self.frame.maxY - height/2, width: width, height: height)
        
        UIView.animate(withDuration: 1.5, delay: 0, options: [.repeat], animations: {
            if self.animate {
                self.downloadImageView.frame = CGRect(x: self.frame.midX - width/2, y: self.frame.minY - height/2, width: width, height: height)
            }
            
        }, completion: nil)
    }
    
    private func mask(withRect rect: CGRect, inverse: Bool = false) {
        let path = UIBezierPath(rect: rect)
        let maskLayer = CAShapeLayer()
        
        if inverse {
            path.append(UIBezierPath(rect: rect))
            maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        }
        
        maskLayer.path = path.cgPath
        emptyView.layer.mask = maskLayer
    }
}
