//
//  Created by Nikita Borodulin on 07.09.2022.
//

import ComposableArchitecture
import SwiftUI

@main
struct testing_switchstoreApp: App {
    var body: some Scene {
        WindowGroup {
          AppView(
            store: .init(
              initialState: .init(),
              reducer: AppReducer().debug()
            )
          )
        }
    }
}

struct AppReducer: ReducerProtocol {

  struct State: Equatable {

    enum Tab: Equatable {
      case first
      case second
    }

    var first = First.State()
    var second = Second.State()
    var selectedTab: Tab = .first
  }

  enum Action {
    case first(First.Action)
    case second(Second.Action)
    case selectTab(State.Tab)
  }

  var body: some ReducerProtocol<State, Action> {
    Scope(state: \.first, action: /Action.first) {
      First()
    }
    Scope(state: \.second, action: /Action.second) {
      Second()
    }

    Reduce { state, action in
      switch action {
        case .first:
          return .none
        case .second:
          return .none
        case let .selectTab(tab):
          state.selectedTab = tab
          return .none
      }
    }
  }
}

struct AppView: View {

  let store: StoreOf<AppReducer>

  var body: some View {
    WithViewStore(store.scope(state: \.selectedTab)) { viewStore in
      TabView(selection: viewStore.binding(send: { .selectTab($0) })) {
        NavigationView {
          FirstView(store: store.scope(state: \.first, action: AppReducer.Action.first))
        }
        .tag(AppReducer.State.Tab.first)
        .tabItem { Label("First", systemImage: "list.dash") }
        NavigationView {
          SecondView(store: store.scope(state: \.second, action: AppReducer.Action.second))
        }
        .tag(AppReducer.State.Tab.second)
        .tabItem { Label("Second", systemImage: "star") }
      }
    }
  }
}
