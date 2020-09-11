import Foundation

struct SwiftRX {
    var text = "Hello, World!"
}

// MARK: State
@available(OSX 10.15, *)
protocol State: ObservableObject {}

/** HOW TO CREATE STATE
 *
 *  struct PostState: State {
 *      @Published posts: String[] = ["XD", ":D"]
 *  }
 */


// MARK: Action
protocol Action {}

// MARK: Reducer
typealias Reducer<S: State> = (Action, S) -> S


// MARK: Effect
typealias Effect<S: State> = (_ state: S, _ store: Store<S>) -> Action?

final class Store<S: State> {
    private(set) var state: S
    private let reducer: Reducer<S>
    
    init(reducer: @escaping Reducer<S>, initialState state: S) {
        self.reducer = reducer
        self.state = state
    }
    
    func dispatch(_ action: Action) {
        state = reducer(action, state)
    }
    
    // MARK: TO FIX
    func dispatch(_ effect: @escaping Effect<S>) {
        guard let action = effect(state, self) else { return }
        
        self.dispatch(action)
    }
    
    
}


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
