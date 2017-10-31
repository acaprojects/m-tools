/**
 * Right-to-left composition of a pair of unary functions.
 *
 * :: (b -> c) (a -> b) -> a -> c
 */
(f as function, g as function) =>
    (x as any) =>
        f(g(x))
