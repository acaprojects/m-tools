/**
 * Takes a function f and a list of arguments, and returns a function g.
 * When applied, g returns the result of applying f to the arguments
 * provided initially followed by the argument list provided to g.
 *
 * :: ((a, b, c, ..., n) -> x) -> [a, b, c, ...] -> ([d, e, f, ..., n] -> x)
 */
(f as function, args as list) =>
    Compose(Apply(f), Join(args))
