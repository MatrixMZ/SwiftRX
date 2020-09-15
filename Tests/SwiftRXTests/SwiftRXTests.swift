import XCTest
@testable import SwiftRX

@available(iOS 13.0, *)
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
    
    func testActionCreator() {
           sut.dispatch(LoadPosts)

           XCTAssertEqual(sut.state.posts.posts, ["From Action Creator"], "Action Creator does not return Action")
       }

}


struct PostState: State {
    let posts: [String]
}

let initialPostState: PostState = PostState(posts: [])

enum PostAction: Action {
    case LoadPosts(_ request: String)
    case RemovePost(index: Int)
    case AddOne(post: String)
}

func PostReducer(action: PostAction, state: PostState) -> PostState {
    switch action {
        case .LoadPosts:
            print("LoadPost Action Dispatched")
            break
        case .RemovePost:
            print("RemovePost Action Dispatched")
            break
        case .AddOne(post: let post):
            return PostState(posts: [] + state.posts + [post])
    }
    
    return state
}

struct AppState: State {
    var posts: PostState = initialPostState
}

func AppReducer(action: Action, state: AppState) -> AppState {
    return AppState(posts: ((action as? PostAction) != nil) ? PostReducer(action: action as! PostAction, state: state.posts) : state.posts)
}

@available(iOS 13.0, *)
let store = Store<AppState>(initialState: AppState()
    , reducer: AppReducer)

@available(iOS 13.0, *)
let LoadPosts: ActionCreator<AppState> = { state, store in
    return PostAction.AddOne(post: "From Action Creator")
}
