/**
 * Reverse the order of arguments to a function or arity 2.
 *
 * :: ((a, b) -> c) -> ((b, a) -> c)
 */
(f as function) =>
    (a as any, b as any) =>
        f(b, a)
