# SwiftRX
Swift Package that brings `Redux` pattern into `Swift`!

## Features
- Lightweight
- Code examples withing documentation of package types
- Support for sub-states
- Easy to use with `SwiftUI`
- Fully tested

## Instalation
Add dependency to `Swift` project:
`File` -> `Swift Packages` -> `Add Package Dependency`

Search for:
`https://github.com/MatrixMZ/SwiftRX`

Add to project.

## Implementation

### State
This defines model for your data that can be access inside the application.
`States` can only be mutated by `Reducers`.

```swift
struct PostState: RXState {
    let posts: [Post] = []
}
```

### Action
Defines a list of actions that can be used to mutate the `State`.
It is good convention to keep `Actions` inside one group - `struct` for particular `State`.
`Actions` can also have `paylaod` definition inside - it is constants.

```swift
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
    struct LoadPosts: RXAction { }
 
    // with payload
    struct LoadPostsSuccess: RXAction {
        let posts: [Post]
    }
```

Actions can be dispatched in `Store`.
```swift
store.dispatch(PostAction.AddOne(post: "New Post"))
```

### Reducer
`Reducer` is a pure function, that takes and `Action` if confroms and `State` and returns mutated state.

```swift
// sub state reducer
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
```

### Store

`Store` keeps the reactively changing data model in your application.
Store can be subscribed to many places inside your application, very helpful can be `EnvironmentObject` for storing our `Store`.
The data inside store can be only updated by `dispatching` an `Action`.`Action` can also provide additional data with its payload.

The key alements are `State` and its `Reducer`, they need to be injected inside store during the initialiation.
The optional option is to add some `Effects` that will allow perform async request in your application and update data to your `Store`.
    
```swift
import SwiftRX

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


// Subscribing store

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
```

AppView.swift and its sub views
```swift
struct AppView: View {
    @EnvironmentObject var store: RXStore<AppState>
}
```

### Selector
It is optional but helps to create a shortcut path inside `Views` to access data from particular `State` in `Store`.
Its a simple computed variable.
```swift
struct AppView: View {
    @EnvironmentObject var store: RXStore<AppState>

    // Define selector
    var productState: ProductState {
        return store.state.products
    }

    var body: some View {
        // Use selector to access data
        Text("Total products: \(productState.products.count)")
    }
}

```

### Effects

Helfps to create a function that can be used to dispatch async `RXAction`.
It can be usefull with making async API calls, or with creating middleware functions.

Every efect to be executed needs to be injected into Store initializer.

Effects are executed after the `RXAction` is dispatched.
So you can make `RXAction` type check inside `RXEffect`'s body to execute special code for partical effects.

```swift
func RXLogger() -> RXEffect<AppState> {
    return { state, action, dispatcher in
        print("[\(action.self)]")
    }
}
```

## Extra
### RXRequest<SuccessType, FailureType>
This enum supports getting and storing data catched from API requests.

```swift
struct PostsState: RXState {
    let posts: RXRequest<[Posts], String> = .initial
}
```

### RXLogger
This DevTool -  `Effect` prints out in terminal all names of dispatched `Actions` in `Store` to easly debug `Store` lifecycle.

```swift
var store = RXStore(reducer: appReducer, state: AppState(), effects: [
    RXLogger() // <- Inject logger here
])
```

## Licence
Licence under the [MIT Licence](LICENSE)
