
// this is autogenerated file, do not edit it.
#include "ficus/ficus.h"


typedef uint64_t hash_t;
#define FNV_1A_PRIME 1099511628211ULL
#define FNV_1A_OFFSET 14695981039346656037ULL

typedef struct _fx_R8format_t {
   char_ fill;
   char_ align;
   char_ sign;
   bool num_alt;
   int_ width;
   int_ precision;
   char_ grouping;
   char_ typ;
} _fx_R8format_t;

typedef struct _fx_LS_data_t {
   int_ rc;
   struct _fx_LS_data_t* tl;
   fx_str_t hd;
} _fx_LS_data_t, *_fx_LS;

typedef struct _fx_T2R8format_ti {
   struct _fx_R8format_t t0;
   int_ t1;
} _fx_T2R8format_ti;

static void _fx_free_LS(struct _fx_LS_data_t** dst)
{
   FX_FREE_LIST_IMPL(_fx_LS, fx_free_str);
}

static int _fx_cons_LS(fx_str_t* hd, struct _fx_LS_data_t* tl, bool addref_tl, struct _fx_LS_data_t** fx_result)
{
   FX_MAKE_LIST_IMPL(_fx_LS, fx_copy_str);
}

int _FX_EXN_E4Exit = 0;
int _FX_EXN_E4Fail = 0;
int_ _fx_g15__ficus_major__ = 
FX_VERSION_MAJOR
;
int_ _fx_g15__ficus_minor__ = 
FX_VERSION_MINOR
;
int_ _fx_g20__ficus_patchlevel__ = 
FX_VERSION_PATCH
;
fx_str_t _fx_g16__ficus_suffix__ = 
FX_MAKE_STR(FX_VERSION_SUFFIX)
;
fx_str_t _fx_g20__ficus_git_commit__ = 
FX_MAKE_STR(FX_GIT_COMMIT)
;
fx_str_t _fx_g21__ficus_version_str__ = {0};
FX_EXTERN_C int _fx_F6stringS1i(int_ a, fx_str_t* fx_result, void* fx_fv);

FX_EXTERN_C int _fx_F6stringS1S(fx_str_t* a_0, fx_str_t* fx_result, void* fx_fv);

fx_exn_t _fx_E10ASCIIErrorv = {0};
fx_exn_t _fx_E11AssertErrorv = {0};
fx_exn_t _fx_E11BadArgErrorv = {0};
fx_exn_t _fx_E5Breakv = {0};
fx_exn_t _fx_E8DimErrorv = {0};
fx_exn_t _fx_E14DivByZeroErrorv = {0};
fx_exn_info_t _fx_E4Exit_info = {0};
typedef struct {
   int_ rc;
   int_ data;
} _fx_E4Exit_data_t;

fx_exn_info_t _fx_E4Fail_info = {0};
typedef struct {
   int_ rc;
   fx_str_t data;
} _fx_E4Fail_data_t;

FX_EXTERN_C void _fx_free_E4Fail(_fx_E4Fail_data_t* dst)
{
   FX_FREE_STR(&dst->data);
   fx_free(dst);
}

fx_exn_t _fx_E13FileOpenErrorv = {0};
fx_exn_t _fx_E7IOErrorv = {0};
fx_exn_t _fx_E12NoMatchErrorv = {0};
fx_exn_t _fx_E13NotFoundErrorv = {0};
fx_exn_t _fx_E19NotImplementedErrorv = {0};
fx_exn_t _fx_E13NullFileErrorv = {0};
fx_exn_t _fx_E13NullListErrorv = {0};
fx_exn_t _fx_E12NullPtrErrorv = {0};
fx_exn_t _fx_E11OptionErrorv = {0};
fx_exn_t _fx_E13OutOfMemErrorv = {0};
fx_exn_t _fx_E15OutOfRangeErrorv = {0};
fx_exn_t _fx_E13OverflowErrorv = {0};
fx_exn_t _fx_E16ParallelForErrorv = {0};
fx_exn_t _fx_E10RangeErrorv = {0};
fx_exn_t _fx_E9SizeErrorv = {0};
fx_exn_t _fx_E17SizeMismatchErrorv = {0};
fx_exn_t _fx_E18StackOverflowErrorv = {0};
fx_exn_t _fx_E17TypeMismatchErrorv = {0};
fx_exn_t _fx_E13ZeroStepErrorv = {0};
FX_EXTERN_C int _fx_F9make_ExitE1i(int_ arg0, fx_exn_t* fx_result)
{
   FX_MAKE_EXN_IMPL_START(_FX_EXN_E4Exit, _fx_E4Exit_data_t, _fx_E4Exit_info);
   exn_data->data = arg0;
   return 0;
}

