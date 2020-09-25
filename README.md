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
// sub state
struct PostState: State {
    let posts: [Post]
}

// initial sub state definition
let initialPostState: PostState = PostState(posts: [])

// main state
struct AppState: State {
    // here you inclide your sub states
    var posts: PostState = initialPostState
    ...
}
```

### Action
Defines a list of actions that can be used to mutate the `State`.
It is good convention to keep `Actions` inside one group - `struct` for particular `State`.
`Actions` can also have `paylaod` definition inside - it is constants.

```swift
struct PostAction {
    struct LoadPosts: Action {}
    
    struct RemovePost: Action {
        let index: Int // payload
    }
    
    struct AddOne: Action {
        let post: String // payload
    }
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
func PostReducer(action: Action, state: PostState) -> PostState {
    switch action {
    case _ as PostAction.LoadPosts:
        return state
        break
    case let action as PostAction.AddOne:
        return PostState(posts: [] + state.posts + [action.post])
    default:
        return state
    }
}

// main state reducer
func AppReducer(action: Action, state: AppState) -> AppState {
    return AppState(
        posts: PostReducer(action: action, state: state.posts)
    )
}
```

### Store
Store keeps all the data in app in the main `State` that can be mutated by its `Reducer`.
The only way to change the state is to dispatch an action on it.
    
SceneDelegate.swift
```swift
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
```

AppView.swift and its sub views
```swift
struct AppView: View {
    @EnvironmentObject var store: Store<AppState>
}
```

### Selector
It is optional but helps to create a shortcut path inside `Views` to access data from particular `State` in `Store`.
Its a simple computed variable.
```swift
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

```

### Async Actions: ActionCreator & ActionCreatorFactory

`ActionCreator` can be used to define function that can be used to dispatch async `Action`.
It can be usefull with making async API calls.

Methd can be later dipatched in the application `Store`.

```swift
let AsyncWithoutPayload: ActionCreator = { store in
    DispatchQueue.main.async {
        // action dispatched asynchronously
        store.dispatch(PostAction.AddOne(post: "Default"))
    }

    // action dispatched straight away
    return PostAction.AddOne(post: "First")
}
```

`ActionCreatorFactory` can be used to define function that can be used to dispatch async `Action`.
But in difference to `ActionCreator` it also supports getting payload from `Action`.
It can be usefull with making async API calls.

Methd can be later dipatched in the application `Store`.

```swift
let AsyncWithPayload: ActionCreatorFactory<PostAction.AddOne> = { payload in
    return { store in
        DispatchQueue.main.async {
            store.dispatch(PostAction.AddOne(post: action.post))
        }
         
        return PostAction.AddOne(post: "First")
    }
}
```

## Extra
### Request<SuccessType, FailureType>
This enum supports getting and storing data catched from API requests.

```swift
struct PostsState: State {
    let posts: Request<[Posts], String>
}

let initialPostsState: PostsState(posts: .initial)
```

## Licence
Licence under the [MIT Licence](LICENSE)
