//
//  CentralViewController.swift
//  BLESample
//
//  Created by Shinya Yamamoto on 2016/11/23.
//  Copyright © 2016年 Shinya Yamamoto. All rights reserved.
//

import UIKit
import MultipeerConnectivity

//このクラスでセントラルとセントラルのBLE通信を試す。
class MultipeerViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let alert = UIAlertAction()
        self.startHosting(action: alert)
        
    }
    
    @IBAction func willconnect(_ sender: Any) {
        
        let alert = UIAlertAction()
        self.startHosting(action: alert)
        self.joinSession(action: alert)
    }
    
    
    func connectedDevicesChanged(manager : ColorServiceManager, connectedDevices: [String]){
        print("connectedDevicesChanged")
    }
    
    func colorChanged(manager : ColorServiceManager, colorString: String){
        print("colorChanged")
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            self.sendImage(img: UIImage(named: "test")!)
            self.sendArray()
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
            
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        }
    }
    
    func sendImage(img: UIImage) {
        if mcSession.connectedPeers.count > 0 {
            if let imageData = UIImagePNGRepresentation(img) {
                do {
                    try mcSession.send(imageData, toPeers: mcSession.connectedPeers, with: .reliable)
                } catch let error as NSError {
                    let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    present(ac, animated: true)
                }
            }
        }
    }
    
    func sendArray() {
        let testArray = ["hello","hello","hello"]
        let data = NSKeyedArchiver.archivedData(withRootObject: testArray)
        do {
            try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
        } catch let error as NSError {
            let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let image = UIImage(data: data) {
            DispatchQueue.main.async { [unowned self] in
                // do something with the image
                print("sending")
                self.imageView.image = image
            }
        }
        
        if let array = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String] {
            DispatchQueue.main.async { [unowned self] in
                var str = ""
                for elem in array {
                    if elem is String {
                        str = str.appending(elem)
                    }
                }
                self.textView.text = str
            }
        }
    }
    
    func startHosting(action: UIAlertAction!) {
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "hws-kb", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant.start()
    }
    
    func joinSession(action: UIAlertAction!) {
        let mcBrowser = MCBrowserViewController(serviceType: "hws-kb", session: mcSession)
        mcBrowser.delegate = self
        self.present(mcBrowser, animated: true)
//        self.navigationController?.pushViewController(mcBrowser, animated: true)
    }
    
    

}
