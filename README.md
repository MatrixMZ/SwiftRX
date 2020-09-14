# SwiftRX

Swift Package that bring Redux pattern into Swift!

## About
This version of Redux is ready to be used with `SwiftUI`. It allows to be connected as `@EnvironmentObject`.
It allso allow to create substates (that are rcommeded to be created).

## Instalation
-  `File -> Swift Packages -> Add Package Dependency`
-  `https://github.com/MatrixMZ/SwiftRX`

## Implementation

```

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

let LoadPosts: ActionCreator<AppState> = { state, store in
    
    return nil
    
}

func test() {
    store.dispatch(LoadPosts)
}
```

### Recomended folder structure
-  App /
-  Store /
    - Actions /
    - Reducers /
    - States /
    - ActionCreators /
