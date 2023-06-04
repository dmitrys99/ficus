/*
    This file is a part of ficus language project.
    See ficus/LICENSE for the licensing terms
*/

// Ficus lexer/tokenizer

import Hashmap
import Ast
import LexerUtils as Lxu
import Filename

type lloc_t = Lxu.lloc_t
type stream_t = Lxu.stream_t

// Ficus tokens
type token_t =
    | LITERAL: Ast.lit_t | IDENT: (bool, string) | TYVAR: string
    | APOS | AS | AT | BREAK | CATCH | CCODE | CLASS | CONTINUE
    | DO | DATA: string | ELLIPSIS | ELSE | EXCEPTION | FINALLY
    | FOLD | FOR: bool | FROM | FUN | IF | IMPORT: bool
    | INLINE | INTERFACE | MATCH | NOTHROW | OPERATOR
    | PARALLEL | PRAGMA | PRIVATE | PURE | REF: bool | RETURN: bool
    | THROW | TRY | TYPE | VAL | VAR | WHEN | WITH | WHILE: bool
    | UNZIP | LPAREN: bool | STR_INTERP_LPAREN | RPAREN
    | LSQUARE: bool | RSQUARE | LBRACE | RBRACE | COMMA | DOT
    | SEMICOLON | COLON | BAR | CONS | CAST | BACKSLASH: bool
    | BACK_ARROW | DOUBLE_ARROW | ARROW | QUESTION | EOF | MINUS: bool
    | PLUS: bool | STAR: bool | SLASH | SYNC | PERCENT | POWER | DOT_STAR
    | DOT_PLUS: bool | DOT_MINUS: bool | DOT_SLASH | DOT_PERCENT | DOT_POWER
    | SHIFT_RIGHT | SHIFT_LEFT | BITWISE_AND | BITWISE_XOR | BITWISE_OR
    | TILDE | LOGICAL_AND | LOGICAL_OR | LOGICAL_NOT | EQUAL
    | DOT_EQUAL | AUG_BINOP: Ast.binary_t | SPACESHIP | CMP: Ast.cmpop_t
    | DOT_SPACESHIP | DOT_CMP: Ast.cmpop_t | SAME | RESERVED: string
    | PP_IF | PP_IFDEF | PP_IFNDEF | PP_ELIF | PP_ELSE
    | PP_ENDIF | PP_DEFINE | PP_UNDEF | PP_ERROR | PP_WARNING

fun ne2u(ne: bool, s: string) = if ne {s} else {s.decapitalize()}

