//
//  SwiftRX.swift
//
//
//  Created by Mateusz Ziobrowski on 27/11/2020.
//

import Foundation


// **************************
// MARK: STATE
// **************************
/**
    Defines a data model that can be stored in `Store`.
 
    # How to use?
        // define data model
        struct PostState: State {
            let posts: [Post] = []
        }
 */
public protocol RXState { }


// **************************
// MARK: ACTION
// **************************
/**
    `Action` can be used to be dispatched to `Reducer` with or without payload (additional) data.
 
    # How to use with enums?
         enum PostAction: RXAction {
            // without payload
             case load
            // with payload
             case loadSuccess([Post])
             case loadFailure(String)
         }
         
    # Or with structs:
        // without payload
        struct LoadPosts: Action { }
     
        // with payload
        struct LoadPostsSuccess: Action {
            let posts: [Post]
        }
 */
public protocol RXAction { }


// **************************
// MARK: REDUCER
// **************************
/**
    Defines a pure function that mutates the given `State` inside `Store` depending on the given `Action`.
 
    # How to use?
 
        // main state reducer
         let appReducer: RXReducer<AppState> = { state, action in
             var state = state
             
             state.posts = postsReducer(state.posts, action)
             
             return state
         }
 
        // sub state reducer
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
        
    - Parameters:
        - action: Type of `Action` that will mutate the `State`.
        - state: Type of `State` that will be mutated.
 
    - Returns: Mutated `State`
 */
public typealias RXReducer<State: RXState> = (_ state: State, _ action: RXAction) -> State


// **************************
// MARK: DISPATCHER
// **************************
/**
    Used by `Effect` to dispatch an async action from it's body.
 */
public typealias RXDispatcher = (RXAction) -> Void


// **************************
// MARK: EFFECT
// **************************
/**
    Helfps to create a function that can be used to dispatch async `Action`.
    It can be usefull with making async API calls, or with creating middleware functions.
    
    # Setup
    Every efect to be executed needs to be injected into Store initializer.
 
    # How to use?
    Effects are executed after the `Action` is dispatched.
    So you can make `Action` type check inside `Effect`'s body to execute special code for partical effects.
 
         func RXLogger() -> RXEffect<AppState> {
             return { state, action, dispatcher in
                 print("[\(action.self)]")
             }
         }
 
    - Parameters:
        - store: Type of `Store` that can be used to dispatch an action.
    - Returns: `Optional<Action>` that can be dispatched straight away.
  */
public typealias RXEffect<Store: RXState> = (Store, RXAction, @escaping RXDispatcher) -> Void



/**
    `Store` keeps the reactively changing data model in your application.
    Store can be subscribed to many places inside your application, very helpful can be `EnvironmentObject` for storing our `Store`.
    The data inside store can be only updated by `dispatching` an `Action`.`Action` can also provide additional data with its payload.
    
    # Setup
    The key alements are `State` and its `Reducer`, they need to be injected inside store during the initialiation.
    The optional option is to add some `Effects` that will allow perform async request in your application and update data to your `Store`.
 
        // Create State
         struct AppState: RXState {
             var posts = PostsState()
         }

        // Create Reducer
         let appReducer: RXReducer<AppState> = { state, action in
             var state = state
             
             state.posts = postsReducer(state.posts, action)
             
             return state
         }
 
        // Create Store instance
        let store: RXStore<AppState> = RXStore(reducer: appReducer, state: AppState(), effects: [RXLogger()])
 
 
    # Subscribing store
    
 
        import class SwiftRX
 
        struct LoginView: View {
            // Store available in View
            @EnvironmentObject var store: RXStore<AppState>
 
                var body: some View {
                    // Subscribing data from store
                     Button("Total posts: \(store.state.posts.posts.count)") {
                        // Dispatching an action
                        store.dispatch(PostAction.load)
 
                        // or with payload
                        store.dispatch(PostAction.loadSuccess(Post(id: 10, title: "New Post")))
        
                    }
                }
            }
        }
*/
public class RXStore<State: RXState>: ObservableObject {
    
    private let reducer: RXReducer<State>
    @Published public private(set) var state: State
    private let effects: [RXEffect<State>]
    private let debuggingMode: Bool
    
    
    /**
        Creates `Store` that can be used to mutating and accessing `State` in the application.
     
        - Parameters:
            
            - reducer: Main `Reducer<State>` that will help with mutating the main `State`.
            - state: Main `State` that will be used to define data tree.
            - effects: An array of middlewere (`RXEffect`) to catch and execute code during dispatching.
     
     */
    public init(reducer: @escaping RXReducer<State>, state: State, effects: [RXEffect<State>] = [], debuggingMode: Bool = false) {
        self.reducer = reducer
        self.state = state
        self.effects = effects
        self.debuggingMode = debuggingMode
    }
    
    /**
        Dispatches an `Action` to the `Reducer`to mutate the `State`.
        - Parameters:
            - action: `Action` to be dispatched.
     */
    public func dispatch(_ action: RXAction) {
        if debuggingMode {
            var actionName = ""
            for character in "\(action.self)" {
                if character == "(" {
                    return
                }
                actionName.append(character)
            }
            
            print("[\(type(of: action))] \(actionName)")
        }
        
        DispatchQueue.main.async {
            self.state = self.reducer(self.state, action)
        }
        
        effects.forEach { effect in
            effect(state, action, dispatch)
        }
    }
}


// **************************
// MARK: HELPERS
// **************************
/**
    Supports getting and storing data catched from API requests.
 
    # How to use?
        let auth: Request<String, String> = .initial
 */
public enum RXRequest<Success, Failure> {
    case initial
    case inProgress
    case success(Success)
    case failure(Failure)
}
