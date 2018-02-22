public struct AppConfigurationsViewModel: Hashable {
	public let title: String
	public let configurations: [AppConfigurationViewModel]

	public var hashValue: Int {
		var hash = title.hashValue

		configurations.forEach { hash ^= $0.hashValue }

		return hash
	}

	public static func == (lhs: AppConfigurationsViewModel, rhs: AppConfigurationsViewModel) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
}

public struct AppConfigurationViewModel: Hashable {
	public let title: String
	public let subtitle: String?
	public let value: AppConfigurationViewModelValue

	public var hashValue: Int {
		var hash = title.hashValue

		if let subtitleHash = subtitle?.hashValue {
			hash ^= subtitleHash
		}

		return hash
	}

	public static func == (lhs: AppConfigurationViewModel, rhs: AppConfigurationViewModel) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
}

public enum AppConfigurationViewModelValue {
	case none
	case boolean(value: Bool)
}