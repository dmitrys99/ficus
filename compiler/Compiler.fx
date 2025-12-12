/*
    This file is a part of ficus language project.
    See ficus/LICENSE for the licensing terms
*/

// Ficus compiler, the driving part
// (calls all other parts of the compiler in the proper order)

import Filename, File, Sys, Hashmap, Hashset, LexerUtils as Lxu
import Ast, Ast_pp, Lexer, Parser, Options
import Ast_typecheck
import K_form, K_pp, K_normalize, K_annotate, K_mangle
import K_remove_unused, K_lift_simple, K_flatten, K_tailrec, K_copy_n_skip
import K_cfold_dealias, K_fast_idx, K_inline, K_loop_inv, K_fuse_loops
import K_optim_matop, K_nothrow_wrappers, K_freevars, K_declosure, K_lift
import C_form, C_gen_std, C_gen_code, C_pp
import C_post_rename_locals, C_post_adjust_decls

from Compiler_env import *
from Compiler_msg import *
from Compiler_print import *
from Compiler_runcc import *
from Compiler_preamble import *
from TopoSort import *

exception CumulativeParseError

type id_t = Ast.id_t
type kmodule_t = K_form.kmodule_t
val pr_verbose = Ast.pr_verbose

fun print_all_compile_errs()
{
    val nerrs = Ast.all_compile_errs.length()
    if nerrs != 0 {
        Ast.all_compile_errs.rev().app(Ast.print_compile_err)
        println(f"\n{nerrs} errors occured during type checking.")
    }
}

fun parse_all(fname0: string, ficus_path: string list): bool
{
    val cwd = Filename.getcwd()
    val fname0 = Filename.normalize(cwd, fname0)
    val dir0 = Filename.dirname(fname0)
    val inc_dirs0 = if dir0 == cwd { [:: cwd] } else { [:: dir0, cwd] }
    val inc_dirs0 = inc_dirs0 + Options.opt.include_path
    val inc_dirs0 = inc_dirs0 + ficus_path
    val inc_dirs0 = [:: for d <- inc_dirs0 { Filename.normalize(cwd, d) }]
    val name0_id = Ast.get_id(Filename.remove_extension(Filename.basename(fname0)))
    val m_idx = Ast.find_module(name0_id, fname0)
    var queue = [:: m_idx]
    var ok = true
    while queue != [] {
        val m_idx = queue.hd()
        queue = queue.tl()
        val minfo = Ast.all_modules[m_idx]
        val mfname = minfo.dm_filename
        if !minfo.dm_parsed {
            try {
                // prevent from repeated parsing
                Ast.all_modules[m_idx].dm_parsed = true
                val dir1 = Filename.dirname(mfname)
                val inc_dirs = (if dir1 == dir0 {[]} else {[:: dir1]}) + inc_dirs0
                val preamble = get_preamble(mfname)
                ok &= Parser.parse(m_idx, preamble, inc_dirs)
                for dep <- Ast.all_modules[m_idx].dm_deps.rev() {
                    val dep_minfo = Ast.get_module(dep)
                    if !dep_minfo.dm_parsed {
                        queue = dep :: queue
                    }
                }
            }
            catch {
            | Lxu.LexerError((l, c), msg) =>
                println(f"{mfname}:{l}:{c}: error: {msg}\n"); ok = false
            | Parser.ParseError(loc, msg) =>
                println(f"{loc}: error: {msg}\n"); ok = false
            | e => println(f"{mfname}: exception {e} occured"); ok = false
            }
        }
    }
    ok
}

fun typecheck_all(modules: int list): bool
{
    Ast.all_compile_errs = []
    for m <- modules {Ast_typecheck.check_mod(m)}
    Ast.all_compile_errs == []
}

fun k_normalize_all(modules: int list): (kmodule_t list, bool)
{
    Ast.all_compile_errs = []
    K_form.init_all_idks()
    val kmods = K_normalize.normalize_all_modules(modules)
    (kmods, Ast.all_compile_errs == [])
}

