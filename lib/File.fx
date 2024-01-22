/*
    This file is a part of ficus language project.
    See ficus/LICENSE for the licensing terms
*/

// C-style operations on files
@ccode { #include <stdio.h> }

val SEEK_SET: int = @ccode { (int)SEEK_SET }
val SEEK_CURR: int = @ccode { (int)SEEK_CUR }
val SEEK_END: int = @ccode { (int)SEEK_END }

class t { handle: cptr }

fun get_stdstream(i: int): t
@ccode {
    if(i != 0 && i != 1 && i != 2)
        FX_FAST_THROW_RET(FX_EXN_NullFileError);
    fx_result->handle = fx_get_stdstream(i);
    return FX_OK;
}

val stdin = get_stdstream(0)
val stdout = get_stdstream(1)
val stderr = get_stdstream(2)

@private fun open_(fname: string, mode: string, ispipe: bool): cptr
@ccode {
    fx_cstr_t fname_, mode_;
    int fx_status = fx_str2cstr(fname, &fname_, 0, 0);
    if (fx_status >= 0) {
        fx_status = fx_str2cstr(mode, &mode_, 0, 0);
        if (fx_status >= 0) {
            FILE* f = ispipe ?
            #ifdef _WIN32
                _popen(fname_.data, mode_.data) :
            #else
                popen(fname_.data, mode_.data) :
            #endif
                fopen(fname_.data, mode_.data);
            if (f) {
                fx_status = fx_make_cptr(f, (ispipe ? fx_pipe_destructor :
                                        fx_file_destructor), fx_result);
            }
            else {
                fx_status = FX_SET_EXN_FAST(FX_EXN_FileOpenError);
            }
            fx_free_cstr(&mode_);
        }
        fx_free_cstr(&fname_);
    }
    return fx_status;
}

fun open(fname: string, mode: string) =
    t { handle=open_(fname, mode, false) }

fun popen(cmdname: string, mode: string) =
    t { handle=open_(cmdname, mode, true) }

@nothrow fun close(f: File.t): void
@ccode {
    if(f->handle && f->handle->ptr) {
        f->handle->free_f(f->handle->ptr);
        f->handle->ptr = 0;
    }
}

fun pclose_exit_status(f: File.t): int
@ccode {
    if(!f->handle || !f->handle->ptr || f->handle->free_f != fx_pipe_destructor)
        FX_FAST_THROW_RET(FX_EXN_FileOpenError);

#ifdef _WIN32
    *fx_result = _pclose(f->handle->ptr);
#else
    int result = pclose(f->handle->ptr);
    *fx_result = WEXITSTATUS(result);
#endif

    f->handle->ptr = 0;
    return FX_OK;
}

@nothrow fun is_open(f: File.t): bool
@ccode { return f->handle && f->handle->ptr; }

fun eof(f: File.t): bool
@ccode {
    if(!f->handle || !f->handle->ptr)
        FX_FAST_THROW_RET(FX_EXN_NullFileError);
    *fx_result = feof((FILE*)(f->handle->ptr)) != 0;
    return FX_OK;
}

fun seek(f: File.t, pos: int64, origin: int): void
@ccode {
    if(!f->handle || !f->handle->ptr)
        FX_FAST_THROW_RET(FX_EXN_NullFileError);
    int code = fseek((FILE*)(f->handle->ptr), (long)pos, origin);
    return code == 0 ? FX_OK : FX_EXN_IOError;
}

fun tell(f: File.t): int64
@ccode {
    if(!f->handle || !f->handle->ptr)
        FX_FAST_THROW_RET(FX_EXN_NullFileError);
    long code = ftell((FILE*)(f->handle->ptr));
    if(code == -1) FX_FAST_THROW_RET(FX_EXN_IOError);
    *fx_result = (int64_t)code;
    return FX_OK;
}

fun flush(f: File.t): void
@ccode {
    if(!f->handle || !f->handle->ptr)
        FX_FAST_THROW_RET(FX_EXN_NullFileError);
    fflush((FILE*)(f->handle->ptr));
    return FX_OK;
}

fun print(f: File.t, x: 't) = print(f, string(x))

fun print(f: File.t, x: string): void
@ccode {
    if(!f->handle || !f->handle->ptr)
        FX_FAST_THROW_RET(FX_EXN_NullFileError);
    return fx_fputs((FILE*)(f->handle->ptr), x);
}

fun print(f: File.t, x: int): void
@ccode {
    if(!f->handle || !f->handle->ptr)
        FX_FAST_THROW_RET(FX_EXN_NullFileError);
    fprintf((FILE*)(f->handle->ptr), "%zd", x);
    return FX_OK;
}

fun print(f: File.t, x: float): void
@ccode {
    if(!f->handle || !f->handle->ptr)
        FX_FAST_THROW_RET(FX_EXN_NullFileError);
    fprintf((FILE*)(f->handle->ptr), "%.8g", x);
    return FX_OK;
}

fun print(f: File.t, x: double): void
@ccode {
    if(!f->handle || !f->handle->ptr)
        FX_FAST_THROW_RET(FX_EXN_NullFileError);
    fprintf((FILE*)(f->handle->ptr), "%.16g", x);
    return FX_OK;
}

fun println(f: File.t, x: 't): void
{
    print(f, x)
    print(f, "\n")
}

fun println(f: File.t): void
{
    print(f, "\n")
}

fun write(f: File.t, a: 't []): void
@ccode {
    if(!f->handle || !f->handle->ptr)
        FX_FAST_THROW_RET(FX_EXN_NullFileError);
    size_t elem_size = a->dim[0].step, count0 = (size_t)a->dim[0].size;
    size_t count = fwrite(a->data, elem_size, count0, (FILE*)f->handle->ptr);
    return count == count0 ? FX_OK : FX_EXN_IOError;
}

fun write(f: File.t, a: 't [,]): void
@ccode {
    size_t step = a->dim[0].step, elem_size = a->dim[1].step;
    size_t count0 = (size_t)a->dim[1].size;
    int_ i, m = a->dim[0].size;
    if(!f->handle || !f->handle->ptr)
        FX_FAST_THROW_RET(FX_EXN_NullFileError);

    for(i = 0; i < m; i++) {
        size_t count = fwrite(a->data + i*step, elem_size, count0, (FILE*)f->handle->ptr);
        if(count != count0) FX_FAST_THROW_RET(FX_EXN_IOError);
    }
    return FX_OK;
}

fun read(f: File.t, a: 't []): int
@ccode {
    if(!f->handle || !f->handle->ptr)
        FX_FAST_THROW_RET(FX_EXN_NullFileError);
    FILE* fh = (FILE*)f->handle->ptr;
    size_t elem_size = a->dim[0].step, count0 = (size_t)a->dim[0].size;
    size_t count = fread(a->data, elem_size, count0, fh);
    *fx_result = (int_)count;
    return count == count0 || feof(fh) ? FX_OK : FX_EXN_IOError;
}

fun readln(f: File.t): string
@ccode {
    if(!f->handle || !f->handle->ptr)
        FX_FAST_THROW_RET(FX_EXN_NullFileError);
    return fx_fgets((FILE*)(f->handle->ptr), fx_result);
}

fun read_binary_u8(fname: string): uint8 []
{
    val f = open(fname, "rb")
    f.seek(0i64, SEEK_END)
    val sz = f.tell()
    f.seek(0i64, SEEK_SET)
    val arr = array(int(sz), 0u8)
    assert(f.read(arr) == int(sz))
    f.close()
    arr
}

fun read_utf8(fname: string): string
@ccode {
    fx_cstr_t fname_;
    int fx_status = fx_str2cstr(fname, &fname_, 0, 0);
    if (fx_status >= 0) {
        FILE* f;
        errno_t err = fopen_s(&f, fname_.data, "rb");
        if (err = 0) {
            fseek(f, 0, SEEK_END);
            int_ size = (int_)ftell(f);
            fseek(f, 0, SEEK_SET);
            fx_cstr_t buf;
            fx_status = fx_make_cstr(0, size, &buf);
            if (fx_status >= 0) {
                int_ count = (int_)fread(buf.data, 1, (size_t)size, f);
                if (count == size) {
                    char* ptr = buf.data;
                    if (count >= 3 && ptr[0] == (char)0xEF && ptr[1] == (char)0xBB && ptr[2] == (char)0xBF) {
                        ptr += 3; count -= 3;
                    }
                    fx_status = fx_cstr2str(ptr, count, fx_result);
                } else {
                    fx_status = FX_SET_EXN_FAST(FX_EXN_IOError);
                }
                fx_free_cstr(&buf);
            }
            fclose(f);
        } else {
            fx_status = FX_SET_EXN_FAST(FX_EXN_FileOpenError);
        }
        fx_free_cstr(&fname_);
    }
    return fx_status;
}

fun write_utf8(fname: string, text: string): void
@ccode {
    fx_cstr_t fname_;
    int fx_status = fx_str2cstr(fname, &fname_, 0, 0);
    if (fx_status >= 0) {
        FILE* f;
	errno_t err = fopen_s(&f, fname_.data, "wb");
        if (f) {
            fx_cstr_t buf;
            fx_status = fx_str2cstr(text, &buf, 0, 0);
            if (fx_status >= 0) {
                int_ count = (int_)fwrite(buf.data, 1, buf.length, f);
                if (count != buf.length)
                    fx_status = FX_SET_EXN_FAST(FX_EXN_IOError);
                fx_free_cstr(&buf);
            }
            fclose(f);
            if (fx_status < 0)
                remove(fname_.data);
        } else {
            fx_status = FX_SET_EXN_FAST(FX_EXN_FileOpenError);
        }
        fx_free_cstr(&fname_);
    }
    return fx_status;
}
