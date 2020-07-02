//
//  WebController.swift
//  SpriteKitFirst
//
//  Created by Roman on 01.07.2020.
//  Copyright © 2020 Roman Monakhov. All rights reserved.
//

import UIKit
import WebKit
import FBSDKLoginKit


class WebController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    
    let homePage = "https://www.google.com/"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let loginButton = FBLoginButton()
        loginButton.frame = CGRect(x: view.bounds.width - 120, y: 1, width: 100, height: 30)
        loginButton.permissions = ["public_profile", "email"]
       
        view.addSubview(loginButton)
        
        webView.navigationDelegate = self
        
        let url = URL(string: homePage)
        let request = URLRequest(url: url!)
        
        webView.load(request)
        webView.allowsBackForwardNavigationGestures = true
        // Do any additional setup after loading the view.
    }
    

    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true)
    }


}
