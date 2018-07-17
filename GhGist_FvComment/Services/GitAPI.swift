//
//  GitAPI.swift
//  GhGist_FvComment
//
//  Created by Philliph on 14/07/18.
//  Copyright © 2018 Philliph. All rights reserved.
//

import Foundation
import OAuthSwift

enum GitRequestResult {
    case success
    case failed
    case parseError
}

struct DataComments {
    var body : String
    var userName : String
    var createdAt : String
}

class GitAPI {
    
    static var sharedInstance = GitAPI()

    var oauthswift: OAuth2Swift!

    let baseGistString = "https://api.github.com/gists/"
    var commentGistString = ""
    var codeGistString = ""

    fileprivate var validToken = false
    
    
    
    
    init() {
        
        //App Specific
        oauthswift = OAuth2Swift(
            consumerKey: "c3fbec49d0518c64ccb8",
            consumerSecret: "99c40ae89b9e44a5a6fba71f550323b2bbf6f259",
            authorizeUrl: "https://github.com/login/oauth/authorize",
            accessTokenUrl: "https://github.com/login/oauth/access_token",
            responseType: "code"
        )
        
        oauthswift.allowMissingStateCheck = true
    }
    
    fileprivate func registerViewController(viewController : UIViewController?) {
        
        guard let view = viewController else { return }
        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: view, oauthSwift: oauthswift)
    }
    
    func clearURLHandler() {
        oauthswift.authorizeURLHandler = OAuthSwiftOpenURLExternally.sharedInstance
    }
    
    func createCommentString(gistID stringRec : String){
        
        commentGistString = baseGistString + stringRec + "/comments"
        codeGistString = baseGistString + stringRec
    }
    
    func requiresAuth() -> Bool {
        
        if !validToken {
            let tokenS = KeychainService.loadPassword()
            guard let token = tokenS else { return true }
            
            validToken = true
            self.oauthswift.client.credential.oauthToken = token as String
        }
        return false
    }
    
    func loadToken(viewController : UIViewController?) {
        
        registerViewController(viewController: viewController )
        self.authorizeGistPermission()
     }
    
   fileprivate func authorizeGistPermission(){
        
        //Same callback as defined in the app register in the github website
        guard let callBackURL = URL(string: "GhGist-FvComment://login/oauthcallback") else { return }//URL Scheme
        let definedScope = "gist" //Asks for gist permission
        
        oauthswift.authorize(withCallbackURL: callBackURL, scope: definedScope, state: "", success: { [weak self] (credential, response, parameters) in
            
            KeychainService.savePassword(token: credential.oauthToken as NSString )
            self?.oauthswift.client.credential.oauthToken = credential.oauthToken
            self?.validToken = true
            }, failure: { (error) in
                print(error.localizedDescription)
        })
    }
    
    func extractComments( response : OAuthSwiftResponse) -> [DataComments] {
        
        //Convert to JSON parsing library
        
        let json = try? response.jsonObject()
        
        //Convert Data
        var returnArray : [DataComments] = Array();
        
        //Get comments arrives as an array
        if let jsonType = json as? NSArray {
            
            jsonType.forEach { dictionary in
                
                //Requires json integrity from git
                if let element = dictionary as? NSDictionary,
                    let body = element["body"] as? String,
                    let userName = ((element["user"])! as! NSDictionary)["login"] as? String,
                    let createdAt = element["created_at"] as? String
                {
                    //Converts to local time
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                    
                    guard let date = dateFormatter.date(from: createdAt ) else {
                        print("ERROR: Date conversion failed due to mismatched format.")
                        return
                    }
                    
                    dateFormatter.timeZone = TimeZone.current
                    dateFormatter.dateFormat = "MM/dd/yyyy 'at' HH:mm"
                    let newLocalString = dateFormatter.string(from: date)
                    
                    let dc = DataComments(body: body, userName: userName, createdAt: newLocalString )
                    returnArray.append(dc)
                }
            }
        }
        return returnArray
    }
    
    func extractGistCode( response : OAuthSwiftResponse) -> (title: String, text: String) {
        
        let emptyTuple = ("","")
        let json = try? response.jsonObject()
        
        if let json1 = json as? [String : Any] {
            
            guard let files = json1["files"] as? NSDictionary else { return emptyTuple}
            
            let dataReturn = files.map { recDict -> (String, String) in
                
                guard let title = recDict.key as? String else { return emptyTuple }
                guard let currentFile = recDict.value as? NSDictionary else { return emptyTuple }
          
                if let content = currentFile["content"] as? String {
                    return (title, content)
                }
                    return emptyTuple
                }
                .filter{ $0.0.count > 0 }
           
            if dataReturn.count > 0  {
                return dataReturn.first!
            } else {
                return emptyTuple
            }
        }
        return emptyTuple
    }
    
    func getGistCode( gistString: String? = nil, callback: @escaping (_ comments: (title: String, text: String), _ tuple: ( status : GitRequestResult , resultString : String?) ) -> Void) {

        var stringRequest : String!
        if let recString = gistString {
            stringRequest = recString
        } else {
            stringRequest = codeGistString
        }
        
        _ = self.oauthswift.client.get( stringRequest,
                                        success: { [weak self] response in
                                            
                                            if let result = self?.extractGistCode(response: response) { callback(result, (status : .success, resultString : nil) )
                                            } else { callback( ("",""), (status : .parseError, resultString : "Could not parse the received data") ) }
                                        },
                                        failure: { error in
                                            callback( ("",""), (status : .failed, resultString : error.localizedDescription) )
                                        })
    }
    
    func getCommentList( gistString: String? = nil, callback: @escaping (_ comments: [DataComments],
                                                                    _ tuple: ( status : GitRequestResult , resultString : String?) ) -> Void) {
        
        var stringRequest : String!
        if let recString = gistString {
            stringRequest = recString
        } else {
            stringRequest = commentGistString
        }
        
        _ = self.oauthswift.client.get( stringRequest,
                                    success: { [weak self] response in
                                        
                                        if let retAr = self?.extractComments(response: response) { callback(retAr, (status : .success, resultString : nil) )
                                        } else { callback([], (status : .parseError, resultString : "Could not parse the received data") ) }
                                    },
                                    failure: { error in
                                        callback([], (status : .failed, resultString : error.localizedDescription) )
                                    })
    }
    
    func postComment(_ comment : String, callback: @escaping (( status : GitRequestResult , resultString : String?))-> Void ) {
        
        let configBody : [String: Any] = [ "body" : comment ]
        let dataSend = try? JSONSerialization.data(withJSONObject: configBody,
                                                   options: JSONSerialization.WritingOptions.prettyPrinted )
        
        guard let data = dataSend else {
            return callback( (status : .parseError, resultString : "The provided string could not be serialized") )
        }
        
       _ = self.oauthswift.client.post(commentGistString,
                                    body: data,
                                    success: { response in
                                        callback((status : .success, resultString : response.string))
                                    },
                                    failure: { error in
                                        callback((status : .failed, resultString : error.localizedDescription))
                                    })
    }
}


