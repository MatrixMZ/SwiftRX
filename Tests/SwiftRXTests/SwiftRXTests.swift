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

@available(iOS 13.0, *)
let store = Store<AppState>(initialState: AppState(), reducer: AppReducer)


func LoadData(payload: PostAction.LoadPosts) -> ActionCreator {
   return {
        // You have to return here the AsyncActioon or nil
        return PostAction.LoadPosts(request: "XD")
   }
}


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

let postsFeatureSelector: (AppState) -> PostState = { state in return state.posts }
