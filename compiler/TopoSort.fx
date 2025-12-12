import Ast

type dep_graph_t = (int, int list) list

fun toposort(graph: dep_graph_t): int list
{
    //print("before toposort: ")
    //println([::for (i, _) <- graph {(Ast.pp(Ast.get_module_name(i)), i)}])
    val graph = [for (_, deps) <- graph {deps}], nvtx = size(graph)
    val processed = array(nvtx, false)
    var result: int list = []

    fun dfs(i: int, visited: int list) {
        val deps = graph[i]
        if visited.mem(i) {
            val vlist = ", ".join([::for j <- visited { Ast.pp(Ast.get_module_name(j)) }])
            throw Fail(f"error: cyclib dependency between the modules: {vlist}")
        }
        val visited = i :: visited
        for j <- deps {
            if processed[j] {continue}
            dfs(j, visited)
        }
        result = i :: result
        processed[i] = true
    }

    for i <- 0:nvtx {
        if processed[i] { continue }
        dfs(i, [])
    }

    result.rev()
}
