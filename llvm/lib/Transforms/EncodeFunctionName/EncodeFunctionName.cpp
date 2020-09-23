//
// Created by root on 9/22/20.
//
#include "llvm/Pass.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/raw_ostream.h"

#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/Transforms/EncodeFunctionName/EncodeFunctionName.h"


using namespace llvm;

namespace {
struct EncodeFunctionName : public FunctionPass {
  static char ID;
  EncodeFunctionName() : FunctionPass(ID) {}

  bool runOnFunction(Function &F) override {
    errs() << "EncodeFunctionName: "+F.getName()+" -> ";
    if(F.getName().compare("main")!=0){

      llvm::MD5 Hasher;
      llvm::MD5::MD5Result Hash;
      Hasher.update("zdd_");
      Hasher.update(F.getName());

      Hasher.final(Hash);

      SmallString<32> HexString;
      llvm::MD5::stringifyResult(Hash, HexString);


      F.setName(HexString);
    }

    errs().write_escaped(F.getName()) << '\n';
    return false;
  }
}; // end of struct Hello
}  // end of anonymous namespace

char EncodeFunctionName::ID = 0;
static RegisterPass<EncodeFunctionName> X("encode", "Encode Function Name Pass",
                             false /* Only looks at CFG */,
                             false /* Analysis Pass */);


Pass* llvm::createEncodeFunctionName(){
  return new EncodeFunctionName();
}
