/*
    This file is a part of ficus language project.
    See ficus/LICENSE for the licensing terms
*/

// String operations

@ccode { #include <string.h> }

@inline fun length(s: string) = __intrin_size__(s)
@inline fun join(sep: string, strs: string []) = Builtins.join(sep, strs)
@inline fun join(sep: string, strs: string list) = Builtins.join(sep, strs)
@inline fun cmp(s1: string, s2: string) = s1 <=> s2
@pure fun copy(s: string): string = @ccode { return fx_make_str(s->data, s->length, fx_result) }

@inline fun empty(s: string): bool = __intrin_size__(s) == 0

@pure @nothrow fun startswith(s: string, prefix: string): bool
@ccode {
    int_ sz1 = s->length;
    int_ sz2 = prefix->length;
    return sz2 == 0 ? true : sz2 <= sz1 && memcmp(s->data, prefix->data,
        (size_t)(sz2*sizeof(s->data[0]))) == 0;
}

@pure @nothrow fun startswith(s: string, prefix: char): bool
@ccode { return s->length > 0 && s->data[0] == prefix; }

@pure @nothrow fun endswith(s: string, suffix: string): bool
@ccode {
    int_ sz1 = s->length;
    int_ sz2 = suffix->length;
    return sz2 == 0 ? true : sz2 <= sz1 && memcmp(s->data + (sz1 - sz2), suffix->data,
        (size_t)(sz2*sizeof(s->data[0]))) == 0;
}

@pure @nothrow fun endswith(s: string, suffix: char): bool
@ccode { return s->length > 0 && s->data[s->length-1] == suffix; }

@pure @nothrow fun find(s: string, part: string, from_pos: int): int
@ccode {
    int_ i, sz1 = s->length, sz2 = part->length, l = sz1 - sz2 + 1;
    if (sz2 == 0)
        return 0;
    for( i = (from_pos >= 0 ? from_pos : 0); i < l; i++ ) {
        if( s->data[i] == part->data[0] &&
            memcmp(s->data + i, part->data, sz2*sizeof(part->data[0])) == 0 )
            return i;
    }
    return -1;
}

@inline fun find(s: string, part: string): int = find(s, part, 0)

@pure @nothrow fun find(s: string, c: char): int
@ccode {
    int_ i, sz1 = s->length;
    for( i = 0; i < sz1; i++ )
        if( s->data[i] == c ) return i;
    return -1;
}

@pure @nothrow fun find(s: string, c: char, from_pos: int): int
@ccode {
    int_ i, sz1 = s->length;
    for( i = (from_pos >= 0 ? from_pos : 0); i < sz1; i++ )
        if( s->data[i] == c ) return i;
    return -1;
}

@pure @nothrow fun rfind(s: string, part: string, from_pos: int): int
@ccode {
    int_ sz1 = s->length, sz2 = part->length;
    int_ i = (from_pos < sz1 ? from_pos+1 : sz1) - sz2;
    if (sz2 == 0)
        return i - 1;
    for ( ; i >= 0; i--) {
        if( memcmp(s->data + i, part->data, sz2*sizeof(part->data[0])) == 0)
            break;
    }
    return i;
}

@inline fun rfind(s: string, part: string): int = rfind(s, part, s.length()-1)

@pure @nothrow fun rfind(s: string, c: char): int
@ccode {
    int_ i, sz1 = s->length;
    for( i = sz1-1; i >= 0; i-- )
        if( s->data[i] == c ) return i;
    return -1;
}

@pure @nothrow fun rfind(s: string, c: char, from_pos: int): int
@ccode {
    int_ i, sz1 = s->length;
    for( i = (from_pos < sz1 ? from_pos : sz1-1); i >= 0; i-- )
        if( s->data[i] == c ) return i;
    return -1;
}

@pure @nothrow fun contains(s: string, c: char): bool
@ccode {
    int_ i, sz = s->length;
    char_* data = s->data;

    for ( i = 0; i < sz; i++ ) {
        if (data[i] == c) return true;
    }
    return false;
}

@inline fun contains(s: string, substr: string): bool = find(s, substr) >= 0

@pure fun replace(s: string, substr: string, new_substr: string): string
@ccode {
    int_ i, j = 0, sz = s->length, sz1 = substr->length, sz2 = new_substr->length;
    int_ newsz = 0;
    if (sz == 0 || sz1 == 0) {
        fx_copy_str(s, fx_result);
        return FX_OK;
    }
    for( i = 0; i < sz; ) {
        if( i <= sz - sz1 && s->data[i] == substr->data[0] &&
            memcmp(s->data + i, substr->data, sz1*sizeof(s->data[0])) == 0 ) {
            newsz += sz2;
            i += sz1;
        } else {
            newsz++;
            i++;
        }
    }
    int fx_status = fx_make_str(0, newsz, fx_result);
    if (fx_status >= 0) {
        for( i = 0; i < sz; ) {
            if( i <= sz - sz1 && s->data[i] == substr->data[0] &&
                memcmp(s->data + i, substr->data, sz1*sizeof(s->data[0])) == 0 ) {
                if (sz2 > 0)
                    memcpy(fx_result->data + j, new_substr->data, sz2*sizeof(s->data[0]));
                j += sz2;
                i += sz1;
            } else {
                fx_result->data[j++] = s->data[i++];
            }
        }
    }
    return fx_status;
}

@pure fun tolower(s: string): string
@ccode {
    int_ i, sz = s->length;
    const char_* src = s->data;
    for (i = 0; i < sz; i++ ) {
        char_ c = src[i];
        if (fx_tolower(c) != c) break;
    }
    if (i == sz) {
        fx_copy_str(s, fx_result);
        return FX_OK;
    }
    int fx_status = fx_make_str(0, sz, fx_result);
    if( fx_status >= 0 ) {
        char_* dst = fx_result->data;
        for (int_ i = 0; i < sz; i++)
            dst[i] = fx_tolower(src[i]);
    }
    return fx_status;
}

@pure fun toupper(s: string): string
@ccode {
    int_ i, sz = s->length;
    const char_* src = s->data;
    for (i = 0; i < sz; i++ ) {
        char_ c = src[i];
        if (fx_toupper(c) != c) break;
    }
    if (i == sz) {
        fx_copy_str(s, fx_result);
        return FX_OK;
    }
    int fx_status = fx_make_str(0, sz, fx_result);
    if( fx_status >= 0 ) {
        char_* dst = fx_result->data;
        for (int_ i = 0; i < sz; i++)
            dst[i] = fx_toupper(src[i]);
    }
    return fx_status;
}

@pure fun capitalize(s: string): string
@ccode {
    int_ sz = s->length;
    const char_* src = s->data;
    if (sz == 0 || fx_toupper(src[0]) == src[0]) {
        fx_copy_str(s, fx_result);
        return FX_OK;
    }
    int fx_status = fx_make_str(0, sz, fx_result);
    if( fx_status >= 0 ) {
        char_* dst = fx_result->data;
        dst[0] = fx_toupper(src[0]);
        for (int_ i = 1; i < sz; i++)
            dst[i] = src[i];
    }
    return fx_status;
}

@pure fun decapitalize(s: string): string
@ccode {
    int_ sz = s->length;
    const char_* src = s->data;
    if (sz == 0 || fx_tolower(src[0]) == src[0]) {
        fx_copy_str(s, fx_result);
        return FX_OK;
    }
    int fx_status = fx_make_str(0, sz, fx_result);
    if( fx_status >= 0 ) {
        char_* dst = fx_result->data;
        dst[0] = fx_tolower(src[0]);
        for (int_ i = 1; i < sz; i++)
            dst[i] = src[i];
    }
    return fx_status;
}

@pure fun lstrip(s: string): string
@ccode {
    const char_* ptr = s->data;
    int_ i = 0, sz = s->length;
    for (; i < sz && fx_isspace(ptr[i]); i++)
        ;
    return fx_substr(s, i, sz, 1, 0, fx_result);
}

@pure fun rstrip(s: string): string
@ccode {
    const char_* ptr = s->data;
    int_ sz = s->length;
    for (; sz > 0 && fx_isspace(ptr[sz - 1]); sz--)
        ;
    return fx_substr(s, 0, sz, 1, 0, fx_result);
}

@pure fun strip(s: string): string
@ccode {
    const char_* ptr = s->data;
    int_ i = 0, sz = s->length;
    for (; i < sz && fx_isspace(ptr[i]); i++)
        ;
    for (; sz > i && fx_isspace(ptr[sz - 1]); sz--)
        ;
    return fx_substr(s, i, sz, 1, 0, fx_result);
}

fun tokens(s: string, f: char->bool)
{
    val fold (sl, start, sep) = ([], 0, true) for c@i <- s {
        if f(c) {
            (if sep {sl} else {s[start:i] :: sl}, start, true)
        } else {
            (sl, if sep {i} else {start}, false)
        }
    }
    (if sep {sl} else {s[start:] :: sl}).rev()
}

fun split(s: string, c: char, ~allow_empty:bool)
{
    val fold (sl, start, sep) = ([], 0, true) for ci@i <- s {
        if ci == c {
            (if sep && !allow_empty {sl} else {s[start:i] :: sl}, i+1, true)
        } else {
            (sl, if sep {i} else {start}, false)
        }
    }
    (if sep {sl} else {s[start:] :: sl}).rev()
}

@nothrow fun to_int(a: string): int?
@ccode {
    bool ok = fx_atoi(a, &fx_result->u.Some, 0);
    fx_result->tag = (int)(ok+1)
}
@nothrow fun to_double(a: string): double?
@ccode {
    bool ok = fx_atof(a, &fx_result->u.Some);
    fx_result->tag = (int)(ok+1)
}

@nothrow fun to_int_or(a: string, defval: int): int
@ccode {
    int_ result;
    bool ok = fx_atoi(a, &result, 0);
    return ok ? result : defval;
}

@nothrow fun to_double_or(a: string, defval: double): int
@ccode {
    double result;
    bool ok = fx_atof(a, &result);
    return ok ? result : defval;
}

fun num_suffix(n: int) =
    match n % 10 {
    | 1 => "st"
    | 2 => "nd"
    | 3 => "rd"
    | _ => "th"
    }

fun escaped(s: string, ~quotes: bool=true)
{
    val sn = "\\n", sr = "\\r", st = "\\t",
        ssq = "\\\'", sdq = "\\\"", ss = "\\\\", sz = "\\0"
    val q = if quotes {"\""} else {""}
    val fold (ll, verb) = (q :., 0) for c@i <- s {
        val code = ord(c)
        if code >= 40 && code != 92 { (ll, verb) }
        else {
            val (esc_s, esc) = match code {
            | 10 => (sn, true)
            | 13 => (sr, true)
            | 9 => (st, true)
            | 39 => (ssq, true)
            | 34 => (sdq, true)
            | 92 => (ss, true)
            | 0 => (sz, true)
            | _ => (sz, false)
            }
            if esc {
                val ll = esc_s :: (if i > verb {s[verb:i] :: ll} else {ll})
                (ll, i+1)
            }
            else { (ll, verb) }
        }
    }
    join("", (q :: s[verb:] :: ll).rev())
}
