//
//  PulseAnimationView.swift
//  Animation
//
//  Created by Kavyashree Hegde on 10/01/24.
//

import Foundation
import SwiftUI

struct PulseAnimationView : UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = PulseAnimationViewController()
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

class PulseAnimationViewController: UIViewController {
    lazy var containerView: UIView = {
        let view = UIView()
        view.frame = CGRect(origin: CGPoint(x: CGRectGetMidX(self.view.frame), y: CGRectGetMidY(self.view.frame)), size: CGSize(width: 400, height: 400))
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
    
    let pulseAttribute = PulseAnimationAttributes(imageContainerWidthAndHeight: (100,100),
                                                  imageContainerViewColor: .yellow,
                                                  mainImageViewWWidthAndHeight: (50,50),
                                                  imageName: "mic")
    
    lazy var micAnimation: PulseAnimation = PulseAnimation(attribute: self.pulseAttribute, frame: CGRect(x: 0, y: 0, width: self.containerView.frame.width, height: self.containerView.frame.width))
    
    var play: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(containerView)
        self.view.addSubview(button)
        self.containerView.addSubview(self.micAnimation)
    }
    
    @objc
    func handleTouchUpEvent(sender: UIButton) {
        play.toggle()
        if play {
            sender.isSelected = true
            micAnimation.play()
        } else {
            sender.isSelected = false
            micAnimation.pause()
        }
    }
}

public struct PulseAnimationAttributes {
    var imageContainerWidthAndHeight: (width: CGFloat, height: CGFloat)
    var imageContainerViewColor: UIColor
    var mainImageViewWWidthAndHeight: (width: CGFloat, height: CGFloat)
    var imageName: String
    
    public init(imageContainerWidthAndHeight: (width: CGFloat, height: CGFloat) = (60, 60),
                imageContainerViewColor: UIColor = UIColor(red: 72/255.0, green: 160/255.0, blue: 219/255.0, alpha: 1),
                mainImageViewWWidthAndHeight: (width: CGFloat, height: CGFloat) = (30, 30),
                imageName: String = "") {
        self.imageContainerWidthAndHeight = imageContainerWidthAndHeight
        self.imageContainerViewColor = imageContainerViewColor
        self.mainImageViewWWidthAndHeight = mainImageViewWWidthAndHeight
        self.imageName = imageName
    }
}

public class PulseAnimation: UIView {
    
    var animationIndex = 0
    var pulseArray = [CAShapeLayer]()
    var attribute = PulseAnimationAttributes()
    
    lazy var mainImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    lazy var imageContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var emptyView: UIView = {
        let view = UIView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(attribute: PulseAnimationAttributes, frame: CGRect) {
        super.init(frame: frame)
        
        self.attribute = attribute
        
        loadLayers()
        loadImageView()
    }
    
    public func play() {
        emptyView.removeFromSuperview()
        loadLayers()
        loadImageView()
        outwardAnimation(index: animationIndex)
    }
    
    public func pause() {
        animationIndex = 0
        let _ = pulseArray.map{ $0.removeAllAnimations() }
        pulseArray.removeAll()
    }
    
    private func loadLayers() {
        for _ in 0...3 {
            let pulsatingLayer = createPulseLayer()
            pulseArray.append(pulsatingLayer)
        }
    }
    
    private func createPulseLayer() -> CAShapeLayer {
        let centerPoint = self.center
        
        let circularPath = UIBezierPath(arcCenter: centerPoint, radius: bounds.width / 2 - 20, startAngle: -CGFloat.pi/2,
                                        endAngle: 2 * CGFloat.pi - CGFloat.pi/2, clockwise: true)
        
        let pulseLayer = CAShapeLayer()
        pulseLayer.path = circularPath.cgPath
        pulseLayer.lineWidth = 14
        pulseLayer.opacity = 0
        pulseLayer.fillColor = UIColor.clear.cgColor
        pulseLayer.lineCap = CAShapeLayerLineCap.round
        pulseLayer.strokeColor = attribute.imageContainerViewColor.cgColor
        pulseLayer.frame = bounds
        self.layer.addSublayer(pulseLayer)
        pulseLayer.isHidden = true
        
        return pulseLayer
    }
    
    private func loadImageView() {
        emptyView.frame = bounds
        self.addSubview(emptyView)
        
        imageContainerView.frame = CGRect(x: frame.midX - attribute.imageContainerWidthAndHeight.width/2,
                                          y: frame.midY - attribute.imageContainerWidthAndHeight.height/2,
                                          width: attribute.imageContainerWidthAndHeight.width,
                                          height: attribute.imageContainerWidthAndHeight.height)
        imageContainerView.backgroundColor = attribute.imageContainerViewColor
        imageContainerView.layer.cornerRadius = imageContainerView.frame.width / 2
        
        mainImageView.image = UIImage(named: attribute.imageName)
        mainImageView.frame = CGRect(x: imageContainerView.frame.midX - attribute.mainImageViewWWidthAndHeight.width/2,
                                     y: imageContainerView.frame.midY - attribute.mainImageViewWWidthAndHeight.height/2,
                                     width: attribute.mainImageViewWWidthAndHeight.width,
                                     height: attribute.mainImageViewWWidthAndHeight.height)
        
        emptyView.addSubview(imageContainerView)
        emptyView.addSubview(mainImageView)
        
        self.mask(withRect: imageContainerView.frame, inverse: false)
    }
    
    private func animatePulseLayer(index: Int,
                                   scaleFromValue: Any?,
                                   scaleToValue: Any?,
                                   opacityFromValue: Any?,
                                   opacityToValue: Any?,
                                   completion: () -> ()) {
        guard pulseArray.count > 0 else {return}
        pulseArray[index].isHidden = false
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = scaleFromValue
        scaleAnimation.toValue = scaleToValue
        
        let opacityAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        opacityAnimation.fromValue = opacityFromValue
        opacityAnimation.toValue = opacityToValue
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [scaleAnimation, opacityAnimation]
        groupAnimation.duration = 1.5
        groupAnimation.repeatCount = .infinity
        groupAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        
        pulseArray[index].add(groupAnimation, forKey: "groupanimation")
        
        completion()
    }
    
    private func outwardAnimation(index: Int) {
        guard pulseArray.count > 0 else {return}
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
            self?.animatePulseLayer(index: index, scaleFromValue: 0.0, scaleToValue: 0.9, opacityFromValue: 0.9, opacityToValue: 0.0) {
                
                if self?.animationIndex ?? 0 == 3 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self?.animationIndex = 0
                        self?.inwardAnimation(index: self?.animationIndex ?? 0)
                    })
                }
                self?.animationIndex += 1
                if self?.animationIndex ?? 0 < 4 {
                    self?.outwardAnimation(index: self?.animationIndex ?? 0)
                }
            }
        })
    }
    
    private func inwardAnimation(index: Int) {
        guard pulseArray.count > 0 else {return}
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.animatePulseLayer(index: index, scaleFromValue: 0.9, scaleToValue: 0.0, opacityFromValue: 0.0, opacityToValue: 0.9) { [weak self] in
                
                if self?.animationIndex ?? 0 == 3 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9, execute: {
                        self?.animationIndex = 0
                        self?.pulseArray.last?.removeAllAnimations()
                        self?.outwardAnimation(index: self?.animationIndex ?? 0)
                    })
                }
                self?.animationIndex += 1
                if self?.animationIndex ?? 0 < 4 {
                    self?.inwardAnimation(index: self?.animationIndex ?? 0)
                }
            }
        })
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

