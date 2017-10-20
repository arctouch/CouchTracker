import UIKit

final class AppConfigurationsViewController: UIViewController, AppConfigurationsView, UITableViewDataSource {
  var presenter: AppConfigurationsPresenter!
  private var configurationSections = [AppConfigurationsViewModel]()

  @IBOutlet weak var tableView: UITableView!

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.dataSource = self
    tableView.delegate = self

    title = R.string.localizable.settings()

    presenter.viewDidLoad()
  }

  func showConfigurations(models: [AppConfigurationsViewModel]) {
    configurationSections.removeAll()
    configurationSections.append(contentsOf: models)
    tableView.reloadData()
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return configurationSections.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard section < configurationSections.count else { return 0 }
    let section = configurationSections[section]
    return section.configurations.count
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    guard section < configurationSections.count else { return nil }
    return configurationSections[section].title
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let identifier = R.reuseIdentifier.appConfigurationsCell
    guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) else {
      fatalError("What a terrible failure - Dequeue AppConfigurationCell fail")
    }

    let section = configurationSections[indexPath.section]
    let configuration = section.configurations[indexPath.row]

    cell.textLabel?.text = configuration.title
    cell.detailTextLabel?.text = configuration.subtitle

    return cell
  }
}

extension AppConfigurationsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    presenter.optionSelectedAt(index: indexPath.row)
  }
}
