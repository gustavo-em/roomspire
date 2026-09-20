import UIKit
import SwiftUI
import OSLog

class ListRoomsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "RoomInspiration2", category: "ViewController")

    private let viewModel: ListRoomsViewModel

    init(viewModel: ListRoomsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    lazy var uiLabelView: UILabel = {
        let label: UILabel = .init()
        label.text = "Hello, World!"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var uiTableView: UITableView = {
        let tableView: UITableView = .init()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        uiTableView.dataSource = self
        uiTableView.delegate = self

        uiTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        uiTableView.rowHeight = 50

        view.addSubview(uiLabelView)
        view.addSubview(uiTableView)

        NSLayoutConstraint.activate([
            uiLabelView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            uiLabelView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            uiLabelView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            uiTableView.topAnchor.constraint(equalTo: uiLabelView.bottomAnchor),
            uiTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            uiTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            uiTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        viewModel.onChange = { [weak self] in
            self?.uiTableView.reloadData()
        }

        viewModel.load()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRooms
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let room = viewModel.room(at: indexPath.row)

        cell.contentConfiguration = UIHostingConfiguration {
            CellTableView(room: room)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let room = viewModel.room(at: indexPath.row)
        let host = UIHostingController(rootView: RoomDetailView(room: room))
        if let sheet = host.sheetPresentationController {
               sheet.detents = [.medium(), .large()]
               sheet.prefersGrabberVisible = true
           }
        present(host, animated: true)
    }
}
