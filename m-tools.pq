// A collection a useful tools for building Microsoft Power BI queries.
//
// Author: Kim Burgess <kim@acaprojects.com>
// Repo:   https://github.com/acaprojects/m-tools

let

    /**
     * Right-to-left composition of a pair of unary functions.
     *
     * :: (b -> c) (a -> b) -> a -> c
     */
    _Compose =
        (f as function, g as function) =>
        (x as any) =>
        f(g(x))

in [

    /**
     * Identity for functions under composition.
     *
     * :: a -> a
     */
    Identity =
        (a as any) =>
        a,

    /**
     * Return a function which always returns a given value.
     *
     * a -> b -> a
     */
    Const =
        (a as any) =>
        (b as any) =>
        a,

    /**
     * Reverse the order of arguments to a function or arity 2.
     *
     * :: ((a, b) -> c) -> ((b, a) -> c)
     */
    Flip =
        (f as function) =>
        (a as any, b as any) =>
        f(b, a),

    /**
     * Perform a right-to-left composition across a list of functions.
     *
     * :: ((y -> z), (x -> y), ..., (a -> b)) -> a -> z
     */
    Compose =
        Foldr(_Compose, Identity),

    /**
     * Perform a left-to-right composition across a list of functions.
     *
     * :: ((a -> b), (b -> c), ..., (y -> z)) -> a -> z
     */
    Pipe =
        Foldl(Flip(_Compose), Identity),

    /**
     * Return a single item array containing the passed value.
     *
     * :: a -> [a]
     */
    Of =
        (a as any) =>
        {a},

    /**
     * Takes a function f and a list of arguments, and returns a function g.
     * When applied, g returns the result of applying f to the arguments
     * provided initially followed by the argument list provided to g.
     *
     * :: ((a, b, c, ..., n) -> x) -> [a, b, c, ...] -> ([d, e, f, ..., n] -> x)
     */
    Partial =
        (f as function, a as list) =>
        (b as list) =>
        Function.Invoke(f, a & b),

    /**
     * Similar to Partial but instead of returning a function expecting a list
     * of remaining arguments, provides a function expecting a final single
     * argument in order to fully apply the initial function.
     *
     * :: ((a, b, c, ..., n) -> x) -> [a, b, c, ...] -> (n -> x)
     */
    Partial1 =
        (f as function, a as list) =>
        _Compose(Partial(f, a), Of),

    /**
     * Takes a function f and a list of arguments, and returns a function g.
     * When applied, g returns the result of applying f to the arguments
     * provided to g followed by the argument list provided initially.
     *
     * :: ((a, b, c, ..., n) -> x) -> [d, e, f, ..., n] -> ([a, b, c, ...] -> x)
     */
    PartialRight =
        (f as function, a as list) =>
        (b as list) =>
        Function.Invoke(f, b & a),

    /**
     * Similar to PartialRight however accepts a single, final argument in order
     * to fully apply the intial function.
     *
     * :: ((a, b, c, ..., n) -> x) -> d, e, f, ..., n] -> (a -> x)
     */
    PartialRight1 =
        (f as function, a as list) =>
        _Compose(PartialRight(f, a), Of),

    /**
     * Curry a function so that it will continue to return functions or arity 1
     * up until the original function is saturated, at which point it will be
     * invoked.
     *
     * e.g. Curry((a, b, c) => x) = (a) => (b) => (c) => x
     *
     * :: (* -> a) -> (* -> a)
     */
    Curry =
        (f as function) =>
        let
            arity = Record.FieldCount(Type.FunctionParameters(Value.Type(f))),
            Apply =
                (args as list) =>
                if List.Count(args) >= arity then
                    Function.Invoke(f, args)
                else
                    (x as any) =>
                    @Apply(args & Of(x))
        in
            Apply({}),

    /**
     * Perform a left-associative reduction over a list.
     *
     * :: (a b -> a) a -> [b] -> a
     */
    Foldl =
        (f as function, seed as any) =>
        (a as list) =>
        List.Accumulate(a, seed, f),

    /**
     * Perform a right-associative reduction over a list.
     *
     * :: (a b -> b) -> b -> [a] -> b
     */
    Foldr =
        (f as function, seed as any) =>
        (a as list) =>
        if List.IsEmpty(a) then
            seed
        else
            let
                x = List.Last(a),
                xs = List.RemoveLastN(a, 1)
            in
                f(@Foldr(f, x)(xs), seed),

    /**
     * Apply a transform to all elements of a list.
     *
     * (a -> b) -> [a] -> [b]
     */
    Map =
        (f as function) =>
        (a as list) =>
        List.Transform(a, f),

    /**
     * Evaluate elements of a list against a predicate, returning a new list
     * of the items which evaluated to true.
     *
     * :: (a -> Boolean) -> [a] -> [a]
     */
    Filter =
        (f as function) =>
        (a as list) =>
        List.Select(a, f),

    /**
     * Given two lists, create a new list containing the result of appending b
     * to a.
     *
     * :: [a] [a] -> [a]
     */
    Combine =
        (a as list, b as list) =>
        a & b,

    /**
     * Add a single element to the tail of a list and return a new list
     * containing the merged result.
     *
     * :: a -> [a] -> [a]
     */
    Append =
        (a as any) =>
        (b as list) =>
        b & Of(a),

    /**
    * Add a single element to the head of a list and return a new list
    * containing the merged result.
     *
     * :: a -> [a] -> [a]
     */
    Prepend =
        (a as any) =>
        (b as list) =>
        Of(a) & b,

    /**
     * Provide the ability to chain sequences of internal table, record and
     * list operations.
     *
     * The internal transform functions all take the object being transformed
     * as parameter 0. To remove the need to assign intermediate variables
     * this lifts that argument to be within a higher-order function allowing
     * a sequence of operations to be performed. This sequence is defined as a
     * list of lists, with element 0 containing the transform function and
     * elements 1..n containing the arguments 1..n for that transform.
     *
     *     ExtractRoomInfo = M[ChainOperations]({
     *         {Table.SelectColumns, {"RoomID", "RoomName"}},
     *         {Table.RenameColumns, {"RoomID", "ID"}},
     *         {Table.RenameColumns, {"RoomName", "Name"}}
     *     })
     *
     * :: [(a -> b, x, y, ..n), (b -> c, x, y, ..n),...] -> a -> z
     */
    ChainOperations =
        let
            Transform =
                (t as list) =>
                let
                    f = List.First(t),
                    args = List.Skip(t)
                in
                    PartialRight1(f, args)
        in
            _Compose(Pipe, Map(Transform)),

    /**
     * Provide a simplified method for programmatically contructing table from
     * relationships between columns. Accept a list of lists of the structure:
     *
     *     {<column name>, <column generator>, <type>}
     *
     * The chain may then be fed a table containing at least on column as a
     * seed.
     *
     * :: Table a => a -> [b] -> a
     */
    AddColumns =
        _Compose(ChainOperations, Map(Prepend(Table.AddColumn)))

]
