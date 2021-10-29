//
//  ContentView.swift
//  SplatNet2Demo
//
//  Created by tkgstrator on 2021/05/01.
//

import SwiftUI
import SplatNet2
import Combine
import BetterSafariView

struct ContentView: View {

    var body: some View {
        NavigationView {
            SignInView()
            ProgressLogView()
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension String {
    func capture(pattern: String, group: Int) -> String? {
        let result = capture(pattern: pattern, group: [group])
        return result.isEmpty ? nil : result[0]
    }
    
    private func capture(pattern: String, group: [Int]) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        guard let matched = regex.firstMatch(in: self, range: NSRange(location: 0, length: self.count)) else { return [] }
        return group.map { group -> String in
            return (self as NSString).substring(with: matched.range(at: group))
        }
    }
}
