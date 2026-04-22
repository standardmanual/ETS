//
//  KeyboardShortcutHost.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

// MARK: - KeyboardShortcutHost
// iOS 26.4: onKeyPress 직접 지원 → UIKeyCommand 폴백 불필요 (PRD §1.2, §6.4).
// 이 파일은 빈 컨테이너 역할. 실제 단축키는 각 View의 .onKeyPress 수식어로 처리.
//
// 향후 UIKeyCommand를 통한 시스템 레벨 단축키가 필요하면 여기서 확장.

enum KeyboardShortcutHost {
    // 현재 사용 없음 — onKeyPress가 모든 케이스를 처리함
}
