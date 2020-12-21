import XCTest
@testable import SwiftRX


final class SwiftRXTests: XCTestCase {
    var sut: RXStore<AppState>!
    
    override func setUp() {
        super.setUp()
        sut = RXStore(reducer: appReducer, state: AppState(), effects: [
            RXLogger()
        ])
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testDispatchAnAction() {
        let post = [Post(id: 10, title: "New Post")]

        sut.dispatch(PostAction.loadSuccess(post))

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.sut.state.posts.posts, post, "After dispatching action the store does not contain expected value")
        }
    }
}
// MARK: MODELS
struct Post: Equatable {
    let id: Int
    let title: String
}


// MARK: APP STATE
struct AppState: RXState {
    var posts = PostsState()
}

let appReducer: RXReducer<AppState> = { state, action in
    var state = state
    
    state.posts = postsReducer(state.posts, action)
    
    return state
}



// MARK: POSTS SUB STATE
struct PostsState: RXState {
    var posts: [Post] = []
}

enum PostAction: RXAction {
    case load
    case loadSuccess([Post])
    case loadFailure(String)
}

let postsReducer: RXReducer<PostsState> = { state, action in
    var state = state
    
    switch action as! PostAction {

    case .load:
        print("")
    case .loadSuccess(let posts):
        state.posts = posts
    case .loadFailure(let error):
        print(error)
    }
    
    return state
}
