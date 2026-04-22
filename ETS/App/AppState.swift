//
//  AppState.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

@MainActor
class AppState: ObservableObject {
    /// 우선순위 탭과 코드암기 탭이 공유하는 힌트 토글
    /// guitar.html 원본에서 hintOn은 전역 변수
    @Published var hintOn: Bool = false
}
