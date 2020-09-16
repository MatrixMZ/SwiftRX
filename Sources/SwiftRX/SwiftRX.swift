import Foundation

/**
    Should be implemented with every redux action.
 
    # Implementation
    To declare an `Action` use struct, good convention is to group them by nesting in the other struct.
    If you want to specify payload - simply put any constant attribute definition inside `Action`.
    ```
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
 
    If you want to get access to action's payload you have to cast it using `if let` statement.
 
    # Implementation
    ```
     let PostActionCreator: ActionCreator = { action in
         if let payload = action as? PostAction.AddOne {
             return PostAction.AddOne(post: payload.post)
         }
         return nil
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
public typealias ActionCreator = (_ action: Action) -> Action?


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
    
    public func dispatch(_ action: Action) {
        state = reducer(action, state)
    }
    
    func dispatch(_ resolver: ActionCreator, payload: Action) {
        if let action = resolver(payload) {
            dispatch(action)
        }
    }
}


/**
 * SwiftRX Helper
 */
public enum Request<Response, Error> {
    case loading
    case success(response: Response)
    case failure(error: Error)
}
