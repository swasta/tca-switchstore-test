//
//  Created by Nikita Borodulin on 07.09.2022.
//

import ComposableArchitecture
import SwiftUI

struct Second: ReducerProtocol {

  struct State: Equatable {}

  enum Action {
    case action
  }

  var body: some ReducerProtocol<State, Action> {
    EmptyReducer()
  }
}

struct SecondView: View {

  let store: StoreOf<Second>

  var body: some View {
    Color.green
  }
}
