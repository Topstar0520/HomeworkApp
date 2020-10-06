//
//  ArcButton.swift
//  MenuArcAnimationDemo
//
//  Created by Sunil Zalavadiya on 03/04/19.
//  Copyright © 2019 Sunil Zalavadiya. All rights reserved.
//

import UIKit
import Toast_Swift
struct ScreenSize
{
    static let SCREEN_BOUNDS = UIScreen.main.bounds
    static let SCREEN_WIDTH = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE = UIDevice.current.userInterfaceIdiom == .phone
    static let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad
    //static let IS_TV = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.TV
    
    static let IS_IPHONE_4_OR_LESS =  IS_IPHONE && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5 = IS_IPHONE && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6 = IS_IPHONE && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P = IS_IPHONE && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPHONE_X = IS_IPHONE && ScreenSize.SCREEN_MAX_LENGTH == 812.0
    static let IS_IPHONE_XR = IS_IPHONE && ScreenSize.SCREEN_MAX_LENGTH == 896.0
    static let IS_IPHONE_XS = IS_IPHONE && ScreenSize.SCREEN_MAX_LENGTH == 812.0

    static let IS_IPHONE_LESS_THAN_6 =  IS_IPHONE && ScreenSize.SCREEN_MAX_LENGTH < 667.0
    static let IS_IPHONE_LESS_THAN_OR_EQUAL_6 =  IS_IPHONE && ScreenSize.SCREEN_MAX_LENGTH <= 667.0
}


extension UIButton {
    func dropShadow(scale: Bool = true) {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        self.layer.shadowRadius = 3
        self.layer.masksToBounds = false
    }
}
protocol ArcButtonDelegate {
    func didClickOnCircularMenuButton(_ menuButton: ArcButton , indexForButton:Int , button: ArcButton)
    //func buttonForIndexAt(_ menuButton: ArcMenuButton , indexForButton:Int ) -> ArcMenuButton
    func buttonForIndexAt(_ menuButton: ArcButton, currentButton: ArcButton , indexForButton:Int ) -> ArcButton
}

extension ArcButtonDelegate where Self:UIViewController{
    
    func configureDynamicCircularMenuButton(button: ArcButton, numberOfMenuItems: Int){
        button.numberOfMenuItems = numberOfMenuItems
        button.parentViewOfMenuButton = UIApplication.shared.keyWindow ?? UIWindow()
        button.delegate = self
        if !button.isSubMenu {
            button.setupGesture()
        }
        //button.isUserInteractionEnabled = false
    }
    
}

class ArcButton: SpringButton {
    
    //This varible is used for number of menu items
    public var numberOfMenuItems : Int = 0
    
    //Parent view where the button is added
    public var parentViewOfMenuButton: UIView = UIView()
    
    //Object for protocol/delegete
    public var delegate: ArcButtonDelegate?
    
    public var menuButtonSize: CGSize = CGSize.init(width: 70 , height: 70) {
        didSet {
            self.frame.size = self.menuButtonSize
        }
    }
    
    public var insets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    var index = 0
    var isSubMenu = false
    var level = 0
    var superMenuButton: ArcButton!
    var superButton: ArcButton!
    
    private var prevTouchedButton: ArcButton?
    
    private var arrayButton: [ArcButton] = []
    
    //This method is called only for initialze some varibles
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isSelected = false
        self.tintColor = .clear
        
        self.addTarget(self, action: #selector(onMenuButtonTouchUpInside), for: .touchUpInside)
        self.addTarget(self, action: #selector(onMenuButtonTouchDown), for: .touchDown)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isSelected = false
        self.tintColor = .clear
        
        self.addTarget(self, action: #selector(onMenuButtonTouchUpInside), for: .touchUpInside)
        self.addTarget(self, action: #selector(onMenuButtonTouchDown), for: .touchDown)
    }
    
    func setupGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(recognizer:)))
        self.parentViewOfMenuButton.addGestureRecognizer(panGesture)
    }
    
//    func removeAllSubMenuForLevel(level: Int) {
//        for subview in parentViewOfMenuButton.subviews {
//            if let button = subview as? ArcButton, button.isSubMenu, button.level > level {
//                button.removeFromSuperview()
//                button.superButton.arrayButton.removeAll()
//            }
//        }
//    }
    
