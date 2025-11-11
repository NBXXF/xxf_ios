//
//  EmptyCancellable.swift
//  xxf_ios
//
//  Created by xx on 8/19.
//
import Nuke
import XXFFoundation
import XXFImageLoader

final class EmptyCancellable: Nuke.Cancellable, XXFImageLoader.Cancellable {
    func cancel() {}
}
