
import Foundation
import RxSwift

private nonisolated(unsafe) var queueKey: UInt8 = 0
extension ConcurrentDispatchQueueScheduler {
    /// 关联对象存储 queue,先不要暴漏出去
    var storedQueue: DispatchQueue {
        get {
            guard let queue = objc_getAssociatedObject(self, &queueKey) as? DispatchQueue else {
                fatalError("storedQueue not init")
            }
            return queue
        }
        set {
            objc_setAssociatedObject(self, &queueKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    convenience init(dispatchQoS qos: DispatchQoS,
                     queueConfiguration: ((DispatchQueue) -> Void)? = nil,
                     leeway: DispatchTimeInterval = DispatchTimeInterval.nanoseconds(0))
    {
        let queue = DispatchQueue(
            label: "rxswift.queue.\(qos)",
            qos: qos,
            attributes: [DispatchQueue.Attributes.concurrent],
            target: nil
        )
        queueConfiguration?(queue)
        self.init(queue: queue, leeway: leeway)
        storedQueue = queue
    }
}
