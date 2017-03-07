//
//  SongbookTests.swift
//  SongbookTests
//
//  Created by William Liddy on 2/23/17.
//  Copyright © 2017 NeutralSpace. All rights reserved.
//

import XCTest

@testable import Songbook

class SongbookSocketTest: XCTestCase
{
    
    private static var _ss: SongSocket?;
    
    override func setUp() {
        super.setUp();
        print("Setting up")
        do
        {
            SongbookSocketTest._ss = try SongSocket();
        }
        catch
        {
            print("Connection Failure!")
            XCTFail("Should not have failed")
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        SongbookSocketTest._ss!.close()
        super.tearDown()
    }
    
    func testExample() {
        
        SongbookSocketTest._ss!.sendRequest(request : JoinRequest(name: "me",group: "the velvet underground"))
        sleep(1)
        do
        {
            let recv_ = try SongbookSocketTest._ss!.recvJSON()
            XCTAssert(recv_!["response"] as! String == "error","Should have got error-group does not exist")
        } catch
        {
            print("should not have errored")
        }
    }
    
}
