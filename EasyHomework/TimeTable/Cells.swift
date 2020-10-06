//
//  EventDataObject.swift
//  Timetable
//
//  Created by Valentina Henao on 8/24/17.
//  Copyright © 2017 Valentina Henao. All rights reserved.
//

import UIKit
import SpreadsheetView
import Realm


class SlotCell: Cell, UIGestureRecognizerDelegate {
    
    
    @IBOutlet private weak var slotTitleLabel: UILabel!
    @IBOutlet private weak var slotLocationLabel: UILabel!
    @IBOutlet private weak var slotTypeLabel: UILabel!
    @IBOutlet private weak var slotTimeLabel: UILabel!
    @IBOutlet private weak var slotImage: UIImageView!
    
    var event:RLMRepeatingSchedule!
    
    var delegate: SlotNavigationDelegate?
    
    var labelColor = UIColor.white {
        didSet {
            slotTitleLabel.textColor    = labelColor
            slotLocationLabel.textColor = labelColor
            slotTypeLabel.textColor     = labelColor
            slotTimeLabel.textColor 	= labelColor
        }
    }
    
    var slotTitle = "" {
        didSet {
            slotTitleLabel.text = slotTitle
        }
    }
    
    var slotTitleFont = UIFont.boldSystemFont(ofSize: 16.0) {
        didSet {
            slotTitleLabel.font = slotTitleFont
        }
    }
    
    var slotLocation = "" {
        didSet {
            slotLocationLabel.text = slotLocation
        }
    }
    
    var slotType = "" {
        didSet {
            slotTypeLabel.text = slotType
        }
    }
    
    var slotTypeImage = "" {
        didSet {
            slotImage.image = UIImage(named: "Default" + slotTypeImage)
            
        }
    }
    
    
    var slotTime = "" {
        didSet {
            slotTimeLabel.text = slotTime
        }
    }
    
    var weekday = 0 {
        didSet {
            let calendar = Calendar.current
            
            if calendar.component(.weekday, from: Date()) == weekday {
                slotTitleLabel.textColor = UIColor.white
                slotLocationLabel.textColor = UIColor.white
                slotTypeLabel.textColor = UIColor.white
                slotTimeLabel.textColor = UIColor.white
                
            } else {
                slotTitleLabel.textColor = TTColorGray
                slotLocationLabel.textColor = TTColorGray
                slotTypeLabel.textColor = TTColorGray
                slotTimeLabel.textColor = TTColorGray
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let tap = UITapGestureRecognizer(target: self, action: #selector(gesture))
        tap.delegate = self
        contentView.addGestureRecognizer(tap)
        
    }
    
    @objc func gesture() {
        delegate?.segueFromSlot(event: event, cell: self)
    }
}

protocol SlotNavigationDelegate {
    func segueFromSlot(event: RLMRepeatingSchedule, cell:SlotCell)
}

class StandardCell: Cell {
    let colorBarView = UIView()
    let label = UILabel()
    
    var color: UIColor = TTColorMateBlack {
        didSet {
            colorBarView.backgroundColor = color
        }
    }
    
    override var frame: CGRect {
        didSet {
            colorBarView.frame = bounds.insetBy(dx: 0, dy: 0)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(colorBarView)
        
        let newFrame            = bounds.insetBy(dx: 0, dy: 0)
        label.frame             = CGRect(x: newFrame.origin.x, y: -2, width: newFrame.size.width, height: 20)
        
        label.autoresizingMask  = [.flexibleWidth, .flexibleHeight]
        label.font              = UIFont.boldSystemFont(ofSize: 10)
        label.textAlignment     = .center
        label.textColor         = .white
        
        contentView.addSubview(label)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.label.text = ""
        
    }
}

class WeekdayCell: Cell {
    let colorBarView = UIView()
    let label = UILabel()
    var blackLine = UIView()
    
    var color: UIColor = TTColorMateBlack {
        didSet {
            colorBarView.backgroundColor = color
        }
    }
    
    override var frame: CGRect {
        didSet {
            colorBarView.frame = bounds.insetBy(dx: 0, dy: 0)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(colorBarView)
        
        let newFrame            = bounds.insetBy(dx: 0, dy: 0)
        label.frame             = CGRect(x: newFrame.origin.x, y: -2, width: newFrame.size.width, height: 20)
        
        label.autoresizingMask  = [.flexibleWidth, .flexibleHeight]
        label.font              = UIFont.boldSystemFont(ofSize: 10)
        label.textAlignment     = .center
        label.textColor         = .white
        
        contentView.addSubview(label)
        
        blackLine = UIView(frame: CGRect(x: 0, y: self.frame.size.height - 2, width: self.frame.size.width, height: 1))
        blackLine.backgroundColor = UIColor(red:0.0, green:0.0, blue:0.0, alpha:1.0)
        self.addSubview(blackLine)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.label.text = ""
        
    }
}

class TimeCell: Cell {
    let label = UILabel()
    
    override var frame: CGRect {
        didSet {
            label.frame = CGRect(x: 0, y: -10, width: 40, height: 40)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        
        label.frame = bounds 
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.textAlignment = .center
        label.numberOfLines = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}


extension UIFont {
    
    func withTraits(traits:UIFontDescriptorSymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor
            .withSymbolicTraits(UIFontDescriptorSymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
    
    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }
    
}
