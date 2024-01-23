
// this is autogenerated file, do not edit it.
#include "ficus/ficus.h"


#include <limits.h>
    #include <stdlib.h>
    #include <stdio.h>
    #include <sys/stat.h>
    #include <time.h>
#if !defined WIN32 && !defined _WIN32
    #include <unistd.h>
#else
    #include <direct.h>
#endif

    #ifndef PATH_MAX
    #define PATH_MAX 8192
    #endif

typedef struct _fx_LS_data_t {
   int_ rc;
   struct _fx_LS_data_t* tl;
   fx_str_t hd;
} _fx_LS_data_t, *_fx_LS;

typedef struct _fx_R7File__t {
   fx_cptr_t handle;
} _fx_R7File__t;

typedef struct _fx_FPS1B {
   int (*fp)(bool, fx_str_t*, void*);
   fx_fcv_t* fcv;
} _fx_FPS1B;

typedef struct _fx_rS_data_t {
   int_ rc;
   fx_str_t data;
} _fx_rS_data_t, *_fx_rS;

typedef struct {
   int_ rc;
   int_ data;
} _fx_E4Exit_data_t;

typedef struct {
   int_ rc;
   fx_str_t data;
} _fx_E4Fail_data_t;

static void _fx_free_LS(struct _fx_LS_data_t** dst)
{
   FX_FREE_LIST_IMPL(_fx_LS, fx_free_str);
}

static int _fx_cons_LS(fx_str_t* hd, struct _fx_LS_data_t* tl, bool addref_tl, struct _fx_LS_data_t** fx_result)
{
   FX_MAKE_LIST_IMPL(_fx_LS, fx_copy_str);
}

static void _fx_free_R7File__t(struct _fx_R7File__t* dst)
{
   fx_free_cptr(&dst->handle);
}

static void _fx_copy_R7File__t(struct _fx_R7File__t* src, struct _fx_R7File__t* dst)
{
   fx_copy_cptr(src->handle, &dst->handle);
}

static void _fx_make_R7File__t(fx_cptr_t r_handle, struct _fx_R7File__t* fx_result)
{
   fx_copy_cptr(r_handle, &fx_result->handle);
}

static void _fx_free_rS(struct _fx_rS_data_t** dst)
{
   FX_FREE_REF_IMPL(_fx_rS, fx_free_str);
}

static int _fx_make_rS(fx_str_t* arg, struct _fx_rS_data_t** fx_result)
{
   FX_MAKE_REF_IMPL(_fx_rS, fx_copy_str);
}

_fx_LS _fx_g9Sys__argv = 0;
bool _fx_g10Sys__win32 = 
#if defined _WIN32 || defined WINCE
    true
#else
    false
#endif
;
bool _fx_g9Sys__unix =
   
#if defined __linux__ || defined __unix__ || defined __MACH__ || \
    defined __APPLE__ || defined BSD || defined __hpux || \
    defined _AIX || defined __sun
    true
#else
    false
#endif
;
_fx_FPS1B _fx_g11Sys__osname = {0};
FX_EXTERN_C int _fx_M3SysFM7make_fpFPS1B2rSrS(
   struct _fx_rS_data_t* arg0,
   struct _fx_rS_data_t* arg1,
   struct _fx_FPS1B* fx_result);

static int _fx_M3SysFM10__lambda__S1B(bool get_version_0, fx_str_t* fx_result, void* fx_fv);

FX_EXTERN_C int _fx_M4FileFM5popenRM1t2SS(fx_str_t* cmdname, fx_str_t* mode, struct _fx_R7File__t* fx_result, void* fx_fv);

FX_EXTERN_C int _fx_M4FileFM6readlnS1RM1t(struct _fx_R7File__t* f, fx_str_t* fx_result, void* fx_fv);

FX_EXTERN_C int _fx_M6StringFM5stripS1S(fx_str_t* s, fx_str_t* fx_result, void* fx_fv);

FX_EXTERN_C void _fx_M4FileFM5closev1RM1t(struct _fx_R7File__t* f, void* fx_fv);

FX_EXTERN_C int_ _fx_M6StringFM4findi3SSi(fx_str_t* s, fx_str_t* part, int_ from_pos, void* fx_fv);

