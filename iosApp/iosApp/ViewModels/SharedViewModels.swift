import Foundation
import Shared

@MainActor
final class CaseListViewModelWrapper: ObservableObject {
    @Published var state: CaseListState
    private let viewModel: CaseListViewModel
    private var task: Task<Void, Never>?

    init(viewModel: CaseListViewModel) {
        self.viewModel = viewModel
        self.state = viewModel.state.value
        self.viewModel.observe(status: nil)
        self.task = Task { [weak self] in
            guard let self else { return }
            for await value in viewModel.state {
                self.state = value
            }
        }
    }
}

@MainActor
final class CaseSetupViewModelWrapper: ObservableObject {
    @Published var state: CaseSetupState
    private let viewModel: CaseSetupViewModel
    private var task: Task<Void, Never>?

    init(viewModel: CaseSetupViewModel) {
        self.viewModel = viewModel
        self.state = viewModel.state.value
        self.task = Task { [weak self] in
            guard let self else { return }
            for await value in viewModel.state {
                self.state = value
            }
        }
    }

    func updatePatientName(_ value: String) { viewModel.updatePatientName(value: value) }
    func updateSpecies(_ value: Species) { viewModel.updateSpecies(value: value) }
    func updateWeight(_ value: Double?) { viewModel.updateWeight(value: kotlinDouble(value)) }
    func updateProcedure(_ value: String) { viewModel.updateProcedure(value: value) }
    func updateAnestheticProtocol(_ value: String) { viewModel.updateAnestheticProtocol(value: value) }
    func startCase() { viewModel.startCase() }
}

@MainActor
final class CatalogPickerViewModelWrapper: ObservableObject {
    @Published var state: CatalogPickerState
    private let viewModel: CatalogPickerViewModel
    private var task: Task<Void, Never>?

    init(viewModel: CatalogPickerViewModel) {
        self.viewModel = viewModel
        self.state = viewModel.state.value
        self.task = Task { [weak self] in
            guard let self else { return }
            for await value in viewModel.state {
                self.state = value
            }
        }
    }

    func updateQuery(_ value: String) { viewModel.updateQuery(value: value) }
}

private func kotlinDouble(_ value: Double?) -> KotlinDouble? {
    guard let value else { return nil }
    return KotlinDouble(double: value)
}

@MainActor
final class RecordTableViewModelWrapper: ObservableObject {
    @Published var state: RecordTableState
    private let viewModel: RecordTableViewModel
    private var task: Task<Void, Never>?

    init(viewModel: RecordTableViewModel) {
        self.viewModel = viewModel
        self.state = viewModel.state.value
        self.viewModel.observe()
        self.task = Task { [weak self] in
            guard let self else { return }
            for await value in viewModel.state {
                self.state = value
            }
        }
    }
}

@MainActor
final class MonitoringViewModelWrapper: ObservableObject {
    @Published var state: MonitoringState
    private let viewModel: MonitoringViewModel
    private var task: Task<Void, Never>?

    init(viewModel: MonitoringViewModel) {
        self.viewModel = viewModel
        self.state = viewModel.state.value
        self.task = Task { [weak self] in
            guard let self else { return }
            for await value in viewModel.state {
                self.state = value
            }
        }
    }

    func updateVitals(_ updated: VitalsInput) {
        viewModel.updateVitals(input: updated)
    }

    func updateEcg(name: String?) {
        viewModel.updateEcg(name: name)
    }

    func updateCrt(name: String?) {
        viewModel.updateCrt(name: name)
    }

    func updateMucousMembrane(name: String?) {
        viewModel.updateMucousMembrane(name: name)
    }

    func updateNotes(_ value: String?) {
        viewModel.updateNotes(value: value)
    }

    func save() { viewModel.save() }
}
