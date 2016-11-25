//
//  ColorServiceManager.swift
//  BLESample
//
//  Created by Shinya Yamamoto on 2016/11/24.
//  Copyright © 2016年 Shinya Yamamoto. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol ColorServiceManagerDelegate {
    
    func connectedDevicesChanged(manager : ColorServiceManager, connectedDevices: [String])
    func colorChanged(manager : ColorServiceManager, colorString: String)
    
}

class ColorServiceManager: NSObject,MCNearbyServiceBrowserDelegate, MCSessionDelegate {
    
    // Service type must be a unique string, at most 15 characters long
    // and can contain only ASCII lowercase letters, numbers and hyphens.
    private let ColorServiceType = "example-color"
    
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private var serviceAdvertiser : MCNearbyServiceAdvertiser = MCNearbyServiceAdvertiser()
    private var serviceBrowser : MCNearbyServiceBrowser = MCNearbyServiceBrowser()
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.required)
        session.delegate = self
        return session
    }()
    
    // ...
    
    var delegate : ColorServiceManagerDelegate?
    
    // ...
    
    func sendColor(colorName : String) {
        NSLog("%@", "sendColor: \(colorName)")
        
        if session.connectedPeers.count > 0 {
    
            try! self.session.send(colorName.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
        
            
        }
        
    }
    
    override init() {
        super.init()
        
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: ColorServiceType)
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
        
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: ColorServiceType)
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        NSLog("%@", "foundPeer: \(peerID)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
    
    public func browser(_ browser: MCNearbyServiceBrowser,
                        foundPeer peerID: MCPeerID,
                        withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession?) -> Void)!) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.stringValue())")
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
}

extension ColorServiceManager : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping ((Bool, MCSession?) -> Void)) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
    }
    
    
    
}

extension ColorServiceManager  {
    
    // ...
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.stringValue())")
        self.delegate?.connectedDevicesChanged(manager: self, connectedDevices: session.connectedPeers.map({$0.displayName}))
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        NSLog("%@", "didReceiveData: \(data.length) bytes")
        let str = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue) as! String
        self.delegate?.colorChanged(manager: self, colorString: str)
    }
    
}

extension MCSessionState {
    
    func stringValue() -> String {
        switch(self) {
        case .notConnected: return "NotConnected"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        default: return "Unknown"
        }
    }
    
}



