//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Fiona Thompson on 1/14/17.
//  Copyright © 2017 Fiona Thompson. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var movies: [NSDictionary]?
    var filteredData: [NSDictionary]!
    var endpoint: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)

        collectionView.insertSubview(refreshControl, at: 0)

        
        collectionView.delegate = self
        collectionView.dataSource = self
        searchBar.delegate = self
        
        self.navigationItem.titleView = self.searchBar
        
        refreshControlAction(refreshControl)
        
       
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        if let filteredData = self.filteredData {
            return filteredData.count
        } else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCell
    
        let movie = filteredData![indexPath.row]
        //let title = movie["title"] as! String
        //let overview = movie["overview"] as! String
        //cell.titleLabel.text = title
        //cell.overviewLabel.text = overview
    
        let baseUrl = "http://image.tmdb.org/t/p/w342"
    
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = NSURL(string: baseUrl + posterPath)
            cell.posterImage.setImageWith(imageUrl as! URL)
        }
        
        
        //print ("row \(indexPath.row)")
        return cell
    }

    
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        guard let ep = endpoint else {
            refreshControl.endRefreshing()
            return
        }
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(ep)?api_key=\(apiKey)")
        let request = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    print(dataDictionary)
                    
                    self.movies = dataDictionary["results"] as? [NSDictionary]
                    self.collectionView.reloadData()
                }
            }
            self.filteredData = self.movies
            MBProgressHUD.hide(for: self.view, animated: true)
            
            self.collectionView.reloadData()
            refreshControl.endRefreshing()
        }
        
        task.resume()
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        filteredData = searchText.isEmpty ? movies : movies?.filter({(movie: NSDictionary) -> Bool in
            // If dataItem matches the searchText, return true to include it
            let title = movie["title"] as! String
            return title.range(of: searchText, options: .caseInsensitive) != nil
        })
        
        
        
        collectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPath(for: cell)
        let filteredData = self.filteredData![indexPath!.row]
        
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = filteredData
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
