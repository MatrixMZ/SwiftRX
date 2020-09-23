import Foundation


/**
    Defines `Action` types for `Reducers` with possible payload inside.
 
    # How to use?

        // without payload
        struct LoadPosts: Action { }
     
        // with payload
        struct LoadPostsSuccess: Action {
            let posts: [Post]
        }
 */
public protocol Action { }


/**
    Defines data model that can be available in `Store`.
 
    # How to use?
        // sub state
        struct PostState: State {
            let posts: [Post]
        }
        
        // initial sub state definition
        let initialPostState: PostState = PostState(posts: [])

        // main state
        struct AppState: State {
            var posts: PostState = initialPostState
        }
 */
public protocol State {}


/**
    Defines a pure function that mutate the given `State` inside `Store` depending on the given `Action`.
 
    # How to use?
 
        // main state reducer
        func AppReducer(action: Action, state: AppState) -> AppState {
            return AppState(
                posts: PostReducer(action: action, state: state.posts)
            )
        }
 
        // sub state reducer
        func PostReducer(action: Action, state: PostState) -> PostState {
            switch action {
            case let action as PostAction.LoadPosts:
                return state
                break
            case let action as PostAction.AddOne:
                return PostState(posts: [] + state.posts + [action.post])
            default:
                return state
            }
        }
        
    - Parameters:
        - action: Type of `Action` that will mutate the `State`.
        - state: Type of `State` that will be mutated.
 
    - Returns: Mutated `State`
 */
public typealias Reducer<S: State> = (Action,  S) -> S


/**
    Can be used to define function that can be used to dispatch async `Action`.
    It can be usefull with making async API calls.
    
    Methd can be later dipatched in the application `Store`.
 
    # How to use?
        let AsyncWithoutPayload: ActionCreator = { store in
            DispatchQueue.main.async {
                // action dispatched asynchronously
                store.dispatch(PostAction.AddOne(post: "Default"))
            }
     
            // action dispatched straight away
            return PostAction.AddOne(post: "First")
        }
 
    - Parameters:
        - store: Type of `Store` that can be used to dispatch an action.
    - Returns: `Optional<Action>` that can be dispatched straight away.
  */
public typealias ActionCreator = (StoreType) -> Action?


/**
    Can be used to define function that can be used to dispatch async `Action`.
    But in difference to `ActionCreator` it also supports getting payload from `Action`.
    It can be usefull with making async API calls.
    
    Methd can be later dipatched in the application`Store`.
 
    # How to use?
        let AsyncWithPayload: ActionCreatorFactory<PostAction.AddOne> = { payload in
            return { store in
                DispatchQueue.main.async {
                    store.dispatch(PostAction.AddOne(post: action.post))
                }
                 
                return PostAction.AddOne(post: "First")
            }
        }
 
    - Parameters:
        - payload: Type of `Action` to define the payload.
    - Returns: `ActionCreator` that can be dispatched in `Store`.
 */
public typealias ActionCreatorFactory<A: Action> = (A) -> ActionCreator


/**
    Helper protocol to support `ActionCreator` in the app.
 */
public protocol StoreType {
    func dispatch(_ actionCreator: ActionCreator)
    func dispatch(_ action: Action)
}


/**
    The `Store` keeps the whole state tree of your application.
    The only way to change the state inside it is to dispatch an action on it.
 
    # Implementation with SwiftUI
        
    ## SceneDelegate.swift
        import SwiftRX

        class SceneDelegate: UIResponder, UIWindowSceneDelegate {
            // define global store
            let store: Store<AppState> = Store<AppState>(initialState: AppState(), reducer: AppReducer)
            ...
 
            func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
                let contentView = AppView().environmentObject(store) /// Inject `Store` to `AppView` as `EnvironmentObject`
                ...
            }
        }
    
    ## AppView.swift and its sub views
        struct AppView: View {
            @EnvironmentObject var store: Store<AppState>
        }
    
    # Selectors
    It is optional but helps to create a shortcut path inside `Views` to access data from particular `State` in `Store`.
    Its a simple computed variable.
 
        struct AppView: View {
            @EnvironmentObject var store: Store<AppState>
     
            // Define selector
            var productState: ProductState {
                return store.state.products
            }
 
            var body: some View {
                // Use selector to access data
                Text("Total products: \(productState.products.count)")
            }
        }
 */
public final class Store<S: State>: ObservableObject, StoreType {

    @Published public private(set) var state: S
    private let reducer: Reducer<S>
    
    /**
        Creates `Store` that can be used to mutating and accessing `State` in the application.
     
        - Parameters:
            - initialState: Main `State` that will be used to define data tree.
            - reducer: Main `Reducer<State>` that will help with mutating the main `State`.
     */
    public init(initialState: S, reducer: @escaping Reducer<S>) {
        self.reducer = reducer
        self.state = initialState
    }
    
    /**
        Dispatches an `Action` to the `Reducer`to mutate the `State`.
        - Parameters:
            - action: `Action` to be dispatched.
     */
    public func dispatch(_ action: Action) {
        state = reducer(action, state)
    }
    
    /**
        Dispatches an `ActionCreator` that can dispatch asynchronously different `Action` in the background.
        - Parameters:
            - actionCreator: `ActionCreator` - function that can return `Optional<Action>` to dispatch action after completion or dispatch an `Action` asynchronously.
     */
    public func dispatch(_ actionCreator: ActionCreator) {
        if let action = actionCreator(self) {
            dispatch(action)
        }
    }
}
