//
//  CommentsListVC.swift
//  GhGist_FvComment
//
//  Created by Philliph on 14/07/18.
//  Copyright © 2018 Philliph. All rights reserved.
//

import UIKit

class CommentsListVC: UIViewController {
    
    @IBOutlet weak var labelTitleGist: UILabel!
    @IBOutlet weak var textViewCode: UITextView!
    @IBOutlet weak var tableView: UITableView!
    var stopActivity = 0
    var cameFromComment = false
    var activityView : UIView?
    lazy var refreshControl = UIRefreshControl()
    
    var displayElements : [DataComments] = []
    let git = GitAPI.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = false
        view.backgroundColor = .CustomDarkOne()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .CustomDarkOne()
        tableView.register(UINib(nibName: "CommentsCell", bundle: nil), forCellReuseIdentifier: "CCell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self,
                                                            action: #selector(addNewComment(_:)) )
        refreshControl.addTarget(self, action: #selector(tbRefresh(_:)), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white ])
        tableView.addSubview(refreshControl)
        
        textViewCode.isEditable = false
        textViewCode.setPreferences()
        labelTitleGist.text = " "
        labelTitleGist.numberOfLines = 0
        labelTitleGist.textColor = .white
        
        git.getGistCode { [weak self] tuple, result in
            
            if result.status  == .success {
                DispatchQueue.main.async {
                    self?.textViewCode.text = tuple.text
                    self?.labelTitleGist.text = tuple.title
                    self?.checkStopActivity()
                }}}
        updateComments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "Gist Comments"
        
        //Git Gist takes a while to update a posted comment - We try to counter that
        if cameFromComment {
            cameFromComment = false
            //Request for gist code is not invoked again - animation control
            self.stopActivity = 1
            //Gist API has some delay to return a new comment
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(15) ) {
                self.updateComments()
            }
        }
    }
    
    @IBAction func tbRefresh(_ sender: Any?) {
        self.stopActivity = 1
        updateComments()
    }
    
    fileprivate func updateComments() {
        DispatchQueue.main.async {
            self.activityView = UIViewController.displaySpinner(onView: self.view)
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.refreshControl.endRefreshing()
        }

        git.getCommentList { [weak self] comments, result in
            
            if result.status  == .success {
                self?.displayElements = comments
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.checkStopActivity()
                }}}
        
    }
    
    fileprivate func checkStopActivity() {
        self.stopActivity += 1
        if self.stopActivity == 2 {
            self.stopActivity = 0
            navigationItem.rightBarButtonItem?.isEnabled = true
            if let activity = self.activityView {
                UIViewController.removeSpinner(spinner: activity )
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = nil
    }
    
    @IBAction func addNewComment(_ sender : UIBarButtonItem) {
        let addComVC = AddCommentVC(nibName: "AddCommentVC", bundle: nil)
        addComVC.delegate = self
        navigationController?.pushViewController(addComVC, animated: true)
    }
}

extension CommentsListVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "CCell") as! CommentsCell
        let item = displayElements[indexPath.section]
        cell.labelBody.text = item.body
        cell.labelUser.text = "\(item.userName) commented"
        cell.labelCreatedAt.text = item.createdAt
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.displayElements.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // "Empty" space between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
}

//Add comment protocol
extension CommentsListVC : AddCommentProt {
    
    func receivedCommentText(text: String) {
        self.cameFromComment = true
        git.postComment(text) { _ in }
    }
}