fun tok2str(t: token_t)
{
    | LITERAL(l) => (f"LITERAL({Ast.lit2str(l)})", Ast.lit2str(l))
    | IDENT(ne, s) => (ne2u(ne, f"IDENT({s})"), s)
    | TYVAR(s) => (f"TYVAR({s})", s)
    | APOS => ("APOS", "'")
    | AS => ("AS", "as")
    | AT => ("AT", "@")
    | BREAK => ("BREAK", "break")
    | CATCH => ("CATCH", "catch")
    | CCODE => ("CCODE", "@ccode")
    | CLASS => ("CLASS", "class")
    | CONTINUE => ("CONTINUE", "continue")
    | DATA kind => (f"DATA(kind)", "@data(kind)")
    | DO => ("DO", "do")
    | ELLIPSIS => ("ELLIPSIS", "...")
    | ELSE => ("ELSE", "else")
    | EXCEPTION => ("EXCEPTION", "exception")
    | FINALLY => ("FINALLY", "finally")
    | FOLD => ("FOLD", "fold")
    | FOR(ne) => (ne2u(ne, "FOR"), "for")
    | FROM => ("FROM", "from")
    | FUN => ("FUN", "fun")
    | IF => ("IF", "if")
    | IMPORT(ne) => (ne2u(ne, "IMPORT"), "import")
    | INLINE => ("INLINE", "@inline")
    | INTERFACE => ("INTERFACE", "interface")
    | MATCH => ("MATCH", "match")
    | NOTHROW => ("NOTHROW", "@nothrow")
    | OPERATOR => ("OPERATOR", "operator")
    | PARALLEL => ("PARALLEL", "@parallel")
    | PRAGMA => ("PRAGMA", "pragma")
    | PRIVATE => ("PRIVATE", "@private")
    | PURE => ("PURE", "@pure")
    | REF(ne) => (ne2u(ne, "REF"), "ref")
    | RETURN(false) => ("RETURN", "return")
    | RETURN(true) => ("RETURN_WITH", "return_with")
    | SYNC => ("SYNC", "@sync")
    | THROW => ("THROW", "throw")
    | TRY => ("TRY", "try")
    | TYPE => ("TYPE", "type")
    | VAL => ("VAL", "val")
    | VAR => ("VAR", "var")
    | WHEN => ("WHEN", "when")
    | WITH => ("WITH", "with")
    | WHILE(ne) => (ne2u(ne, "WHILE"), "while")
    | UNZIP => ("UNZIP", "@unzip")
    | LPAREN(ne) => (ne2u(ne, "LPAREN"), "(")
    | STR_INTERP_LPAREN => ("STR_INTERP_LPAREN", "<str_interp>{")
    | RPAREN => ("RPAREN", ")")
    | LSQUARE(ne) => (ne2u(ne, "LSQUARE"), "[")
    | RSQUARE => ("RSQUARE", "]")
    | LBRACE => ("LBRACE", "{")
    | RBRACE => ("RBRACE", "}")
    | COMMA => ("COMMA", ",")
    | DOT => ("DOT", ".")
    | SEMICOLON => ("SEMICOLON", ";")
    | COLON => ("COLON", ":")
    | BAR => ("BAR", "|")
    | CONS => ("CONS", "::")
    | CAST => ("CAST", ":>")
    | BACKSLASH(ne) => (ne2u(ne, "BACKSLASH"), "\\")
    | ARROW => ("ARROW", "->")
    | BACK_ARROW => ("BACK_ARROW", "<-")
    | DOUBLE_ARROW => ("DOUBLE_ARROW", "=>")
    | QUESTION => ("QUESTION", "?")
    | EOF => ("EOF", "<EOF>")
    | MINUS(ne) => (ne2u(ne, "MINUS"), "-")
    | PLUS(ne) => (ne2u(ne, "PLUS"), "+")
    | STAR(ne) => (ne2u(ne, "STAR"), "*")
    | SLASH => ("SLASH", "/")
    | PERCENT => ("PERCENT", "%")
    | POWER => ("POWER", "**")
    | DOT_PLUS(ne) => (ne2u(ne, "DOT_PLUS"), ".+")
    | DOT_MINUS(ne) => (ne2u(ne, "DOT_MINUS"), ".-")
    | DOT_STAR => ("DOT_STAR", ".*")
    | DOT_SLASH => ("DOT_SLASH", "./")
    | DOT_PERCENT => ("DOT_PERCENT", ".%")
    | DOT_POWER => ("DOT_POWER", ".**")
    | SHIFT_LEFT => ("SHIFT_LEFT", "<<")
    | SHIFT_RIGHT => ("SHIFT_RIGHT", ">>")
    | BITWISE_AND => ("BITWISE_AND", "&")
    | BITWISE_XOR => ("BITWISE_XOR", "^")
    | BITWISE_OR => ("BITWISE_OR", "|")
    | TILDE => ("TILDE", "~")
    | LOGICAL_AND => ("LOGICAL_AND", "&&")
    | LOGICAL_OR => ("LOGICAL_OR", "||")
    | LOGICAL_NOT => ("LOGICAL_NOT", "!")
    | EQUAL => ("EQUAL", "=")
    | DOT_EQUAL => ("DOT_EQUAL", ".=")
    | AUG_BINOP(o) => (f"AUG_BINOP({o})", f"{o}=")
    | SPACESHIP => ("SPACESHIP", "<=>")
    | CMP(c) => (f"CMP({c})", string(c))
    | DOT_SPACESHIP => ("DOT_SPACESHIP", ".<=>")
    | DOT_CMP(c) => (f"DOT_CMP({c})", f".{c}")
    | SAME => ("SAME", "===")
    | RESERVED(s) => val r = f"<reserved({s})>"; (r, r)
    | PP_IF => ("PP_IF", "@IF")
    | PP_IFDEF => ("PP_IFDEF", "@IFDEF")
    | PP_IFNDEF => ("PP_IFNDEF", "@IFNDEF")
    | PP_ELIF => ("PP_ELIF", "@ELIF")
    | PP_ELSE => ("PP_ELSE", "@ELSE")
    | PP_ENDIF => ("PP_ENDIF", "@ENDIF")
    | PP_DEFINE => ("PP_DEFINE", "@DEFINE")
    | PP_UNDEF => ("PP_UNDEF", "@UNDEF")
    | PP_ERROR => ("PP_ERROR", "@ERROR")
    | PP_WARNING => ("PP_WARNING", "@WARNING")
}

