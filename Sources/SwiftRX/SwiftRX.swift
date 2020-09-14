import Foundation

struct SwiftRX {
    var text = "Hello, World!"
}

protocol Action {

}

protocol State {}

typealias Reducer<S: State> = (Action,  S) -> S

typealias ActionCreator<S: State> = (_ state: S, _ store: Store<S>) -> Action?

final class Store<S: State>: ObservableObject {
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
