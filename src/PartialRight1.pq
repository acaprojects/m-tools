/**
 * Similar to PartialRight however accepts a single, final argument in order
 * to fully apply the intial function.
 *
 * :: ((a, b, c, ..., n) -> x) -> d, e, f, ..., n] -> (a -> x)
 */
(f as function, a as list) =>
    Compose(PartialRight(f, a), Of)
