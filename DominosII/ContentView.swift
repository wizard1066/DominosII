//
//  ContentView.swift
//  DominosII
//
//  Created by localadmin on 13.04.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import SwiftUI
import Combine

let talkingPublisher = PassthroughSubject<String, Never>()
let mobilePublisher = PassthroughSubject<Void, Never>()
let resetPublisher = PassthroughSubject<Void, Never>()

struct Fonts {
  static func avenirNextCondensedBold (size:CGFloat) -> Font{
    return Font.custom("AvenirNextCondensed-Bold",size: size)
  }
}


//class sharedDevices: ObservableObject {
//  @Published var devices: [String] {
//    willSet {
//      objectWillChange.send()
//    }
//  }
//
//  init() {
//    self.devices = []
//  }
//}

struct ContentView: View {
  @ObservedObject var mobile = BonjourBrowser()
  @State var name: String = ""
  @State var telegram:String = ""
  @State var udpCode = UDPNetwork()
  @State var tcpCode = TCPNetwork()
  @State var message:String = ""
  @State var selected = 0
  @State var startSvr = false
  @State var searchSvr = false
  @State var connectSvr = false
  @State var stopStr = false
  
  var body: some View {
    return VStack {
      List(mobile.devices, id: \.device) { item in
        VStack {
          Text(item.device)
            .font(Fonts.avenirNextCondensedBold(size: 16))
            .onTapGesture {
            print("item.device ",item.device)
            self.name = item.device
          }
        }
      }.frame(width: 256, height: 128, alignment: .center)
      
      //      Picker(selection: self.$selected, label: Text("")) {
      //        ForEach(self.mobile.devices, id: \.device) { dix in
      //          Text(dix.device)
      //        }
      //      }.pickerStyle(WheelPickerStyle())
      //        .onTapGesture {
      //          print("You tapped")
      //      }.clipped()
      //        .frame(width: 128, height: 96, alignment: .center)
      
      TextField("sending What ", text: $telegram, onCommit: {
        //        self.tcpCode.send(self.telegram)
//        self.tcpCode.send(self.telegram)
        self.tcpCode.superTCPSend(content: self.telegram)
      })
      .font(Fonts.avenirNextCondensedBold(size: 16))
      .multilineTextAlignment(.center)
      .padding(64)
      Text("sending To " + self.name)
      .font(Fonts.avenirNextCondensedBold(size: 16))
      .padding()
      .onReceive(resetPublisher) { (_) in
        self.name = ""
      }
      Text(message)
          .font(Fonts.avenirNextCondensedBold(size: 16))
          .padding()
          .onReceive(talkingPublisher) { ( data ) in
            self.message = "received " + data
        }
      Group {
        HStack {
          Image("Image-1")
          .resizable()
          .frame(width: 32, height: 32, alignment: .center)
          .overlay(
            Image("Image-Back")
            .resizable()
            .opacity(0.4)
            .frame(width: 48, height: 48, alignment: .center)
            )
          Text("start server")
          .font(Fonts.avenirNextCondensedBold(size: 16))
          .foregroundColor(Color.blue)
          .background(startSvr ? Color.yellow:Color.clear)
          .onTapGesture {
            self.startSvr = true
            
            //        self.tcpCode.listenTCP(port: 5418)
        self.tcpCode.bonjourTCP(UIDevice.current.name)
//          self.udpCode.bonjourUDP(UIDevice.current.name)
          //          self.udpCode.listenUDP(1854)
          }.padding()
        }
        HStack {
        Image("Image-2")
        .resizable()
        .frame(width: 32, height: 32, alignment: .center)
        .overlay(
            Image("Image-Back")
            .resizable()
            .opacity(0.4)
            .frame(width: 48, height: 48, alignment: .center)
            )
//        Button(action: {
////          self.mobile.search(typeOf: "_domino._tcp")
//          self.mobile.search(typeOf: "_domino._tcp")
//          self.tcpCode.resetTCPLink()
//        }) {
          Text("search")
          .foregroundColor(Color.blue)
          .background(searchSvr ? Color.yellow:Color.clear)
          .font(Fonts.avenirNextCondensedBold(size: 16))
          .onTapGesture {
            self.searchSvr = true
            //          self.mobile.search(typeOf: "_domino._tcp")
//          self.mobile.search(typeOf: "_domino._tcp")
            self.mobile.seek(typeOf: serviceTCPName)
          self.tcpCode.resetTCPLink()
          }
        .padding()
        }
        HStack {
        Image("Image-3")
        .resizable()
        .frame(width: 32, height: 32, alignment: .center)
        .overlay(
            Image("Image-Back")
            .resizable()
            .opacity(0.4)
            .frame(width: 48, height: 48, alignment: .center)
            )
        
          Text("connect")
          .font(Fonts.avenirNextCondensedBold(size: 16))
          .foregroundColor(Color.blue)
          .background(connectSvr ? Color.yellow:Color.clear)
          .onTapGesture {
            self.connectSvr = true
             print("mobile.devices ",self.mobile.devices)
          //        self.tcpCode.connectToTCP(host: "192.168.1.110", port: "1854")
          self.tcpCode.bonjourToTCP(self.name)
//          self.udpCode.bonjourToUDP(self.name)
          //          self.udpCode.connectToUDP(host: "192.168.1.110", port: "1854")
          }
        .padding()
        }
        HStack {
          Image("Image-4")
          .resizable()
          .frame(width: 32, height: 32, alignment: .center)
          .overlay(
            Image("Image-Back")
            .resizable()
            .opacity(0.4)
            .frame(width: 48, height: 48, alignment: .center)
            )
          
          Text("disconnect")
          .font(Fonts.avenirNextCondensedBold(size: 16))
          .background(stopStr ? Color.yellow:Color.clear)
          .onTapGesture {
            self.stopStr = true
            self.tcpCode.sendEnd(nil)
          }
        .padding()
        }
        

        
      }
    }
  }
}


struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
