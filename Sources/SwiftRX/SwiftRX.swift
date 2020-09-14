import Foundation

struct SwiftRX {
    var text = "Hello, World!"
}

protocol Action {}

protocol State {}

typealias Reducer <S: State> = (Action,  S) -> S

protocol StoreType {
    func dispatch(_ action: Action)
    func dispatch(_ effect: @escaping Effect)
}

typealias Effect = (_ state: State, _ store: StoreType) -> Action?


final class Store<S: State>: StoreType, ObservableObject {
    @Published private(set) var state: S
    private let reducer: Reducer<S>
    
    init(initialState: S, reducer: @escaping Reducer<S>) {
        self.reducer = reducer
        self.state = initialState
    }
    
    func dispatch(_ action: Action) {
        state = reducer(action, state)
    }
    
    func dispatch(_ effect: @escaping Effect) {
        guard let action = effect(state, self) else { return }

        self.dispatch(action)
    }
}

//var globalStore: Store = Store(reducer: AppReducer, initialState: AppState())

// MARK: POST STATE

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
        case .LoadPosts(let request):
            break
        case .RemovePost(index: let index):
            break
        case .AddOne(post: let post):
            break
    }
    
    return state
}

struct AppState: State {
    var posts: PostState = initialPostState
}

func AppReducer(action: Action, state: AppState) -> AppState {
    return AppState(posts: ((action as? PostAction) != nil) ? PostReducer(action: action as! PostAction, state: state.posts) : state.posts)
}

let store = Store<AppState>(initialState: AppState(), reducer: AppReducer)













// MARK: State
//@available(OSX 10.15, *)
//protocol State { }


/** HOW TO CREATE STATE
 *
 *  struct PostState: State {
 *      @Published posts: String[] = ["XD", ":D"]
 *  }
 */


//// MARK: Action
//protocol Action {}
//
//// MARK: Reducer
//typealias Reducer<S: State> = (_ action: Action, _ state: S?) -> S
//
//typealias ActionReducerMap<T>
//
//
//// MARK: Effect
//typealias Effect<S: State> = (_ state: S, _ store: Store<S>) -> Action?
//
//class Store<S: State>: ObservableObject {
//    @Published private(set) var state: S
//    private let reducer: Reducer<S>
//    // MARK: implement dispatch QUEUE for Effects
//
//    init(reducer: @escaping Reducer<S>, initialState state: S) {
//        self.reducer = reducer
//        self.state = state
//    }
//
//    func dispatch(_ action: Action) {
//        state = reducer(action, state)
//    }
//
//    // MARK: TO FIX
//    func dispatch(_ effect: @escaping Effect<S>) {
//        guard let action = effect(state, self) else { return }
//
//        self.dispatch(action)
//    }
    
    // MARK: SELECTOR FUNTION
    
//}

/// TESTING SECTION

//struct Post {
//    id: Int
//    title: String
//    body: String
//}


//struct PostState: State {
//    var posts: [String]
//}
//
//let initialPostState: PostState = PostState(posts: [])
//
//// MARK: Action<StateType> for strongly typed structure
//enum PostAction: Action {
//    case LoadPosts(_ request: String)
//    case RemovePost(index: Int)
//    case AddOne(post: String)
//}
//
//let PostsReducer: Reducer<PostState> = { action, state in
//    switch action as! PostAction {
//        case .AddOne:
//            break
//
//        case .LoadPosts(request: let request):
//            break
//
//        case .RemovePost(index: let index):
//            break
//    }
//
//    return state ?? initialPostState
//}
//
//struct AppState: State {
//    var posts: PostState = initialPostState
//}
//
//let AppReducer: Reducer<AppState> = { action, state in
//    return AppState(
//        posts: ((action as? PostAction) != nil) ? PostsReducer(action, state) : state
//    )
//}




//
//
//// MARK: Store
//
//class ActionReducerMap<S: State> {
//    private(set) var state: S
//    private let reducer: Reducer<S>
//
//    init(reducer: @escaping Reducer<S>, initialState state: S) {
//        self.reducer = reducer
//        self.state = state
//    }
//
//    func dispatch(_ action: Action) {
//        state = reducer(action, state)
//    }
//
////    func dispatch(_ actionCreator: @escaping Effect) {
////        guard let action = actionCreator(state, self) else { return }
////
////        self.dispatch(action)
////    }
//}