fun k_skip_some(kmods: kmodule_t list)
{
    val skip_flags = array(size(Ast.all_modules), false)
    val build_root_dir = Options.opt.build_rootdir
    val ok = Sys.mkdir(build_root_dir, 0755)
    val build_dir = Options.opt.build_dir
    var ok = ok && Sys.mkdir(build_dir, 0755)
    val obj_ext = if Sys.win32 {".obj"} else {".o"}

    val kmods = [:: for km <- kmods {
        val {km_idx, km_cname, km_top, km_deps, km_pragmas} = km
        val is_cpp = Options.opt.compile_by_cpp || km_pragmas.pragma_cpp
        val ext = if is_cpp { ".cpp" } else { ".c" }
        val mname = K_mangle.mangle_mname(km_cname)
        val cname = Filename.normalize(build_dir, mname)
        val k_filename = cname + ".k"
        val c_filename = cname + ext
        val o_filename = cname + obj_ext

        val new_kform = K_pp.pp_top_to_string(km_top)
        val have_k = Filename.exists(k_filename)
        val have_c = Filename.exists(c_filename)
        val have_o = Filename.exists(o_filename)
        val have_all = have_k & have_c & have_o

        val old_kform =
            if Options.opt.force_rebuild || !have_all {""}
            else {
                try
                    File.read_utf8(k_filename)
                catch {
                | IOError | FileOpenError => ""
                }
            }
        val (ok_j, same_kform, status_j) =
            if new_kform == old_kform {
                (true, true, "")
            } else {
                val well_written =
                    try {
                        File.write_utf8(k_filename, new_kform)
                        true
                    }
                    catch {
                    | IOError | FileOpenError => false
                    }
                (well_written, false,
                if well_written {""} else {clrmsg(MsgRed, "failed to write .k")})
            }
        ok = ok & ok_j
        if !same_kform {
            if have_c { Sys.remove(c_filename) }
            if have_o { Sys.remove(o_filename) }
        }
        // [TODO] with properly constructed K-form dump format it should be
        // not necessary to check the dependencies. Types of the dependencies from
        // other modules (basically, their API) could be included into the dump.
        val skip_module = same_kform && all(for d <- km_deps {skip_flags[d]})
        val status_j = if status_j != "" {status_j} else if skip_module {"skip"} else {clrmsg(MsgBlue, "process")}
        pr_verbose(f"K {km_cname}: {status_j}")
        if skip_module {
            for e <- km_top {
                | K_form.KDefFun kf when kf->kf_flags.fun_flag_ctor == Ast.CtorNone =>
                    val {kf_flags, kf_rt, kf_loc} = *kf
                    *kf = kf->{
                        kf_flags=kf_flags.{
                            fun_flag_ccode=true,
                            fun_flag_inline=false,
                            },
                        kf_body=K_form.KExpCCode("", (kf_rt, kf_loc)),
                        }
                | _ => {}
            }
        }
        skip_flags[km_idx] = skip_module
        km.{km_skip=skip_module}
    } ]

    if !ok {throw Fail("failed to write some k-forms")}
    kmods
}

fun k_optimize_all(kmods: kmodule_t list): (kmodule_t list, bool) {
    Ast.all_compile_errs = []
    val niters = Options.opt.optim_iters
    var temp_kmods = kmods
    prf("remove unused")
    temp_kmods = K_remove_unused.remove_unused(temp_kmods, true)
    prf("annotate types")
    temp_kmods = K_annotate.annotate_types(temp_kmods)
    prf("copy generic/inline functions")
    temp_kmods = K_copy_n_skip.copy_some(temp_kmods)
    prf("remove unused by main")
    temp_kmods = K_remove_unused.remove_unused_by_main(temp_kmods)
    prf("mangle & dump intermediate K-forms")
    temp_kmods = K_mangle.mangle_all(temp_kmods, false)
    temp_kmods = K_mangle.mangle_locals(temp_kmods)
    temp_kmods = k_skip_some(temp_kmods)
    prf("demangle")
    temp_kmods = K_mangle.demangle_all(temp_kmods)
    for i <- 1: niters+1 {
        pr_verbose(f"Optimization pass #{i}:")
        if i <= 2 {
            prf("simple lambda lifting")
            temp_kmods = K_lift_simple.lift(temp_kmods)
        }
        prf("tailrec")
        temp_kmods = K_tailrec.tailrec2loops_all(temp_kmods)
        prf("loop inv")
        temp_kmods = K_loop_inv.move_loop_invs_all(temp_kmods)
        prf("gemm implantation")
        temp_kmods = K_optim_matop.optimize_gemm(temp_kmods)
        prf("inline")
        if Options.opt.inline_thresh > 0 {
            temp_kmods = K_inline.inline_some(temp_kmods)
        }
        prf("flatten")
        temp_kmods = K_flatten.flatten_all(temp_kmods)
        prf("fuse loops")
        temp_kmods = K_fuse_loops.fuse_loops_all(temp_kmods)
        prf("fast idx")
        temp_kmods = K_fast_idx.optimize_idx_checks_all(temp_kmods)
        prf("const folding")
        temp_kmods = K_cfold_dealias.cfold_dealias(temp_kmods)
        prf("remove unused")
        temp_kmods = K_remove_unused.remove_unused(temp_kmods, false)
    }
    pr_verbose("Finalizing K-form:")
    prf("linearize array access")
    temp_kmods = K_fast_idx.linearize_arrays_access(temp_kmods)
    prf("making wrappers for nothrow functions")
    temp_kmods = K_nothrow_wrappers.make_wrappers_for_nothrow(temp_kmods)
    prf("mutable freevars referencing")
    temp_kmods = K_freevars.mutable_freevars2refs(temp_kmods)
    prf("declosuring")
    temp_kmods = K_declosure.declosure_all(temp_kmods)
    prf("lambda lifting")
    temp_kmods = K_lift.lift_all(temp_kmods)
    prf("flatten")
    temp_kmods = K_flatten.flatten_all(temp_kmods)
    prf("remove unused")
    temp_kmods = K_remove_unused.remove_unused(temp_kmods, false)
    prf("mangle")
    temp_kmods = K_mangle.mangle_all(temp_kmods, true)
    prf("remove unused")
    temp_kmods = K_remove_unused.remove_unused(temp_kmods, false)
    prf("mark recursive")
    temp_kmods = K_inline.find_recursive_funcs_all(temp_kmods)
    prf("annotate types")
    temp_kmods = K_annotate.annotate_types(temp_kmods)
    (temp_kmods, Ast.all_compile_errs == [])
}