FX_EXTERN_C int _fx_M6StringFM5splitLS3SCB(
   fx_str_t* s,
   char_ c,
   bool allow_empty,
   struct _fx_LS_data_t** fx_result,
   void* fx_fv);

typedef struct {
   int_ rc;
   fx_free_t free_f;
   struct _fx_rS_data_t* t0;
   struct _fx_rS_data_t* t1;
} _fx_M3SysFM10__lambda__S1B_cldata_t;

FX_EXTERN_C void _fx_free_M3SysFM10__lambda__S1B(_fx_M3SysFM10__lambda__S1B_cldata_t* dst)
{
   _fx_free_rS(&dst->t0);
   _fx_free_rS(&dst->t1);
   fx_free(dst);
}

static int_ _fx_M3SysFM4argci0(void* fx_fv)
{
   
return fx_argc();

}

static int _fx_M3SysFM4argvS1i(int_ i, fx_str_t* fx_result, void* fx_fv)
{
   
return fx_cstr2str(fx_argv(i), -1, fx_result);

}

FX_EXTERN_C int _fx_M3SysFM7osname_FPS1B0(struct _fx_FPS1B* fx_result, void* fx_fv)
{
   _fx_rS osname_ref_0 = 0;
   _fx_rS osinfo_ref_0 = 0;
   int fx_status = 0;
   fx_str_t slit_0 = FX_MAKE_STR("");
   FX_CALL(_fx_make_rS(&slit_0, &osname_ref_0), _fx_cleanup);
   fx_str_t slit_1 = FX_MAKE_STR("");
   FX_CALL(_fx_make_rS(&slit_1, &osinfo_ref_0), _fx_cleanup);
   _fx_M3SysFM7make_fpFPS1B2rSrS(osinfo_ref_0, osname_ref_0, fx_result);

_fx_cleanup: ;
   if (osname_ref_0) {
      _fx_free_rS(&osname_ref_0);
   }
   if (osinfo_ref_0) {
      _fx_free_rS(&osinfo_ref_0);
   }
   return fx_status;
}

static int _fx_M3SysFM10__lambda__S1B(bool get_version_0, fx_str_t* fx_result, void* fx_fv)
{
   fx_str_t str_0 = {0};
   fx_str_t v_0 = {0};
   fx_str_t v_1 = {0};
   _fx_R7File__t p_0 = {0};
   fx_str_t v_2 = {0};
   fx_str_t v_3 = {0};
   int fx_status = 0;
   _fx_M3SysFM10__lambda__S1B_cldata_t* cv_0 = (_fx_M3SysFM10__lambda__S1B_cldata_t*)fx_fv;
   fx_str_t* osinfo_0 = &cv_0->t0->data;
   fx_str_t* osname_0 = &cv_0->t1->data;
   bool t_0;
   if (!get_version_0) {
      t_0 = _fx_g10Sys__win32;
   }
   else {
      t_0 = false;
   }
   if (t_0) {
      fx_str_t slit_0 = FX_MAKE_STR("Windows"); fx_copy_str(&slit_0, fx_result);
   }
   else {
      if (FX_STR_LENGTH(*osinfo_0) == 0) {
         fx_str_t slit_1 = FX_MAKE_STR("");
         fx_copy_str(&slit_1, &str_0);
         if (_fx_g10Sys__win32) {
            fx_str_t slit_2 = FX_MAKE_STR("ver"); fx_copy_str(&slit_2, &v_0);
         }
         else {
            fx_str_t slit_3 = FX_MAKE_STR("uname -msr"); fx_copy_str(&slit_3, &v_0);
         }
         if (_fx_g10Sys__win32) {
            fx_str_t slit_4 = FX_MAKE_STR("rt"); fx_copy_str(&slit_4, &v_1);
         }
         else {
            fx_str_t slit_5 = FX_MAKE_STR("r"); fx_copy_str(&slit_5, &v_1);
         }
         FX_CALL(_fx_M4FileFM5popenRM1t2SS(&v_0, &v_1, &p_0, 0), _fx_cleanup);
         for (;;) {
            fx_str_t v_4 = {0};
            fx_str_t v_5 = {0};
            FX_CALL(_fx_M4FileFM6readlnS1RM1t(&p_0, &v_4, 0), _fx_catch_0);
            FX_FREE_STR(&str_0);
            fx_copy_str(&v_4, &str_0);
            if (FX_STR_LENGTH(str_0) == 0) {
               FX_BREAK(_fx_catch_0);
            }
            FX_CALL(_fx_M6StringFM5stripS1S(&str_0, &v_5, 0), _fx_catch_0);
            FX_FREE_STR(&str_0);
            fx_copy_str(&v_5, &str_0);
            if (FX_STR_LENGTH(str_0) != 0) {
               FX_BREAK(_fx_catch_0);
            }

         _fx_catch_0: ;
            FX_FREE_STR(&v_5);
            FX_FREE_STR(&v_4);
            FX_CHECK_BREAK();
            FX_CHECK_EXN(_fx_cleanup);
         }
         _fx_M4FileFM5closev1RM1t(&p_0, 0);
         if (FX_STR_LENGTH(str_0) != 0) {
            fx_copy_str(&str_0, &v_2);
         }
         else if (_fx_g10Sys__win32) {
            fx_str_t slit_6 = FX_MAKE_STR("Windows"); fx_copy_str(&slit_6, &v_2);
         }
         else {
            fx_str_t slit_7 = FX_MAKE_STR("Unix"); fx_copy_str(&slit_7, &v_2);
         }
         FX_FREE_STR(osinfo_0);
         fx_copy_str(&v_2, osinfo_0);
         int_ sp_0;
         fx_str_t slit_8 = FX_MAKE_STR(" ");
         sp_0 = _fx_M6StringFM4findi3SSi(osinfo_0, &slit_8, 0, 0);
         if (sp_0 >= 0) {
            FX_CALL(fx_substr(osinfo_0, 0, sp_0, 1, 1, &v_3), _fx_cleanup);
         }
         else {
            fx_copy_str(osinfo_0, &v_3);
         }
         FX_FREE_STR(osname_0);
         fx_copy_str(&v_3, osname_0);
      }
      if (get_version_0) {
         fx_copy_str(osinfo_0, fx_result);
      }
      else {
         fx_copy_str(osname_0, fx_result);
      }
   }

_fx_cleanup: ;
   FX_FREE_STR(&str_0);
   FX_FREE_STR(&v_0);
   FX_FREE_STR(&v_1);
   _fx_free_R7File__t(&p_0);
   FX_FREE_STR(&v_2);
   FX_FREE_STR(&v_3);
   return fx_status;
}

