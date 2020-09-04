# SysImages

This packages is an experiment to mitigate some of the anoying issues for building and linking sysimages per project basis. This package extends `Project.toml` with additional entry `[sysimg]` where user specifies a list of packages which should be baked in the sysimage. That allows to avoid repetions and seperate development environment (where I personally put `Revise`) from the project environment by collecting all packages from the project files listed in  `Base.load_path()`. For example, a project file:
```
[deps]
Interpolations = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
TaskMaster = "2f14bf60-09e4-11e9-2b32-676fc1c2075a"

[sysimg]
packages = ["Interpolations"]
```
would mean that `Interpolations` would be one of the package part of the sysimage.

To build a sysimage for the active project one does:
```
using SysImages
SysImages.build()
```
which if succesfull for packages `A`, `B` and `C` would create a project environment and sysimage in `~/.julia/sysimages/A-B-C/`. To link the sysimage one uses a function `SysImages.link()` to get the linkable argument if sysimage exists for the particular environment, so one can write a simple bash script to start julia:
```
SYSARG=$(julia --project=. -e "using SysImages; println(SysImages.link())")
julia --project=. $SYSARG
```
