import SwiftUI

struct Content: View {
    var body: some View {
        EmptyView()
            .onAppear {
                print(wing.label)
                
            }
    }
}

#Preview { Content() }

func parse(text: String?) -> String {
    guard var input = text else { return "" }
    input.removeFirst()
    let t = input.split(separator: /,(?=\()/)
    return t.reduce("") { output, p in
        output + "Point" + p + ",\n"
    }
}
