//
//  SessionTests.swift
//  IconicTests
//
//  Created by Mohssen Fathi on 12/18/19.
//  Copyright © 2019 Mohssen Fathi. All rights reserved.
//

import XCTest
@testable import Iconic

class SessionTests: XCTestCase {

    func testiPhoneAssetGeneration() {
        
        let devices: [Device] = [.iPhone, .iPad, .appleWatch, .mac, .carPlay]
        
        for device in devices {
            let exp = expectation(description: "\(device.title) asset generation")
            
            generateAssets(for: device) { session in
                for asset in session.assets {
                    let url = session.imageUrl(imageName: asset.filename)
                    XCTAssertTrue(
                        session.fileManager.fileExists(atPath: url.path),
                        "No image found for \(asset.filename)"
                    )
                }
                
                exp.fulfill()
            }
            
            wait(for: [exp], timeout: 100000)
        }
    }
    
    func generateAssets(for device: Device, completion: @escaping ((SessionProtocol) -> ())) {
        let session: MockSession
        do {
            session = try MockSession(image: #imageLiteral(resourceName: "norah"), devices: [device])
        } catch {
            XCTFail("Failed to create session")
            return
        }
        
        XCTAssert(session.assets.count == device.assets.count, "Incorrect number of assets")
        
        session.generateAssets(progress: nil) { url, error in
            XCTAssertNotNil(url)
            XCTAssertNil(error)
            completion(session)
        }
    }
}
