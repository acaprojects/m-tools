/**
 * Similar to Partial but instead of returning a function expecting a list
 * of remaining arguments, provides a function expecting a final single
 * argument in order to fully apply the initial function.
 *
 * :: ((a, b, c, ..., n) -> x) -> [a, b, c, ...] -> (n -> x)
 */
(f as function, args as list) =>
    Compose(Partial(f, args), Of)