FX_EXTERN_C int _fx_F9make_FailE1S(fx_str_t* arg0, fx_exn_t* fx_result)
{
   FX_MAKE_EXN_IMPL_START(_FX_EXN_E4Fail, _fx_E4Fail_data_t, _fx_E4Fail_info);
   fx_copy_str(arg0, &exn_data->data);
   return 0;
}

FX_EXTERN_C int _fx_F6assertv1B(bool f_0, void* fx_fv)
{
   int fx_status = 0;
   if (!f_0) {
      FX_FAST_THROW(FX_EXN_AssertError, _fx_cleanup);
   }

_fx_cleanup: ;
   return fx_status;
}

FX_EXTERN_C int _fx_F4joinS2SA1S(fx_str_t* sep, fx_arr_t* strs, fx_str_t* fx_result, void* fx_fv)
{
   
return fx_strjoin(0, 0, sep, (fx_str_t*)strs->data,
                    strs->dim[0].size, fx_result);

}

FX_EXTERN_C int _fx_F12join_embraceS4SSSA1S(
   fx_str_t* begin,
   fx_str_t* end,
   fx_str_t* sep,
   fx_arr_t* strs,
   fx_str_t* fx_result,
   void* fx_fv)
{
   
return fx_strjoin(begin, end, sep,
        (fx_str_t*)strs->data,
        strs->dim[0].size, fx_result);

}

FX_EXTERN_C int _fx_F12join_embraceS4SSSLS(
   fx_str_t* begin_0,
   fx_str_t* end_0,
   fx_str_t* sep_0,
   struct _fx_LS_data_t* strs_0,
   fx_str_t* fx_result,
   void* fx_fv)
{
   fx_arr_t v_0 = {0};
   int fx_status = 0;
   fx_str_t* dstptr_0 = 0;
   _fx_LS lst_0 = strs_0;
   int_ len_0 = fx_list_length(lst_0);
   {
      const int_ shape_0[] = { len_0 };
      FX_CALL(fx_make_arr(1, shape_0, sizeof(fx_str_t), (fx_free_t)fx_free_str, (fx_copy_t)fx_copy_str, 0, &v_0), _fx_cleanup);
   }
   dstptr_0 = (fx_str_t*)v_0.data;
   for (; lst_0; lst_0 = lst_0->tl, dstptr_0++) {
      fx_str_t* x_0 = &lst_0->hd; fx_copy_str(x_0, dstptr_0);
   }
   FX_CALL(_fx_F12join_embraceS4SSSA1S(begin_0, end_0, sep_0, &v_0, fx_result, 0), _fx_cleanup);

_fx_cleanup: ;
   FX_FREE_ARR(&v_0);
   return fx_status;
}

FX_EXTERN_C int _fx_F4joinS2SLS(fx_str_t* sep_0, struct _fx_LS_data_t* strs_0, fx_str_t* fx_result, void* fx_fv)
{
   fx_arr_t v_0 = {0};
   int fx_status = 0;
   fx_str_t* dstptr_0 = 0;
   _fx_LS lst_0 = strs_0;
   int_ len_0 = fx_list_length(lst_0);
   {
      const int_ shape_0[] = { len_0 };
      FX_CALL(fx_make_arr(1, shape_0, sizeof(fx_str_t), (fx_free_t)fx_free_str, (fx_copy_t)fx_copy_str, 0, &v_0), _fx_cleanup);
   }
   dstptr_0 = (fx_str_t*)v_0.data;
   for (; lst_0; lst_0 = lst_0->tl, dstptr_0++) {
      fx_str_t* s_0 = &lst_0->hd; fx_copy_str(s_0, dstptr_0);
   }
   FX_CALL(_fx_F4joinS2SA1S(sep_0, &v_0, fx_result, 0), _fx_cleanup);

_fx_cleanup: ;
   FX_FREE_ARR(&v_0);
   return fx_status;
}

FX_EXTERN_C int _fx_F6stringS1E(fx_exn_t* a, fx_str_t* fx_result, void* fx_fv)
{
   
return fx_exn_to_string(a, fx_result);

}

