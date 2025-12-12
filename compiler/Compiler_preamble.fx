import Options, Lexer, Filename, Ast, List

val preamble_list = [:: 
    ("Builtins", true),
    ("Math", true),
    ("Complex", true),
    ("Array", true),
    ("List", false),
    ("Vector", false),
    ("Char", false),
    ("String", false),
]

fun get_preamble(mfname: string): Lexer.token_t list {
    val preamble =
    if Options.opt.use_preamble {
        val bare_name = Filename.remove_extension(Filename.basename(mfname))
        val (preamble, _) = fold (preamble, found) = (([] : Lexer.token_t list), false)
            for (mname, from_import) <- preamble_list {
            if found {
                (preamble, found)
            } else if bare_name == mname {
                (preamble, true)
            } else if from_import {
                // 'from <mname> import *;'
                (preamble + [:: Lexer.FROM, Lexer.IDENT(true, mname), Lexer.IMPORT(false), Lexer.STAR(true), Lexer.SEMICOLON], false)
            } else {
                // import <mname>;
                (preamble + [:: Lexer.IMPORT(true), Lexer.IDENT(true, mname), Lexer.SEMICOLON], false)
            }
        }
        preamble
    } else { [] }
    fold p=preamble for (n, v) <- Options.opt.defines {
        val v = match v {
        | Options.OptBool(b) => Ast.LitBool(b)
        | Options.OptInt(i) => Ast.LitInt(int64(i))
        | Options.OptString(s) => Ast.LitString(s)
        }
        Lexer.PP_DEFINE :: Lexer.IDENT(true, n) :: Lexer.LITERAL(v) :: p
    }
}
