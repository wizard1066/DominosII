//
//  ContentView.swift
//  DominosII
//
//  Created by localadmin on 13.04.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import SwiftUI
import Network
import Combine

let talkingPublisher = PassthroughSubject<String, Never>()

struct ContentView: View {
  @State var name: String = ""
  @State var talk = Connect()
  @State var listen = Listen()
  @State var message:String = ""
  
  
  var body: some View {
    return VStack {
      Spacer()
      Group { Text("Hello World").onAppear {
        
//        communication.listenUDP(port: 1854)
        self.listen.listenTCP(port: 5418)
      }
      Spacer()
      Button(action: {
        let host = NWEndpoint.Host.init("192.168.1.110")
        let port = NWEndpoint.Port.init("5418")
        self.talk.connectToTCP(hostTCP: host, portTCP: port!)
      }) {
        Text("connect")
      }
      Spacer()
      Button(action: {
        self.talk.sendEnd(nil)
      }) {
        Text("disconnect")
      }
      Spacer()
       TextField("Give me stuff to send", text: $name, onCommit: {
        self.talk.send(self.name)
       })
      Spacer()
      Text(message)
         .onReceive(talkingPublisher) { ( data ) in
            self.message = data
        }
      Spacer()
      }
    }
  }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
