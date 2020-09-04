module SysImages

using Pkg
using Pkg.TOML
using PackageCompiler

function syspackages(path::String)
    project = TOML.parsefile(path)
    if haskey(project,"sysimg")
        packages = project["sysimg"]["packages"]
        return Symbol.(packages)
    else
        return Symbol[]
    end
end

function syspackages()
    deps = Symbol[]
    for i in Base.load_path()
        if isfile(i)
            packages = syspackages(i)
            append!(deps,packages)
        end
    end
    return unique(deps)
end

function sysdir(packages::Vector)
    pstr = ["$i" for i in packages]
    name = join(sort(pstr),"-")
    imagedir = homedir() * "/.julia/sysimages/"
    return imagedir * name * "/"
end


# function sysimage(packages::Vector)
    
#     path = sysdir(packages) ".so"
#     return path
# end

function build()
    packages = syspackages()
    path = sysdir(packages)
    mkpath(path)

    io = open(path * "/Project.toml", "w")
    println(io, "")
    close(io)
        
    ctx = PackageCompiler.create_pkg_context(path)
    pkgs = (x->PackageSpec("$x")).(packages)
    Pkg.add(ctx, pkgs)
    
    create_sysimage(packages; sysimage_path=path * "/sys.so", project=path, incremental=true)
end

function link()
    packages = syspackages()

    if length(packages)==0
        return ""
    end
        
    path = sysdir(packages)
    
    if isdir(path)
        return "-J $path/sys.so"
    else
        @warn "A sysimage with packages $packages not found."
        return ""
    end
end

end # module
