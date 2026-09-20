extension Array {
    func chunked(into size: Int) -> [[Element]] {
        precondition(size > 0)
        return stride(from: 0, to: count, by: size).map { start in
            Array(self[start..<Swift.min(start + size, count)])
        }
    }
}
