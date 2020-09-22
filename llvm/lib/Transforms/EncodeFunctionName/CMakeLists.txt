# If we don't need RTTI or EH, there's no reason to export anything
# from the hello plugin.
add_llvm_library( LLVMEncodeFunctionName MODULE BUILDTREE_ONLY
  EncodeFunctionName.cpp

  DEPENDS
  intrinsics_gen
  PLUGIN_TOOL
  opt
  )
