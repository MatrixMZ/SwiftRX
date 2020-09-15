import Foundation

/**
    Should be implemented with every redux action.
 
    # Implementation
    Enum type objects are the best option to implement it because it is easy to define action payload.
    ```
    enum PostAction: Action {
        case LoadPosts(_ request: String)
        case RemovePost(index: Int)
        case AddOne(post: String)
    }
    ```
    But if you do not like it you can use Struct as well.
    
 */
public protocol Action {}

/**
    Used to define State type Struct in redux pattern.
 
    # Implementation
    Main state definition will be different comparing to substate.
    Main:
    ```
    struct AppState: State {
        var posts: PostState = initialPostState
    }
    ```
    Sub:
    ```
    struct PostState: State {
        let posts: [String]
    }
    
    let initialPostState: PostState = PostState(posts: [])
    ```
 */
public protocol State {}

/**
    Can be used to create reducer.
    Takes Action and State and returns updated copy of state.
 
    # Implementation
 
    For main state:
    ```
    func AppReducer(action: Action, state: AppState) -> AppState {
        return AppState(posts: ((action as? PostAction) != nil) ? PostReducer(action: action as! PostAction, state: state.posts) : state.posts)
    }
    ```
 
    For sub state
    ```
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
    ```
 
    
 */
public typealias Reducer<S: State> = (Action,  S) -> S

/**
    Used to dispatch async actions.
 
    Async actions can be dispatched from inside of the fuction after the function returned Action or nil by simply placing them in Dispatch Queue.
 
    # Implementation
    ```
     struct PostsActionCreator {
         static let getPosts: ActionCreator = { state, store in
             AF.request("https://jsonplaceholder.typicode.com/posts").response { response in
                 let response: [Post] = try! JSONDecoder().decode([Post].self, from: response.data!)
                 store.dispatch(PostAction.LoadPosts(.success(response: response)))
             }
 
             return PostAction.LoadPosts(.loading)
         }
     }
    ```
    Alternative:
    ```
    let LoadPosts: ActionCreator<AppState> = { state, store in
         AF.request("https://jsonplaceholder.typicode.com/posts").response { response in
            let response: [Post] = try! JSONDecoder().decode([Post].self, from: response.data!)
            store.dispatch(PostAction.LoadPosts(.success(response: response)))
        }
 
        return PostAction.LoadPosts(.loading)
    }
    ```
 
    - Parameters:
        - state: State
        - store: Store
 
    - Returns: Optional<Action>
 
 */
public typealias ActionCreator<S: State> = (_ state: S, _ store: Store<S>) -> Action?


/**
    This final class defines Store that access will be available in the entire application.
    
    # Implementation
    In your ```SceneDelegate.swift```
    ```
    class SceneDelegate: UIResponder, UIWindowSceneDelegate {
        var store: Store<AppState> = Store<AppState>(initialState: AppState(), reducer: AppReducer)
 
        ...
 
        func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
 
            // It has to be injected as EnvironmentObject to the MainView
            let appView = AppView().environmentObject(store)

            if let windowScene = scene as? UIWindowScene {
                let window = UIWindow(windowScene: windowScene)
                window.rootViewController = UIHostingController(rootView: appView)
                self.window = window
                window.makeKeyAndVisible()
            }
        }
    ```
    So you can use it in view like so:
    ```
    struct AppView: View {
        @EnvironmentObject var store: Store
 
        ...
    }
    
    ```
 
    # Action | ActionCreator dispatcher
    To dispatch an action or action creator use:
    ```
        store.dispatch(LoadPosts)
    ```
    This will update the state in store and also automatically refresh every view that was implementing this feature.
 */
public final class Store<S: State>: ObservableObject {
    @Published private(set) var state: S
    private let reducer: Reducer<S>
    
    init(initialState: S, reducer: @escaping Reducer<S>) {
        self.reducer = reducer
        self.state = initialState
    }
    
    func dispatch(_ action: Action) {
        state = reducer(action, state)
    }
    
    func dispatch(_ actionCreator: @escaping ActionCreator<S>) {
        guard let action = actionCreator(state, self) else { return }

        self.dispatch(action)
    }
}
