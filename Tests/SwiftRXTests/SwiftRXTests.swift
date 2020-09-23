import XCTest
@testable import SwiftRX


final class SwiftRXTests: XCTestCase {
    var sut: Store<AppState>!
    
    override func setUp() {
        super.setUp()
        sut = Store<AppState>(initialState: AppState(), reducer: AppReducer)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testCreateStore() {
        XCTAssertEqual(sut.state.posts.posts, AppState().posts.posts, "After init store conatins different items")
    }

    func testDispatchAction() {
        sut.dispatch(PostAction.AddOne(post: "New Post"))
        XCTAssertEqual(sut.state.posts.posts, ["New Post"], "After dispatching action the store does not contain expected value")
    }

    func testDispatchMultipleActions() {
        sut.dispatch(PostAction.AddOne(post: "Post1"))
        sut.dispatch(PostAction.AddOne(post: "Post2"))

        XCTAssertEqual(sut.state.posts.posts, ["Post1", "Post2"], "After dispatching multiple action the store does not contain expected value")
    }
    
    func testDispatchingActionCreatorFactory() {
        sut.dispatch(AsyncWithPayload(PostAction.AddOne(post: "XD")))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.sut.state.posts.posts, ["First", "Async Call"], "Action creator dispatcher does not dispaches correct actions")
        }
       
    }
    
    func testDispatchingActionCreator() {
        sut.dispatch(AsyncWithoutPayload)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.sut.state.posts.posts, ["First", "Async Call"], "Action creator dispatcher does not dispaches correct actions")
        }
    }
}


struct PostState: State {
    let posts: [String]
}

let initialPostState: PostState = PostState(posts: [])

func PostReducer(action: Action, state: PostState) -> PostState {
    switch action {
        case let action as PostAction.LoadPosts:
            print("\(action.request)")
            break
        case let action as PostAction.RemovePost:
            print("\(action.index)")
            break
        case let action as PostAction.AddOne:
            return PostState(posts: [] + state.posts + [action.post])
    default:
        return state
    }
    
    return state
}

struct AppState: State {
    var posts: PostState = initialPostState
}

func AppReducer(action: Action, state: AppState) -> AppState {
    return AppState(
        posts: PostReducer(action: action, state: state.posts)
    )
}

let store = Store<AppState>(initialState: AppState(), reducer: AppReducer)


struct PostAction {
    struct LoadPosts: Action {
        let request: String
    }
    
    struct RemovePost: Action {
        let index: Int
    }
    
    struct AddOne: Action {
        let post: String
    }
    
    struct Test: Action {
       
    }
}

let AsyncWithPayload: ActionCreatorFactory<PostAction.AddOne> = { payload in
    return { store in
        DispatchQueue.main.async {
            store.dispatch(PostAction.AddOne(post: payload.post))
        }
        
        return PostAction.AddOne(post: "First")
    }
}

let AsyncWithoutPayload: ActionCreator = { store in
    DispatchQueue.main.async {
        store.dispatch(PostAction.AddOne(post: "Default"))
    }
    
    return PostAction.AddOne(post: "First")
}
