/**
 * Takes a function f and a list of arguments, and returns a function g.
 * When applied, g returns the result of applying f to the arguments
 * provided to g followed by the argument list provided initially.
 *
 * :: ((a, b, c, ..., n) -> x) -> [d, e, f, ..., n] -> ([a, b, c, ...] -> x)
 */
(f as function, a as list) =>
    Compose(Apply(f), (b as list) => b & a)
