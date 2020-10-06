//
//  ArcMenuButton.swift
//  MenuArcAnimationDemo
//
//  Created by Sunil Zalavadiya on 19/03/19.
//  Copyright © 2019 Sunil Zalavadiya. All rights reserved.
//

import UIKit
import Social

//Enum for position options
public enum CircularButtonPosition{
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    case center
    case centerRight
    case centerLeft
    case centerTop
    case centerBottom
}

public enum CircularButtonAnimationSpeed{
    case fast
    case modarate
    case slow
}

public enum MenuButtonSize{
    case small
    case medium
    case large
}

protocol ArcCircularButtonDelegate {
    func didClickOnCircularMenuButton(_ menuButton: ArcMenuButton , indexForButton:Int , button: ArcMenuButton)
    //func buttonForIndexAt(_ menuButton: ArcMenuButton , indexForButton:Int ) -> ArcMenuButton
    func buttonForIndexAt(_ menuButton: ArcMenuButton, currentButton: ArcMenuButton , indexForButton:Int ) -> ArcMenuButton
}

extension ArcCircularButtonDelegate where Self:UIViewController{
    
    func configureCircularMenuButton(button: ArcMenuButton, numberOfMenuItems: Int , menuRedius: CGFloat ,postion ofButton: CircularButtonPosition){
        button.configureCircularButton(numberOfMenuItems: numberOfMenuItems, menuRedius: menuRedius, postion: ofButton)
        button.parentViewOfMenuButton = UIApplication.shared.keyWindow ?? UIWindow()
        button.delegate = self
    }
    
    func configureDraggebleCircularMenuButton(button: ArcMenuButton, numberOfMenuItems: Int , menuRedius: CGFloat ,postion ofButton: CircularButtonPosition){
        button.configureCircularButton(numberOfMenuItems: numberOfMenuItems, menuRedius: menuRedius, postion: ofButton)
        button.parentViewOfMenuButton = UIApplication.shared.keyWindow ?? UIWindow()
        button.delegate = self
        //button.isDreggable = true
    }
    
    func configureDynamicCircularMenuButton(button: ArcMenuButton, numberOfMenuItems: Int){
        button.numberOfMenuItems = numberOfMenuItems
        button.setupDynamically()
        button.parentViewOfMenuButton = UIApplication.shared.keyWindow ?? UIWindow()
        button.delegate = self
        if !button.isSubMenu {
            button.setupGesture()
        }
        //button.isUserInteractionEnabled = false
    }
    
}

