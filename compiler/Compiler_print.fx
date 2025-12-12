import Sys, Ast

val pr_verbose = Ast.pr_verbose
val iscolorterm = Sys.colorterm()

type msgcolor_t = MsgRed | MsgGreen | MsgBlue
fun clrmsg(clr: msgcolor_t, msg: string)
{
    if iscolorterm {
        val esc = match clr {
            | MsgRed => "\33[31;1m"
            | MsgGreen => "\33[32;1m"
            | MsgBlue => "\033[34;1m"
            | _ => ""
        }
        f"{esc}{msg}\33[0m"
    } else {
        msg
    }
}

val error = clrmsg(MsgRed, "error")

fun prf(str: string) = pr_verbose(f"\t{str}")

