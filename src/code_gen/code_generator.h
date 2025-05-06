#ifndef __CODE_GENERATOR_H__
#define __CODE_GENERATOR_H__


#include <passes/module.h>

#include <utility>
class CodeGen {
   private:
    std::shared_ptr<Module> module_;

   public:
    CodeGen(std::shared_ptr<Module> module):module_(std::move(module)){}

    std::string gen(std::string file_name);
};

#endif  // !__CODE_GENERATOR_H__