class ArcMenuButton: SpringButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var index = 0
    var isSubMenu = false
    var level = 0
    var superMenuButton: ArcMenuButton!
    var superButton: ArcMenuButton!
    
    private var prevTouchedButton: ArcMenuButton?
    
    //This is varible for give Button to initial position and also it is set dynamically for draggble button and dynamic button
    private var _circularButtonPositon : CircularButtonPosition = .bottomLeft
    public var circularButtonPositon : CircularButtonPosition = .bottomLeft
    
    
    
    //This is varible for redius of circular Menu
    public var menuRedius: CGFloat = 0.0
    public var _menuRedius: CGFloat = 0.0
    
    //This varible is used for number of menu items
    public var numberOfMenuItems : Int = 0
    
    //This is used for animation speed
    public var circularButtonAnimationSpeed : CircularButtonAnimationSpeed = .modarate
    
    //Parent view where the button is added
    public var parentViewOfMenuButton: UIView = UIView()
    
    //Object for protocol/delegete
    public var delegate: ArcCircularButtonDelegate?
    
    //This var is used for Adding/removeing 360 degree rotation for main menuButton. By defualt it will be true.
    public var sholudMenuButtonAnimate: Bool = true
    
    //Varibles to set the size for Dynamic button
    private var _menuButtonSize:CGSize = CGSize.init(width: UIScreen.main.bounds.width/4.5 , height: UIScreen.main.bounds.width/4.5)
    public var menuButtonSize: MenuButtonSize = .medium{
        didSet{
            switch menuButtonSize {
            case .small:
                self._menuButtonSize = CGSize.init(width: UIScreen.main.bounds.width/4.5, height: UIScreen.main.bounds.width/4.5)
                break
            case .medium:
                self._menuButtonSize = CGSize.init(width: UIScreen.main.bounds.width/4.0, height: UIScreen.main.bounds.width/4.0)
                break
            case .large:
                self._menuButtonSize = CGSize.init(width: UIScreen.main.bounds.width/3.5, height: UIScreen.main.bounds.width/3.5)
                break
            }
        }
    }
    
    //It is dummy array for save the instance of created button. It will completly flushed when button is Tapped second time.
    private var arrayButton: [ArcMenuButton] = []
    
    //This method is called only for initialze some varibles
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isSelected = false
        self.tintColor = .clear
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isSelected = false
        self.tintColor = .clear
    }
    
    func setupGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(recognizer:)))
        self.parentViewOfMenuButton.addGestureRecognizer(panGesture)
        //let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(recognizer:)))
        //self.parentViewOfMenuButton.addGestureRecognizer(longPressGesture)
    }
    
    //function for configure MenuButton
    public func configureCircularButton(numberOfMenuItems: Int , menuRedius: CGFloat ,postion: CircularButtonPosition){
        layoutIfNeeded()
        self.numberOfMenuItems = numberOfMenuItems
        self.menuRedius = menuRedius
        layer.cornerRadius = self.frame.width / 2
        setTargetForButton()
        circularButtonPositon = postion
        _circularButtonPositon = circularButtonPositon
    }
    
    public func setupDynamically(){
        self.customRadiusForButton()
        self.circularButtonPositon = self.setDynamicButtonPosition()
        layer.cornerRadius = self.frame.width / 2
        setTargetForButton()
    }
    
    //This method is use for set target for MenuButton.
    public func setTargetForButton(){
        self.addTarget(self, action: #selector(onMenuButtonTouchUpInside), for: .touchUpInside)
        self.addTarget(self, action: #selector(onMenuButtonTouchDown), for: .touchDown)
        self._menuRedius = menuRedius
    }
    
    func removeAllSubMenuForLevel(level: Int) {
        for subview in parentViewOfMenuButton.subviews {
            if let button = subview as? ArcMenuButton, button.isSubMenu, button.level > level {
                button.removeFromSuperview()
                button.superButton.arrayButton.removeAll()
            }
        }
    }
    
    @objc func handleLongPressGesture(recognizer: UILongPressGestureRecognizer) {
        print("handleLongPressGesture")
        
        let touchPoint = recognizer.location(in: self.parentViewOfMenuButton)
        let hitView = self.parentViewOfMenuButton.hitTest(touchPoint, with: nil)
        
        var touchedButton = self
        
        if let button = hitView as? ArcMenuButton {
            touchedButton = button
        } else {
            return
        }
        
        if touchedButton.level == 0 && recognizer.state == .began {
            if recognizer.state == .began {
                if touchedButton.numberOfMenuItems > 0 {
                    touchedButton.showMenu()
                }
            } else {
                removeAllSubMenuForLevel(level: 0)
            }
            
        }
    }
    
    @objc func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        print("handlePanGesture = ", type(of: recognizer.view))
        print("handlePanGesture state = ", recognizer.state.rawValue)
        
        let touchPoint = recognizer.location(in: self.parentViewOfMenuButton)
        let hitView = self.parentViewOfMenuButton.hitTest(touchPoint, with: nil)
        
        var touchedButton = self
        
        if let button = hitView as? ArcMenuButton {
            touchedButton = button
        } else {
            if(recognizer.state == .ended) {
                removeAllSubMenuForLevel(level: 0)
            }
            /*if(recognizer.state != .began && recognizer.state != .changed) {
                removeAllSubMenuForLevel(level: 0)
            } else {
                removeAllSubMenuForLevel(level: 1)
            }*/
            prevTouchedButton = nil
            return
        }
        
        if touchedButton != prevTouchedButton {
            prevTouchedButton = touchedButton
            prevTouchedButton?.animation = "pop"
            prevTouchedButton?.animate()
        }
        print("handlePanGesture touchedButton = ", touchedButton.level)
        if(recognizer.state == .began || recognizer.state == .changed) {
            if touchedButton.arrayButton.isEmpty && touchedButton.level == 1 {
                removeAllSubMenuForLevel(level: 1)
            }
            if touchedButton.numberOfMenuItems > 0 {
                touchedButton.showMenu()
            }
        } else {
            print("handlePanGesture end touchedButton = ", touchedButton.titleLabel)
            if touchedButton.level > 0 {
                if let index = touchedButton.superButton.arrayButton.firstIndex(where: { (arcBtn) -> Bool in
                    if touchedButton == arcBtn {
                        return true
                    }
                    return false
                }) {
                    delegate?.didClickOnCircularMenuButton(touchedButton.superButton, indexForButton: index, button: touchedButton)
                    removeAllSubMenuForLevel(level: 0)
                }
                
            } else {
                for subview in parentViewOfMenuButton.subviews {
                    if let button = subview as? ArcMenuButton, button.isSubMenu {
                        button.removeFromSuperview()
                    }
                }
                self.arrayButton.removeAll()
            }
        }
        
    }
    
    @objc func holdDown() {
        
    }
    
    func showMenu() {
        if self.arrayButton.isEmpty {
            //will get all origins
            let origines = setupCGPoints()
            
            //creating all buttons at menu button icon
            for i in 0...numberOfMenuItems-1{
                
                let origine = CGPoint.init(x: origines[i].x - self._menuButtonSize.width / 2, y: origines[i].y - self._menuButtonSize.width / 2)
                
                if(self.arrayButton.count < numberOfMenuItems){
                    var button: ArcMenuButton? = ArcMenuButton()
                    button?.frame = CGRect.init(origin: origine, size: self._menuButtonSize)
                    button = delegate?.buttonForIndexAt(self, currentButton: button!, indexForButton: i)
                    //button?.frame = self.frame
                    button?.layer.cornerRadius = _menuButtonSize.width / 2
                    button?.tag = i
                    button?.alpha = 0.0
                    //button?.imageView?.contentMode = .center
                    //button?.backgroundColor =  #colorLiteral(red: 0.9568627451, green: 0.4862745098, blue: 0.2823529412, alpha: 1)
                    //button?.addTarget(self, action: #selector(onClickMenuItemButton(sender:)), for: .touchUpInside)
                    arrayButton.append(button!)
                }else{
                    arrayButton[i].frame = self.frame
                    layoutIfNeeded()
                }
                
                self.parentViewOfMenuButton.addSubview(self.arrayButton[i])
                
                /*if sholudMenuButtonAnimate{
                    rotate360Degrees(isClockwise: true)
                }*/
                
                //animate buttons from menu button to their origines
                UIView.animate(withDuration: 0.3, delay: 0.025 * Double(i), options: .curveEaseIn, animations: {
                    let origine = CGPoint.init(x: origines[i].x - self._menuButtonSize.width / 2, y: origines[i].y - self._menuButtonSize.width / 2)
                    self.arrayButton[i].frame = CGRect.init(origin: origine, size: self._menuButtonSize)
                    self.arrayButton[i].alpha = 1.0
                    self.layoutIfNeeded()
                }, completion: nil)
            }
        }
    }
    
    // This function will called when menu button is clicked an create/remove all child buttons
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
    
    @objc public func onClickMenuButton(){
        
        /*if !isSelected{
            //will get all origins
            let origines = setupCGPoints()
            
            //creating all buttons at menu button icon
            for i in 0...numberOfMenuItems-1{
                
                if(self.arrayButton.count < numberOfMenuItems){
                    var button: UIButton? = UIButton()
                    button = delegate?.buttonForIndexAt(self, indexForButton: i)
                    button?.frame = self.frame
                    button?.layer.cornerRadius = _menuButtonSize.width / 2
                    button?.tag = i
                    button?.alpha = 0.0
                    button?.imageView?.contentMode = .center
                    button?.addTarget(self, action: #selector(onClickMenuItemButton(sender:)), for: .touchUpInside)
                    arrayButton.append(button!)
                }else{
                    arrayButton[i].frame = self.frame
                    layoutIfNeeded()
                }
                
                self.parentViewOfMenuButton.addSubview(self.arrayButton[i])
                
                if sholudMenuButtonAnimate{
                    rotate360Degrees(isClockwise: true)
                }
                
                //animate buttons from menu button to their origines
                UIView.animate(withDuration: 0.3, delay: 0.025 * Double(i), options: .curveEaseIn, animations: {
                    let origine = CGPoint.init(x: origines[i].x - self._menuButtonSize.width / 2, y: origines[i].y - self._menuButtonSize.width / 2)
                    self.arrayButton[i].frame = CGRect.init(origin: origine, size: self._menuButtonSize)
                    self.arrayButton[i].alpha = 1.0
                    self.layoutIfNeeded()
                }, completion: nil)
            }
            // If menu is already open
        }else{
            for button in arrayButton{
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                    button.alpha = 0.0
                    button.frame = self.frame
                    self.layoutIfNeeded()
                }, completion: { (status) in
                    button.removeFromSuperview()
                })
                if sholudMenuButtonAnimate{
                    rotate360Degrees(isClockwise: false)
                }
                
            }
            //arrayButton = []
        }
        self.isSelected = !self.isSelected*/
        self.isSelected = !self.isSelected
    }
    
    //This function is used for rotate button on click 360 Degree clock or anticlock wise
    private func rotate360Degrees(duration: CFTimeInterval = 0.2, completionDelegate: AnyObject? = nil , isClockwise: Bool) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        
        if isClockwise{
            rotateAnimation.toValue = CGFloat(2 * Double.pi)
        }else{
            rotateAnimation.toValue = CGFloat(-2 * Double.pi)
        }
        rotateAnimation.duration = duration
        self.layer.add(rotateAnimation, forKey: nil)
    }
    
    //This is method for getting cerculer CGPoints using geometry and trigometry
    private func setupCGPoints()->[CGPoint]{
        var arrayCGPoint:[CGPoint] = []
        
        var origineX = self.frame.origin.x + self.frame.width / 2
        var origineY = self.frame.origin.y + self.frame.height / 2
        /*if level == 0 {
            menuRedius = menuRedius * 1.2
        } else if level == 1 {
            menuRedius = menuRedius * 1.2
        }*/
        
        if self.level > 0 {
            /*let startX = superMenuButton.frame.origin.x + superMenuButton.frame.width / 2
            let startY = superMenuButton.frame.origin.y - menuRedius
            
            let endX = superMenuButton.frame.origin.x - menuRedius
            let endY = superMenuButton.frame.origin.y + superMenuButton.frame.height / 2
            
            let midX = (startX - endX) / 2.0
            let midY = (endY - startY) / 2.0
            
            let radiusXDif = startX - midX
            let radiusYDif = endY - midY
            
            origineX = radiusXDif
            origineY = radiusYDif*/
            
            let centerPoint = CGPoint(x: superMenuButton.frame.origin.x + superMenuButton.frame.width / 2, y: superMenuButton.frame.origin.y + superMenuButton.frame.height / 2)
            let startPoint = CGPoint(x: centerPoint.x - menuRedius / 2, y: centerPoint.y - menuRedius / 2)
            let endPoint = CGPoint(x: centerPoint.x , y: centerPoint.y)
            let midPoint = CGPoint(x: (startPoint.x - endPoint.x) / 2.0, y: (endPoint.y - startPoint.y) / 2.0)
            origineX = startPoint.x - midPoint.x
            origineY = endPoint.y - midPoint.y
        }
        print("origineX = ", origineX)
        print("origineY = ", origineY)
        switch circularButtonPositon {
        case .bottomRight:
            let angleArray = findAngles()
            for i in 0...numberOfMenuItems - 1{
                arrayCGPoint.append(CGPoint.init(x: origineX - (menuRedius * CGFloat(sin(angleArray[i]))), y: origineY - (menuRedius * CGFloat(cos(angleArray[i])))))
            }
            print("arrayCGPoint = ", arrayCGPoint)
            break
            
        case .bottomLeft:
            let angleArray = findAngles()
            for i in 0...numberOfMenuItems - 1{
                arrayCGPoint.append(CGPoint.init(x: origineX + (menuRedius * CGFloat(sin(angleArray[i]))), y: origineY - (menuRedius * CGFloat(cos(angleArray[i])))))
            }
            break
        case .topLeft:
            let angleArray = findAngles()
            for i in 0...numberOfMenuItems - 1{
                arrayCGPoint.append(CGPoint.init(x: origineX + (menuRedius * CGFloat(sin(angleArray[i]))), y: origineY + (menuRedius * CGFloat(cos(angleArray[i])))))
            }
            break
        case .topRight:
            let angleArray = findAngles()
            for i in 0...numberOfMenuItems - 1{
                arrayCGPoint.append(CGPoint.init(x: origineX - (menuRedius * CGFloat(sin(angleArray[i]))), y: origineY + (menuRedius * CGFloat(cos(angleArray[i])))))
            }
            break
        case .center:
            let angleArray = findAngles()
            for i in 0...numberOfMenuItems - 1{
                arrayCGPoint.append(CGPoint.init(x: origineX + (menuRedius * CGFloat(sin(angleArray[i]))), y: origineY + (menuRedius * CGFloat(cos(angleArray[i])))))
            }
            break
        case .centerLeft:
            let angleArray = findAngles()
            for i in 0...numberOfMenuItems - 1{
                arrayCGPoint.append(CGPoint.init(x: origineX + (menuRedius * CGFloat(sin(angleArray[i]))), y: origineY + (menuRedius * CGFloat(cos(angleArray[i])))))
            }
            break
        case .centerRight:
            let angleArray = findAngles()
            for i in 0...numberOfMenuItems - 1{
                arrayCGPoint.append(CGPoint.init(x: origineX - (menuRedius * CGFloat(sin(angleArray[i]))), y: origineY + (menuRedius * CGFloat(cos(angleArray[i])))))
            }
            break
        case .centerTop:
            let angleArray = findAngles()
            for i in 0...numberOfMenuItems - 1{
                arrayCGPoint.append(CGPoint.init(x: origineX - (menuRedius * CGFloat(sin(angleArray[i]))), y: origineY - (menuRedius * CGFloat(cos(angleArray[i])))))
            }
            break
        case .centerBottom:
            let angleArray = findAngles()
            for i in 0...numberOfMenuItems - 1{
                arrayCGPoint.append(CGPoint.init(x: origineX - (menuRedius * CGFloat(sin(angleArray[i]))), y: origineY + (menuRedius * CGFloat(cos(angleArray[i])))))
            }
            break
        }
        return arrayCGPoint
    }
    
    //This method is used for find the angles for button where they need to set
    private func findAngles()->[CGFloat]{
        var array: [CGFloat] = []
        switch circularButtonPositon{
        case .center:
            let anglePartSize = (CGFloat(Double.pi) * 2) / CGFloat(numberOfMenuItems)
            for i in 0...numberOfMenuItems-1{
                array.append( CGFloat(i) * anglePartSize)
            }
            break
        case .centerLeft:
            let anglePartSize = (CGFloat(Double.pi)) / CGFloat(numberOfMenuItems - 1)
            for i in 0...numberOfMenuItems-1{
                array.append(CGFloat(i) * anglePartSize)
            }
            break
        case .centerRight:
            let anglePartSize = (CGFloat(Double.pi)) / CGFloat(numberOfMenuItems - 1)
            for i in 0...numberOfMenuItems-1{
                array.append(CGFloat(i) * anglePartSize)
            }
            break
        case .centerTop:
            let anglePartSize = (CGFloat(Double.pi)) / CGFloat(numberOfMenuItems - 1)
            for i in 0...numberOfMenuItems-1{
                array.append((CGFloat(Double.pi) / 2) + CGFloat(i) * anglePartSize)
            }
            break
        case .centerBottom:
            let anglePartSize = (CGFloat(Double.pi)) / CGFloat(numberOfMenuItems - 1)
            for i in 0...numberOfMenuItems-1{
                array.append((CGFloat(Double.pi) / 2) + CGFloat(i) * anglePartSize)
            }
            break
        default:
            if self.level > 0 && self.numberOfMenuItems <= superButton.numberOfMenuItems {
                let anglePartSize = (CGFloat(Double.pi) / CGFloat(2)) / CGFloat(superButton.numberOfMenuItems - 1)
                for i in 0...numberOfMenuItems-1{
                    array.append( CGFloat(i) * anglePartSize)
                }
                
            } else if numberOfMenuItems <= 1 {
                let anglePartSize = (CGFloat(Double.pi) / CGFloat(4))
                array.append(anglePartSize)
            } else {
                let anglePartSize = (CGFloat(Double.pi) / CGFloat(2)) / CGFloat(numberOfMenuItems - 1)
                for i in 0...numberOfMenuItems-1{
                    array.append( CGFloat(i) * anglePartSize)
                }
            }
            print("angles = ", array)
            break
        }
        return array
    }
    
    //This method is used when button will Dynamically set its redius
    private func customRadiusForButton(){
        
        if(circularButtonPositon == .center){
            self.menuRedius = (CGFloat(self.numberOfMenuItems) * (_menuButtonSize.width + 10.0)) / (CGFloat(Double.pi) * 2) + self.frame.width
        }else if(circularButtonPositon == .centerBottom || circularButtonPositon == .centerTop || circularButtonPositon == .centerLeft || circularButtonPositon == .centerRight ){
            self.menuRedius = CGFloat(self.numberOfMenuItems - 1) * CGFloat(self.frame.width) / CGFloat(Double.pi)
        }else{
            if self.level > 0 && self.numberOfMenuItems <= superButton.numberOfMenuItems {
                self.menuRedius = 2 * CGFloat(superButton.numberOfMenuItems) * CGFloat(self.frame.width) / CGFloat(Double.pi)
                
            } else if self.numberOfMenuItems > 1 {
                self.menuRedius = 2 * CGFloat(self.numberOfMenuItems - 1) * CGFloat(self.frame.width) / CGFloat(Double.pi)
            } else {
                self.menuRedius = 2 * CGFloat(self.frame.width) * CGFloat(Double.pi) / 2
            }
        }
        if level == 0 {
            menuRedius = menuRedius * 1.2
        } else if level == 1 {
            menuRedius = menuRedius * 1.2
        }
    }
    
    //This function is used for check at which position button is
    private func setDynamicButtonPosition()-> CircularButtonPosition{
        var isLeft: Bool = false
        var isTop: Bool = false
        var isCenterX: Bool = false
        var isCenterY: Bool = false
        let x1 = self.center.x - self._menuRedius - (self._menuButtonSize.width / 2)
        let x2 = self.center.x +  (self._menuRedius) + (self._menuButtonSize.width / 2)
        let y1 = self.center.y - self._menuRedius - (self._menuButtonSize.width / 2)
        let y2 = self.center.y +  (self._menuRedius) + (self._menuButtonSize.width / 2)
        
        if(x1 <= 0){
            isLeft = true
        }else if(x1 > 0 && x2 < self.parentViewOfMenuButton.frame.width){
            isCenterX = true
        }
        
        if(y1 <= 0){
            isTop = true
        }else if(y1 > 0 && y2 < self.parentViewOfMenuButton.frame.height){
            isCenterY = true
        }
        //For setting positions
        if(isLeft){
            if isTop{
                return .topLeft
            }else if isCenterY{
                return .centerLeft
            }else{
                return .bottomLeft
            }
        }else if isCenterX{
            if isTop{
                return .centerTop
            }else if isCenterY{
                return .center
            }else{
                return .centerBottom
            }
        }else{
            if isTop{
                return .topRight
            }else if isCenterY{
                return .centerRight
            }else{
                return .bottomRight
            }
        }
        //
    }

}
