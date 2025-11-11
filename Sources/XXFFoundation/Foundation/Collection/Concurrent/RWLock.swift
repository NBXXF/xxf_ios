//
//  RWLock.swift
//  SwiftConcurrentCollections
//
import Foundation

final class RWLock {
    private var lock: pthread_rwlock_t

    // MARK: Lifecycle

    deinit {
        pthread_rwlock_destroy(&lock)
    }

    init() {
        lock = pthread_rwlock_t()
        pthread_rwlock_init(&lock, nil)
    }

    // MARK: Public

    func writeLock() {
        pthread_rwlock_wrlock(&lock)
    }

    func readLock() {
        pthread_rwlock_rdlock(&lock)
    }

    func unlock() {
        pthread_rwlock_unlock(&lock)
    }
}
