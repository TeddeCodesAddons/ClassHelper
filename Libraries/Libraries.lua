local libs={

}
function ClassHelper:NewLibrary(libname)
    local lib={

    }
    libs[libname]=lib
    return lib
end
function ClassHelper:ImportLibrary(libname)
    return libs[libname]
end