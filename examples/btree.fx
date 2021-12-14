/*
    This file is a part of ficus language project.
    See ficus/LICENSE for the licensing terms
*/

import Sys

type tree = Empty | Node: {left: tree; right: tree}

fun make_(d: int) =
    if d > 1 { Node{right=make_(d-1), left=make_(d-1)} }
    else {
        Node {
            left=Node{left=Empty, right=Empty},
            right=Node{left=Empty, right=Empty}
        }
    }

fun make(d: int) =
    if d == 0 { Node {left=Empty, right=Empty} }
    else { make_(d) }

fun check (t: tree): int {
    | Node {left=l, right=r} => if l != Empty {1 + check(l) + check(r)} else {1}
    | _ => 0
}

val min_depth = 4
val max_depth = match Sys.arguments() {
    | n_str :: [] => n_str.to_int_or(10)
    | _ => 20
    }
val max_depth = max(min_depth + 2, max_depth)
val stretch_depth = max_depth + 1

val c = check (make(stretch_depth))
println(f"stretch tree of depth {stretch_depth}\t check: {c}")

val long_lived_tree = make(max_depth)

val report = [| @parallel for i <- 0 : (max_depth - min_depth) / 2 + 1
{
    val d = min_depth + i * 2
    val niter = 1 << (max_depth - d + min_depth)
    val fold c = 0 for i <- 0:niter {
        c + check(make(d))
    }
    f"{niter}\t trees of depth {d}\t check: {c}"
} |]

for l <- report {println(l)}

println(f"long lived tree of depth {max_depth}\t check: {check(long_lived_tree)}")
