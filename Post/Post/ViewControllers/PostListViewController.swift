//
//  PostListViewController.swift
//  Post
//
//  Created by Blake kvarfordt on 8/12/19.
//  Copyright © 2019 Blake kvarfordt. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        postController.fetchPosts {
            DispatchQueue.main.async {
                self.reloadTableView()
            }
        }
        tableView.estimatedRowHeight = 45
        tableView.rowHeight = UITableView.automaticDimension
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
    }
    
    let postController = PostController()
    
    let refreshControl = UIRefreshControl()
    
    // MARK: - TableView Protocol Stubs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postController.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath)
        
        let post = postController.posts[indexPath.row]
        
        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = post.username
        
        return cell
    }
    
    // MARK: - Actions
    @IBAction func adButtonTapped(_ sender: UIBarButtonItem) {
        presentNewPostAlert()
    }
    
    // Alert Controller
    func presentNewPostAlert() {
        
        let errorAlert = UIAlertController(title: "Didnt work", message: "go back and try again", preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "Error", style: .cancel, handler: { (action) in
            self.presentNewPostAlert()
            return
        }))
        
        let alert = UIAlertController(title: "Alert", message: "create new message", preferredStyle: .alert)
        alert.addTextField { (userNameTextField) in }
        alert.addTextField { (messageTextField) in }

        
        alert.addAction(UIAlertAction(title: "add stuff", style: .default, handler: { (action) in
            
            guard let username = alert.textFields?[0].text, let message = alert.textFields?[1].text  else { return }
            
            if message == "" || username == ""{
                self.present(errorAlert, animated: true, completion: nil)
            }
            
            self.postController.addNewPost(username: username, text: message, completion: { (success) in
                DispatchQueue.main.async {
                    self.reloadTableView()
                }
            })
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    // MARK: - tableView Refresh
    @objc func refreshControlPulled() {
        postController.fetchPosts {
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.tableView.reloadData()
    }
}
    
    
}

extension PostListViewController {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= postController.posts.count - 1 {
            postController.fetchPosts(reset: false, completion: reloadTableView)
        }
    }
}
