//
//  DiscordRPCApp.swift
//  DiscordRPC
//
//  Created by Deltaion Lee on 12/3/23.
//

import SwiftUI
import AppKit
import Foundation
import Cocoa
import SwordRPC

class AppDelegate: NSObject, NSApplicationDelegate {
    static private(set) var instance: AppDelegate! = nil
    // Properties accessible by AppleScript
    @objc dynamic var client: Int = -1
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.instance = self
        
    }
    func application(_ sender: NSApplication, delegateHandlesKey key: String) -> Bool {
        if (key == "client") {
            return true
        }
        return false
    }
}

enum ScriptError: Error {
    case runtimeError(String)
}

var controller: RPCController?


enum ClientAPIEndpoint: String, Codable {
    case Discord = "//discord.com/api"
    case Discord_PTB = "//ptb.discord.com/api"
    case Discord_Canary = "//canary.discord.com/api"
    
    static var allValues: [ClientAPIEndpoint] {
        return [
            .Discord,
            .Discord_PTB,
            .Discord_Canary
        ]
    }
}

class RPCController: SwordRPCDelegate {
    var rpc: SwordRPC
    var client: ClientAPIEndpoint?
    var connected: Bool = false
    
    init(_ id:String) {
        self.rpc = SwordRPC(appId: id)
        self.rpc.delegate = self
    }
    
    func connect(_ pipe:Int) throws {
        try self.rpc.connect(pipe)
    }
    
    func disconnect() {
        // No freaking clue
    }
    
    func rpcDidConnect(_ test: SwordRPC, data: [String: Any]) {
        let config = data["config"] as! [String: String]
        self.client = ClientAPIEndpoint(rawValue: config["api_endpoint"]!)
        self.connected = true
    }
}

class Using: NSScriptCommand {
    override func performDefaultImplementation() -> Any? {
        do {
            NSApp.hide(nil)
            
            let client = self.evaluatedArguments!["client"] as! Int?
            let appID = self.evaluatedArguments!["appID"] as! String
            
            // The client matching code is VERY cursed. Please ignore it if at all possible
            for pipe in 0 ..< 2 {
                controller = RPCController(appID)
                try controller!.connect(pipe) // Could throw
                
                let st = NSDate().timeIntervalSince1970
                while !controller!.connected { // CURSED
                    if (NSDate().timeIntervalSince1970 - st > 3) {
                        throw ScriptError.runtimeError("timed out. try restarting ScriptRPC")
                    }
                }
                if (client == nil || client == -1) {
                    break
                } else if (ClientAPIEndpoint.allValues[client!] == controller!.client!) {
                    break
                } else if (pipe == 2) { // If all failed to match
                    throw ScriptError.runtimeError("that client of Discord was not found running on this machine")
                }
                controller!.disconnect()
                /*switch (controller!.client!) {
                case .Discord:
                    print("connected to Discord")
                case .Discord_PTB:
                    print("connected to Discord PTB")
                case .Discord_Canary:
                    print("connected to Discord Canary")
                }*/
            }
            AppDelegate.instance.client = ClientAPIEndpoint.allValues.firstIndex(of: controller!.client!)! // Set client property in AppDelegate
            return nil
        }
        catch {
            return "\(error)"
        }
    }
}

@main
struct DiscordRPCApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
