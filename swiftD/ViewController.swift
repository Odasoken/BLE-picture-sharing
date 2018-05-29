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

class ViewController: UIViewController , MCSessionDelegate,MCBrowserViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate {
    var connectedPeers: [MCPeerID] = []
    var session : MCSession?
    var advertiserAssistant : MCAdvertiserAssistant?

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        let colorView = ColorView()
//        colorView.backgroundColor = UIColor.redColor()
//        colorView.frame = CGRectMake(100, 100, 50, 50)
//        view.addSubview(colorView)
//        self.childViewControllers;
        let peerID = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peerID)
        session?.delegate = self
        advertiserAssistant = MCAdvertiserAssistant.init(serviceType: serviceType, discoveryInfo: nil, session: session!)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 // MARK:
    

    @IBAction func searchDevice(sender: UIButton) {
        advertiserAssistant?.start()
        let blvc = MCBrowserViewController.init(serviceType: serviceType, session: session!)
        blvc.delegate = self
        present(blvc, animated: true, completion: nil)
        
        
    }
    @IBAction func sendData(sender: UIButton) {
        
        if(connectedPeers.count > 0)
        {
          let peer = self.connectedPeers.first
          let data = UIImagePNGRepresentation(self.imageView.image!)
            do {
               try session?.send(data!, toPeers: Array.init(arrayLiteral: peer!), with: .reliable)
                //self.session!.sendData(data!, toPeers: Array.init(arrayLiteral: peer!), withMode: MCSessionSendDataMode.Reliable)
            }catch
            {
                print("Error occurs while sending data!")
            }
        }   
      

    }
     // MARK: selectImage
    @IBAction func selectImage(_ sender: UIButton) {
        let imagePKVc = UIImagePickerController.init()
        imagePKVc.delegate = self
        present(imagePKVc, animated: true, completion: nil)
    }
   
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.imageView.image = image;
        picker.dismiss(animated: true, completion: nil)
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
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
   
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let img = UIImage.init(data: data)
        
        DispatchQueue.main.async {
            self.imageView.image = img!
            UIImageWriteToSavedPhotosAlbum(img!, self, nil, nil)
        }
        
    }
    
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if(state == .connected)
        {
            
            if(self.connectedPeers.contains(peerID) == false)
            {
                self.connectedPeers.append(peerID)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        }else if(self.connectedPeers.contains(peerID) == true)
        {
            self.connectedPeers.remove(at: self.connectedPeers.index(of: peerID)!)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
   
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("progress:\(progress)")
    }
    
    
    // MARK:
    
    // MARK:MCBrowserViewControllerDelegate
    
    func browserViewController(_ browserViewController: MCBrowserViewController, shouldPresentNearbyPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) -> Bool {
        return true
    }
    
    
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true, completion: nil)
    }
    
    
    // Notifies delegate that the user taps the cancel button.
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
         browserViewController.dismiss(animated: true, completion: nil)
    }
    
// MARK:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connectedPeers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ID = ""
        var cell = tableView.dequeueReusableCell(withIdentifier: ID)
       if cell == nil {
        cell = UITableViewCell(style: .default, reuseIdentifier: ID)
        }
        
        let pid = connectedPeers[indexPath.row]
        cell?.textLabel?.text = String(pid.displayName)
        
    
        
        
        return cell!
        
    }
    
    // MARK:
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
        {
        get{
            return  .portrait
        }
    }
   
    
    
   
}
