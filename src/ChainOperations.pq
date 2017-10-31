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
let
    Transform = (t as list) =>
        let
            f = List.First(t),
            args = List.Skip(t)
        in
            PartialRight1(f, args)
in
    Compose(Pipe, Map(Transform))
