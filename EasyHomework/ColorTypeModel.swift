//
//  ColorTypeModel.swift
//  B4Grad
//
//  Created by Sunil Zalavadiya on 21/01/19.
//  Copyright © 2019 Anthony Giugno. All rights reserved.
//

import Foundation
//let ColorDataModel: ColorDataModel

enum PaletteType {
    case palette
    case individual
}

class ColorGroupModel {
    var name = ""
    var showInfo = false
    var info: String?
    var paletteType: PaletteType = .palette
    var palettes = [ColorTypeModel]()
    
    init(name: String, info: String? = nil, showInfo: Bool = false, paletteType: PaletteType, palettes: [ColorTypeModel]) {
        self.name = name
        self.info = info
        self.showInfo = showInfo
        self.paletteType = paletteType
        self.palettes = palettes
    }
    
    class func getGroupedColors() -> [ColorGroupModel] {
        var colorGroups = [ColorGroupModel]()
        
        var colorTypes = [ColorTypeModel]()
        colorTypes.append(ColorTypeModel(typeName: "Graduation Day", colors: ColorDataModel.getColorsArray(), bgImageName: "DefaultBackground1", paletteType: .palette))
        colorTypes.append(ColorTypeModel(typeName: "Sandy Shoreside", colors: ColorDataModel.getSandyShoresideColorsArray(), bgImageName: "Shore_porttrait", paletteType: .palette))
        colorTypes.append(ColorTypeModel(typeName: "Dry Dry Desert", colors: ColorDataModel.getDryDesertColorsArray(), bgImageName: "Desert_porttrait", paletteType: .palette))
        colorTypes.append(ColorTypeModel(typeName: "Orbital Beauty", colors: ColorDataModel.getOrbitalBeautyColorsArray(), bgImageName: "Earth_porttrait", paletteType: .palette))
        colorTypes.append(ColorTypeModel(typeName: "Calming Jungle", colors: ColorDataModel.getCalmingJungleColorsArray(), bgImageName: "Foliage_porttrait", paletteType: .palette))
        colorTypes.append(ColorTypeModel(typeName: "Thunder Mountain", colors: ColorDataModel.getThunderMountainColorsArray(), bgImageName: "Mountain_porttrait", paletteType: .palette))
        colorTypes.append(ColorTypeModel(typeName: "Sunflower Bliss", colors: ColorDataModel.getSunflowerBlissColorsArray(), bgImageName: "Sunflower_porttrait", paletteType: .palette))
        colorTypes.append(ColorTypeModel(typeName: "Eye of the Tiger", colors: ColorDataModel.getEyeOfTheTigerColorsArray(), bgImageName: "Tiger_porttrait", paletteType: .palette))
        
        colorGroups.append(ColorGroupModel(name: "Color Palettes", info: "These are color palettes with matching backgrounds designed specifically for the B4Grad mobile app.", showInfo: true, paletteType: .palette, palettes: colorTypes))
        
        let individualColors = ColorDataModel.getIndividualColorsArray()
        colorTypes.removeAll()
        colorTypes = [ColorTypeModel]()
        for colors in individualColors {
            colorTypes.append(ColorTypeModel(typeName: "", colors: colors, paletteType: .individual))
        }
        colorGroups.append(ColorGroupModel(name: "Colors", paletteType: .individual, palettes: colorTypes))
        
        return colorGroups
    }
}

class ColorTypeModel {
    var paletteType: PaletteType = .palette
    var paletteName = ""
    var colors = [ColorDataModel]()
    var bgImageName: String = ""
    
    init(typeName: String, colors: [ColorDataModel], bgImageName: String = "", paletteType: PaletteType) {
        self.paletteName = typeName
        self.colors = colors
        self.bgImageName = bgImageName
        self.paletteType = paletteType
    }
    
    class func getAllColorTypes() -> [ColorTypeModel] {
        var colorTypes = [ColorTypeModel]()
        
        colorTypes.append(ColorTypeModel(typeName: "Graduation Day", colors: ColorDataModel.getColorsArray(), bgImageName: "DefaultBackground1", paletteType: .palette))
        colorTypes.append(ColorTypeModel(typeName: "Sandy Shoreside", colors: ColorDataModel.getSandyShoresideColorsArray(), bgImageName: "Shore_porttrait", paletteType: .palette))
        
        let individualColors = ColorDataModel.getIndividualColorsArray()
        for colors in individualColors {
            colorTypes.append(ColorTypeModel(typeName: "", colors: colors, paletteType: .individual))
        }
        //colorTypes.append(ColorTypeModel(typeName: "", colors: ColorDataModel.getIndividualColorsArray(), paletteType: .individual))
        
        return colorTypes
    }
}
