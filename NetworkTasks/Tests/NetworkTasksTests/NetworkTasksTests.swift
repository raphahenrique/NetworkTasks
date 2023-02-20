
import XCTest
@testable import NetworkTasks

struct FakeResponse: Decodable {
    let userID, id: Int
    let title: String
    let completed: Bool
    
    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case id, title, completed
    }
}

struct RequestFake: NetworkRequest {
    typealias ResponseType = FakeResponse
    
    var endpoint: String
    
    var method: HTTPMethod = .get
    
    var parameters: [String : Any]?
    
    var headers: [String : String]?
    
    init(endpoint: String, method: HTTPMethod, parameters: [String : Any]? = nil, headers: [String : String]? = nil) {
        self.endpoint = endpoint
        self.method = method
        self.parameters = parameters
        self.headers = headers
    }
}

class NetworkTasksTests: XCTestCase {
    
    var network: NetworkTasks!
    var requestFake: RequestFake!
    
    override func setUp() {
        super.setUp()
        network = NetworkTasks()
    }
    
    override func tearDown() {
        network = nil
        requestFake = nil
        super.tearDown()
    }
    
    func testValidUrl() {
        requestFake = RequestFake(endpoint: "https://jsonplaceholder.typicode.com/todos/1", method: .get)
        let expectation = self.expectation(description: "Valid URL")
        
        network.send(requestFake) { (result: Result<FakeResponse>) in
            switch result {
            case .success(let data):
                XCTAssertNotNil(data)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
}
