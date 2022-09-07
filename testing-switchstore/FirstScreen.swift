//
//  Created by Nikita Borodulin on 07.09.2022.
//

import ComposableArchitecture
import SwiftUI

struct First: ReducerProtocol {

  struct State: Equatable {

    enum LoadingState: Equatable {
      case loading(LoadingFeature.State)
      case loaded(ColorFeature.State)
    }

    var loadingState: LoadingState = .loading(.init())
  }

  enum Action {
    case loading(LoadingFeature.Action)
    case loaded(ColorFeature.Action)
    case refresh
  }

  var body: some ReducerProtocol<State, Action> {

    Scope(state: \.loadingState, action: .self) {
      EmptyReducer()
        .ifCaseLet(/State.LoadingState.loaded, action: /Action.loaded) {
          ColorFeature()
        }
        .ifCaseLet(/State.LoadingState.loading, action: /Action.loading) {
          LoadingFeature()
        }
    }

    Reduce { state, action in
      switch action {
        case .loading(.loaded(let color)):
          state.loadingState = .loaded(.init(color: color))
          return .none
        case .loading:
          return .none
        case .loaded:
          return .none
        case .refresh:
          state.loadingState = .loading(.init())
          return .none
      }
    }
  }
}

struct FirstView: View {

  let store: StoreOf<First>

  var body: some View {
    SwitchStore(store.scope(state: \.loadingState)) {
      CaseLet(state: /First.State.LoadingState.loading, action: First.Action.loading, then: LoadingView.init)
      CaseLet(state: /First.State.LoadingState.loaded, action: First.Action.loaded, then: ColorView.init)
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        refreshButton
      }
    }
  }


  @ViewBuilder
  private var refreshButton: some View {
    WithViewStore(store.stateless) { viewStore in
      Button(action: { viewStore.send(.refresh, animation: .easeOut) }) {
        Image(systemName: "arrow.2.circlepath")
      }
    }
  }
}

struct LoadingFeature: ReducerProtocol {
  struct State: Equatable {
    var hasTaskInFlight = false
  }
  enum Action: Equatable {
    case loaded(Color)
    case onAppear
  }
  func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
    switch action {
      case .loaded:
        state.hasTaskInFlight = false
        return .none
      case .onAppear:
        if state.hasTaskInFlight {
          return .none
        }
        state.hasTaskInFlight = true
        return .task {
          try await Task.sleep(nanoseconds: NSEC_PER_SEC * 2)
          return .loaded(.blue)
        }
    }
  }
}

struct LoadingView: View {
  let store: StoreOf<LoadingFeature>

  var body: some View {
    WithViewStore(store) { viewStore in
      ProgressView()
        .onAppear {
          viewStore.send(.onAppear)
        }
    }
  }
}

struct ColorFeature: ReducerProtocol {

  struct State: Equatable {
    let color: Color
  }

  enum Action: Equatable {
    case unusedAction
  }

  func reduce(into state: inout State, action: Action) -> Effect<Action, Never> { .none }
}

struct ColorView: View {

  let store: StoreOf<ColorFeature>

  var body: some View {
    WithViewStore(store) { viewStore in
      Rectangle()
        .fill(viewStore.color)
    }
  }
}
