//
//  NSWindowListenable.swift
//  xxf_ios
//
//  Created by trl on 9/15.
//

public protocol NSWindowListenable {
    func viewDidAttachToWindow()
    func viewDidDetachFromWindow()
}
