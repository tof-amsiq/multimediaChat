////
////  ImageViewController.swift
////  CollectionView
////
////  Created by Tobias Frantsen on 24/09/2018.
////  Copyright © 2018 Tobias Frantsen. All rights reserved.
////
//import Photos
//import UIKit
//
//class ImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
//
//    @IBOutlet weak var imageView: UIImageView!
//
//
//    let imagePicker = UIImagePickerController()
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.imagePicker.delegate = self
//
//        imagePicker.allowsEditing = false
//        imagePicker.sourceType = .photoLibrary
//
//        let photos = PHPhotoLibrary.authorizationStatus()
//        if photos == .notDetermined {
//            PHPhotoLibrary.requestAuthorization({status in
//                if status == .authorized{
//
//                } else {}
//            })
//        }
//
//        present(imagePicker, animated: true, completion: nil)
//        // Do any additional setup after loading the view.
//    }
//
//    @IBAction func goBack(_ sender: Any) {
//        debugPrint(navigationController!)
//        navigationController?.dismiss(animated: true)
//    }
//
//
//
//    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            imageView.contentMode = .scaleAspectFit
//            imageView.image = pickedImage
//        }
//
//        dismiss(animated: true, completion: nil)
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        dismiss(animated: true, completion: nil)
//    }
//
//    }
//