fun getnumber(s: string, pos: int, loc: lloc_t, just_int: bool): (int, (token_t, char)) =
    try {
        val (pos1, i, f, bits, c) = Lxu.getnumber(s, pos, just_int, true)
        (pos1, match (c, bits) {
        | ('i', 128) => (LITERAL(Ast.LitString(s[pos:pos1-1])), 'l')
        | ('i', 0) => (LITERAL(Ast.LitInt(i)), 'i')
        | ('i', _) => (LITERAL(Ast.LitSInt(bits, i)), 's')
        | ('u', _) => (LITERAL(Ast.LitUInt(bits, uint64(i))), 'u')
        | ('f', _) => (LITERAL(Ast.LitFloat(bits, f)), 'f')
        | (c, _) => throw Lxu.LexerError(loc, f"unknown type '{c}' of numeric literal")
        })
    } catch {
        | OverflowError => throw Lxu.LexerError(loc, "too long numeric literal")
        | OutOfRangeError =>
            throw Lxu.LexerError(loc, "the numeric literal is out of range for the specified type")
        | BadArgError =>
            throw Lxu.LexerError(loc, "invalid i/u suffix (should be 8, 16, 32 or 64)")
        | e =>
            throw Lxu.LexerError(loc, f"exception {e} occured when parsing numeric literal")
    }

/*
    Ficus keywords, represented as string -> (token, kwtyp) dictionary, where kwtyp is:
    0 - keyword that represents a single-keyword expression
        (well, 'operator' is not a single-keyword expression,
        but from lexer/parser perspective it behaves as if it was).
    1 - a keyword that cannot start a new expression, but
        it links the previous part of expression with the subsequent one;
        so it can immediately follow expression (be placed on the same line),
        e.g. "else" in if-then expression
    2 - a keyword that starts a new expression; it cannot follow another expression
        without some explicit operator or a separator (';' or a newline) in between.
        Note that sometimes several such keywords are used together,
        e.g. pure nothrow fun foo(x: int) = ...
    3 - a keyword that can play a role of a connector (type 1)
        or an expression beginning (type 2), depending on context
   -1 - reserved/internal-use keyword.
*/
var ficus_keywords = Hashmap.from_list("", (FUN, 0),
    [:: ("as", (AS, 1)), ("break", (BREAK, 0)), ("catch", (CATCH, 1)),
    ("class", (CLASS, 2)), ("continue", (CONTINUE, 0)), ("do", (DO, 2)),
    ("else", (ELSE, 1)), ("exception", (EXCEPTION, 2)),
    ("false", (LITERAL(Ast.LitBool(false)), 0)), ("finally", (FINALLY, 1)),
    ("fold", (FOLD, 2)), ("for", (FOR(true), 2)), ("from", (FROM, 2)),
    ("fun", (FUN, 2)), ("inf", (LITERAL(Ast.LitFloat(64, inf)), 0)),
    ("inff", (LITERAL(Ast.LitFloat(32, inf)), 0)),
    ("if", (IF, 2)), ("import", (IMPORT(true), 3)), ("interface", (INTERFACE, 2)),
    ("match", (MATCH, 2)), ("nan", (LITERAL(Ast.LitFloat(64, nan)), 0)),
    ("nanf", (LITERAL(Ast.LitFloat(32, nan)), 0)),
    ("null", (LITERAL(Ast.LitNull), 0)), ("operator", (OPERATOR, 0)),
    ("pragma", (PRAGMA, 2)), ("ref", (REF(true), 3)),
    ("return", (RETURN(false), 2)), ("throw", (THROW, 2)),
    ("true", (LITERAL(Ast.LitBool(true)), 0)), ("try", (TRY, 2)),
    ("type", (TYPE, 2)), ("val", (VAL, 2)), ("var", (VAR, 2)),
    ("when", (WHEN, 1)), ("while", (WHILE(true), 2)), ("with", (WITH, 1)),
    ("__fold_result__", (RESERVED("__fold_result__"), -1)),
    ("__lambda__", (RESERVED("__lambda__"), -1)),
    ("__kwargs__", (RESERVED("__kwargs__"), -1)),
    ("__pat__", (RESERVED("__pat__"), -1)),
    ("@ccode", (CCODE, 2)),  ("@data", (DATA("binary"), 2)),
    ("@data_le", (DATA("binary_le"), 2)), ("@data_be", (DATA("binary_be"), 2)),
    ("@inline", (INLINE, 2)), ("@nothrow", (NOTHROW, 2)),
    ("@parallel", (PARALLEL, 2)),  ("@private", (PRIVATE, 2)),
    ("@sync", (SYNC, 1)), ("@text", (DATA("text"), 2)),
    ("@pure", (PURE, 2)),  ("@unzip", (UNZIP, 2)),
    ("@if", (PP_IF, 2)), ("@ifdef", (PP_IFDEF, 2)), ("@ifndef", (PP_IFNDEF, 2)),
    ("@elif", (PP_ELIF, 1)), ("@else", (PP_ELSE, 1)), ("@endif", (PP_ENDIF, 3)),
    ("@define", (PP_DEFINE, 2)), ("@undef", (PP_UNDEF, 2)),
    ("@error", (PP_ERROR, 2)), ("@warning", (PP_WARNING, 2))
    ])

