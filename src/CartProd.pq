/**
 * Given two lists of values, return a list containing their product set.
 *
 * :: [a] [b] -> [[a, b]]
 */
(xs as list, ys as list) =>
    M[ConcatMap]((x) => M[ConcatMap]((y) => {
        {x, y}
    })(ys))(xs)
