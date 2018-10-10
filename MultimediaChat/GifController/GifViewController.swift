////
////  GifViewController.swift
////  CollectionView
////
////  Created by Tobias Frantsen on 26/09/2018.
////  Copyright © 2018 Tobias Frantsen. All rights reserved.
////
//import GiphyCoreSDK
//import UIKit
//
//class GifViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
//   
//   
//    private var gifArray: [String]?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        GiphyCore.configure(apiKey: "NYpq6j1X5wXDZYYslFFsBmA8A2OF7nIk")
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        
//        collectionView.register(UINib.init(nibName: "CollectionCell", bundle: nil), forCellWithReuseIdentifier: "CollectionCell")
//
//        // Do any additional setup after loading the view.
//    }
//    
//    
//    func getGifArray() {
//        /// Gif Search
//        _ = GiphyCore.shared.search("cats") { (response, error) in
//            
//            if (error as NSError?) != nil {
//                // Do what you want with the error
//            }
//            
//            if let response = response, let data = response.data, let pagination = response.pagination {
//                print(response.meta)
//                print(pagination)
//                for result in data {
//                    if let gifUrl = result.images?.original?.gifUrl {
//                        self.gifArray?.append(gifUrl)
//                    }
//                }
//            } else {
//                print("No Results Found")
//            }
//        }
//        
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.gifArray?.count ?? 0
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionCell
//        
//        if let gifURL = self.gifArray?[indexPath.row] {
//            cell.configure(gifURL: gifURL)
//        }
//        return cell
//    }
//
//}
