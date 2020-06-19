/*
    This file is a part of ficus language project.
    See ficus/LICENSE for the licensing terms
*/

#ifndef __FICUS_IMPL_H__
#define __FICUS_IMPL_H__

#ifdef __cplusplus
extern "C" {
#endif

FX_THREAD_LOCAL fx_exn_t fx_exn;
FX_THREAD_LOCAL fx_rng_t fx_rng;

static int _fx_argc = 0;
static char** _fx_argv = 0;

int_ fx_argc(void) { return _fx_argc; }
char* fx_argv(int_ idx) { return _fx_argv[idx]; }

void fx_init(int argc, char** argv)
{
    _fx_argc = argc;
    _fx_argv = argv;
    fx_init_thread(0);
}

void fx_init_thread(int t_idx)
{
    uint64_t state = (uint64_t)-1;
    for(int i = 0; i < t_idx*2 + 10; i++)
        state = (uint64_t)(unsigned)state*4187999619U + (unsigned)(state >> 32);
    fx_rng.state = state;
}

/* [TODO] replace it with something more efficient,
   e.g. mimalloc (https://github.com/microsoft/mimalloc) */
void* fx_malloc(size_t sz)
{
    return malloc(sz);
}

void* fx_realloc(void* ptr, size_t sz)
{
    return realloc(ptr, sz);
}

void fx_free(void* ptr)
{
    free(ptr);
}

/////////////// list ////////////////

typedef struct fx_list_simple_data_t
{
    int_ rc;
    struct fx_list_simple_data_t* tl;
    int hd;
}* fx_list_simple_t;

void fx_free_list_simple(void* dst_)
{
    fx_list_simple_t *dst = (fx_list_simple_t*)dst_;
    FX_FREE_LIST_IMPL(fx_list_simple_t, FX_NOP);
}

int_ fx_list_length(void* pl_)
{
    fx_list_simple_t pl = (fx_list_simple_t)pl_;
    int_ len = 0;
    for(; pl != 0; pl = pl->tl)
        len++;
    return len;
}

///////////// references ////////////

void fx_free_ref_simple(void* dst_)
{
    fx_ref_simple_t *dst = (fx_ref_simple_t*)dst_;
    FX_FREE_REF_IMPL(fx_ref_simple_t, FX_NOP);
}

////// reference-counted cells //////

void fx_copy_ptr(const void* src, void* dst)
{
    int_* src_ = (int_*)src;
    int_** dst_ = (int_**)dst;
    if(src_) FX_INCREF(*src_);
    *dst_ = src_;
}

///////////// exceptions /////////////

void fx_free_exn(fx_exn_t* exn)
{
    if(exn->data)
    {
        if(FX_DECREF(exn->data->rc) == 1)
            exn->data->free_f(exn->data);
        exn->data = 0;
    }
}

void fx_copy_exn(const fx_exn_t* src, fx_exn_t* dst)
{
    if(src->data) FX_INCREF(src->data->rc);
    *dst = *src;
}

//////////////// function pointers ////////////////

typedef struct fx_fv_t
{
    int_ rc;
    fx_free_t free_f;
} fx_fv_t;

typedef struct fx_fp_t
{
    void (*fp)(void);
    fx_fv_t* fcv;
} fx_fp_t;

void fx_free_fp(void* fp)
{
    fx_fp_t* fp_ = (fx_fp_t*)fp;
    FX_FREE_FP(fp_)
}

void fx_copy_fp(const void* src, void* pdst)
{
    fx_fp_t *src_ = (fx_fp_t*)src, **pdst_ = (fx_fp_t**)pdst;
    FX_COPY_FP(src_, *pdst_);
}

//////////////////// cpointers ////////////////////

void fx_cptr_no_free(void* ptr) {}

void fx_free_cptr(fx_cptr_t* pcptr)
{
    if(*pcptr)
    {
        fx_cptr_t cptr = *pcptr;
        if(cptr->free_f && FX_DECREF(cptr->rc) == 1) {
            cptr->free_f(cptr->ptr);
            fx_free(cptr);
        }
        *pcptr = 0;
    }
}

void fx_copy_cptr(const fx_cptr_t src, fx_cptr_t* dst)
{
    if(src && src->free_f) FX_INCREF(src->rc);
    *dst = src;
}

int fx_make_cptr(void* ptr, fx_free_t free_f, fx_cptr_t* fx_result)
{
    FX_DECL_AND_MALLOC(fx_cptr_t, p, sizeof(*p));
    p->rc = 1;
    p->free_f = free_f;
    p->ptr = ptr;
    *fx_result = p;
    return FX_OK;
}

#ifdef __cplusplus
}
#endif

#include "ficus/impl/array.impl.h"
#include "ficus/impl/file.impl.h"
#include "ficus/impl/string.impl.h"

#endif