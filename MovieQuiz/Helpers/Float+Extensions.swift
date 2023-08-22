import Foundation

extension Float {
    func isLess(than: Float, precision: Float = Float.ulpOfOne) -> Bool {
        return (than - self) > ((abs(self) < abs(than) ? abs(than) : abs(self)) * precision);
    }
    
    func isGreater(than: Float, precision: Float = Float.ulpOfOne) -> Bool {
        return (self - than) > ((abs(self) < abs(than) ? abs(than) : abs(self)) * precision);
    }
    
    func isEqual(other: Float, precision: Float = Float.ulpOfOne) -> Bool {
        return abs(self - other) < precision
    }
}
