enum ShowsManagerOption: String {
  case progress
  case now
  case trending
}

protocol ShowsManagerPresenter: class {
  init(view: ShowsManagerView, loginObservable: TraktLoginObservable, moduleSetup: ShowsManagerDataSource)

  func viewDidLoad()
}

protocol ShowsManagerView: class {
  var presenter: ShowsManagerPresenter! { get set }

  func show(pages: [ModulePage], withDefault index: Int)

  func showNeedsTraktLogin()
}

protocol ShowsManagerDataSource: class {
  var options: [ShowsManagerOption] { get }
  var modulePages: [ModulePage] { get }
  var defaultModuleIndex: Int { get }
}
