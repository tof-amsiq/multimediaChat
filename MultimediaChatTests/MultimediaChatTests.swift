//
//  MultimediaChatTests.swift
//  MultimediaChatTests
//
//  Created by Tobias Frantsen on 20/12/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//

import XCTest

@testable import MultimediaChat

class MultimediaChatTests: XCTestCase {

    var testChatiView: ChatView!
  
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreateMessage() {
        let testMessage = Message(messageType: .text, isSender: true, time: Date(), nameSender: "tobias", filePath: "", messageText: "test")
        XCTAssertNotNil(testMessage)
    }
    
    func testValueOfMessage() {
        let testMessage = Message(messageType: .text, isSender: true, time: Date(), nameSender: "tobias", filePath: "", messageText: "test")
        XCTAssertEqual(testMessage?.type, messageType.text)
        XCTAssertEqual(testMessage?.nameOfSender, "tobias")
        XCTAssertEqual(testMessage?.text, "test")
    }
    
    func testDonwloadManager() {
        Downloader.testLoad(url: "http://www.orimi.com/pdf-test.pdf") { (url) in
            XCTAssertNotNil(url)
        }
    }
    
    func testImagefixedOrientation() {
        var image =  #imageLiteral(resourceName: "photo")
        image = image.withHorizontallyFlippedOrientation()
        image = image.fixedOrientation()!
        XCTAssert(image.imageOrientation == UIImage.Orientation.up)
    }
    
    func testImagegetCropRation() {
        let image =  #imageLiteral(resourceName: "photo")
        XCTAssertEqual(image.getCropRation(), 1)
    }
    
    func testSetupChatView() {
        testChatiView = ChatView()
        XCTAssertNotNil(testChatiView)
    }
    
    func testJsonConverter() {
        let testMessage = Message(messageType: .text, isSender: true, time: Date(), nameSender: "tobias", filePath: "", messageText: "test")!
        let jsonObject = SocketIOManager.shared.convertToJson(message: testMessage)
        let valid = JSONSerialization.isValidJSONObject(jsonObject)
        XCTAssertTrue(valid)
    }
    
    func testSendMessage() {
        SocketIOManager.shared.connectSocket()
         let testMessage = Message(messageType: .text, isSender: true, time: Date(), nameSender: "tobias", filePath: "", messageText: "test")!
        let ack = SocketIOManager.shared.sendNewMessage(message: testMessage)
        XCTAssertNotNil(ack?.description)
    }
    
    func testConnectSocket() {
     let value = SocketIOManager.shared.connectAndGetValue()
        XCTAssertTrue(value)
    
    }
    
    func testConnectSocketWithUserName() {
   SocketIOManager.shared.connectToServerWithUserName(nickname: "Tobias")
    }
    
    
    
    
    

   

}
