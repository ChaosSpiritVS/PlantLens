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

    @Published var modalScreen: (Pla_Screen, ModalType)? {
        didSet {
            impl.modalScreen = modalScreen
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

    func present(_ screen: Pla_Screen, _ modalType: ModalType = .fullScreen) {
        modalScreen = (screen, modalType)
    }

    func dismiss() {
        modalScreen = nil
    }

    func resetToRoot() {
        impl.popToRoot()
        dismiss()
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
    var modalScreen: (Pla_Screen, Pla_AppCoordinator.ModalType)? { get set }
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
    var modalScreen: (Pla_Screen, Pla_AppCoordinator.ModalType)?

    var currentPathScreens: [Pla_Screen] {
        [] // NavigationPath 内部不公开元素，返回空或用额外 stack
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
    var modalScreen: (Pla_Screen, Pla_AppCoordinator.ModalType)?

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

enum Pla_Screen: Hashable, Identifiable{
    /// `id` 让它唯一识别
    var id: Self { self }
    
    case login
    case mainTab
    case recommend
    case diagnosis
    case camera
    case plants
    case more

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
        }
    }
    
}
