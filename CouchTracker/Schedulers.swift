import RxSwift

protocol Schedulers: class {
  var networkScheduler: ImmediateSchedulerType { get }
  var networkQueue: DispatchQueue { get }
  var dataSourceScheduler: ImmediateSchedulerType { get }
  var dataSourceQueue: DispatchQueue { get }
}
