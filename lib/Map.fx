/*
    This file is a part ficus language project.
    See ficus/LICENSE for the licensing terms
*/

/* The ordered map implemented using Red-Black trees.

   This is partially derived from Ocaml's Red-Black tree implementation
   by Benedikt Meurer taken from https://github.com/bmeurer/ocaml-rbtrees.

   Below is the original copyright and the license:

 * =====
 * Copyright (c) 2007, Benedikt Meurer <benedikt.meurer@googlemail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software {out restriction, including {out limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 *
 * This is my implementation of Red-Black Trees for OCaml. It is based upon
 * "Red-Black Trees in a Functional Setting", Chris Okasaki in "Functional
 * Pearls".
 * Red-Black Trees are exposed via a map and a set API, which is designed to
 * be compatible { the Map and Set modules in the OCaml standard library
 * (which are implemented using AVL trees). You can use the Rbmap and Rbset
 * modules as drop-in replacement for the Map and Set modules.
 * =====
*/

type 'k cmp_t = ('k, 'k) -> int
type color_t = Red | Black
type ('k,'d) tree_t = Empty | Node: (color_t, ('k,'d) tree_t, 'k, 'd, ('k,'d) tree_t)
class ('k, 'd) t { root: ('k,'d) tree_t; cmp: 'k cmp_t }

exception MapError

fun empty(cmp: 'k cmp_t): ('k, 'd) Map.t =
    t { root=(Empty : ('k, 'd) tree_t), cmp=cmp }

fun empty(s: 't t): bool
{
    | { root=(Empty : ('k, 'd) tree_t) } => true
    | _ => false
}

@private fun find_opt_(t: ('k, 'd) tree_t, xk: 'k, cmp: 'k cmp_t) : 'd? =
match t
{
    | Node(_, l, yk, yd, r) =>
        val c = cmp(xk, yk)
        if c < 0 { find_opt_(l, xk, cmp) }
        else if c > 0 { find_opt_(r, xk, cmp) }
        else { Some(yd) }
    | _ => None
}

fun find_opt(m: ('k, 'd) Map.t, x: 'k): 'd? = find_opt_(m.root, x, m.cmp)

// Overloaded function with exception if no value found
fun find(m: ('k, 'd) Map.t, xk: 'k): 'd =
match find_opt(m, xk)
{
    | Some(xd) => xd
    | _ => throw MapError
}

fun find(m: ('k, 'd) Map.t, xk: 'k, def_xd: 'd): 'd =
match find_opt(m, xk)
{
    | Some(xd) => xd
    | _ => def_xd
}

fun mem(m: ('k, 'd) Map.t, x: 'k): bool
{
    fun mem_(t: ('k, 'd) tree_t, xk: 'k, cmp: 'k cmp_t) =
    match t {
        | Node(_, l, yk, yd, r) =>
            val c = cmp(xk, yk)
            if c < 0 { mem_(l, xk, cmp) }
            else if c > 0 { mem_(r, xk, cmp) }
            else { true }
        | _ => false
    }
    mem_(m.root, x, m.cmp)
}

@private fun balance_left(l: ('k, 'd) tree_t, xk: 'k, xd: 'd, r: ('k, 'd) tree_t)
{
    | (Node(Red, Node(Red, a, xk, xd, b), yk, yd, c), zk, zd, d) =>
        Node(Red, Node(Black, a, xk, xd, b), yk, yd, Node(Black, c, zk, zd, d))
    | (Node(Red, a, xk, xd, Node(Red, b, yk, yd, c)), zk, zd, d) =>
        Node(Red, Node(Black, a, xk, xd, b), yk, yd, Node(Black, c, zk, zd, d))
    | _ =>
        Node(Black, l, xk, xd, r)
}

@private fun balance_right(l: ('k, 'd) tree_t, xk: 'k, xd: 'd, r: ('k, 'd) tree_t)
{
    | (a, xk, xd, Node(Red, Node(Red, b, yk, yd, c), zk, zd, d)) =>
        Node(Red, Node(Black, a, xk, xd, b), yk, yd, Node(Black, c, zk, zd, d))
    | (a, xk, xd, Node(Red, b, yk, yd, Node(Red, c, zk, zd, d))) =>
        Node(Red, Node(Black, a, xk, xd, b), yk, yd, Node(Black, c, zk, zd, d))
    | _ =>
        Node(Black, l, xk, xd, r)
}

@private fun blackify(t: ('k, 'd) tree_t)
{
    | Node(Red, l, xk, xd, r) => (Node(Black, l, xk, xd, r), false)
    | _ => (t, true)
}

@private fun add_(t: ('k, 'd) tree_t, xk: 'k, xd: 'd, cmp: 'k cmp_t): ('k, 'd) tree_t
{
    fun add_to_tree_(t: ('k, 'd) tree_t, xk: 'k, xd: 'd, cmp: 'k cmp_t): ('k, 'd) tree_t =
    match t
    {
        | Node(Red, l, yk, yd, r) =>
            val c = cmp(xk, yk)
            if c < 0 { Node(Red, add_to_tree_(l, xk, xd, cmp), yk, yd, r) }
            else if c > 0 { Node(Red, l, yk, yd, add_to_tree_(r, xk, xd, cmp)) }
            else { Node(Red, l, xk, xd, r) }
        | Node(Black, l, yk, yd, r) =>
            val c = cmp(xk, yk)
            if c < 0 { balance_left(add_to_tree_(l, xk, xd, cmp), yk, yd, r) }
            else if c > 0 { balance_right(l, yk, yd, add_to_tree_(r, xk, xd, cmp)) }
            else { Node(Black, l, xk, xd, r) }
        | _ => Node(Red, (Empty: ('k, 'd) tree_t), xk, xd, (Empty: ('k, 'd) tree_t))
    }
    blackify(add_to_tree_(t, xk, xd, cmp)).0
}

fun add(m: ('k, 'd) Map.t, xk: 'k, xd: 'd): ('k, 'd) Map.t
{
    val new_root = add_(m.root, xk, xd, m.cmp)
    t { root=new_root, cmp=m.cmp }
}

@private fun update_(t: ('k, 'd) tree_t, xk: 'k, f: ('k, 'd?) -> 'd, cmp: 'k cmp_t): ('k, 'd) tree_t =
match t
{
    | Node(Red, l, yk, yd, r) =>
        val c = cmp(xk, yk)
        if c < 0 { Node(Red, update_(l, xk, f, cmp), yk, yd, r) }
        else if c > 0 { Node(Red, l, yk, yd, update_(r, xk, f, cmp)) }
        else { Node(Red, l, xk, f(xk, Some(yd)), r) }
    | Node(Black, l, yk, yd, r) =>
        val c = cmp(xk, yk)
        if c < 0 { balance_left(update_(l, xk, f, cmp), yk, yd, r) }
        else if c > 0 { balance_right(l, yk, yd, update_(r, xk, f, cmp)) }
        else { Node(Black, l, xk, f(xk, Some(yd)), r) }
    | _ =>
        Node(Red, (Empty: ('k, 'd) tree_t), xk,
            f(xk, (None : 'd?)), (Empty: ('k, 'd) tree_t))
}

fun update(m: ('k, 'd) Map.t, xk: 'k, f: ('k, 'd?) -> 'd): ('k, 'd) Map.t
{
    val new_root = blackify(update_(m.root, xk, f, m.cmp)).0
    t { root=new_root, cmp=m.cmp }
}

@private fun unbalanced_left(t: ('k, 'd) tree_t): (('k, 'd) tree_t, bool) =
match t
{
    | Node(Red, Node(Black, a, xk, xd, b), yk, yd, c) =>
        (balance_left(Node(Red, a, xk, xd, b), yk, yd, c), false)
    | Node(Black, Node(Black, a, xk, xd, b), yk, yd, c) =>
        (balance_left(Node(Red, a, xk, xd, b), yk, yd, c), true)
    | Node(Black, Node(Red, a, xk, xd, Node(Black, b, yk, yd, c)), zk, zd, d) =>
        (Node(Black, a, xk, xd, balance_left(Node(Red, b, yk, yd, c), zk, zd, d)), false)
    | _ => throw MapError
}

@private fun unbalanced_right(t: ('k, 'd) tree_t): (('k, 'd) tree_t, bool) =
match t
{
    | Node(Red, a, xk, xd, Node(Black, b, yk, yd, c)) =>
        (balance_right(a, xk, xd, Node(Red, b, yk, yd, c)), false)
    | Node(Black, a, xk, xd, Node(Black, b, yk, yd, c)) =>
        (balance_right(a, xk, xd, Node(Red, b, yk, yd, c)), true)
    | Node(Black, a, xk, xd, Node(Red, Node(Black, b, yk, yd, c), zk, zd, d)) =>
        (Node(Black, balance_right(a, xk, xd, Node(Red, b, yk, yd, c)), zk, zd, d), false)
    | _ => throw MapError
}

@private fun remove_min(t: ('k, 'd) tree_t): (('k, 'd) tree_t, 'k, 'd, bool)
{
    | Node(Black, Empty, xk, xd, Empty) => (Empty, xk, xd, true)
    | Node(Black, Empty, xk, xd, Node(Red, l, yk, yd, r)) =>
        (Node(Black, l, yk, yd, r), xk, xd, false)
    | Node(Red, Empty, xk, xd, r) =>
        (r, xk, xd, false)
    | Node(Black, l, xk, xd, r) =>
        val (l, yk, yd, d) = remove_min(l)
        val s = Node(Black, l, xk, xd, r)
        if d {
            val (s, d) = unbalanced_right(s)
            (s, yk, yd, d)
        } else {
            (s, yk, yd, false)
        }
    | Node(Red, l, xk, xd, r) =>
        val (l, yk, yd, d) = remove_min(l)
        val s = Node(Red, l, xk, xd, r)
        if d {
            val (s, d) = unbalanced_right(s)
            (s, yk, yd, d)
        } else {
            (s, yk, yd, false)
        }
    | _ => throw MapError
}

@private fun remove_(t: ('k, 'd) tree_t, xk: 'k, cmp: 'k cmp_t): (('k, 'd) tree_t, bool) =
match t
{
    | Node(Black, l, yk, yd, r) =>
        val c = cmp(xk, yk)
        if c < 0 {
            val (l, d) = remove_(l, xk, cmp)
            val s = Node(Black, l, yk, yd, r)
            if d { unbalanced_right(s) } else { (s, false) }
        } else if c > 0 {
            val (r, d) = remove_(r, xk, cmp)
            val s = Node(Black, l, yk, yd, r)
            if d { unbalanced_left(s) } else { (s, false) }
        } else {
            match r {
            | Empty =>
                val (l1, d) = blackify(l)
                (l1, d)
            | _ =>
                val (r, yk, yd, d) = remove_min(r)
                val s = Node(Black, l, yk, yd, r)
                if d { unbalanced_left(s) } else { (s, false) }
            }
        }
    | Node(Red, l, yk, yd, r) =>
        val c = cmp(xk, yk)
        if c < 0 {
            val (l, d) = remove_(l, xk, cmp)
            val s = Node(Red, l, yk, yd, r)
            if d { unbalanced_right(s) } else { (s, false) }
        } else if c > 0 {
            val (r, d) = remove_(r, xk, cmp)
            val s = Node(Red, l, yk, yd, r)
            if d { unbalanced_left(s) } else { (s, false) }
        } else {
            match r {
            | Empty => (l, false)
            | _ =>
                val (r, yk, yd, d) = remove_min(r)
                val s = Node(Red, l, yk, yd, r)
                if d { unbalanced_left(s) } else { (s, false) }
            }
        }
    | _ =>
        (Empty, false)
}

fun remove(m: ('k, 'd) Map.t, xk: 'k)
{
    val (new_root, _) = remove_(m.root, xk, m.cmp)
    t { root=new_root, cmp=m.cmp }
}

fun foldl(m: ('k, 'd) Map.t, f: ('k, 'd, 'r) -> 'r, res0: 'r)
{
    fun update_(t: ('k, 'd) tree_t, f: ('k, 'd, 'r) -> 'r, res: 'r): 'r =
    match t {
        | Node(_, l, xk, xd, r) => update_(r, f, f(xk, xd, update_(l, f, res)))
        | _ => res
    }
    update_(m.root, f, res0)
}

fun foldr(m: ('k, 'd) Map.t, f: ('k, 'd, 'r) -> 'r, res0: 'r): 'r
{
    fun update_(t: ('k, 'd) tree_t, f: ('k, 'd, 'r) -> 'r, res: 'r): 'r =
    match t {
        | Node(_, l, xk, xd, r) => update_(l, f, f(xk, xd, update_(r, f, res)))
        | _ => res
    }
    update_(m.root, f, res0)
}

fun app(m: ('k, 'd) Map.t, f: ('k, 'd) -> void): void
{
    fun app_(t: ('k, 'd) tree_t, f: ('k, 'd) -> void): void =
    match t {
        | Node(_, l, xk, xd, r) => app_(l, f); f(xk, xd); app_(r, f)
        | _ => {}
    }
    app_(m.root, f)
}

// similar to foldr, but does a specific task - constructs the list of results
fun map(m: ('k, 'd) Map.t, f: ('k, 'd) -> 'r): 'res list
{
    fun update_list_(t: ('k, 'd) tree_t, f: ('k, 'd) -> 'r, res: 'r list): 'r list =
    match t {
        | Node(_, l, xk, xd, r) =>
            update_list_(l, f, f(xk, xd) :: update_list_(r, f, res))
        | _ => res
    }
    update_list_(m.root, f, [])
}

fun filter(m: ('k, 'd) Map.t, f: ('k, 'd) -> bool): ('k, 'd) Map.t
{
    fun filter_(t: ('k, 'd) tree_t, f: ('k, 'd) -> bool,
                cmp: 'k cmp_t, res: ('k, 'd) tree_t): ('k, 'd) tree_t =
    match t {
        | Node(_, l, xk, xd, r) =>
            val res = filter_(l, f, cmp, res)
            val res = if f(xk, xd) { add_(res, xk, xd, cmp) } else { res }
            filter_(r, f, cmp, res)
        | _ => res
    }
    val new_root = filter_(m.root, f, m.cmp, Empty)
    t {root=new_root, cmp=m.cmp}
}

fun add_list(m: ('k, 'd) Map.t, l: ('k, 'd) list)
{
    val cmp = m.cmp
    val fold new_root=m.root for (xk, xd) <- l {
        add_(new_root, xk, xd, cmp)
    }
    t {root=new_root, cmp=cmp}
}

fun from_list(cmp: 'k cmp_t, l: ('k, 'd) list): ('k, 'd) Map.t =
    add_list((empty(cmp) : ('k, 'd) Map.t), l)

fun list(m: ('k, 'd) Map.t): ('k, 'd) list
{
    fun update_list_(t: ('k, 'd) tree_t, res: ('k, 'd) list): ('k, 'd)  list =
    match t {
        | Node(_, l, xk, xd, r) =>
            update_list_(l, (xk, xd) :: update_list_(r, res))
        | _ => res
    }
    update_list_(m.root, [])
}
