//
//  ColorDataModel.swift
//  B4Grad
//
//  Created by Sunil Zalavadiya on 12/01/19.
//  Copyright © 2019 Anthony Giugno. All rights reserved.
//

import Foundation

class ColorDataModel {
    var colorStaticValue = 0
    var color = UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1)
    
    init(colorStaticValue: Int, color: UIColor) {
        self.colorStaticValue = colorStaticValue
        self.color = color
    }
    
    class func defaultColorModel() -> ColorDataModel {
        return ColorDataModel(colorStaticValue: 0, color: UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1))
    }
    
    class func getAllColorsArray() -> [ColorDataModel] {
        var colors = [ColorDataModel]()
        
        colors.append(contentsOf: getColorsArray())
        colors.append(contentsOf: getSandyShoresideColorsArray())
        for colorsAr in getIndividualColorsArray() {
            colors.append(contentsOf: colorsAr)
        }
        //colors.append(contentsOf: getIndividualColorsArray())
        
        return colors
    }
    
    class func getColorsArray() -> [ColorDataModel] {
        var colors = [ColorDataModel]()
        
        colors.append(ColorDataModel(colorStaticValue: 1, color: UIColor(red: 43/255, green: 132/255, blue: 210/255, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 2, color: UIColor(red: 44/255, green: 197/255, blue: 94/255, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 3, color: UIColor(red: 237/255, green: 186/255, blue: 16/255, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 4, color: UIColor(red: 222/255, green: 106/255, blue: 27/255, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 5, color: UIColor(red: 223/255, green: 52/255, blue: 46/255, alpha: 1)))
        
        return colors
    }
    
    class func getSandyShoresideColorsArray() -> [ColorDataModel] {
        var colors = [ColorDataModel]()
        
        colors.append(ColorDataModel(colorStaticValue: 6, color: #colorLiteral(red: 1, green: 0.7529411765, blue: 0.5333333333, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 7, color: #colorLiteral(red: 0.8470588235, green: 0.6509803922, blue: 0.6705882353, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 8, color: #colorLiteral(red: 0.5176470588, green: 0.3921568627, blue: 0.4941176471, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 9, color: #colorLiteral(red: 0.1803921569, green: 0.1490196078, blue: 0.2, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 10, color: #colorLiteral(red: 0.4117647059, green: 0.2705882353, blue: 0.3058823529, alpha: 1)))
        
        return colors
    }
    
    class func getDryDesertColorsArray() -> [ColorDataModel] {
        var colors = [ColorDataModel]()
        
        colors.append(ColorDataModel(colorStaticValue: 11, color: #colorLiteral(red: 0.9647058824, green: 0.8549019608, blue: 0.7529411765, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 12, color: #colorLiteral(red: 0.7215686275, green: 0.8823529412, blue: 0.937254902, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 13, color: #colorLiteral(red: 0.7058823529, green: 0.5294117647, blue: 0.4039215686, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 14, color: #colorLiteral(red: 0.9333333333, green: 0.9568627451, blue: 0.9607843137, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 15, color: #colorLiteral(red: 0.9019607843, green: 0.7450980392, blue: 0.6078431373, alpha: 1)))
        
        return colors
    }
    
    class func getOrbitalBeautyColorsArray() -> [ColorDataModel] {
        var colors = [ColorDataModel]()
        
        colors.append(ColorDataModel(colorStaticValue: 16, color: #colorLiteral(red: 0.1019607843, green: 0.1529411765, blue: 0.2196078431, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 17, color: #colorLiteral(red: 0.1803921569, green: 0.2705882353, blue: 0.3725490196, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 18, color: #colorLiteral(red: 0.7450980392, green: 0.7843137255, blue: 0.8196078431, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 19, color: #colorLiteral(red: 0.262745098, green: 0.3607843137, blue: 0.4588235294, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 20, color: #colorLiteral(red: 0.368627451, green: 0.4431372549, blue: 0.5254901961, alpha: 1)))
        
        return colors
    }
    
    class func getCalmingJungleColorsArray() -> [ColorDataModel] {
        var colors = [ColorDataModel]()
        
        colors.append(ColorDataModel(colorStaticValue: 21, color: #colorLiteral(red: 0.08235294118, green: 0.4431372549, blue: 0.368627451, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 22, color: #colorLiteral(red: 0.07843137255, green: 0.4196078431, blue: 0.2666666667, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 23, color: #colorLiteral(red: 0.2588235294, green: 0.7019607843, blue: 0.5294117647, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 24, color: #colorLiteral(red: 0.04705882353, green: 0.2509803922, blue: 0.1450980392, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 25, color: #colorLiteral(red: 0.1294117647, green: 0.5490196078, blue: 0.3843137255, alpha: 1)))
        
        return colors
    }
    
    class func getThunderMountainColorsArray() -> [ColorDataModel] {
        var colors = [ColorDataModel]()
        
        colors.append(ColorDataModel(colorStaticValue: 26, color: #colorLiteral(red: 0.2823529412, green: 0.2235294118, blue: 0.2039215686, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 27, color: #colorLiteral(red: 0.3607843137, green: 0.2901960784, blue: 0.168627451, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 28, color: #colorLiteral(red: 0.4745098039, green: 0.3098039216, blue: 0.2156862745, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 29, color: #colorLiteral(red: 0.6823529412, green: 0.3607843137, blue: 0.2196078431, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 30, color: #colorLiteral(red: 0.6823529412, green: 0.3607843137, blue: 0.2196078431, alpha: 1)))
        
        return colors
    }
    
    class func getSunflowerBlissColorsArray() -> [ColorDataModel] {
        var colors = [ColorDataModel]()
        
        colors.append(ColorDataModel(colorStaticValue: 31, color: #colorLiteral(red: 0.7450980392, green: 0.4117647059, blue: 0.01568627451, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 32, color: #colorLiteral(red: 0.7098039216, green: 0.2941176471, blue: 0.01568627451, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 33, color: #colorLiteral(red: 0.2666666667, green: 0.2, blue: 0.0431372549, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 34, color: #colorLiteral(red: 0.05882352941, green: 0.6941176471, blue: 0.9137254902, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 35, color: #colorLiteral(red: 0.9333333333, green: 0.662745098, blue: 0.02352941176, alpha: 1)))
        
        return colors
    }
    
    class func getEyeOfTheTigerColorsArray() -> [ColorDataModel] {
        var colors = [ColorDataModel]()
        
        colors.append(ColorDataModel(colorStaticValue: 36, color: #colorLiteral(red: 0.8784313725, green: 0.6745098039, blue: 0.4745098039, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 37, color: #colorLiteral(red: 0.8862745098, green: 0.8117647059, blue: 0.6901960784, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 38, color: #colorLiteral(red: 0.6980392157, green: 0.5411764706, blue: 0.4196078431, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 39, color: #colorLiteral(red: 0.3019607843, green: 0.2509803922, blue: 0.1921568627, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 40, color: #colorLiteral(red: 0.9058823529, green: 0.8705882353, blue: 0.831372549, alpha: 1)))
        
        return colors
    }
    
    class func getIndividualColorsArray() -> [[ColorDataModel]] {
        var individualColors = [[ColorDataModel]]()
        
        var colors = [ColorDataModel]()
        colors.append(ColorDataModel(colorStaticValue: 41, color: #colorLiteral(red: 0.9215686275, green: 0.3176470588, blue: 0.2901960784, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 42, color: #colorLiteral(red: 0.8, green: 0.2, blue: 0.2, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 43, color: #colorLiteral(red: 0.6745098039, green: 0.03529411765, blue: 0.1137254902, alpha: 1)))
        individualColors.append(colors)
        
        colors = [ColorDataModel]()
        colors.append(ColorDataModel(colorStaticValue: 44, color: #colorLiteral(red: 1, green: 0.7058823529, blue: 0.1843137255, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 45, color: #colorLiteral(red: 0.9960784314, green: 0.6, blue: 0, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 46, color: #colorLiteral(red: 0.8705882353, green: 0.4980392157, blue: 0, alpha: 1)))
        individualColors.append(colors)
        
        colors = [ColorDataModel]()
        colors.append(ColorDataModel(colorStaticValue: 47, color: #colorLiteral(red: 0.9960784314, green: 0.9098039216, blue: 0.3176470588, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 48, color: #colorLiteral(red: 1, green: 0.8, blue: 0.2, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 49, color: #colorLiteral(red: 0.8784313725, green: 0.6901960784, blue: 0.01960784314, alpha: 1)))
        individualColors.append(colors)
        
        colors = [ColorDataModel]()
        colors.append(ColorDataModel(colorStaticValue: 50, color: #colorLiteral(red: 0.5607843137, green: 0.8784313725, blue: 0.2352941176, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 51, color: #colorLiteral(red: 0.4470588235, green: 0.768627451, blue: 0.09803921569, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 52, color: #colorLiteral(red: 0.3294117647, green: 0.6588235294, blue: 0, alpha: 1)))
        individualColors.append(colors)
        
        colors = [ColorDataModel]()
        colors.append(ColorDataModel(colorStaticValue: 53, color: #colorLiteral(red: 0.4588235294, green: 0.7803921569, blue: 0.8862745098, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 54, color: #colorLiteral(red: 0.3450980392, green: 0.6745098039, blue: 0.7764705882, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 55, color: #colorLiteral(red: 0.2235294118, green: 0.568627451, blue: 0.6666666667, alpha: 1)))
        individualColors.append(colors)
        
        colors = [ColorDataModel]()
        colors.append(ColorDataModel(colorStaticValue: 56, color: #colorLiteral(red: 0.3843137255, green: 0.5568627451, blue: 0.9960784314, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 57, color: #colorLiteral(red: 0.2509803922, green: 0.4588235294, blue: 0.8823529412, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 58, color: #colorLiteral(red: 0.03137254902, green: 0.3647058824, blue: 0.768627451, alpha: 1)))
        individualColors.append(colors)
        
        colors = [ColorDataModel]()
        colors.append(ColorDataModel(colorStaticValue: 59, color: #colorLiteral(red: 0.7843137255, green: 0.4862745098, blue: 1, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 60, color: #colorLiteral(red: 0.6705882353, green: 0.3843137255, blue: 0.8901960784, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 61, color: #colorLiteral(red: 0.5568627451, green: 0.2823529412, blue: 0.7764705882, alpha: 1)))
        individualColors.append(colors)
        
        colors = [ColorDataModel]()
        colors.append(ColorDataModel(colorStaticValue: 62, color: #colorLiteral(red: 0.9725490196, green: 0.4941176471, blue: 0.7607843137, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 63, color: #colorLiteral(red: 0.8588235294, green: 0.3882352941, blue: 0.6549019608, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 64, color: #colorLiteral(red: 0.7450980392, green: 0.2784313725, blue: 0.5490196078, alpha: 1)))
        individualColors.append(colors)
        
        colors = [ColorDataModel]()
        colors.append(ColorDataModel(colorStaticValue: 65, color: #colorLiteral(red: 0.568627451, green: 0.568627451, blue: 0.568627451, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 66, color: #colorLiteral(red: 0.4705882353, green: 0.4705882353, blue: 0.4705882353, alpha: 1)))
        colors.append(ColorDataModel(colorStaticValue: 67, color: #colorLiteral(red: 0.3725490196, green: 0.3725490196, blue: 0.3725490196, alpha: 1)))
        individualColors.append(colors)
        
        return individualColors
    }
}
