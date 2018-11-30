//
//  CameraController.swift
//  CollectionView
//
//  Created by Tobias Frantsen on 03/10/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//
import MobileCoreServices
import Photos
import UIKit

enum AttachmentType: String{
    case camera, video, photoLibrary
}

class CameraController: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentMenuDelegate, UIDocumentPickerDelegate {
    
    static let shared = CameraController()
    private var attachmentType : AttachmentType?
    private var currentVC: UIViewController?
    //MARK: - Internal Properties
    var imagePickedBlock: ((UIImage, URL) -> Void)?
    var videoPickedBlock: ((NSURL) -> Void)?
    var filePickedBlock: ((URL) -> Void)?
    var imagePickedURL: ((String) -> Void)?
    var imageLibraryPickedBlock: ((UIImage, URL) -> Void)?
    var videoLibraryPickedBlock: (( URL) -> Void)?
    
    func authorisationStatus(attachmentTypeEnum: AttachmentType, vc: UIViewController){
        currentVC = vc
        self.attachmentType = attachmentTypeEnum
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            if attachmentTypeEnum == AttachmentType.camera{
                openCamera()
            }
            if attachmentTypeEnum == AttachmentType.photoLibrary{
                photoLibrary()
            }
            if attachmentTypeEnum == AttachmentType.video{
                videoCamera()
            }
        case .denied:
            print("permission denied")
        case .notDetermined:
            print("Permission Not Determined")
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == PHAuthorizationStatus.authorized{
                    // photo library access given
                    print("access given")
                    if attachmentTypeEnum == AttachmentType.camera{
                        self.openCamera()
                    }
                    if attachmentTypeEnum == AttachmentType.photoLibrary{
                        self.photoLibrary()
                    }
                    if attachmentTypeEnum == AttachmentType.video{
                        self.videoCamera()
                    }
                }else{
                    print("restriced manually")
                }
            })
        case .restricted:
            print("permission restricted")
        default:
            break
        }
    }
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .camera
            currentVC?.present(myPickerController, animated: true, completion: nil)
        }
    }
    
    func photoLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .photoLibrary
            myPickerController.mediaTypes = [kUTTypeMovie as String, kUTTypeVideo as String, kUTTypeImage as String, kUTTypePNG as String]
            currentVC?.present(myPickerController, animated: true, completion: nil)
        }
    }
    
    func videoCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .camera
            myPickerController.mediaTypes = [kUTTypeMovie as String]
            myPickerController.allowsEditing = true
            currentVC?.present(myPickerController, animated: true, completion: nil)
        }
    }
    
    func documentPicker() {
        let importMenu = UIDocumentMenuViewController(documentTypes: [String(kUTTypePDF)], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        currentVC?.present(importMenu, animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // To handle image
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let scaleImage = self.resizeImageWithAspect(image: image, scaledToMaxWidth: 250, maxHeight: 300) {
                if self.attachmentType == . photoLibrary {
                    let imageUrl          = info[UIImagePickerControllerReferenceURL] as? NSURL
                    let imageName         = imageUrl?.lastPathComponent
                    let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                    let photoURL          = NSURL(fileURLWithPath: documentDirectory)
                    if let localPath         = photoURL.appendingPathComponent(imageName!) {
                         self.imageLibraryPickedBlock?(scaleImage, localPath)
                    }
                } else {
                    let dateFormatterGet = DateFormatter()
                    dateFormatterGet.dateFormat = "yyyy-MM-ddHHmmss"
                    let date = dateFormatterGet.string(from: Date())
                    let path = self.saveImage(imageName: "\(date).png",  image: scaleImage)
                    debugPrint("noob \(path)")
                    self.imagePickedURL?(path)
                }
            }
      
            
        } else{
//            if info[UIImagePickerControllerMediaType] as? String  == String(kUTTypeMovie) {
//              debugPrint("NOOB I GO THIS")
//            }
//            print("Something went wrong in  image")
        }
        // To handle video
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL{
            print("videourl: ", videoUrl)
            //trying compression of video
            let data = NSData(contentsOf: videoUrl as URL)!
            print("File size before compression: \(Double(data.length / 1048576)) mb")
            compressWithSessionStatusFunc(videoUrl)
            self.videoLibraryPickedBlock?(videoUrl as URL)
        }
        else{
            print("Something went wrong in  video")
        }
        currentVC?.dismiss(animated: true, completion: nil)
    }
    
    
//    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
//        debugPrint(image)
//    }
    
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPreset1280x720) else {
            handler(nil)
            
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
    private func compressWithSessionStatusFunc(_ videoUrl: NSURL) {
        let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".MOV")
        compressVideo(inputURL: videoUrl as URL, outputURL: compressedURL) { (exportSession) in
            guard let session = exportSession else {
                return
            }
            
            switch session.status {
            case .completed:
                guard let compressedData = NSData(contentsOf: compressedURL) else {
                    return
                }
                print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
                
                DispatchQueue.main.async {
                    self.videoPickedBlock?(compressedURL as NSURL)
                }
            case .unknown, .waiting, .exporting, .failed, .cancelled:
                break
             
            }
        }
    }
        
        func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
            documentPicker.delegate = self
            currentVC?.present(documentPicker, animated: true, completion: nil)
        }
        
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
            print("url", url)
            self.filePickedBlock?(url)
        }
        
        //    Method to handle cancel action.
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            currentVC?.dismiss(animated: true, completion: nil)
        }
    
    func saveImage(imageName: String, image: UIImage) -> String{
        //create an instance of the FileManager
        let fileManager = FileManager.default
        //get the image path
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        //get the image we took with camera
        let _image = image
        //get the PNG data for this image
        let data = UIImagePNGRepresentation(_image)
        //store it in the document directory
        fileManager.createFile(atPath: imagePath as String, contents: data, attributes: nil)
        
        return self.getImagePath(imageName: imageName)
        
    }

    
    func getImagePath(imageName: String) ->  String{
        let fileManager = FileManager.default
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        if fileManager.fileExists(atPath: imagePath){
           return imagePath
        }else{
            print("Panic! No Image!")
        }
        return ""
    }
    
    private func resizeImageWithAspect(image: UIImage,scaledToMaxWidth width:CGFloat,maxHeight height :CGFloat)->UIImage? {
        let oldWidth = image.size.width;
        let oldHeight = image.size.height;
        
        let scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight;
        
        let newHeight = oldHeight * scaleFactor;
        let newWidth = oldWidth * scaleFactor;
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize,false,UIScreen.main.scale);
        
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height));
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage
    }
    
}
