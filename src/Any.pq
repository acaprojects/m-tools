/**
 * Check if any elements of a list satisfy a given predicate.
 *
 * :: (a -> Bool) -> [a] -> Bool
 */
(p as function) =>
    (xs as list) =>
        Or(Map(p, xs))