FX_EXTERN_C int _fx_F6stringS1B(bool a_0, fx_str_t* fx_result, void* fx_fv)
{
   int fx_status = 0;
   if (a_0) {
      fx_str_t slit_0 = FX_MAKE_STR("true"); fx_copy_str(&slit_0, fx_result);
   }
   else {
      fx_str_t slit_1 = FX_MAKE_STR("false"); fx_copy_str(&slit_1, fx_result);
   }
   return fx_status;
}

FX_EXTERN_C int _fx_F6stringS1i(int_ a, fx_str_t* fx_result, void* fx_fv)
{
   
return fx_itoa(a, false, fx_result);

}

FX_EXTERN_C int _fx_F6stringS1q(uint64_t a, fx_str_t* fx_result, void* fx_fv)
{
   
return fx_itoa((int64_t)a, true, fx_result);

}

FX_EXTERN_C int _fx_F6stringS1l(int64_t a, fx_str_t* fx_result, void* fx_fv)
{
   
return fx_itoa(a, false, fx_result);

}

FX_EXTERN_C int _fx_F6stringS1C(char_ c, fx_str_t* fx_result, void* fx_fv)
{
   
return fx_make_str(&c, 1, fx_result);

}

FX_EXTERN_C int _fx_F6stringS1f(float a, fx_str_t* fx_result, void* fx_fv)
{
   
char buf[32];
    fx_bits32_t u;
    u.f = a;
    if ((u.i & 0x7f800000) != 0x7f800000)
        sprintf(buf, (a == (int)a ? "%.1f" : "%.8g"), a);
    else
        strcpy(buf, (u.i & 0x7fffff) != 0 ? "nan" : u.i > 0 ? "inf" : "-inf");
    return fx_ascii2str(buf, -1, fx_result);

}

FX_EXTERN_C int _fx_F6stringS1d(double a, fx_str_t* fx_result, void* fx_fv)
{
   
char buf[32];
    fx_bits64_t u;
    u.f = a;
    if ((u.i & 0x7FF0000000000000LL) != 0x7FF0000000000000LL)
        sprintf(buf, (a == (int)a ? "%.1f" : "%.16g"), a);
    else
        strcpy(buf, (u.i & 0xfffffffffffffLL) != 0 ? "nan" : u.i > 0 ? "inf" : "-inf");
    return fx_ascii2str(buf, -1, fx_result);

}

FX_EXTERN_C int _fx_F6stringS1S(fx_str_t* a_0, fx_str_t* fx_result, void* fx_fv)
{
   int fx_status = 0;
   fx_copy_str(a_0, fx_result);
   return fx_status;
}

FX_EXTERN_C int _fx_F3ordi1C(char_ c_0, int_* fx_result, void* fx_fv)
{
   int fx_status = 0;
   *fx_result = (int_)c_0;
   return fx_status;
}

FX_EXTERN_C int _fx_F3chrC1i(int_ i_0, char_* fx_result, void* fx_fv)
{
   int fx_status = 0;
   *fx_result = (char_)i_0;
   return fx_status;
}

FX_EXTERN_C int _fx_F4reprS1S(fx_str_t* a_0, fx_str_t* fx_result, void* fx_fv)
{
   int fx_status = 0;
   fx_str_t slit_0 = FX_MAKE_STR("\"");
   fx_str_t slit_1 = FX_MAKE_STR("\"");
   {
      const fx_str_t strs_0[] = { slit_0, *a_0, slit_1 };
      FX_CALL(fx_strjoin(0, 0, 0, strs_0, 3, fx_result), _fx_cleanup);
   }

_fx_cleanup: ;
   return fx_status;
}

FX_EXTERN_C int _fx_F4reprS1C(char_ a, fx_str_t* fx_result, void* fx_fv)
{
   
char_ buf[16] = {39, 92, 39};
    if (32 <= a && a != 39 && a != 34 && a != 92) {
        buf[1] = a;
        return fx_make_str(buf, 3, fx_result);
    } else {
        int k, len = 4;
        buf[3] = 39;
        switch(a) {
        case 10: buf[2]='n'; break;
        case 13: buf[2]='r'; break;
        case 9: buf[2]='t'; break;
        case 0: buf[2]='0'; break;
        case 39: buf[2]=39; break;
        case 34: buf[2]=34; break;
        case 92: buf[2]=92; break;
        default:
            if (a < 128) {
                len = 2;
                buf[2] = 'x';
            } else if (a < 65536) {
                len = 4;
                buf[2] = 'u';
            } else {
                len = 8;
                buf[2] = 'U';
            }
            for(k = 0; k < len; k++) {
                unsigned denom = 1U << ((len-k-1)*4);
                unsigned d = (unsigned)a/denom;
                a = (char_)(a%denom);
                buf[k+3] = (char_)(d > 10 ? (d - 10 + 'A') : (d + '0'));
            }
            len += 4;
            buf[len-1] = '\'';
            printf("len=%d: \n", len);
            for (int i = 0; i < len; i++)
                printf("%c", buf[i]);
            printf("\n");
        }
        return fx_make_str(buf, len, fx_result);
    }

}