FX_EXTERN_C int _fx_M3SysFM7make_fpFPS1B2rSrS(
   struct _fx_rS_data_t* arg0,
   struct _fx_rS_data_t* arg1,
   struct _fx_FPS1B* fx_result)
{
   FX_MAKE_FP_IMPL_START(_fx_M3SysFM10__lambda__S1B_cldata_t, _fx_free_M3SysFM10__lambda__S1B, _fx_M3SysFM10__lambda__S1B);
   FX_COPY_PTR(arg0, &fcv->t0);
   FX_COPY_PTR(arg1, &fcv->t1);
   return 0;
}

FX_EXTERN_C int _fx_M3SysFM10cc_versionS0(fx_str_t* fx_result, void* fx_fv)
{
   
return fx_cc_version(fx_result);

}

FX_EXTERN_C int _fx_M3SysFM6removev1S(fx_str_t* name, void* fx_fv)
{
   
fx_cstr_t name_;
    int fx_status = fx_str2cstr(name, &name_, 0, 0);
    if (fx_status >= 0) {
        if(remove(name_.data) != 0)
            fx_status = FX_SET_EXN_FAST(FX_EXN_IOError);
        fx_free_cstr(&name_);
    }
    return fx_status;

}

FX_EXTERN_C int _fx_M3SysFM5mkdirB2Si(fx_str_t* name, int_ permissions, bool* fx_result, void* fx_fv)
{
   
fx_cstr_t name_;
    int fx_status = fx_str2cstr(name, &name_, 0, 0);
    struct stat s;
    *fx_result = false;
    if (fx_status >= 0) {
        int fstat_err = stat(name_.data, &s);
        if( fstat_err == -1) {
#           ifdef _WIN32
            *fx_result = _mkdir(name_.data) == 0;
#           else
            *fx_result = mkdir(name_.data, (int)permissions) == 0;
#           endif
        } else
            *fx_result = fstat_err == 0;
        fx_free_cstr(&name_);
    }
    return fx_status;

}

