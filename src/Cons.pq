/**
 * Add a single element to the head of a list and return a new list
 * containing the merged result.
 *
 * :: a -> [a] -> [a]
 */
(x as any) =>
    (xs as list) =>
        {x} & xs
