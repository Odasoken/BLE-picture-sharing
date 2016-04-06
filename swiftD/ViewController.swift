//
//  ViewController.swift
//  swiftD
//
//  Created by juliano on 15/11/5.
//  Copyright © 2015年 WT. All rights reserved.
//

import UIKit
import MultipeerConnectivity

let serviceType = "BBE-SERVICE"

class ViewController: UIViewController , MCSessionDelegate,MCBrowserViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var connectedPeers: [MCPeerID] = []
    var session : MCSession?
    var advertiserAssistant : MCAdvertiserAssistant?

    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        let colorView = ColorView()
//        colorView.backgroundColor = UIColor.redColor()
//        colorView.frame = CGRectMake(100, 100, 50, 50)
//        view.addSubview(colorView)
        self.childViewControllers;
        let peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        session = MCSession(peer: peerID)
        session?.delegate = self
        advertiserAssistant = MCAdvertiserAssistant.init(serviceType: serviceType, discoveryInfo: nil, session: session!)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 // MARK:

    @IBAction func searchDevice(sender: AnyObject) {
        advertiserAssistant?.start()
        let blvc = MCBrowserViewController.init(serviceType: serviceType, session: session!)
        blvc.delegate = self
        self.presentViewController(blvc, animated: true, completion: nil)
        
    }
    @IBAction func sendData(sender: AnyObject) {
        
        if(connectedPeers.count > 0)
        {
          let peer = self.connectedPeers.first
          let data = UIImagePNGRepresentation(self.imageView.image!)
            do {
               try  self.session!.sendData(data!, toPeers: Array.init(arrayLiteral: peer!), withMode: MCSessionSendDataMode.Reliable)
            }catch
            {
                print("Error occurs while sending data!")
            }
        }   
      
B
    }
    
    // MARK: selectImage
    @IBAction func selectImage(sender: AnyObject) {
        let ipc = UIImagePickerController.init()
         ipc.delegate = self
         self.presentViewController(ipc, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.imageView.image = image;
        picker .dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
     // MARK:
    // MARK:MCSessionDelegate
    /**
    <#Description#>
    
    - parameter session:      <#session description#>
    - parameter resourceName: <#resourceName description#>
    - parameter peerID:       <#peerID description#>
    - parameter localURL:     <#localURL description#>
    - parameter error:        <#error description#>
    */
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        
    }
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        
        let img = UIImage.init(data: data)
        self.imageView.image = img!
        UIImageWriteToSavedPhotosAlbum(img!, self, nil, nil)
        
    }
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        
        if(state == MCSessionState.Connected)
        {
            
            if(self.connectedPeers.contains(peerID) == false)
            {
              self.connectedPeers.append(peerID)
            }

        }else
        {
            if(self.connectedPeers.contains(peerID) == true)
            {
                self.connectedPeers.removeAtIndex(self.connectedPeers.indexOf(peerID)!)
            }
        }
        
    }
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        
    }
    
    
    // MARK:
    
    // MARK:MCBrowserViewControllerDelegate
    
    func browserViewController(browserViewController: MCBrowserViewController, shouldPresentNearbyPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) -> Bool {
        return true;
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        browserViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Notifies delegate that the user taps the cancel button.
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController)
    {
        browserViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK:
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
}
