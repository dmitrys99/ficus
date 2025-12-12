import Sys, Filename

fun find_ficus_dirs(): (string, string list)
{
    var ficus_path = Sys.getpath("FICUS_PATH")
    // if 'ficus' is '<ficus_root>/bin/ficus'
    val ficus_app_path = Filename.dirname(Filename.normalize(Filename.getcwd(), Sys.argv.hd()))
    // if 'ficus' is '<ficus_root>/__fxbuild__/fx/fx'
    val ficus_pp_path = Filename.dirname(Filename.dirname(ficus_app_path))
    // if 'ficus' is '{/usr|/usr/local|/opt}/bin/ficus'
    val ficus_inst_path = Filename.normalize(Filename.dirname(ficus_app_path),
                            f"lib/ficus-{__ficus_major__}.{__ficus_minor__}")
    val std_ficus_path = [:: Filename.normalize(Filename.dirname(ficus_app_path), "lib"),
                           Filename.normalize(ficus_pp_path, "lib"),
                           Filename.normalize(ficus_inst_path, "lib") ]
    val std_ficus_path_len = std_ficus_path.length()
    val search_path = std_ficus_path + ficus_path
    var found = ""
    for d@i <- search_path {
        val builtins_fx = Filename.normalize(d, "Builtins.fx")
        val ficus_h = Filename.normalize(d, "../runtime/ficus/ficus.h")
        if Filename.exists(builtins_fx) && Filename.exists(ficus_h) {
            found = Filename.dirname(d)
            if i < std_ficus_path_len {
                // unless Builtins.fx is already found in FICUS_PATH,
                // we add it to the end of FICUS_PATH
                ficus_path = ficus_path + (d::[])
            }
            break
        }
    }
    (found, ficus_path)
}

fun print_ficus_environment(ficus_root: string, ficus_path: string list): void {
    println("Ficus environment:")
    val ficus_path_env = Sys.getenv("FICUS_PATH")
    val indent = "  "
    println(f"FICUS_PATH={ficus_path_env}")
    println(f"Ficus root:\n{indent}{ficus_root}")
    println("Ficus path(s):")
    for p <- ficus_path {
        println(f"{indent}{p}");
    }
}
