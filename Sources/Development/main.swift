import CMinpack

let residualCallback: @convention(c) (
    UnsafeMutableRawPointer?,
    CInt,
    CInt,
    UnsafePointer<Double>?,
    UnsafeMutablePointer<Double>?,
    CInt
) -> CInt = { rawProblem, m, n, xPtr, fvecPtr, iflag in

    guard
        let rawProblem,
        let xPtr,
        let fvecPtr
    else {
        return -1
    }

    let problem = Unmanaged<ExpFitProblem>
        .fromOpaque(rawProblem)
        .takeUnretainedValue()

    let a = xPtr[0]
    let b = xPtr[1]

    for i in 0..<Int(m) {
        let model = a * Foundation.exp(-b * problem.t[i])
        fvecPtr[i] = model - problem.y[i]
    }

    return 0
}

print("hello")
lmdif1(nil, nil, )