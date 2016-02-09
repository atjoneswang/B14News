//
//  NewsDetailViewController.swift
//  BMWNews
//
//  Created by jones wang on 2015/12/27.
//  Copyright © 2015年 DevJW. All rights reserved.
//

import UIKit
import WebKit
import FontAwesome_swift


class NewsDetailViewController: UIViewController, WKNavigationDelegate,UIWebViewDelegate {

    var link:String?
    
    var webView: WKWebView!
    
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.toolbarHidden = false
                
        // set navigationItem back bouuton color
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        navigationController?.toolbar.barTintColor = UIColor.darkGrayColor()
        
		// self.navigationController?.navigationBarHidden = true
		// let attributes = [NSFontAttributeName: UIFont.fontAwesomeOfSize(20)] as Dictionary!
		// refreshButton.setTitleTextAttributes(attributes, forState: .Normal)
		// refreshButton.title = String.fontAwesomeIconWithCode("fa-refresh")
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        progressBar.hidden = true
        refreshButton.enabled = false
        view.insertSubview(webView, belowSubview: progressBar)
        
        if let address = link {
            let webURL = NSURL(string: address)
            let request = NSURLRequest(URL: webURL!)
            self.webView.loadRequest(request)
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.toolbarHidden = true
        navigationController?.hidesBarsOnSwipe = false
        
        //navigationController?.popToRootViewControllerAnimated(animated)
        
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (keyPath == "estimatedProgress") {
            progressBar.hidden = webView.estimatedProgress == 1
            refreshButton.enabled = webView.estimatedProgress == 1
            
            navigationController?.hidesBarsOnSwipe = webView.estimatedProgress == 1
            progressBar.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        progressBar.setProgress(0.0, animated: false)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
        
    }
    
    @IBAction func shareLink(sender: AnyObject) {
        let activityViewController = UIActivityViewController(activityItems: [link! as NSString], applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: {})
    }
    
    @IBAction func refreshWebPage(sender: AnyObject) {
        self.webView.reload()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
