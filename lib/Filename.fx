/*
    This file is a part of ficus language project.
    See ficus/LICENSE for the licensing terms
*/

@ccode {
    #include <limits.h>
    #include <stdlib.h>
    #include <stdio.h>
    #include <sys/stat.h>
#if defined WIN32 || defined _WIN32
    #include <io.h>
    #include <direct.h>
#else
    #include <glob.h>
    #include <unistd.h>
#endif
    #ifndef PATH_MAX
    #define PATH_MAX 8192
    #endif
}

@pure fun dir_sep(): string = @ccode {
    const char sep[] =
#if defined _WIN32 || defined WINCE
        {92, 0} // back slash
#else
        {47, 0} // slash
#endif
    ;
    return fx_cstr2str(sep, -1, fx_result);
}

fun is_absolute(path: string) =
    path.startswith(dir_sep()) ||
    path.startswith("/") ||
    path.find(":") >= 0

fun is_relative(path: string) = !is_absolute(path)

fun split(path: string) {
    val sep = dir_sep()
    val sep0 = "/"
    assert(sep.length() == 1)
    if path.endswith(sep) || (sep != sep0 && path.endswith(sep0)) {
        if path.length() == 1 { (sep, sep) }
        else { split(path[:.-1]) }
    } else {
        val pos = path.rfind(sep)
        val pos0 = if sep == sep0 { pos } else { path.rfind(sep0) }
        val pos = if pos < 0 {pos0} else if pos0 < 0 {pos} else {max(pos, pos0)}
        if pos < 0 {
            (".", path)
        } else if pos == 0 || path[pos-1] == ':' {
            (path[:pos+1], path[pos+1:])
        } else {
            (path[:pos], path[pos+1:])
        }
    }
}

fun dirname(path: string) = split(path).0
fun basename(path: string) = split(path).1

fun concat(dir: string, fname: string) {
    val sep = dir_sep()
    val sep0 = "/"
    if dir.endswith(sep) || dir.endswith(sep0) {
        dir + fname
    } else {
        dir + sep + fname
    }
}

fun normalize(dir: string, fname: string)
{
    val sep = dir_sep()
    val sep0 = "/"
    assert(sep.length() == 1)
    if is_absolute(fname) {
        fname
    } else if fname.startswith("." + sep) || (sep != sep0 && fname.startswith("./")) {
        normalize(dir, fname[2:])
    } else if fname.startswith(".." + sep) || (sep != sep0 && fname.startswith("../")) {
        normalize(dirname(dir), fname[3:])
    } else {
        concat(dir, fname)
    }
}

fun remove_extension(path: string) {
    val sep = dir_sep()
    val sep0 = "/"
    val dotpos = path.rfind(".")
    if dotpos < 0 {
        path
    } else {
        val pos = path.rfind(sep)
        val pos0 = if sep == sep0 { pos } else { path.rfind(sep0) }
        val pos = if pos < 0 {pos0} else if pos0 < 0 {pos} else {max(pos, pos0)}
        if dotpos <= pos+1 { path }
        else { path[:dotpos]}
    }
}

fun getcwd(): string = @ccode {
    char buf[PATH_MAX+16];
#if defined WIN32 || defined _WIN32
    char* p = _getcwd(buf, PATH_MAX);
#else
    char* p = getcwd(buf, PATH_MAX);
#endif
    return fx_cstr2str(p, (p ? -1 : 0), fx_result);
}

fun exists(name: string): bool
@ccode {
    fx_cstr_t name_;
    int fx_status = fx_str2cstr(name, &name_, 0, 0);
    if (fx_status >= 0) {
        struct stat s;
        *fx_result = stat(name_.data, &s) == 0;
        fx_free_cstr(&name_);
    }
    return fx_status;
}

// throws NotFoundError if there is no such file in specified directories
fun locate(name: string, dirs: string list): string
{
    val dir = find(for d <- dirs {exists(concat(d, name))})
    normalize(getcwd(), concat(dir, name))
}

fun glob(pattern: string): string []
{
    fun glob_(pattern: string, strarr: string []): (string [], bool)
    @ccode {
        fx_cstr_t cpattern;
        int fx_status = fx_str2cstr(pattern, &cpattern, 0, 0);
        if (fx_status < 0) return fx_status;
#if defined _WIN32 || defined WINCE
        fx_result->t1 = false;
        int_ i, capacity = 0, nentries = 0;
        fx_str_t* buf = 0, *newbuf = 0;
        struct _finddata_t fd;
        intptr_t h = _findfirst(cpattern.data, &fd);
        fx_free_cstr(&cpattern);
        if (h == -1L) {
            if (errno == ENOENT)
                return FX_OK;
            FX_FAST_THROW_RET(FX_EXN_IOError);
        }
        for(;;) {
            if (nentries >= capacity) {
                capacity *= 2;
                if (capacity < 256) capacity = 256;
                newbuf = (fx_str_t*)fx_realloc(buf, capacity*sizeof(buf[0]));
                if (!newbuf) {
                    FX_SET_EXN_FAST(FX_EXN_OutOfMemError);
                    break;
                }
                buf = newbuf;
            }
            fx_status = fx_cstr2str(fd.name, -1, buf + nentries);
            if (fx_status < 0) break;
            nentries++;
            if (_findnext(h, &fd) != 0)
                break;
        }
        _findclose(h);
        if (fx_status >= 0) {
            fx_status = fx_make_arr(1, &nentries, sizeof(fx_str_t), strarr->free_elem, strarr->copy_elem, 0, &fx_result->t0);
            if (fx_status >= 0) {
                memcpy(fx_result->t0.data, buf, nentries*sizeof(buf[0]));
                nentries = 0;
            }
        }
        for (i = 0; i < nentries; i++)
            fx_free_str(buf + i);
        fx_free(buf);
#else
        fx_result->t1 = true;
        glob_t globbuf;
        globbuf.gl_offs = 0;
        int glob_err = glob(cpattern.data, GLOB_TILDE, NULL, &globbuf);
        int_ nentries = (int_)globbuf.gl_pathc;
        fx_free_cstr(&cpattern);
        if (glob_err != 0) {
            if (glob_err == GLOB_NOMATCH)
                return FX_OK;
            FX_FAST_THROW_RET(FX_EXN_IOError);
        }
        fx_status = fx_make_arr(1, &nentries, sizeof(fx_str_t), strarr->free_elem, strarr->copy_elem, 0, &fx_result->t0);
        if (fx_status >= 0) {
            fx_str_t* data = (fx_str_t*)(fx_result->t0.data);
            for(int_ i = 0; i < nentries && fx_status >= 0; i++, data++) {
                fx_status = fx_cstr2str(globbuf.gl_pathv[i], -1, data);
            }
        }
        globfree(&globbuf);
#endif
        return fx_status;
    }
    val (files, sorted) = glob_(pattern, ([]: string []))
    if !sorted {sort(files, (<))}
    files
}