fun k2c_all(kmods: kmodule_t list)
{
    pr_verbose(clrmsg(MsgBlue, "Generating C code"))
    Ast.all_compile_errs = []
    C_form.init_all_idcs()
    C_gen_std.init_std_names()
    val cmods = C_gen_code.gen_ccode_all(kmods)
    pr_verbose(clrmsg(MsgBlue, "C code generated"))
    val cmods = C_post_rename_locals.rename_locals(cmods)
    val cmods = [:: for cmod <- cmods {
        val is_cpp = Options.opt.compile_by_cpp || cmod.cmod_pragmas.pragma_cpp
        if is_cpp { C_post_adjust_decls.adjust_decls(cmod) }
        else { cmod }
        }]
    pr_verbose("\tConversion to C-form complete")
    (cmods, Ast.all_compile_errs == [])
}

fun run_app(): bool
{
    val appname = Options.opt.app_filename
    val appname = Filename.normalize(Filename.getcwd(), appname)
    val cmd = " ".join(appname :: Options.opt.app_args)
    Sys.command(cmd) == 0
}

fun process_all(fname0: string): bool {
    Ast.init_all()
    try {
        val (ficus_root, ficus_path) = find_ficus_dirs()
        if ficus_root == "" { throw Fail(msg_ficus_root_not_found) }
        val ok = parse_all(fname0, ficus_path)
        if !ok { throw CumulativeParseError }
        val graph = [:: for minfo <- Ast.all_modules {
                        (minfo.dm_idx, minfo.dm_deps)
                    }]
        Ast.all_modules_sorted = toposort(graph).tl().tl()
        if Options.opt.print_ast0 {
            for m <- Ast.all_modules_sorted {
                val minfo = Ast.get_module(m)
                Ast_pp.pprint_mod(minfo)
            }
        }
        val modules_used = ", ".join([::for m_idx <- Ast.all_modules_sorted { Ast.pp(Ast.get_module_name(m_idx)) }])
        val parsing_complete = clrmsg(MsgBlue, "Parsing complete")
        pr_verbose(f"{parsing_complete}. Modules used: {modules_used}")
        val ok = typecheck_all(Ast.all_modules_sorted)
        if ok {
            pr_verbose(clrmsg(MsgBlue, "Type checking complete"))
            if Options.opt.print_ast {
                for m <- Ast.all_modules_sorted {
                    val minfo = Ast.get_module(m)
                    Ast_pp.pprint_mod(minfo)
                }
            }
        }
        val (kmods, ok) = if ok { k_normalize_all(Ast.all_modules_sorted) } else { ([], false) }
        if ok {
            pr_verbose(clrmsg(MsgBlue, "K-normalization complete"))
            if Options.opt.print_k0 { K_pp.pp_kmods(kmods) }
        }
        val (kmods, ok) = if ok {
            pr_verbose(clrmsg(MsgBlue, "K-form optimization started"))
            k_optimize_all(kmods)
        } else { ([], false) }
        if ok {
            pr_verbose(clrmsg(MsgBlue, "K-form optimization complete"))
            if Options.opt.print_k { K_pp.pp_kmods(kmods) }
        }
        val ok = if !Options.opt.gen_c { ok } else {
            val (cmods, ok) = if ok { k2c_all(kmods) } else { ([], false) }
            val ok =
                if ok && (Options.opt.make_app || Options.opt.run_app) {
                    run_cc(cmods, ficus_root)
                } else { ok }
            val ok = if ok && Options.opt.run_app { run_app() } else { ok }
            ok
        }
        if !ok { print_all_compile_errs() }
        ok
    } catch {
    | e =>
        print_all_compile_errs()
        match e {
        | Fail(msg) => println(f"{error}: {msg}")
        | Ast.CompileError(loc, msg) as e => Ast.print_compile_err(e)
        | CumulativeParseError => {}
        | _ => println(f"\n\n{error}: Exception {e} occured")
        }
        false
    }
}
