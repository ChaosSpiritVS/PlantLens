//
//  Pla_AppCoordinator.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/3.
//

import SwiftUI
 
class Pla_AppCoordinator: ObservableObject {
    enum ModalType {
        case fullScreen
        case sheet
    }

    static let shared = Pla_AppCoordinator()

    private var impl: Pla_AppCoordinatorBase

    /// ✅ 支持多个 modal 页面堆叠
    @Published var modalStack: [(Pla_Screen, ModalType)] = [] {
        didSet {
            impl.modalStack = modalStack
        }
    }

    init() {
        if #available(iOS 16.0, *) {
            impl = Pla_AppCoordinator_iOS16()
        } else {
            impl = Pla_AppCoordinator_iOS15()
        }
    }

    func push(_ screen: Pla_Screen) {
        impl.push(screen)
    }

    func pop() {
        impl.pop()
    }

    func popToRoot() {
        impl.popToRoot()
    }

    /// ✅ 弹出一个 modal（支持堆叠）
    func present(_ screen: Pla_Screen, _ modalType: ModalType = .fullScreen) {
        modalStack.append((screen, modalType))
    }

    /// dismiss 最顶层 modal 或指定类型 modal（按 type 匹配，不用带参数）
    func dismiss(_ screenType: Pla_ScreenType? = nil, type: ModalType? = nil) {
        if let screenType = screenType {
            modalStack.removeAll { $0.0.type == screenType }
        } else if let type = type {
            if let lastIndex = modalStack.lastIndex(where: { $0.1 == type }) {
                modalStack.remove(at: lastIndex)
            }
        } else {
            _ = modalStack.popLast()
        }
    }

    /// ✅ 全部关闭
    func dismissAll() {
        modalStack.removeAll()
    }

    func resetToRoot() {
        impl.popToRoot()
        dismissAll()
    }

    var currentPathScreens: [Pla_Screen] {
        impl.currentPathScreens
    }

    @available(iOS 16.0, *)
    var pathBinding: Binding<NavigationPath>? {
        (impl as? Pla_AppCoordinatorProtocol)?.pathBinding
    }
}

private protocol Pla_AppCoordinatorBase {
    var modalStack: [(Pla_Screen, Pla_AppCoordinator.ModalType)] { get set }
    var currentPathScreens: [Pla_Screen] { get }
    func push(_ screen: Pla_Screen)
    func pop()
    func popToRoot()
}

@available(iOS 16.0, *)
private protocol Pla_AppCoordinatorProtocol: Pla_AppCoordinatorBase {
    var pathBinding: Binding<NavigationPath> { get }
}

@available(iOS 16.0, *)
class Pla_AppCoordinator_iOS16: Pla_AppCoordinatorProtocol {
    @Published private var path = NavigationPath()
    var modalStack: [(Pla_Screen, Pla_AppCoordinator.ModalType)] = []

    var currentPathScreens: [Pla_Screen] {
        []
    }

    func push(_ screen: Pla_Screen) {
        path.append(screen)
    }

    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    var pathBinding: Binding<NavigationPath> {
        Binding(get: { self.path }, set: { self.path = $0 })
    }
}

class Pla_AppCoordinator_iOS15: Pla_AppCoordinatorBase {
    @Published private var path: [Pla_Screen] = []
    var modalStack: [(Pla_Screen, Pla_AppCoordinator.ModalType)] = []

    var currentPathScreens: [Pla_Screen] {
        path
    }

    func push(_ screen: Pla_Screen) {
        path.append(screen)
    }

    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func popToRoot() {
        path.removeAll()
    }
}

enum Pla_ScreenType: Hashable {
    case login
    case mainTab
    case recommend
    case diagnosis
    case camera
    case plants
    case more
    case recognition
    case plantDetail
}

enum Pla_Screen: Hashable, Identifiable {
    var id: Self { self }
    
    case login
    case mainTab
    case recommend
    case diagnosis
    case camera
    case plants
    case more
    case recognition(UIImage)
    case plantDetail(Pla_RecognitionResult?)

    // 新增页面类型，不带参数
    var type: Pla_ScreenType {
        switch self {
        case .login: return .login
        case .mainTab: return .mainTab
        case .recommend: return .recommend
        case .diagnosis: return .diagnosis
        case .camera: return .camera
        case .plants: return .plants
        case .more: return .more
        case .recognition: return .recognition
        case .plantDetail: return .plantDetail
        }
    }

    @ViewBuilder
    func view() -> some View {
        switch self {
        case .login:
            Pla_LoginView()
        case .mainTab:
            Pla_MainTabView()
        case .recommend:
            Pla_RecommendView()
        case .diagnosis:
            Pla_DiagnosisView()
        case .camera:
            Pla_CameraView()
        case .plants:
            Pla_PlantsView()
        case .more:
            Pla_MoreView()
        case .recognition(let image):
            Pla_RecognitionView(image: image)
        case .plantDetail(let recognitionResult):
            Pla_RecognitionResultView(recognitionResult: recognitionResult)
        }
    }
}

