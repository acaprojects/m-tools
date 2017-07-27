// A collection a useful tools for building Microsoft Power BI queries.
//
// Author: Kim Burgess <kim@acaprojects.com>
// Repo:   https://github.com/acaprojects/m-tools

let

// Internal util functions.

    /**
     * Right-to-left composition of unary functions.
     *
     * :: (b -> c) (a -> b) -> a -> c
     */
    _Compose = (f, g) => (x) => f(g(x)),

    /**
     * Generic expander for applying the internal table column expansion
     * functions in a composable way.
     *
     * :: Table a => (a string [string] [string] -> a) -> string [string] -> a -> a
     */
    _ExpandColumn = (fn) => (col, xs) => (t) => fn(t, col, xs, List.Transform(xs, each col & "." & _))

in [

// ---
// Function composition

    /**
     * Function which always returns it's input.
     *
     * :: a -> a
     */
    Identity = (a) => a,

    /**
     * Return a function which always returns a given value.
     *
     * a -> b -> a
     */
    Const = (a) => (b) => a,

    /**
     * Reverse the order of arguments to a function or arity 2.
     *
     * :: ((a, b) -> c) -> ((b, a) -> c)
     */
    Flip = (f) => (a, b) => f(b, a),

    /**
     * Perform a right-to-left composition across a list of functions.
     *
     * :: ((y -> z), (x -> y), ..., (a -> b)) -> a -> z
     */
    Compose = Foldr(_Compose, Identity),

    /**
     * Perform a left-to-right composition across a list of functions.
     *
     * :: ((a -> b), (b -> c), ..., (y -> z)) -> a -> z
     */
    Pipe = Foldl(Flip(_Compose), Identity),

    /**
     * Return a single item array containing the passed value.
     *
     * :: a -> [a]
     */
    Of = (a) => {a},

    /**
     * Takes a function f and a list of arguments, and returns a function g.
     * When applied, g returns the result of applying f to the arguments
     * provided initially followed by the argument list provided to g.
     *
     * :: ((a, b, c, ..., n) -> x) -> [a, b, c, ...] -> ([d, e, f, ..., n] -> x)
     */
    Partial = (f, a) => (b) => Function.Invoke(f, a & b),

    /**
     * Similar to Partial but instead of returning a function expecting a list
     * of remaining arguments, provides a function expecting a final single
     * argument in order to fully apply the initial function.
     *
     * :: ((a, b, c, ..., n) -> x) -> [a, b, c, ...] -> (n -> x)
     */
    Partial1 = (f, a) => _Compose(Partial(f, a), Of),

    /**
     * Takes a function f and a list of arguments, and returns a function g.
     * When applied, g returns the result of applying f to the arguments
     * provided to g followed by the argument list provided initially.
     *
     * :: ((a, b, c, ..., n) -> x) -> [d, e, f, ..., n] -> ([a, b, c, ...] -> x)
     */
    PartialRight = (f, a) => (b) => Function.Invoke(f, b & a),

    /**
     * Similar to PartialRight however accepts a single, final argument in order
     * to fully apply the intial function.
     *
     * :: ((a, b, c, ..., n) -> x) -> d, e, f, ..., n] -> (a -> x)
     */
    PartialRight1 = (f, a) => _Compose(Partial(f, a), Of),

// ---
// Table transforms

    /**
     * Select a specific set of columns from a table of data.
     *
     * :: Table a => [string] -> a -> a
     */
    SelectColumns = (columns) => (table) => Table.SelectColumns(table, columns),

    /**
     * Flatten the fields from a record column into additional columns.
     *
     * :: Table a => string [string] -> a -> a
     */
    ExpandRecordColumn = _ExpandColumn(Table.ExpandRecordColumn),

    /**
     * Flatten the fields from a table column into additional columns and rows.
     *
     * :: Table a => string [string] -> a -> a
     */
    ExpandTableColumn = _ExpandColumn(Table.ExpandTableColumn),

    /**
     * Flatten the fields from a list column into additional rows.
     *
     * :: Table a => string [string] -> a -> a
     */
    ExpandListColumn = (col) => (table) => Table.ExpandListColumn(table, col),

    /**
     * Append a columns to a table. The generator function (fn) will be invoked
     * for each row with a record type containing other column values.
     *
     * :: Table a, Record b => string (b -> c) type -> a -> a
     */
    AddColumn = (name, fn, optional dataType) => (table) => Table.AddColumn(table, name, fn, dataType),

    /**
     * Tranform the data type of a table column.
     *
     * :: Table a, Type b => string b -> a -> a
     */
    TranformColumnType = (col, dataType) => (table) => Table.TransformColumnTypes(table, {{col, dataType}}),

    /**
     * Reorder columns across a table.
     *
     * :: Table a => [string] -> a -> a
     */
    ReorderColumns = (cols) => (table) => Table.ReorderColumns(table, cols),

    /**
     * Remove a set of columns from a table.
     *
     * :: Table a => [string] -> a -> a
     */
    RemoveColumns = (cols) => (table) => Table.RemoveColumns(table, cols),

    /**
     * Rename a column.
     *
     * :: Table a => string string -> a -> a
     */
    RenameColumn = (from, to) => (table) => Table.RenameColumns(table, {from, to}),

// ---
// List operations

    /**
     * Perform a left-associative reduction over a list.
     *
     * :: (a b -> a) a -> [b] -> a
     */
    Foldl = (fn, seed) => (list) => List.Accumulate(list, seed, fn),

    /**
     * Perform a right-associative reduction over a list.
     *
     * :: (a b -> b) -> b -> [a] -> b
     */
    Foldr = (fn, seed) => (list) =>
        if List.IsEmpty(list) then seed
        else
            let
                x = List.Last(list),
                xs = List.RemoveLastN(list, 1)
            in
                fn(@Foldr(fn, x)(xs), seed),

    /**
     * Apply a transform to all elements of a list.
     *
     * (a -> b) -> [a] -> [b]
     */
    Map = (fn) => (list) => List.Transform(list, fn),

    /**
     * Evaluate elements of a list against a predicate, returning a new list
     * of the items which evaluated to true.
     *
     * :: (a -> Boolean) -> [a] -> [a]
     */
    Filter = (fn) => (list) => List.Select(list, fn)

]