FX_EXTERN_C int _fx_M3SysFM7commandi1S(fx_str_t* cmd, int_* fx_result, void* fx_fv)
{
   
fx_cstr_t cmd_;
    int fx_status = fx_str2cstr(cmd, &cmd_, 0, 0);
    if (fx_status >= 0) {
        *fx_result = system(cmd_.data);
        fx_free_cstr(&cmd_);
    }
    return fx_status;

}

FX_EXTERN_C int _fx_M3SysFM6getenvS1S(fx_str_t* name, fx_str_t* fx_result, void* fx_fv)
{
   
fx_cstr_t name_;
    int fx_status = fx_str2cstr(name, &name_, 0, 0);
    if (fx_status >= 0) {
        char* result = getenv(name_.data);
        fx_free_cstr(&name_);
        return fx_cstr2str(result, -1, fx_result);
    }
    return fx_status;

}

FX_EXTERN_C int _fx_M3SysFM6getenvS2SS(fx_str_t* name_0, fx_str_t* defval_0, fx_str_t* fx_result, void* fx_fv)
{
   fx_str_t s_0 = {0};
   int fx_status = 0;
   FX_CALL(_fx_M3SysFM6getenvS1S(name_0, &s_0, 0), _fx_cleanup);
   if (FX_STR_LENGTH(s_0) != 0) {
      fx_copy_str(&s_0, fx_result);
   }
   else {
      fx_copy_str(defval_0, fx_result);
   }

_fx_cleanup: ;
   FX_FREE_STR(&s_0);
   return fx_status;
}

FX_EXTERN_C int _fx_M3SysFM7getpathLS1S(fx_str_t* name_0, struct _fx_LS_data_t** fx_result, void* fx_fv)
{
   fx_str_t v_0 = {0};
   int fx_status = 0;
   char_ pathsep_0;
   if (_fx_g10Sys__win32) {
      pathsep_0 = (char_)59;
   }
   else {
      pathsep_0 = (char_)58;
   }
   FX_CALL(_fx_M3SysFM6getenvS1S(name_0, &v_0, 0), _fx_cleanup);
   FX_CALL(_fx_M6StringFM5splitLS3SCB(&v_0, pathsep_0, false, fx_result, 0), _fx_cleanup);

_fx_cleanup: ;
   FX_FREE_STR(&v_0);
   return fx_status;
}

FX_EXTERN_C int _fx_M3SysFM9colortermB0(bool* fx_result, void* fx_fv)
{
   fx_str_t v_0 = {0};
   int fx_status = 0;
   fx_str_t slit_0 = FX_MAKE_STR("TERM");
   FX_CALL(_fx_M3SysFM6getenvS1S(&slit_0, &v_0, 0), _fx_cleanup);
   int_ v_1;
   fx_str_t slit_1 = FX_MAKE_STR("xterm");
   v_1 = _fx_M6StringFM4findi3SSi(&v_0, &slit_1, 0, 0);
   *fx_result = v_1 >= 0;

_fx_cleanup: ;
   FX_FREE_STR(&v_0);
   return fx_status;
}

FX_EXTERN_C int fx_init_Sys(void)
{
   int fx_status = 0;
   int_ v_0 = _fx_M3SysFM4argci0(0);
   _fx_LS lstend_0 = 0;
   for (int_ i_0 = 0; i_0 < v_0; i_0++) {
      fx_str_t res_0 = {0};
      FX_CALL(_fx_M3SysFM4argvS1i(i_0, &res_0, 0), _fx_catch_0);
      _fx_LS node_0 = 0;
      FX_CALL(_fx_cons_LS(&res_0, 0, false, &node_0), _fx_catch_0);
      FX_LIST_APPEND(_fx_g9Sys__argv, lstend_0, node_0);

   _fx_catch_0: ;
      FX_FREE_STR(&res_0);
      FX_CHECK_EXN(_fx_cleanup);
   }
   FX_CALL(_fx_M3SysFM7osname_FPS1B0(&_fx_g11Sys__osname, 0), _fx_cleanup);

_fx_cleanup: ;
   return fx_status;
}

FX_EXTERN_C void fx_deinit_Sys(void)
{
   if (_fx_g9Sys__argv) {
      _fx_free_LS(&_fx_g9Sys__argv);
   }
   FX_FREE_FP(&_fx_g11Sys__osname);
}

