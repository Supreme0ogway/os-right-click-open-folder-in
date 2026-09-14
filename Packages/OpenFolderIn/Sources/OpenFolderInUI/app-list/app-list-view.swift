import SwiftUI

/// The screen where apps are added, changed and removed.
///
/// Opens with nothing picked, so the window says what it holds before it says what one
/// row of it says.
///
/// Layout only. Every rule about what may be added, what an added app is called and
/// what happens when the last one goes lives in the model this reads from.
public struct AppListView: View {

    @State private var model: AppListViewModel
    @State private var picked: AppIdentifier?
    @State private var isAdding = false

    @Environment(\.colorScheme) private var appearance

    private let defaultApp: DefaultAppViewModel
    private let onOpenSettings: () -> Void

    /// Builds the screen.
    ///
    /// - Parameters:
    ///   - model: What the screen knows and can do.
    ///   - defaultApp: The model for which app a folder opens in by default.
    ///   - onOpenSettings: What to do when the settings button is pressed.
    public init(
        model: AppListViewModel,
        defaultApp: DefaultAppViewModel,
        onOpenSettings: @escaping () -> Void
    ) {
        self._model = State(initialValue: model)
        self.defaultApp = defaultApp
        self.onOpenSettings = onOpenSettings
    }

    public var body: some View {
        NavigationSplitView {
            appList
        } detail: {
            detail
        }
        .navigationTitle(UIText.appName)
        .searchable(text: $model.search, placement: .toolbar, prompt: UIText.search)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(UIText.addApp, systemImage: EditorLayout.addIconName) { isAdding = true }
                Button(
                    UIText.settings,
                    systemImage: EditorLayout.settingsIconName,
                    action: onOpenSettings
                )
            }
        }
        .sheet(isPresented: $isAdding) { addSheet }
        .alert(
            UIText.removeQuestion(model.pendingRemovalName),
            isPresented: askingToRemove
        ) {
            Button(UIText.removeCancel, role: .cancel) { model.cancelRemoval() }
            Button(UIText.removeConfirm, role: .destructive) { model.confirmRemoval() }
        } message: {
            Text(UIText.removeWarning)
        }
    }

    private var addSheet: some View {
        AddAppSheet(
            model: AddAppViewModel(
                found: InstalledApps.thatCanOpenFolders(),
                taken: Set(model.apps.map(\.id))
            ),
            onAdd: { app in
                model.add(app)
                picked = app.id
                isAdding = false
            },
            onCancel: { isAdding = false }
        )
    }

    private var appList: some View {
        List(selection: $picked) {
            ForEach(model.shownApps) { app in
                AppRow(
                    app: app,
                    isDefault: defaultApp.isDefault(app.id),
                    appearance: appearance
                )
                .tag(app.id)
                .contextMenu {
                    Button(defaultLabel(for: app)) { toggleDefault(for: app) }
                    Button(UIText.removeConfirm, role: .destructive) {
                        model.askToRemove(app.id)
                    }
                }
            }
            .onMove(perform: model.move)
            .moveDisabled(!model.canReorder)
        }
        .overlay { listOverlay }
        .navigationSplitViewColumnWidth(
            min: EditorLayout.listMinimumWidth,
            ideal: EditorLayout.listIdealWidth
        )
    }

    @ViewBuilder
    private var listOverlay: some View {
        if model.showsEmptyMessage {
            EmptyState(
                title: UIText.emptyTitle,
                message: UIText.emptyMessage,
                iconName: EditorLayout.emptyIconName
            )
        }

        if model.showsNoMatchesMessage {
            EmptyState(
                title: UIText.noMatchesTitle,
                message: UIText.noMatchesMessage,
                iconName: EditorLayout.noMatchesIconName
            )
        }
    }

    @ViewBuilder
    private var detail: some View {
        if let app = pickedApp {
            AppForm(app: app, model: model, defaultApp: defaultApp)
                .id(app.id)
        }

        if pickedApp == nil, !model.showsEmptyMessage {
            EmptyState(
                title: UIText.nothingPickedTitle,
                message: UIText.nothingPickedMessage,
                iconName: EditorLayout.nothingPickedIconName
            )
        }
    }

    private var askingToRemove: Binding<Bool> {
        Binding(
            get: { model.isAskingToRemove },
            set: { stillAsking in
                guard !stillAsking else { return }
                model.cancelRemoval()
            }
        )
    }

    private var pickedApp: OpenerApp? {
        guard let picked else { return nil }
        return model.apps.first { $0.id == picked }
    }

    private func defaultLabel(for app: OpenerApp) -> String {
        defaultApp.isDefault(app.id) ? UIText.removeDefault : UIText.makeDefault
    }

    private func toggleDefault(for app: OpenerApp) {
        guard !defaultApp.isDefault(app.id) else {
            defaultApp.clear()
            return
        }
        defaultApp.choose(app.id)
    }
}

/// Fixed sizes and symbols for the editor screen.
enum EditorLayout {

    /// The narrowest the list of apps may get.
    static let listMinimumWidth: CGFloat = 200

    /// How wide the list of apps opens.
    static let listIdealWidth: CGFloat = 240

    /// The symbol shown when there are no apps left.
    static let emptyIconName = "tray"

    /// The symbol shown when no app has been picked.
    static let nothingPickedIconName = "hand.point.left"

    /// The symbol on the button that adds an app.
    static let addIconName = "plus"

    /// The symbol on the button that opens the settings screen.
    static let settingsIconName = "gearshape"

    /// The symbol shown when a search matched nothing.
    static let noMatchesIconName = "magnifyingglass"
}