    func removeAllSubMenuForLevel(level: Int) {
        for subview in parentViewOfMenuButton.subviews {
            if let button = subview as? ArcButton, button.isSubMenu, button.level > level {
                UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
                    button.animation = "pop"
                    button.animate()
                    button.alpha = 0.0
                }) { (_) in
                    button.removeFromSuperview()
                    button.superButton.arrayButton.removeAll()
                }
            }
        }
    }
    
    @objc func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        //print("handlePanGesture = ", type(of: recognizer.view))
        //print("handlePanGesture state = ", recognizer.state.rawValue)
        
        let touchPoint = recognizer.location(in: self.parentViewOfMenuButton)
        let hitView = self.parentViewOfMenuButton.hitTest(touchPoint, with: nil)
        
        var touchedButton = self
        
        if let button = hitView as? ArcButton {
            touchedButton = button
        } else {
            if(recognizer.state == .ended) {
                removeAllSubMenuForLevel(level: 0)
            }
            prevTouchedButton = nil
            return
        }
        
        if touchedButton != prevTouchedButton {
            prevTouchedButton = touchedButton
            //prevTouchedButton?.animation = "pop"
            //prevTouchedButton?.animate()
        }
        //print("handlePanGesture touchedButton = ", touchedButton.level)
        if(recognizer.state == .began || recognizer.state == .changed) {
            if touchedButton.arrayButton.isEmpty && touchedButton.level == 1 {
                removeAllSubMenuForLevel(level: 1)
               
            }
           if touchedButton.numberOfMenuItems >= 0 && touchedButton.level == 1 {
                touchedButton.showMenu()
                for btn in self.parentViewOfMenuButton.subviews {
                    if btn.isKind(of: ArcButton.self) {
                        if (btn as! ArcButton).tag % 3 == 0 {
                            (btn as! ArcButton).isSelected = false
                            (btn as! ArcButton).backgroundColor = UIColor(red: 37.0/255.0, green: 37.0/255.0, blue: 37.0/255.0, alpha: 1.0)
                        }
                    }
                    
                }
                if touchedButton.imageView?.image != UIImage(named: "ic_plus") {
                    touchedButton.isSelected = true
                    touchedButton.backgroundColor = UIColor.darkGray
                    touchedButton.animation = "pop"
                    touchedButton.animate()
                }
                
            } else{
                for btn in self.parentViewOfMenuButton.subviews {
                    if btn.isKind(of: ArcButton.self) {
                         if (btn as! ArcButton).tag % 5 == 0 {
                        (btn as! ArcButton).isSelected = false
                        (btn as! ArcButton).backgroundColor = UIColor(red: 37.0/255.0, green: 37.0/255.0, blue: 37.0/255.0, alpha: 1.0)
                            (btn as! ArcButton).centerVerticallyWithPadding(padding: 0.0)

                    }
                    }
                   
                }
            if touchedButton.imageView?.image != UIImage(named: "ic_plus") || touchedButton.level != 0 {

                touchedButton.animation = "pop"
                touchedButton.animate()
                touchedButton.isSelected = true
                touchedButton.backgroundColor = UIColor.darkGray
                touchedButton.centerVerticallyWithPaddingWhileSelected(padding: 0.0)
                if touchedButton.title(for: .normal) != "" && touchedButton.title(for: .normal) != nil {
                    UIApplication.shared.keyWindow?.subviews[0].makeToast(touchedButton.title(for: .normal) ?? "")
                }
            }
            }
        } else {
            //print("handlePanGesture end touchedButton = ", touchedButton.titleLabel)
            if touchedButton.level > 0 {
                if let index = touchedButton.superButton.arrayButton.firstIndex(where: { (arcBtn) -> Bool in
                    if touchedButton == arcBtn {
                        return true
                    }
                    return false
                }) {
                    self.delegate?.didClickOnCircularMenuButton(touchedButton.superButton, indexForButton: index, button: touchedButton)
                    removeAllSubMenuForLevel(level: 0)
                }
                
            } else {
                removeAllSubMenuForLevel(level: 0)
            }
        }
        
        if touchedButton.tag == 1234 {
            touchedButton.isSelected = false
            touchedButton.backgroundColor = UIColor.clear
        }
        
    }

    func showMenu() {
        if self.arrayButton.isEmpty {
            let mainButton = superMenuButton ?? self
            
            if UIDevice.current.orientation.isLandscape && DeviceType.IS_IPHONE {
                self.menuButtonSize = CGSize(width: 60, height: 60)
            }
            
            var initialPoint = CGPoint(x : Int(UIScreen.main.bounds.width - mainButton.frame.width + insets.right), y : Int(UIScreen.main.bounds.height  - mainButton.frame.height + insets.bottom))
            //print("initialPoint = ", initialPoint)
            
//            let startAngle = 100
//            let totalAvailableDegrees = 100
//            var incrementAngle = 0
//
//            var spacing = 10
//            var distanceBtwCircle = -110
//            let DISTANCE_BETWEEN_EACH_CIRCLE = 100
            
            var startAngle = 100
            var totalAvailableDegrees = 100
            var incrementAngle = 0

            var spacing = 32 //portait = 32 1st level
            var distanceBtwCircle = -170
            let DISTANCE_BETWEEN_EACH_CIRCLE = 100
          
            if isSubMenu {
                startAngle = setButtonAngle(totalMenuItems: self.numberOfMenuItems).0
                spacing = setButtonAngle(totalMenuItems: self.numberOfMenuItems).1
                totalAvailableDegrees = setButtonAngle(totalMenuItems: self.numberOfMenuItems).2
                distanceBtwCircle = setButtonAngle(totalMenuItems: self.numberOfMenuItems).3
                
                //print("startAngle: \(startAngle)\nspacing: \(spacing)\ntotalAvailableDegrees: \(totalAvailableDegrees)\ndistanceBtwCircle: \(distanceBtwCircle)")
                
                initialPoint.y = initialPoint.y - 80
                initialPoint.x = initialPoint.x + 80
            } else {
                if DeviceType.IS_IPHONE_X || DeviceType.IS_IPHONE_XR || DeviceType.IS_IPHONE_XS {
                    if UIDevice.current.orientation.isLandscape {
                        startAngle = 95
                        spacing = 30
                    } else {
                        spacing = 28
                    }
                    
                    initialPoint.y = initialPoint.y - 80
                    initialPoint.x = initialPoint.x + 80
                } else {
                    if UIDevice.current.orientation.isLandscape {
                        startAngle = 102
                        spacing = 35
                    }
                    initialPoint.y = initialPoint.y - 60
                    initialPoint.x = initialPoint.x + 95
                }
            }
            
            var currentAngle = startAngle - spacing
            let circleRadius = distanceBtwCircle - (DISTANCE_BETWEEN_EACH_CIRCLE * self.level)
            
            if self.numberOfMenuItems > 1 {
                incrementAngle = totalAvailableDegrees / (self.numberOfMenuItems - 1)
            }
            
            //creating all buttons at menu button icon
            if numberOfMenuItems > 0 {
                for i in 0...numberOfMenuItems-1{
                    
                    if(self.arrayButton.count < numberOfMenuItems){
                        var button: ArcButton? = ArcButton()
                        button = delegate?.buttonForIndexAt(self, currentButton: button!, indexForButton: i)
                        button?.frame = CGRect.init(origin: initialPoint, size: self.menuButtonSize)
                        //button?.frame = self.frame
                        button?.layer.cornerRadius = menuButtonSize.width / 2
                        button?.tag = i
                        button?.alpha = 0.0
                        button?.imageView?.contentMode = .center
                        button?.backgroundColor =  #colorLiteral(red: 0.1450980392, green: 0.1450980392, blue: 0.1450980392, alpha: 1)
                        button?.dropShadow()
                        //button?.addTarget(self, action: #selector(onClickMenuItemButton(sender:)), for: .touchUpInside)
                        if isSubMenu{
                            button?.tag = (i+1)*5
                        }
                        else{
                            button?.tag = (i+1)*3
                        }
                        arrayButton.append(button!)
                    }else{
                        arrayButton[i].frame = self.frame
                        layoutIfNeeded()
                    }
                    
                    self.parentViewOfMenuButton.addSubview(self.arrayButton[i])
                    
                    let buttonCenter = CGPoint(x: Double(initialPoint.x) + cos(Double(currentAngle) * Double.pi/180.0) * Double(circleRadius), y: Double(initialPoint.y) + sin(Double(currentAngle) * Double.pi/180.0) * Double(circleRadius))
                    self.arrayButton[i].center = buttonCenter
                    self.arrayButton[i].alpha = 1.0
                    self.arrayButton[i].animation = "pop"
                    self.arrayButton[i].animate()
                    
                    /*UIView.animate(withDuration: 0.3, delay: 0.025 * Double(i), options: .curveEaseIn, animations: {
                     
                        self.arrayButton[i].center = buttonCenter
                        //self.arrayButton[i].frame = CGRect.init(origin: origine, size: self._menuButtonSize)
                        self.arrayButton[i].alpha = 1.0
                        self.layoutIfNeeded()
                    }, completion: nil)*/
                    
                    currentAngle -= incrementAngle
                }
            }
        }
    }
    
    private func setButtonAngle(totalMenuItems: Int) -> (Int, Int, Int, Int) {
        let landscape = UIDevice.current.orientation.isLandscape ? true : false
        var startAngle = 100
        var totalAvailableDegrees = 100 // distance between two button
        var spacing = 20   // button start position
        var distanceBtwCircle = -170 // distance between level 1(4) & 2(submenu - 6)
        
        if DeviceType.IS_IPHONE && landscape { // only iPhone Landscape
            if totalMenuItems == 1 {
                
                totalAvailableDegrees = 0
                
                if DeviceType.IS_IPHONE_5 {
                    startAngle = 78
                    spacing = 40
                    distanceBtwCircle = -140
                } else if DeviceType.IS_IPHONE_6 {
                    startAngle = 88
                    spacing = 32
                    distanceBtwCircle = -145
                } else if DeviceType.IS_IPHONE_6P {
                    startAngle = 100
                    spacing = 25
                    distanceBtwCircle = -150
                } else if DeviceType.IS_IPHONE_X || DeviceType.IS_IPHONE_XS {
                    startAngle = 86
                    spacing = 35
                    distanceBtwCircle = -165
                } else if DeviceType.IS_IPHONE_XR {
                    startAngle = 95
                    spacing = 28
                    distanceBtwCircle = -165
                }
                
            } else if totalMenuItems == 2 {
                
                totalAvailableDegrees = 20
                
                if DeviceType.IS_IPHONE_5 {
                    startAngle = 78
                    spacing = 40
                    distanceBtwCircle = -140
                    totalAvailableDegrees = 20
                } else if DeviceType.IS_IPHONE_6 {
                    startAngle = 88
                    spacing = 32
                    distanceBtwCircle = -145
                } else if DeviceType.IS_IPHONE_6P {
                    startAngle = 100
                    spacing = 25
                    distanceBtwCircle = -150
                } else if DeviceType.IS_IPHONE_X || DeviceType.IS_IPHONE_XS {
                    startAngle = 86
                    spacing = 35
                    distanceBtwCircle = -165
                    totalAvailableDegrees = 15
                } else if DeviceType.IS_IPHONE_XR {
                    startAngle = 95
                    spacing = 28
                    distanceBtwCircle = -165
                    totalAvailableDegrees = 17
                }
                
            } else if totalMenuItems == 3 {
                
                totalAvailableDegrees = 40
                
                if DeviceType.IS_IPHONE_5 {
                    startAngle = 78
                    spacing = 40
                    distanceBtwCircle = -140
                    totalAvailableDegrees = 40
                } else if DeviceType.IS_IPHONE_6 {
                    startAngle = 88
                    spacing = 32
                    distanceBtwCircle = -145
                } else if DeviceType.IS_IPHONE_6P {
                    startAngle = 100
                    spacing = 25
                    distanceBtwCircle = -150
                } else if DeviceType.IS_IPHONE_X || DeviceType.IS_IPHONE_XS {
                    startAngle = 86
                    spacing = 35
                    distanceBtwCircle = -165
                    totalAvailableDegrees = 35
                } else if DeviceType.IS_IPHONE_XR {
                    startAngle = 95
                    spacing = 28
                    distanceBtwCircle = -165
                    totalAvailableDegrees = 33
                }
                
            } else if totalMenuItems == 4 {
                
                totalAvailableDegrees = 60
                
                if DeviceType.IS_IPHONE_5 {
                    startAngle = 78
                    spacing = 40
                    distanceBtwCircle = -140
                    totalAvailableDegrees = 60
                } else if DeviceType.IS_IPHONE_6 {
                    startAngle = 88
                    spacing = 32
                    distanceBtwCircle = -145
                } else if DeviceType.IS_IPHONE_6P {
                    startAngle = 100
                    spacing = 25
                    distanceBtwCircle = -150
                } else if DeviceType.IS_IPHONE_X || DeviceType.IS_IPHONE_XS {
                    startAngle = 86
                    spacing = 35
                    distanceBtwCircle = -165
                    totalAvailableDegrees = 55
                } else if DeviceType.IS_IPHONE_XR {
                    startAngle = 95
                    spacing = 28
                    distanceBtwCircle = -165
                    totalAvailableDegrees = 53
                }
                
            } else if totalMenuItems == 5 {
                
                distanceBtwCircle = -130
                totalAvailableDegrees = 80
                
                if DeviceType.IS_IPHONE_5 {
                    startAngle = 80
                    spacing = 40
                    distanceBtwCircle = -140
                    totalAvailableDegrees = 70
                } else if DeviceType.IS_IPHONE_6 {
                    startAngle = 88
                    spacing = 32
                    distanceBtwCircle = -145
                } else if DeviceType.IS_IPHONE_6P {
                    startAngle = 100
                    spacing = 30
                    distanceBtwCircle = -150
                } else if DeviceType.IS_IPHONE_X || DeviceType.IS_IPHONE_XS {
                    startAngle = 86
                    spacing = 35
                    distanceBtwCircle = -165
                    totalAvailableDegrees = 70
                } else if DeviceType.IS_IPHONE_XR {
                    startAngle = 95
                    spacing = 28
                    distanceBtwCircle = -165
                    totalAvailableDegrees = 73
                }
            } else if totalMenuItems == 6 {
                
                totalAvailableDegrees = 100
                
                if DeviceType.IS_IPHONE_5 {
                    startAngle = 85
                    spacing = 38
                    distanceBtwCircle = -140
                    totalAvailableDegrees = 83
                } else if DeviceType.IS_IPHONE_6 {
                    startAngle = 88
                    spacing = 32
                    distanceBtwCircle = -145
                    totalAvailableDegrees = 83
                } else if DeviceType.IS_IPHONE_6P {
                    startAngle = 100
                    spacing = 25
                    distanceBtwCircle = -150
                } else if DeviceType.IS_IPHONE_X || DeviceType.IS_IPHONE_XS {
                    startAngle = 86
                    spacing = 35
                    distanceBtwCircle = -165
                    totalAvailableDegrees = 78
                } else if DeviceType.IS_IPHONE_XR {
                    startAngle = 95
                    spacing = 28
                    distanceBtwCircle = -165
                    totalAvailableDegrees = 93
                }
            }
        } else { // Both iPhone & iPad
            
            if DeviceType.IS_IPHONE_X || DeviceType.IS_IPHONE_XR {
                distanceBtwCircle = -190
            }
            
            totalAvailableDegrees = setDefualtAngle(totalMenuItems: totalMenuItems)
        }
        
        return (startAngle, spacing, totalAvailableDegrees, distanceBtwCircle)
    }
    
    private func setDefualtAngle(totalMenuItems: Int) -> Int {
        var totalAvailableDegrees = 0
        
            if totalMenuItems == 1 {
                totalAvailableDegrees = 0
            } else if totalMenuItems == 2 {
                totalAvailableDegrees = 20
            } else if totalMenuItems == 3 {
                totalAvailableDegrees = 40
            } else if totalMenuItems == 4 {
                totalAvailableDegrees = 60
            } else if totalMenuItems == 5 {
                totalAvailableDegrees = 80
            } else if totalMenuItems == 6 {
                totalAvailableDegrees = 100
            }
        
        return totalAvailableDegrees
    }
    
    @objc public func onMenuButtonTouchDown() {
        if self.arrayButton.isEmpty && self.level == 1 {
            removeAllSubMenuForLevel(level: 1)
        }
        if self.numberOfMenuItems > 0 {
            self.showMenu()
        }
    }
    
    @objc public func onMenuButtonTouchUpInside() {
        removeAllSubMenuForLevel(level: 0)
    }
}
