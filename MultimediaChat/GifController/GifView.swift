//
//  GifView.swift
//  CollectionView
//
//  Created by Tobias Frantsen on 26/09/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//

import GiphyCoreSDK
import UIKit

//protocol GifPickerDelegate: class {
//    func getLink(_ url: String?)
//}

class GifView: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionVIew: UICollectionView!
    
    
    weak var delegate: GifPickerDelegate?
    
    private var gifArray: [String] = []
//    private var gifLink: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.collectionVIew.dataSource = self
        self.collectionVIew.delegate = self
        
        self.collectionVIew.register(UINib.init(nibName: "GifCell", bundle: nil), forCellWithReuseIdentifier: "GifCell")
        // Do any additional setup after loading the view.
        GiphyCore.configure(apiKey: "NYpq6j1X5wXDZYYslFFsBmA8A2OF7nIk")
        self.getGifArray()
        
    }
    
    
        func getGifArray() {
            /// Gif Search
            _ = GiphyCore.shared.search("cats") { (response, error) in
    
                if (error as NSError?) != nil {
                    // Do what you want with the error
                }
    
                if let response = response, let data = response.data, let pagination = response.pagination {
                    print(response.meta)
                    print(pagination)
                    for result in data {
                        if let gifUrl = result.images?.original?.gifUrl {
                            self.gifArray.append(gifUrl)
                         
                        }
                    }
                    DispatchQueue.main.async {
                        self.collectionVIew.reloadData()
                    }
                    
                } else {
                    print("No Results Found")
                }
            }
        }
    
    
    

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 250)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.gifArray.isEmpty {
            return 5
        } else {
            return self.gifArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GifCell", for: indexPath) as! GifCell
        
        if self.gifArray.isEmpty {
            cell.setup(gifURL: "")
        }else {
            let URL = self.gifArray[indexPath.row]
            cell.setup(gifURL: URL)
            //        self.gifLink = URL
        }

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let url = self.gifArray[indexPath.row]
        self.delegate?.getLink(url)
        self.navigationController?.popViewController(animated: true)
    }

}