/*  The function that returns the actual tokenizer/lexer function,
    a closure with all the necessary parameters inside.

    Probably, later on this functional construction should be
    replaced with a class and methods.

    The nested/returned tokenizer function returns the "next" token on each
    call. In fact, on each call it may return several tokens, e.g.

    println(f"x={x}")
    is parsed as

    IDENT("println") LPAREN { LPAREN STRING("x=") PLUS }
        { IDENT("string") LPAREN IDENT(x) RPAREN PLUS }
        { STRING("") RPAREN } RPAREN
    where {} denotes groups that are returned together by nexttokens().
*/
fun make_lexer(strm: stream_t): (void -> (token_t, lloc_t) list)
{
    var new_exp = true  // Ficus is the language with optional ';' separators between
                        // expressions in a block, tha's why we need to distinguish
                        // between unary and binary operators that look the same (+, -, *),
                        // between function calls and tuple expressions etc.
                        // The 'new expression' flag helps with that.
                        // It's set to true by ';', a newline characters and
                        // many of the operators/keywords.
                        // It's set to false after an identifier, a literal,
                        // a closing paren or one of a few operators/keywords.

    var paren_stack = []
                        // Another helper data structure
                        // that adds some context information to
                        // a primitive finite state machine that
                        // the lexer should have been in theory.
                        // It does not only contain a stack of so-far opened
                        // and not closd yet parens, but also
                        // some other selected tokens, such as CCODE, MATCH, CATCH etc.

    var pos = strm.bol  // The current position that is automatically updated after each call.
                        // Want to retrieve the position? Each returned token is supplied with
                        // with a tuple (begin_lineno, begin_col, end_lineno, end_col)
                        // describing where it was captured.
                        // Want to reset position or scan the particular fragment of code?
                        // Just create a new lexer with the same string
                        // or its substring of interest - it's a cheap operation.
    var prev_dot = false
    var backquote_pos = -1
    var backquote_loc = (0, 0)
    var fmt: format_t? = None

    fun getloc(pos: int) = (strm.lineno, max(pos - strm.bol, 0) + 1)
    fun addloc(loc: lloc_t, tokens: token_t list) = [:: for t <- tokens {(t, loc)} ]
    fun check_ne(ne: bool, loc: lloc_t, name: string): void =
        if !ne {
            throw Lxu.LexerError(loc, f"unexpected '{name}'. Insert ';' or newline")
        }
    fun lloc2str(l: lloc_t) {
        val colspec = if l.1 == 1 {""} else {f":{l.1}"}
        f"{strm.fname}:{l.0}{colspec}"
    }

    fun get_ccode(p: int): (int, string)
    {
        val buf = strm.buf
        val len = buf.length()
        var lbraces = 1, q = p
        // This implementation assumes that the whole buffer is available.
        // We just find the position q of terminating '}' of the inline C code
        // and then capture the whole thing between '{' (at p), i.e. buf[p:q].
        // If we ever switch to per-line buffer, the code needs to be updated
        // to accumuate C code into some text string
        while q < len {
            var c = buf.zero[q]
            var c1 = buf.zero[q+1]
            if (c == '/' && (c1 == '/' || c1 == '*')) || c == '\n' || c == '\r' {
                q = Lxu.skip_spaces(strm, q, false).1
            } else if c == '"' || c == '\'' { // "
                val (q_, _, dl, _) = Lxu.getstring(buf, q+1, getloc(q+1), c, true, false)
                strm.lineno += dl
                q = q_
            } else {
                q += 1
                match c {
                | '{' => lbraces += 1
                | '}' =>
                    lbraces -= 1
                    if lbraces == 0 {break}
                | _ => {}
                }
            }
        }
        if lbraces > 0 {throw Lxu.LexerError(getloc(p), "unterminated ccode block (check braces)")}
        (q, buf[p:q-1].copy())
    }

    fun fmt2tokens(fmt: format_t?, loc: lloc_t): (token_t, lloc_t) list
    {
        fun add_pair(attrname: string, x: 't, defval: 't, attrval: Ast.lit_t, tl: token_t list) =
            if x == defval {tl} else {[:: IDENT(true, attrname), EQUAL, LITERAL(attrval), COMMA] + tl}
        match fmt {
        | Some(format_t {fill, align, sign, num_alt, width, precision, grouping, typ}) =>
            val params = add_pair("typ", typ, ' ', Ast.LitChar(typ), [])
            val params = add_pair("grouping", grouping, ' ', Ast.LitChar(grouping), params)
            val params = add_pair("precision", precision, -1, Ast.LitInt(int64(precision)), params)
            val params = add_pair("width", width, 0, Ast.LitInt(int64(width)), params)
            val params = add_pair("num_alt", num_alt, false, Ast.LitBool(num_alt), params)
            val params = add_pair("sign", sign, '-', Ast.LitChar(sign), params)
            val params = add_pair("align", align, '-', Ast.LitChar(align), params)
            val params = add_pair("fill", fill, ' ', Ast.LitChar(fill), params)
            if params != [] {
                addloc(loc, [:: COMMA, IDENT(true, "format_t"), LBRACE] + params + [:: RBRACE])
            } else {
                []
            }
        | _ => []
        }
    }

    fun nexttokens(): (token_t, lloc_t) list
    {
        val buf = strm.buf
        val len = buf.length()
        var c = buf.zero[pos]
        var c1 = buf.zero[pos+1]
        if c.isspace() ||
            (c == '/' && (c1 == '/' || c1 == '*')) {
            val (c_, p, nl) = Lxu.skip_spaces(strm, pos, true)
            c = c_
            if nl {
                /* If we met a newline character during the whitespace
                   and comments scan, we set the 'new expression' flag,
                   which helps to distinguish between unary '-' and
                   the binary one, array comprehension from array
                   access operator etc.

                   We do it unless we are inside square or round parentheses.

                   This is because inside those parens it's all one expression
                   anyway. Whereas at the top level or inside curly braces
                   there can be multiple expressions, separated by a new line.
                */
                match paren_stack {
                | (LPAREN _, _) :: _ | (LSQUARE _, _) :: _ => {}
                | _ => new_exp = true
                }
            }
            pos = p
            c1 = buf.zero[pos+1]
        }

        val loc = getloc(pos)

        if '0' <= c <= '9' {
            val (p, (t, c)) = getnumber(buf, pos, loc, prev_dot)
            new_exp = false
            prev_dot = false
            pos = p
            if c == 'l' {
                [:: (IDENT(true, "long"), loc), (LPAREN(false), loc), (t, loc), (RPAREN, loc)]
            } else {
                [:: (t, loc)]
            }
        }
        /*
            single-quote (apostrophe) symbol is used in multiple cases:
            - as matrix transposition operator, e.g. val C = A'*B
            - as a type varible prefix in generic type/function definition,
              e.g. fun foo(a: 'elem_type [+]) { ... }
            - to enclose character literals, e.g. '好'

            therefore, we need to carefully order the checks
            to correctly classify each use case.
        */
        else if c == '\'' && !new_exp {
            prev_dot = false
            pos += 1
            [:: (APOS, loc)]
        } else if c == '\'' && c1.isalpha() && buf.zero[pos+2] != '\'' {
            var p = pos+1
            while p < len {
                val cp = buf[p]
                if !cp.isalnum() && cp != '_' {break}
                p += 1
            }
            val tyvar = buf[pos:p].copy()
            pos = p
            new_exp = false
            prev_dot = false
            [:: (TYVAR(tyvar), loc)]
        } else if c == '"' || c == '\'' || ((c == 'f' || c == 'r') && c1 == '"') {
            val termpos = if c == 'f' || c == 'r' {pos+1} else {pos}
            val term = buf.zero[termpos]
            val (p, res, dl, inline_exp) = Lxu.getstring(buf, termpos+1, getloc(termpos+1),
                                                         term, c == 'r', c == 'f')
            val prev_pos = pos
            strm.lineno += dl
            pos = p
            new_exp = false
            prev_dot = false
            if term == '\'' {
                if res.length() != 1 {
                    throw Lxu.LexerError(getloc(pos),
                        "character literal should contain exactly one character")
                }
                [:: (LITERAL(Ast.LitChar(res[0])), loc)]
            } else if inline_exp {
                paren_stack = (STR_INTERP_LPAREN, getloc(prev_pos)) :: paren_stack
                new_exp = true
                fmt = None
                addloc(loc, (if res == "" {[:: LPAREN(true)]}
                        else {[:: LPAREN(true), LITERAL(Ast.LitString(res)), PLUS(false)]}) +
                        [:: IDENT(true, "string"), LPAREN(false)])
            } else {
                [:: (LITERAL(Ast.LitString(res)), loc)]
            }
        } else if c.isalpha() || c == '_' || (c == '@' && c1.isalpha()) {
            var p = pos+1
            while p < len {
                val cp = buf[p]
                if !cp.isalnum() && cp != '_' {break}
                p += 1
            }
            val ident = buf[pos:p].copy()
            pos = p
            prev_dot = false
            match ficus_keywords.find_opt(ident) {
            | Some((t, n)) =>
                val t = match (t, n) {
                | (CCODE, _) =>
                    check_ne(new_exp, loc, "ccode")
                    paren_stack = (CCODE, loc) :: paren_stack
                    new_exp = true; t
                | (FOR _, _) =>
                    val t = FOR(new_exp); new_exp = true; t
                | (IMPORT _, _) =>
                    val t = IMPORT(new_exp); new_exp = true; t
                | (WHILE _, _) =>
                    val t = WHILE(new_exp); new_exp = true; t
                | (MATCH, _) =>
                    paren_stack = (MATCH, loc) :: paren_stack
                    new_exp = true; t
                | (REF _, _) =>
                    val t = REF(new_exp); /* retain new_exp as-is */ t
                | (PP_ENDIF, _) =>
                    new_exp = false; t
                | (RETURN _, _) =>
                    c = buf.zero[pos]
                    c1 = buf.zero[pos+1]
                    val may_have_arg =
                        if c.isspace() ||
                            (c == '/' && (c1 == '/' || c1 == '*')) {
                            val (c_, p, nl) = Lxu.skip_spaces(strm, pos, true)
                            c = c_
                            pos = p
                            if nl {
                                match paren_stack {
                                | (LPAREN _, _) :: _ | (LSQUARE _, _) :: _ => true
                                | _ => false
                                }
                            } else {true}
                        } else {true}
                    new_exp = true
                    RETURN(may_have_arg && c != ';')
                | (t, -1) =>
                    throw Lxu.LexerError(loc, f"Identifier '{ident}' is reserved and cannot be used")
                | (t, 0) => check_ne(new_exp, loc, ident); new_exp = false; t
                | (t, 1) => new_exp = true; t
                | (t, 2) => check_ne(new_exp, loc, ident); new_exp = true; t
                | _ => throw Lxu.LexerError(loc, f"Unexpected keyword '{ident}'")
                }
                [:: (t, loc)]
            | _ =>
                if c == '@' {
                    val t = IDENT(new_exp, ident[1:]); new_exp = false
                    [:: (AT, loc), (t, getloc(pos+1))]
                } else {
                    val t = IDENT(new_exp, ident); new_exp = false; [:: (t, loc)]
                }
            }
        } else {
            val prev_ne = new_exp
            prev_dot = false
            new_exp = true
            pos = min(pos+1, len)
            val c2 = buf.zero[pos+1]
            val c3 = buf.zero[pos+2]
            match c {
            | '(' =>
                paren_stack = (LPAREN(prev_ne), getloc(pos-1)) :: paren_stack
                [:: (LPAREN(prev_ne), loc)]
            | ')' =>
                new_exp = false
                match paren_stack {
                | (LPAREN _, _) :: rest =>
                    paren_stack = rest
                    [:: (RPAREN, loc)]
                | _ =>
                    throw Lxu.LexerError(loc, "Unexpected ')', check parens")
                }
            | '[' =>
                if prev_ne && c1 == ']' {
                    pos += 1
                    [:: (LITERAL(Ast.LitEmpty), loc)]
                } else {
                    paren_stack = (LSQUARE(prev_ne), getloc(pos-1)) :: paren_stack
                    [:: (LSQUARE(prev_ne), loc)]
                }
            | ']' =>
                new_exp = false
                match paren_stack {
                | (LSQUARE _, _) :: rest =>
                    paren_stack = rest
                    [:: (RSQUARE, loc)]
                | _ =>
                    throw Lxu.LexerError(loc, "Unexpected ']', check parens")
                }
            | '{' =>
                paren_stack = (LBRACE, getloc(pos-1)) :: paren_stack
                match paren_stack {
                | (LBRACE, _) :: (CCODE, _) :: rest =>
                    new_exp = false
                    paren_stack = rest
                    val (p, s) = get_ccode(pos)
                    pos = p
                    [:: (LITERAL(Ast.LitString(s.strip())), loc)]
                | (LBRACE, l1) :: (MATCH, _) :: rest =>
                    paren_stack = (BAR, l1) :: (LBRACE, l1) :: rest
                    [:: (LBRACE, l1)]
                | _ =>
                    /*
                       call nexttokens recursively; if the next token is '|',
                       i.e. '|' goes immediately after '{', it's represented
                       as 'BAR', not 'BITWISE_OR'
                    */
                    (LBRACE, loc) :: (match nexttokens() {
                    | (BITWISE_OR, p) :: rest =>
                        paren_stack = (BAR, p) :: paren_stack
                        (BAR, p) :: rest
                    | tokens => tokens
                    })
                }
            | '}' =>
                new_exp = false
                match paren_stack {
                // handle string interpolation e.g. f"f({x})={f(x)}"
                | (STR_INTERP_LPAREN, _) :: rest =>
                    paren_stack = rest
                    val (p, s, dl, inline_exp) = Lxu.getstring(buf, pos, getloc(pos), chr(34), false, true)
                    strm.lineno += dl
                    pos = p
                    val fmt_curr = fmt
                    fmt = None

                    fmt2tokens(fmt_curr, loc) +
                    (if s == "" {[:: (RPAREN, loc)]}
                    else {[:: (RPAREN, loc), (PLUS(false), loc), (LITERAL(Ast.LitString(s)), loc)]}) +
                    (if inline_exp {
                        new_exp = true
                        paren_stack = (STR_INTERP_LPAREN, getloc(pos)) :: paren_stack
                        [:: (PLUS(false), loc), (IDENT(true, "string"), loc), (LPAREN(false), loc)]
                    } else {
                        [:: (RPAREN, loc)]
                    })
                | (BAR, _) :: (LBRACE, _) :: rest =>
                    paren_stack = rest
                    [:: (RBRACE, loc)]
                | (LBRACE, _) :: rest =>
                    paren_stack = rest
                    [:: (RBRACE, loc)]
                | _ =>
                    throw Lxu.LexerError(loc, "Unexpected '}', check parens")
                }
            | '|' =>
                if c1 == '=' {pos += 1; [:: (AUG_BINOP(Ast.OpBitwiseOr), loc)]}
                else if c1 == '|' {pos += 1; [:: (LOGICAL_OR, loc)]}
                else {
                    match paren_stack {
                    | (BAR, _) :: (LBRACE, _) :: _ => [:: (BAR, loc)]
                    | _ => [:: (BITWISE_OR, loc)]
                    }
                }
            | '+' =>
                if c1 == '=' {pos += 1; [:: (AUG_BINOP(Ast.OpAdd), loc)]}
                else {[:: (PLUS(prev_ne), loc)]}
            | '-' =>
                if c1 == '=' {pos += 1; [:: (AUG_BINOP(Ast.OpSub), loc)]}
                else if c1 == '>' {pos += 1; [:: (ARROW, loc)]}
                else if !prev_ne {[:: (MINUS(false), loc)]} else {
                    match nexttokens() {
                    | (LITERAL(Ast.LitInt(x)), _) :: rest => (LITERAL(Ast.LitInt(-x)), loc) :: rest
                    | (LITERAL(Ast.LitSInt(b, x)), _) :: rest => (LITERAL(Ast.LitSInt(b, -x)), loc) :: rest
                    | (LITERAL(Ast.LitFloat(b, x)), _) :: rest => (LITERAL(Ast.LitFloat(b, -x)), loc) :: rest
                    | ts => (MINUS(true), loc) :: ts
                    }
                }
            | '*' =>
                if c1 == '=' {pos += 1; [:: (AUG_BINOP(Ast.OpMul), loc)]}
                else if c1 == '*' && !prev_ne {pos += 1; [:: (POWER, loc)]}
                else {[:: (STAR(prev_ne), loc)]}
            | '/' =>
                if c1 == '=' {pos += 1; [:: (AUG_BINOP(Ast.OpDiv), loc)]}
                else {[:: (SLASH, loc)]}
            | '%' =>
                if c1 == '=' {pos += 1; [:: (AUG_BINOP(Ast.OpMod), loc)]}
                else {[:: (PERCENT, loc)]}
            | '=' =>
                if c1 == '=' {
                    pos += 1
                    if c2 == '=' {pos += 1; [:: (SAME, loc)]}
                    else {
                        [:: (CMP(Ast.CmpEQ), loc)]
                    }
                }
                else if c1 == '>' {pos += 1; [:: (DOUBLE_ARROW, loc)]}
                else {[:: (EQUAL, loc)]}
            | '^' =>
                if c1 == '=' {pos += 1; [:: (AUG_BINOP(Ast.OpBitwiseXor), loc)]}
                else { [:: (BITWISE_XOR, loc)] }
            | '&' =>
                if c1 == '=' {pos += 1; [:: (AUG_BINOP(Ast.OpBitwiseAnd), loc)]}
                else if c1 == '&' {pos += 1; [:: (LOGICAL_AND, loc)]}
                else {[:: (BITWISE_AND, loc)]}
            | '~' => check_ne(prev_ne, getloc(pos-1), "~"); [:: (TILDE, loc)]
            | '@' => [:: (AT, loc)]
            | '\\' => [:: (BACKSLASH(prev_ne), loc)]
            | '.' =>
                if c1 == '=' {
                    if c2 == '=' {pos += 2; [:: (DOT_CMP(Ast.CmpEQ), loc)]}
                    else {pos += 1; [:: (DOT_EQUAL, loc)]}
                } else if c1 == '!' && c2 == '=' {
                    pos += 2; [:: (DOT_CMP(Ast.CmpNE), loc)]
                } else if c1 == '<' {
                    if c2 == '=' && c3 == '>' {pos += 3; [:: (DOT_SPACESHIP, loc)]}
                    else if c2 == '=' {pos += 2; [:: (DOT_CMP(Ast.CmpLE), loc)]}
                    else {pos += 1; [:: (DOT_CMP(Ast.CmpLT), loc)]}
                } else if c1 == '>' {
                    if c2 == '=' {pos += 2; [:: (DOT_CMP(Ast.CmpGE), loc)]}
                    else {pos += 1; [:: (DOT_CMP(Ast.CmpGT), loc)]}
                } else if c1 == '+' {
                    pos += 1
                    [:: (DOT_PLUS(prev_ne), loc)]
                }  else if c1 == '-' {
                    pos += 1
                    [:: (DOT_MINUS(prev_ne), loc)]
                } else if c1 == '*' {
                    if c2 == '*' {pos += 2; [:: (DOT_POWER, loc)]}
                    else if c2 == '=' {pos += 2; [:: (AUG_BINOP(Ast.OpDotMul), loc)]}
                    else {pos += 1; [:: (DOT_STAR, loc)]}
                } else if c1 == '/' {
                    if c2 == '=' {pos += 2; [:: (AUG_BINOP(Ast.OpDotDiv), loc)]}
                    else {pos += 1; [:: (DOT_SLASH, loc)]}
                } else if c1 == '%' {
                    if c2 == '=' {pos += 2; [:: (AUG_BINOP(Ast.OpDotMod), loc)]}
                    else {pos += 1; [:: (DOT_PERCENT, loc)]}
                } else if c1 == '.' && c2 == '.' {
                    pos += 2; [:: (ELLIPSIS, loc)]
                } else {
                    prev_dot = true; [:: (DOT, loc)]
                }
            | ',' => [:: (COMMA, loc)]
            | ';' => [:: (SEMICOLON, loc)]
            | ':' =>
                match paren_stack {
                // handle string interpolation with formatting
                | (STR_INTERP_LPAREN, _) :: rest =>
                    val (fmt_, end) =
                        try { parse_format(buf, start=pos) }
                        catch { | _ =>
                            throw Lxu.LexerError(getloc(pos), "invalid format specification")
                        }
                    fmt = Some(fmt_)
                    pos = end
                    if buf.zero[pos] != '}' {
                        throw Lxu.LexerError(getloc(pos), "'}' is expected after ':...' inside interpolated expression")
                    }
                    nexttokens()
                | _ =>
                    if c1 == ':' {
                        pos += 1
                        [:: (CONS, loc)]
                    } else if c1 == '>' {
                        pos += 1
                        [:: (CAST, loc)]
                    }
                    else {
                        [:: (COLON, loc)]
                    }
                }
            | '!' =>
                if c1 == '=' {
                    pos += 1
                    [:: (CMP(Ast.CmpNE), loc)]
                }
                else {
                    check_ne(prev_ne, getloc(pos-1), "!")
                    [:: (LOGICAL_NOT, loc)]
                }
            | '?' =>
                new_exp = false
                [:: (QUESTION, loc)]
            | '<' =>
                if c1 == '=' {
                    if c2 == '>' {pos += 2; [:: (SPACESHIP, loc)]}
                    else {pos += 1; [:: (CMP(Ast.CmpLE), loc)]}
                } else if c1 == '<' {
                    if c2 == '=' {pos += 2; [:: (AUG_BINOP(Ast.OpShiftLeft), loc)]}
                    else {pos += 1; [:: (SHIFT_LEFT, loc)]}
                } else if c1 == '-' {
                    pos += 1; [:: (BACK_ARROW, loc)]
                } else {
                    [:: (CMP(Ast.CmpLT), loc)]
                }
            | '>' =>
                if c1 == '=' {
                    pos += 1; [:: (CMP(Ast.CmpGE), loc)]
                } else if c1 == '>' {
                    if c2 == '=' {pos += 2; [:: (AUG_BINOP(Ast.OpShiftRight), loc)]}
                    else {pos += 1; [:: (SHIFT_RIGHT, loc)]}
                } else {
                    [:: (CMP(Ast.CmpGT), loc)]
                }
            | '`' =>
                if backquote_pos < 0 {
                    backquote_pos = pos
                    backquote_loc = getloc(pos-1)
                    paren_stack = (LPAREN(true), backquote_loc) :: paren_stack
                    [:: (LPAREN(true), loc)]
                } else {
                    val verb = buf[backquote_pos:pos-1]
                    val endloc = getloc(pos)
                    backquote_pos = -1
                    new_exp = false
                    match paren_stack {
                    | (LPAREN _, _) :: rest =>
                        paren_stack = rest
                    | _ =>
                        throw Lxu.LexerError(loc, "Unexpected '`', check parens")
                    }
                    [::(COMMA, endloc), (LITERAL(Ast.LitString(verb)), backquote_loc), (COMMA, endloc),
                    (LITERAL(Ast.LitString(Filename.basename(strm.fname))), backquote_loc), (COMMA, endloc),
                    (LITERAL(Ast.LitInt(backquote_loc.0 :> int64)), backquote_loc), (RPAREN, endloc)]
                }
            | '\0' =>
                match paren_stack {
                | (_, l) :: _ => throw Lxu.LexerError(loc,
                    f"some braces (around {lloc2str(l)}) are not closed")
                | _ => {}
                }
                [:: (EOF, loc)]
            | _ =>
                throw Lxu.LexerError(loc, f"unrecognized character '{c}'")
            }
        }
    }
    nexttokens
}
