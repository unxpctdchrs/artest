//
//  MultimeterProtocol.swift
//  Eudori3
//
//  Created by Tubagus Ariq Naufal on 24/06/25.
//

import RealityFoundation

protocol MultimeterProtocol: AnyObject {
    func didFocusEntity(_ entity: Entity)
    func didLoseFocus()
    func didUpdateFocusProgress(_ progress: Double)
    func shouldTrackFocus() -> Bool
}