FX_EXTERN_C int _fx_F6stringS1A1C(fx_arr_t* a, fx_str_t* fx_result, void* fx_fv)
{
   
return fx_make_str((char_*)a->data, a->dim[0].size, fx_result);

}

FX_EXTERN_C int _fx_F12parse_formatT2R8format_ti2Si(fx_str_t* fmt, int_ start, struct _fx_T2R8format_ti* fx_result, void* fx_fv)
{
   
FX_STATIC_ASSERT(sizeof(fx_result->t0) == sizeof(fx_format_t));
    return fx_parse_format(fmt, start, (fx_format_t*)&fx_result->t0, &fx_result->t1);

}

FX_EXTERN_C int _fx_F7__mul__S2Ci(char_ c, int_ n, fx_str_t* fx_result, void* fx_fv)
{
   
int fx_status = fx_make_str(0, n, fx_result);
    if (fx_status >= 0) {
        for( int_ i = 0; i < n; i++ )
            fx_result->data[i] = c;
    }
    return fx_status;

}

FX_EXTERN_C int _fx_F7__cmp__i2ii(int_ a_0, int_ b_0, int_* fx_result, void* fx_fv)
{
   int fx_status = 0;
   *fx_result = (a_0 > b_0) - (a_0 < b_0);
   return fx_status;
}

FX_EXTERN_C int _fx_F7__cmp__i2ll(int64_t a_0, int64_t b_0, int_* fx_result, void* fx_fv)
{
   int fx_status = 0;
   *fx_result = (a_0 > b_0) - (a_0 < b_0);
   return fx_status;
}

FX_EXTERN_C int _fx_F7__cmp__i2BB(bool a_0, bool b_0, int_* fx_result, void* fx_fv)
{
   int fx_status = 0;
   *fx_result = (a_0 > b_0) - (a_0 < b_0);
   return fx_status;
}

FX_EXTERN_C bool _fx_F6__eq__B2SS(fx_str_t* a, fx_str_t* b, void* fx_fv)
{
   
return fx_streq(a, b);

}

FX_EXTERN_C int_ _fx_F7__cmp__i2SS(fx_str_t* a, fx_str_t* b, void* fx_fv)
{
   
int_ alen = a->length, blen = b->length;
    int_ minlen = alen < blen ? alen : blen;
    const char_ *adata = a->data, *bdata = b->data;
    for(int_ i = 0; i < minlen; i++) {
        int_ ai = (int_)adata[i], bi = (int_)bdata[i], diff = ai - bi;
        if(diff != 0)
            return diff > 0 ? 1 : -1;
    }
    return alen < blen ? -1 : alen > blen;

}

FX_EXTERN_C int_ _fx_F5roundi1d(double x, void* fx_fv)
{
   
return fx_round2I(x);

}

FX_EXTERN_C void _fx_F12print_stringv1S(fx_str_t* a, void* fx_fv)
{
   
fx_fputs(stdout, a);

}

FX_EXTERN_C uint64_t _fx_F4hashq1S(fx_str_t* x, void* fx_fv)
{
   
uint64_t hash = FNV_1A_OFFSET;
    int_ i, len = x->length;
    char_* data = x->data;
    for(i = 0; i < len; i++) {
        hash ^= data[i];
        hash *= FNV_1A_PRIME;
    }
    return hash;

}

