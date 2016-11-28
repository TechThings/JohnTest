import UIKit
import RxSwift
import ObjectiveC

public extension UITableViewCell {

    func rx_prepareForReuse() {
        self.rx_prepareForReuse()
        rx_reusableDisposeBag = DisposeBag()
    }

    public override class func initialize() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            self.swizzleMethodForSelector(#selector(self.prepareForReuse),
                                          withMethodForSelector: #selector(self.rx_prepareForReuse))
        }
    }
}
