seterrorhandler(print)
ClassHelper.VERSION={ -- No more need for updating version here.
    interface=GetAddOnMetadata(ClassHelper.ADDON_PATH_NAME,"X-Interface"),
    str=GetAddOnMetadata(ClassHelper.ADDON_PATH_NAME,"Version"),
    isOutOfDate=false
}
ClassHelper.VERSION.update={strsplit(".",ClassHelper.VERSION.str)}
ClassHelper.VERSION.update=ClassHelper.VERSION.update[getn(ClassHelper.VERSION.update)]
ClassHelper.VERSION.whats_new={strsplit("~",GetAddOnMetadata(ClassHelper.ADDON_PATH_NAME,"X-WhatsNew"))}