import SwiftData
import SwiftUI

/// Final standings shown at the end of the score-entry flow. The session is
/// already marked complete by `SessionService.finish`. Done dismisses the whole
/// flow; there's no back to scoring.
struct ResultsView: View {
  let session: GameSession

  @Environment(\.dismissFlow) private var dismissFlow

  var body: some View {
    StandingsView(session: session)
      .navigationTitle("Results")
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarBackButtonHidden(true)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Done") { dismissFlow() }
            .fontWeight(.semibold)
        }
      }
  }
}
