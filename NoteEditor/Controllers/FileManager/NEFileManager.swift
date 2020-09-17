//
//  NEFileManager.swift
//  Note Editor
//
//  Created by Thang Pham on 8/28/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class NEFileManager {
    
    // query app's asset folder path and create  if not existed
    class func assetFolderURL() -> URL? {
        do {
            var path = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            path = path.appendingPathComponent(APP_DOCUMENT_ASSET_FOLDER)
            var isDir : ObjCBool = false
            if FileManager.default.fileExists(atPath: path.path, isDirectory: &isDir) {
                if isDir.boolValue {
                    return path
                }
            }
            try FileManager.default.createDirectory(at: path, withIntermediateDirectories: false, attributes: nil)
            return path
            
        } catch (let error) {
            print(error)
        }
        return nil
    }
    
    class func noteFromAssetFolder(id: String) -> URL? {
        guard let assetUrl = assetFolderURL() else { return nil }
        do {
            let path = assetUrl.appendingPathComponent(id)
            var isDir : ObjCBool = false
            if FileManager.default.fileExists(atPath: path.path, isDirectory: &isDir) {
                if isDir.boolValue {
                    return path
                }
            }
            try FileManager.default.createDirectory(at: path, withIntermediateDirectories: false, attributes: nil)
            return path
        } catch (let error) {
            print(error)
        }
        return nil
    }
    
    class func deleteNoteFromAssetFolder(id: String) -> Bool {
        guard let noteFolderURL = noteFromAssetFolder(id: id) else { return false }
        do {
            try FileManager.default.removeItem(at: noteFolderURL)
            return true
        } catch (let error) {
            print(error)
        }
        return false
    }
    
    class func createdDateOfFile(path: String) -> NSDate? {
        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: path)
            return attrs[FileAttributeKey.creationDate] as? NSDate
        }catch (let error) {
            print(error)
        }
        return nil
    }
    
    class func modifiedDateOfFile(path: String) -> NSDate? {
        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: path)
            return attrs[FileAttributeKey.modificationDate] as? NSDate
        }catch (let error) {
            print(error)
        }
        return nil
    }
    
    class func writeImageToAssetFolder(noteId id: String, image: UIImage, fileName: String) -> Bool {
        guard let noteFolderURL = noteFromAssetFolder(id: id) else { return false }
        var filePath = noteFolderURL.appendingPathComponent(fileName)
        filePath = filePath.appendingPathExtension("jpg")
        do {
            if let imageData =  UIImageJPEGRepresentation(image, 1.0) {
                try imageData.write(to: filePath, options: .atomic)
                return true
            }
        } catch (let error){
            print(error)
        }
        return false
    }
    
    class func getImagesFromAssetFolder(noteId id: String) -> [String] {
        do {
            guard let noteFolderURL = noteFromAssetFolder(id: id) else { return [String]() }
            let files = try FileManager.default.contentsOfDirectory(atPath: noteFolderURL.path)
            var images = [String]()
            for file in files {
                if (file as NSString).pathExtension == "jpg" {
                    images.append(file)
                }
            }
            return images
        } catch (let error) {
            print(error)
        }
        return [String]()
    }
    
    class func writeDataToAssetFolder(noteId id: String, data: Data, fileName:String) -> Bool {
        guard let noteFolderURL = noteFromAssetFolder(id: id) else { return false }
        let filePath = noteFolderURL.appendingPathComponent(fileName)
        do {
            try data.write(to: filePath, options: .atomic)
            return true
        }catch (let error){
            print(error)
        }
        return false
    }
    
    class func moveFileToAssetFolder(noteId id: String, sourceUrl: URL, fileName: String) -> Bool {
        guard let noteFolderURL = noteFromAssetFolder(id: id) else { return false }
        let filePath = noteFolderURL.appendingPathComponent(fileName)
        do {
            if !FileManager.default.fileExists(atPath: filePath.path) {
                try FileManager.default.moveItem(at: sourceUrl, to: filePath)
            }
            return true
        }catch (let error){
            print(error)
        }
        return false
    }
    
    class func getImageFromAssetFolder(noteId id:String, image name: String) -> UIImage? {
        guard let noteFolderURL = noteFromAssetFolder(id: id) else { return nil }
        let imagePath = noteFolderURL.appendingPathComponent(name)
        do {
            if FileManager.default.fileExists(atPath: imagePath.path) {
                let data = try Data(contentsOf: imagePath)
                return UIImage(data: data)
            }
        } catch (let error) {
            print(error)
        }
        
        return nil
    }
    
    class func getFileURLFromAssetFolder(noteId id:String, file name:String) -> URL? {
        guard let noteFolderURL = noteFromAssetFolder(id: id) else { return nil }
        let filePath = noteFolderURL.appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: filePath.path) {
            return filePath
        }
        return nil
    }
}