FX_EXTERN_C int fx_init_Builtins(void)
{
   fx_str_t v_0 = {0};
   fx_str_t v_1 = {0};
   fx_str_t v_2 = {0};
   fx_str_t v_3 = {0};
   FX_REG_SIMPLE_STD_EXN(FX_EXN_ASCIIError, _fx_E10ASCIIErrorv);
   FX_REG_SIMPLE_STD_EXN(FX_EXN_AssertError, _fx_E11AssertErrorv);
   FX_REG_SIMPLE_STD_EXN(FX_EXN_BadArgError, _fx_E11BadArgErrorv);
   FX_REG_SIMPLE_STD_EXN(FX_EXN_Break, _fx_E5Breakv);
   FX_REG_SIMPLE_STD_EXN(FX_EXN_DimError, _fx_E8DimErrorv);
   FX_REG_SIMPLE_STD_EXN(FX_EXN_DivByZeroError, _fx_E14DivByZeroErrorv);
   FX_REG_EXN("Exit", _FX_EXN_E4Exit, _fx_E4Exit_info, fx_free);
   FX_REG_EXN("Fail", _FX_EXN_E4Fail, _fx_E4Fail_info, _fx_free_E4Fail);
   FX_REG_SIMPLE_STD_EXN(FX_EXN_FileOpenError, _fx_E13FileOpenErrorv);
   FX_REG_SIMPLE_STD_EXN(FX_EXN_IOError, _fx_E7IOErrorv);
   FX_REG_SIMPLE_STD_EXN(FX_EXN_NoMatchError, _fx_E12NoMatchErrorv);
   FX_REG_SIMPLE_STD_EXN(FX_EXN_NotFoundError, _fx_E13NotFoundErrorv);
   FX_REG_SIMPLE_STD_EXN(FX_EXN_NotImplementedError, _fx_E19NotImplementedErrorv);
   FX_REG_SIMPLE_STD_EXN(FX_EXN_NullFileError, _fx_E13NullFileErrorv);
   FX_REG_SIMPLE_STD_EXN(FX_EXN_NullListError, _fx_E13NullListErrorv);
   FX_REG_SIMPLE_STD_EXN(FX_EXN_NullPtrError, _fx_E12NullPtrErrorv);
   FX_REG_SIMPLE_STD_EXN(FX_EXN_OptionError, _fx_E11OptionErrorv);
   FX_REG_SIMPLE_STD_EXN(FX_EXN_OutOfMemError, _fx_E13OutOfMemErrorv);
   FX_REG_SIMPLE_STD_EXN(FX_EXN_OutOfRangeError, _fx_E15OutOfRangeErrorv);
   FX_REG_SIMPLE_STD_EXN(FX_EXN_OverflowError, _fx_E13OverflowErrorv);
   FX_REG_SIMPLE_STD_EXN(FX_EXN_ParallelForError, _fx_E16ParallelForErrorv);
   FX_REG_SIMPLE_STD_EXN(FX_EXN_RangeError, _fx_E10RangeErrorv);
   FX_REG_SIMPLE_STD_EXN(FX_EXN_SizeError, _fx_E9SizeErrorv);
   FX_REG_SIMPLE_STD_EXN(FX_EXN_SizeMismatchError, _fx_E17SizeMismatchErrorv);
   FX_REG_SIMPLE_STD_EXN(FX_EXN_StackOverflowError, _fx_E18StackOverflowErrorv);
   FX_REG_SIMPLE_STD_EXN(FX_EXN_TypeMismatchError, _fx_E17TypeMismatchErrorv);
   FX_REG_SIMPLE_STD_EXN(FX_EXN_ZeroStepError, _fx_E13ZeroStepErrorv);
   int fx_status = 0;
   FX_CALL(_fx_F6stringS1i(_fx_g15__ficus_major__, &v_0, 0), _fx_cleanup);
   FX_CALL(_fx_F6stringS1i(_fx_g15__ficus_minor__, &v_1, 0), _fx_cleanup);
   FX_CALL(_fx_F6stringS1i(_fx_g20__ficus_patchlevel__, &v_2, 0), _fx_cleanup);
   FX_CALL(_fx_F6stringS1S(&_fx_g16__ficus_suffix__, &v_3, 0), _fx_cleanup);
   fx_str_t slit_0 = FX_MAKE_STR(".");
   fx_str_t slit_1 = FX_MAKE_STR(".");
   {
      const fx_str_t strs_0[] = { v_0, slit_0, v_1, slit_1, v_2, v_3 };
      FX_CALL(fx_strjoin(0, 0, 0, strs_0, 6, &_fx_g21__ficus_version_str__), _fx_cleanup);
   }

_fx_cleanup: ;
   FX_FREE_STR(&v_0);
   FX_FREE_STR(&v_1);
   FX_FREE_STR(&v_2);
   FX_FREE_STR(&v_3);
   return fx_status;
}

FX_EXTERN_C void fx_deinit_Builtins(void)
{
   FX_FREE_STR(&_fx_g21__ficus_version_str__);
}

