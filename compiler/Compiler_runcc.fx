import C_form, Sys, Filename, Options, Ast, Hashset, C_pp, File

from Compiler_print import *

val pr_verbose = Ast.pr_verbose

// [TODO] add proper support for Windows
fun run_cc(cmods: C_form.cmodule_t list, ficus_root: string) {
    val osinfo = Sys.osname(true)
    val opt_level = Options.opt.optimize_level
    val opt_level_str = if opt_level <= 3 {string(opt_level)} else {"fast"}
    val enable_openmp = Options.opt.enable_openmp
    val runtime_include_path = Filename.normalize(ficus_root, "runtime")
    val runtime_lib_path = Filename.normalize(ficus_root, "runtime/lib")
    val runtime_impl = Filename.normalize(ficus_root, "runtime/ficus/impl/libficus")
    val build_root_dir = Options.opt.build_rootdir
    val ok = Sys.mkdir(build_root_dir, 0755)
    val build_dir = Options.opt.build_dir
    val ok = ok && Sys.mkdir(build_dir, 0755)

    val (_, c_comp, cpp_comp, obj_ext, obj_opt, appname_opt, link_lib_opt, cflags, clibs) =
        if Sys.win32 {
            val omp_flag = ""//if enable_openmp {" /openmp"} else {""}
            val opt_flags =
                if opt_level == 0 {
                    " /D_DEBUG /MTd /Od /GF"
                } else {
                    " /DNDEBUG /MT " + (if opt_level == 1 {"/O1"} else {"/O2"})
                }
            val incdirs = " ".join([::for d <- Ast.all_c_inc_dirs.list() {"/I"+d}])
            val cflags = f"/utf-8 /nologo{opt_flags}{omp_flag} {incdirs} /I{runtime_include_path}"
            ("win", "cl", "cl", ".obj", "/c /Fo", "/Fe", "", cflags, "/nologo /F10485760 kernel32.lib advapi32.lib")
        } else {
            // unix or hopefully something more or less compatible with it
            val c_comp = Sys.getenv("CC", "cc")
            val cpp_comp_name = Sys.getenv("CXX", "c++")
            val cpp_comp = f"{cpp_comp_name} -std=c++11"
            val (os, libpath, cflags, clibs) =
            if osinfo.contains("Darwin") {
                val (omp_cflags, omp_lib) =
                    if enable_openmp {
                        if c_comp.contains("gcc") {
                            ("-fopenmp", " -lgomp")
                        } else {
                            ("-Xclang -fopenmp", " -lomp")
                        }
                    }
                    else { ("", "") }
                val (libpath, cflags, clibs) =
                if osinfo.contains("x86_64") {
                    ("macos_x64", omp_cflags,
                        " " + omp_cflags + omp_lib
                    )
                } else if osinfo.contains ("arm64") {
                    ("macos_arm64", omp_cflags,
                        " " + omp_cflags + omp_lib
                    )
                } else {
                    ("", "", "")
                }
                ("macos", libpath, cflags, clibs)
            } else if osinfo.contains("Linux") {
                val omp_flags = if enable_openmp {" -fopenmp"} else {""}
                ("linux", "", omp_flags, omp_flags)
            } else if Sys.unix {
                ("unix", "", "", "")
            } else {
                ("", "", "", "")
            }
            val common_cflags = "-Wno-unknown-warning-option -Wno-dangling-else -Wno-static-in-inline -Wno-parentheses"
            val ggdb_opt = if opt_level == 0 { " -D_DEBUG -ggdb" } else {
                    val stk_overflow = if opt_level == 100 {" -DFX_NO_STACK_OVERFLOW_CHECK"} else {""}
                    f" -DNDEBUG{stk_overflow}"
                }

            val incdirs = " ".join([::for d <- Ast.all_c_inc_dirs.list() {"-I"+d}])
            val cflags = f"-O{opt_level_str}{ggdb_opt} {cflags} {common_cflags} {incdirs} -I{runtime_include_path}"
            val clibs = (if libpath!="" {f"-L{runtime_lib_path}/{libpath} "} else {""}) + f"-lm {clibs}"
            (os, c_comp, cpp_comp, ".o", "-c -o ", "-o ", "-l", cflags, clibs)
        }

    val custom_cflags = Sys.getenv("FICUS_CFLAGS")
    val custom_cflags = if Options.opt.cflags == "" { custom_cflags }
                        else { Options.opt.cflags + " " + custom_cflags }
    val cflags = cflags + " " + custom_cflags
    pr_verbose(clrmsg(MsgBlue, f"Compiling .c/.cpp files with cflags={cflags}"))
    val runtime_pseudo_cmod = C_form.cmodule_t {cmod_name=Ast.noid, cmod_cname=runtime_impl, cmod_ccode=[], cmod_recompile=true,
        cmod_skip=false, cmod_main=false, cmod_pragmas=Ast.pragmas_t {pragma_cpp=false, pragma_clibs=[]}}
    val cmods = runtime_pseudo_cmod :: cmods
    val results = [@parallel for
        {cmod_cname, cmod_ccode, cmod_skip, cmod_pragmas={pragma_cpp, pragma_clibs}} <- array(cmods) {
        val output_fname = Filename.basename(cmod_cname)
        val is_runtime = cmod_cname == runtime_impl
        val is_cpp = !is_runtime && (Options.opt.compile_by_cpp || pragma_cpp)
        val (comp, ext) = if is_cpp { (cpp_comp, ".cpp") } else { (c_comp, ".c") }
        val output_fname = Filename.normalize(build_dir, output_fname)
        val output_fname_c = output_fname + ext
        val (ok_j, reprocess, status_j) =
            if cmod_skip { (true, false, "skipped") }
            else if is_runtime { (true, true, "")}
            else {
                val str_new = C_pp.pprint_top_to_string(cmod_ccode)
                val str_old = if Options.opt.force_rebuild {""} else {
                    try
                        File.read_utf8(output_fname_c)
                    catch {
                    | IOError | FileOpenError => ""
                    }
                }
                if str_new == str_old {
                    (ok, false, "skipped")
                } else {
                    val well_written =
                        try {
                            File.write_utf8(output_fname_c, str_new)
                            true
                        }
                        catch {
                        | IOError | FileOpenError => false
                        }
                    (well_written, well_written,
                    if well_written {""} else {clrmsg(MsgRed, f"failed to write {output_fname_c}")})
                }
            }
        val c_filename = if is_runtime {runtime_impl + ".c"} else {output_fname_c}
        val obj_filename = output_fname + obj_ext
        val (ok_j, recompiled, status_j) =
            if ok_j && (reprocess || !Filename.exists(obj_filename)) {
                val cmd = f"{comp} {cflags} {obj_opt}{obj_filename} {c_filename}"
                val result =
                    if c_comp == "cl" {
                        val p = File.popen(cmd, "rt")
                        var lineno = 0
                        // read and immediately dump the output from cl,
                        // except for the first line, which is the source file name
                        while true {
                            val str = p.readln()
                            if str == "" { break }
                            lineno += 1
                            if lineno > 1 {print(str)}
                        }
                        p.pclose_exit_status() == 0
                    } else {
                        Sys.command(cmd) == 0
                    }
                val status = if result {clrmsg(MsgGreen, "ok")} else {clrmsg(MsgRed, "fail")}
                (result, true, status)
            } else {
                (ok_j, false, status_j)
            }
        pr_verbose(f"CC {c_filename}: {status_j}")
        val clibs = [:: for (l, _) <- pragma_clibs { l }].rev()
        (is_cpp, recompiled, clibs, ok_j, obj_filename)
    }]

    val fold (any_cpp, any_recompiled, all_clibs, ok, objs) = (false, false, ([] : string list), ok, [])
        for (is_cpp, is_recompiled, clibs_j, ok_j, obj) <- results {
            (any_cpp | is_cpp, any_recompiled | is_recompiled, clibs_j + all_clibs, ok & ok_j, obj :: objs)
        }
    if ok && !any_recompiled && Filename.exists(Options.opt.app_filename) {
        pr_verbose(f"{Options.opt.app_filename} is up-to-date\n")
        ok
    } else if !ok {
        ok
    } else {
        val custom_clibs = Sys.getenv("FICUS_LINK_LIBRARIES")
        val custom_clibs =
            if Options.opt.clibs == "" { custom_clibs }
            else { custom_clibs + " " + Options.opt.clibs }
        val custom_clibs =
            if all_clibs == [] { custom_clibs }
            else {
                custom_clibs + " " +
                " ".join([::for l <- all_clibs.rev() {link_lib_opt + l}])
            }
        val clibs = clibs + " " + custom_clibs
        pr_verbose(f"Linking the app with flags={clibs}")
        val cmd = (if any_cpp {cpp_comp} else {c_comp}) + " " + appname_opt + Options.opt.app_filename
        val cmd = cmd + " " + " ".join(objs) + " " + clibs
        //pr_verbose(f"{cmd}\n")
        val ok = Sys.command(cmd) == 0
        ok
    }
}
