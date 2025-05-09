%{
    #include "helpers/type_helper.h"
    #include "syntax_tree.h"
    #include "utils.h"
    #include "string.h"
    #include "error.h"
    #include "runtime.h"
    #include <vector>
    #include <typeinfo>
    extern tree_comp_unit *root;

    extern int yyline;
    extern int yylex();
    void yyerror(char*s)
    {
        extern char *yytext;	// defined and maintained in lex
        // int len=strlen(yytext);
        // int i;
        char buf[1024]={0};
        strcpy(buf,yytext);
        // for (i=0;i<len;++i)
        // {
        //     //TODO: may have bugs
        //     sprintf(buf,"%s%d ",buf,yytext[i]);

        // }
        // std::string txt = "ERROR: text :"+to
        fprintf(stderr, "ERROR: text %s\n",yytext);
        fprintf(stderr, "ERROR: %s at symbol '%s' on line %d\n", s, buf, yyline);
        exit(YYERROR);
    }
    void insertVarible(std::string& type,std::string& id);
    void insertFunction(std::string& type,std::string& id);
%}

%union{
std::string            *string;
int                    token;
tree_comp_unit         *comp_unit;
tree_func_def          *func_def;
tree_block             *block;
tree_const_decl        *const_decl;
tree_basic_type        *basic_type;
tree_const_def_list    *const_def_list;
tree_const_init_val    *const_init_val;
tree_const_val_list    *const_init_val_list;
tree_const_exp_list    *const_exp_list;
tree_const_exp         *const_exp;
tree_var_decl          *var_decl;
tree_arrray_def        *array_def;
tree_exp               *exp;
tree_init_val          *init_val;
tree_init_val_list     *init_val_list;
tree_func_fparams      *func_fparams;
tree_func_fparam       *func_fparam;
tree_func_fparamone    *func_fparamone;
tree_func_fparamarray  *func_fparamarray;
tree_decl              *decl;
tree_const_def         *const_def;
tree_var_def_list      *var_def_list;
tree_var_def           *var_def;
tree_block_item_list   *block_item_list;
tree_block_item        *block_item;
tree_stmt              *stmt;
tree_assign_stmt       *assign_stmt;
tree_if_stmt           *if_stmt;
tree_if_else_stmt      *if_else_stmt;
tree_while_stmt        *while_stmt;
tree_break_stmt        *break_stmt;
tree_continue_stmt     *continue_stmt;
tree_cond              *cond;
tree_return_stmt       *return_stmt;
tree_return_null_stmt  *return_null_stmt;
tree_l_val             *l_val;
tree_array_ident       *array_ident;
tree_number            *number;
tree_primary_exp       *primary_exp;
tree_unary_exp         *unary_exp;
tree_func_call         *func_call;
tree_func_paramlist   *func_param_list;
tree_mul_exp           *mul_exp;
tree_add_exp           *add_exp;
tree_rel_exp           *rel_exp;
tree_eq_exp            *eq_exp;
tree_l_and_exp         *l_and_exp;
tree_l_or_exp          *l_or_exp;

}

%token <string> TIDENTIFIER TINTEGER TFLOATNUM
%token TSEMICOLOM ";"
%token TCOMMA   ","
%token TINT     "int"
%token TFLOAT   "float"
%token TVOID    "void"
%token TRETURN  "return"
%token TCONST   "const"
%token TBREAK   "break"
%token TCONTINUE"continue"
%token TIF      "if"
%token TELSE    "else"
%token TWHILE   "while"
%token TLBPAREN "{"
%token TRBPAREN "}"
%token TMINUS   "-"
%token TNOT     "!"
%token TPLUS    "+"
%token TDIV     "/"
%token TMOD     "%"
%token TMULTI   "*"
%token TLPAREN  "("
%token TRPAREN  ")"
%token TLMPAREN "["
%token TRMPAREN "]"
%token TL       "<"
%token TLE      "<="
%token TG       ">"
%token TGE      ">="
%token TNE      "!="
%token TE       "=="
%token TLOGAND  "&&"
%token TLOGOR   "||"
%token TASSIGN  "="


%type <comp_unit>        CompUnit // ysx
%type <decl>             Decl
%type <const_decl>       ConstDecl
%type <basic_type>       BType
%type <const_exp>        ConstExp
%type <const_def>        ConstDef
%type <const_def_list>   ConstDefList
%type <const_exp_list>   ConstExpArrayList
%type <const_init_val>   ConstInitVal
%type <const_init_val_list>   ConstInitVallist
%type <var_decl>         VarDecl
%type <func_call>        FuncCall
%type <func_param_list>  FuncParamList
%type <var_def>          VarDef
%type <var_def_list>     VarDefList
%type <array_def>        ArrayDef
%type <init_val>         InitVal // dyb
%type <init_val_list>    InitValList
%type <func_def>         FuncDef
%type<func_fparams>      FuncFParams
%type<func_fparam>       FuncFParam
%type<func_fparamone>    FuncFParamOne
%type<func_fparamarray>  FuncFParamArray
%type <block>            Block
%type <block_item>       BlockItem
%type <block_item_list>  BlockItemList
%type <stmt>             Stmt
%type <cond>             Cond
%type <number>           Number // wq
%type <exp>              Exp
%type <l_val>            LVal
%type <array_ident>      ArrayIdent
%type <primary_exp>      PrimaryExp
%type <unary_exp>        UnaryExp
%type <mul_exp>          MulExp
%type <add_exp>          AddExp
%type <rel_exp>          RelExp
%type <eq_exp>           EqExp
%type <l_and_exp>        LAndExp
%type <l_or_exp>         LOrExp


%start CompUnit
%expect 1
%%
//jyx
CompUnit
    : FuncDef
        {
            root = new tree_comp_unit();
            root->_line_no = yyline+1;
            printf("func def is %s\n",$1->id.c_str());
		    root->functions.push_back(std::shared_ptr<tree_func_def>($1));
        }
    | CompUnit FuncDef
        {
            printf("func def is %s\n",$2->id.c_str());
		    root->functions.push_back(std::shared_ptr<tree_func_def>($2));
        }
    | Decl
        {
            root = new tree_comp_unit();
            root->_line_no = yyline+1;
            root->definitions.push_back(std::shared_ptr<tree_decl>($1));
        }
    | CompUnit Decl
        {
            root->definitions.push_back(std::shared_ptr<tree_decl>($2));
        }
    ;

Decl
    : ConstDecl
        {
            $$ = new tree_decl();
            $$->_line_no = yyline+1;
            $$->const_decl=std::shared_ptr<tree_const_decl>($1);
        }
    | VarDecl
        {
            $$ = new tree_decl();
            $$->_line_no = yyline+1;
            $$->var_decl=std::shared_ptr<tree_var_decl>($1);
        }
    ;

ConstDecl
    : "const" BType ConstDefList ";"
        {
            $$ = new tree_const_decl();
            $$->_line_no = yyline+1;
            $$->b_type=std::shared_ptr<tree_basic_type>($2);
            $$->const_def_list=std::shared_ptr<tree_const_def_list>($3);
        }
    ;

ConstDefList
    : ConstDef
        {
            $$ = new tree_const_def_list();
            $$->_line_no = yyline+1;
            $$->const_defs.push_back(std::shared_ptr<tree_const_def>($1));
        }
    | ConstDefList "," ConstDef
        {
            $1->const_defs.push_back(std::shared_ptr<tree_const_def>($3));
            $$ = $1;
        }
    ;

BType
    : "int"
        {
            $$ = new tree_basic_type();
            $$->_line_no = yyline+1;
            $$->type=type_helper::INT;
        };
    | "float"
        {
            $$ = new tree_basic_type();
            $$->_line_no = yyline+1;
            $$->type=type_helper::FLOAT;
        }
    | "void"
        {
            $$ = new tree_basic_type();
            $$->_line_no = yyline+1;
            $$->type=type_helper::VOID;
        }
    ;

ConstDef
    : TIDENTIFIER ConstExpArrayList "=" ConstInitVal
        {
            $$ = new tree_const_def();
            $$->_line_no = yyline+1;
            $$->id=*$1;
            $$->const_exp_list=std::shared_ptr<tree_const_exp_list>($2);
            $$->const_init_val=std::shared_ptr<tree_const_init_val>($4);
        }
    | TIDENTIFIER "=" ConstInitVal
        {
            $$ = new tree_const_def();
            $$->_line_no = yyline+1;
            $$->id=*$1;
            $$->const_init_val=std::shared_ptr<tree_const_init_val>($3);
        }
    ;

ConstExpArrayList
    : "[" ConstExp "]"
        {
            $$ = new tree_const_exp_list();
            $$->_line_no = yyline+1;
            $$->const_exp.push_back(std::shared_ptr<tree_const_exp>($2));
        }
    | ConstExpArrayList "[" ConstExp "]"
        {
            $1->const_exp.push_back(std::shared_ptr<tree_const_exp>($3));
            $$ = $1;
        }
    ;

ConstInitVal
    : ConstExp
        {
            $$ = new tree_const_init_val();
            $$->_line_no = yyline+1;
            $$->const_exp= std::shared_ptr<tree_const_exp>($1) ;
        }
    | "{"  "}"
        {
            $$ = new tree_const_init_val();
            $$->_line_no = yyline+1;
        }
    | "{" ConstInitVallist "}"
        {
            $$ = new tree_const_init_val();
            $$->_line_no = yyline+1;
            $$->const_val_list = std::shared_ptr<tree_const_val_list>($2) ;
        }
    ;

ConstInitVallist
    : ConstInitVal
        {
            $$ = new tree_const_val_list();
            $$->_line_no = yyline+1;
            $$->const_init_vals.push_back(std::shared_ptr<tree_const_init_val>($1));
        }
    | ConstInitVallist "," ConstInitVal
        {
            $1->const_init_vals.push_back(std::shared_ptr<tree_const_init_val>($3));
            $$ = $1;
        }
    ;

ConstExp
    : AddExp
        {
            $$ = new tree_const_exp();
            $$->_line_no = yyline+1;
            $$->add_exp = std::shared_ptr<tree_add_exp>($1);
        }
    ;

VarDecl
    : BType VarDefList ";"
        {
            $$ = new tree_var_decl();
            $$->_line_no = yyline+1;
            $$->b_type=std::shared_ptr<tree_basic_type>($1);
            $$->var_def_list=std::shared_ptr<tree_var_def_list>($2);
        }
    ;

VarDefList
    : VarDef
        {
            $$ = new tree_var_def_list();
            $$->_line_no = yyline+1;
            $$->var_defs.push_back(std::shared_ptr<tree_var_def>($1));
        }
    |  VarDefList "," VarDef
        {
            $1->var_defs.push_back(std::shared_ptr<tree_var_def>($3));
            $$ = $1;
        }
    ;

VarDef
    : TIDENTIFIER
        {
            $$ = new tree_var_def();
            $$->_line_no = yyline+1;
            $$->id = *$1;
        }
    | TIDENTIFIER "=" InitVal
        {
            $$ = new tree_var_def();
            $$->_line_no = yyline+1;
            $$->id = *$1;
            $$->init_val = std::shared_ptr<tree_init_val>($3);
        };
    | TIDENTIFIER ArrayDef
        {
            $$ = new tree_var_def();
            $$->_line_no = yyline+1;
            $$->id = *$1;
            $$->array_def = std::shared_ptr<tree_arrray_def>($2);
        }
    | TIDENTIFIER ArrayDef "=" InitVal
        {
            $$ = new tree_var_def();
            $$->_line_no = yyline+1;
            $$->id = *$1;
            $$->array_def = std::shared_ptr<tree_arrray_def>($2);
            $$->init_val = std::shared_ptr<tree_init_val>($4);
        }
    ;

ArrayDef
    : "[" ConstExp "]"
        {
            $$ = new tree_arrray_def();
            $$->_line_no = yyline+1;
            $$->const_exps.push_back(std::shared_ptr<tree_const_exp>($2));
        }
    | ArrayDef "[" ConstExp "]"
        {
            $$->const_exps.push_back(std::shared_ptr<tree_const_exp>($3));
            $$ = $1;
        }
    ;

/* wq */
InitVal
    : Exp
        {
            $$ = new tree_init_val();
            $$->_line_no = yyline+1;
            $$->exp=std::shared_ptr<tree_exp>($1);
        }
    | "{" "}" {
            $$ = new tree_init_val();
            $$->_line_no = yyline+1;
    }
    | "{" InitValList "}" {
            $$ = new tree_init_val();
            $$->_line_no = yyline+1;
            $$->init_val_list = std::shared_ptr<tree_init_val_list>($2);
    }
    ;

InitValList
    : InitVal {
        $$ = new tree_init_val_list();
        $$->_line_no = yyline+1;
        $$->init_vals.push_back(std::shared_ptr<tree_init_val>($1));
    }
    | InitValList "," InitVal {
        $1->init_vals.push_back(std::shared_ptr<tree_init_val>($3));
        $$ = $1;
    }
    ;

/* 函数相关 */
FuncDef
    : BType TIDENTIFIER "("")" Block
        {
            $$ = new tree_func_def();
            $$->_line_no = yyline+1;
            $$->type = std::shared_ptr<tree_basic_type>($1);
            $$->id = *$2;
            $$->block.push_back(std::shared_ptr<tree_block>($5));
        }
    | BType TIDENTIFIER "(" FuncFParams ")" Block
        {
            $$ = new tree_func_def();
            $$->_line_no = yyline+1;
            $$->type = std::shared_ptr<tree_basic_type>($1);
            $$->id = *$2;
            $$->funcfparams = std::shared_ptr<tree_func_fparams>($4);

            $$->block.push_back(std::shared_ptr<tree_block>($6));
        }
    ;

FuncFParams
    : FuncFParam
        {
            $$ = new tree_func_fparams();
            $$->_line_no = yyline+1;
            $$->funcfparamlist.push_back(std::shared_ptr<tree_func_fparam>($1));
        }
    | FuncFParams "," FuncFParam
        {
            $1->funcfparamlist.push_back(std::shared_ptr<tree_func_fparam>($3));
            $$ = $1;
        }
    ;

FuncFParam
    : FuncFParamOne
        {
            $$ = new tree_func_fparam();
            $$->_line_no = yyline+1;
            $$->funcfparamone = std::shared_ptr<tree_func_fparamone>($1);
        }
    | FuncFParamArray
        {
            $$ = new tree_func_fparam();
            $$->_line_no = yyline+1;
            $$->funcfparamarray = std::shared_ptr<tree_func_fparamarray>($1);
        }
    ;

FuncFParamOne
    : BType TIDENTIFIER
        {
            $$ = new tree_func_fparamone();
            $$->_line_no = yyline+1;
            $$->b_type = std::shared_ptr<tree_basic_type>($1);
            $$->id = *$2;
        }
    ;

FuncFParamArray
    : BType TIDENTIFIER "[" "]"
        {
            $$ = new tree_func_fparamarray();
            $$->_line_no = yyline+1;
            $$->b_type = std::shared_ptr<tree_basic_type>($1);
            $$->id = *$2;
        }
    | FuncFParamArray "[" Exp "]"
        {
            $1->exps.push_back(std::shared_ptr<tree_exp>($3));
            $$ = $1;
        }
    ;

Block
    : "{" "}"
        {
            $$ = new tree_block();
            $$->_line_no = yyline+1;
        }
    | "{" BlockItemList "}"
        {
            $$ = new tree_block();
            $$->_line_no = yyline+1;
            $$->block_item_list=std::shared_ptr<tree_block_item_list>($2);
        }
    ;

BlockItemList
    : BlockItem
        {
            $$ = new tree_block_item_list();
            $$->_line_no = yyline+1;
            $$->block_items.push_back(std::shared_ptr<tree_block_item>($1));
        }
    |  BlockItemList BlockItem
        {
            $1->block_items.push_back(std::shared_ptr<tree_block_item>($2));
            $$=$1;
        }
    ;

BlockItem
    : Decl
        {
            $$ = new tree_block_item();
            $$->_line_no = yyline+1;
            $$->decl=std::shared_ptr<tree_decl>($1);
        }
    | Stmt
        {
            $$ = new tree_block_item();
            $$->_line_no = yyline+1;
            $$->stmt=std::shared_ptr<tree_stmt>($1);
        }
    ;

/* 语句相关 */
Stmt
    : LVal "=" Exp ";"
        /* assign statement */
        {
            $$ = new tree_stmt();
            $$->_line_no = yyline+1;
            auto a_stmt = new tree_assign_stmt();
            a_stmt->l_val=std::shared_ptr<tree_l_val>($1);
            a_stmt->exp=std::shared_ptr<tree_exp>($3);
            $$->assigm_stmt=std::shared_ptr<tree_assign_stmt>(a_stmt) ;
        }
    | ";"
        {
            $$ = new tree_stmt();
            $$->_line_no = yyline+1;
        }
    | Exp ";"
        {
            $$ = new tree_stmt();
            $$->_line_no = yyline+1;
            $$->exp=std::shared_ptr<tree_exp>($1) ;
        }
    | Block
        {
            $$ = new tree_stmt();
            $$->_line_no = yyline+1;
            $$->block=std::shared_ptr<tree_block>($1) ;
        }
    /* if statement */
    | "if" "(" Cond ")" Stmt
        {
            $$ = new tree_stmt();
            $$->_line_no = yyline+1;
            auto if_stmt = new tree_if_stmt();
            if_stmt->cond = std::shared_ptr<tree_cond>($3);
            if_stmt->stmt = std::shared_ptr<tree_stmt>($5);
            $$->if_stmt = std::shared_ptr<tree_if_stmt>(if_stmt) ;
        }
    | "if" "(" Cond ")" Stmt "else" Stmt
        {
            $$ = new tree_stmt();
            $$->_line_no = yyline+1;
            auto if_else_stmt = new tree_if_else_stmt();
            if_else_stmt->cond = std::shared_ptr<tree_cond>($3);
            if_else_stmt->then_stmt = std::shared_ptr<tree_stmt>($5);
            if_else_stmt->else_stmt = std::shared_ptr<tree_stmt>($7);
            $$->if_else_stmt = std::shared_ptr<tree_if_else_stmt>(if_else_stmt) ;

        }
    /* while statement */
    | "while" "(" Cond ")" Stmt
        {
            $$ = new tree_stmt();
            $$->_line_no = yyline+1;
            auto while_stmt = new tree_while_stmt();
            while_stmt->cond = std::shared_ptr<tree_cond>($3);
            while_stmt->stmt = std::shared_ptr<tree_stmt>($5);
            $$->while_stmt = std::shared_ptr<tree_while_stmt>(while_stmt) ;
        }
    | "continue" ";"
        {
            $$ = new tree_stmt();
            $$->_line_no = yyline+1;
            auto continue_stmt = new tree_continue_stmt();
            $$->continue_stmt = std::shared_ptr<tree_continue_stmt>(continue_stmt) ;
        }
    | "break" ";"
        {
            $$ = new tree_stmt();
            $$->_line_no = yyline+1;
            auto break_stmt = new tree_break_stmt();
            $$->break_stmt = std::shared_ptr<tree_break_stmt>(break_stmt) ;
        }
    /* return statement */
    | "return" ";"
        {
            $$ = new tree_stmt();
            $$->_line_no = yyline+1;
            auto a_stmt = new tree_return_null_stmt();
            $$->return_null_stmt=std::shared_ptr<tree_return_null_stmt>(a_stmt) ;
        }
    | "return" Exp ";"
        {
            $$ = new tree_stmt();
            $$->_line_no = yyline+1;
            auto a_stmt = new tree_return_stmt();
            a_stmt->exp=std::shared_ptr<tree_exp>($2);
            $$->return_stmt=std::shared_ptr<tree_return_stmt>(a_stmt) ;
        }
    ;

/* 表达式相关 */
Exp
    : AddExp
        {
            $$ = new tree_exp();
            $$->_line_no = yyline+1;
            $$->add_exp = std::shared_ptr<tree_add_exp>($1);
        }
    ;

Cond
    : LOrExp
        {
            $$ = new tree_cond();
            $$->_line_no = yyline+1;
            $$->l_or_exp = std::shared_ptr<tree_l_or_exp>($1);
        }
    ;

LVal
    : TIDENTIFIER
        {
            $$ = new tree_l_val();
            $$->_line_no = yyline+1;
            $$->id = *$1;
        }
    | ArrayIdent
        {
            $$ = new tree_l_val();
            $$->_line_no = yyline+1;
            $$->array_ident = std::shared_ptr<tree_array_ident>($1);
        }
    ;

ArrayIdent
    : TIDENTIFIER "[" Exp "]"
        {
            $$ = new tree_array_ident();
            $$->_line_no = yyline+1;
            $$->id = *$1;
            $$->exps.push_back(std::shared_ptr<tree_exp>($3));
        }
    | ArrayIdent "[" Exp "]"
        {
            $1->exps.push_back(std::shared_ptr<tree_exp>($3));
            $$ = $1;
        }
    ;

Number
    : TINTEGER
        {
            $$ = new tree_number();
            $$->_line_no = yyline+1;
            $$->int_value = std::stoi($1->c_str(), nullptr, 0);
            $$->is_int=true;
        }
    | TFLOATNUM
        {
            $$ = new tree_number();
            $$->_line_no = yyline+1;
            $$->float_value = (float)atof($1->c_str());
            $$->is_int=false;
        }
    ;

PrimaryExp
    : "(" Exp ")"
        {
            $$ = new tree_primary_exp();
            $$->_line_no = yyline+1;
            $$->exp = std::shared_ptr<tree_exp>($2);
        }
    | LVal
        {
            $$ = new tree_primary_exp();
            $$->_line_no = yyline+1;
            $$->l_val = std::shared_ptr<tree_l_val>($1);
        }
    | Number
        {
            $$ = new tree_primary_exp();
            $$->_line_no = yyline+1;
            $$->number = std::shared_ptr<tree_number>($1);
        }
    ;

UnaryExp
    : PrimaryExp
        {
            $$ = new tree_unary_exp();
            $$->_line_no = yyline+1;
            $$->primary_exp = std::shared_ptr<tree_primary_exp>($1);
        }
    | "+" UnaryExp
        {
            $$ = new tree_unary_exp();
            $$->_line_no = yyline+1;
            $$->unary_exp=std::shared_ptr<tree_unary_exp>($2);
            $$->oprt="+";
        }
    | "-" UnaryExp
        {
            $$ = new tree_unary_exp();
            $$->_line_no = yyline+1;
            $$->unary_exp=std::shared_ptr<tree_unary_exp>($2);
            $$->oprt="-";
        }
    | "!" UnaryExp
        {
            $$ = new tree_unary_exp();
            $$->_line_no = yyline+1;
            $$->unary_exp=std::shared_ptr<tree_unary_exp>($2);
            $$->oprt="!";
        };
    /* FUNCTION CALL */
    | FuncCall
        {
            $$ = new tree_unary_exp();
            $$->_line_no = yyline+1;
            $$->func_call = std::shared_ptr<tree_func_call>($1);
        }
    ;

FuncCall
    : TIDENTIFIER "(" ")"
        {
            $$ = new tree_func_call();
            $$->_line_no = yyline+1;
            $$->id = *$1;
        }
    | TIDENTIFIER "(" FuncParamList ")"
        {
            $$ = new tree_func_call();
            $$->_line_no = yyline+1;
            $$->id = *$1;
            $$->func_param_list = std::shared_ptr<tree_func_paramlist>($3);
        }
    ;

FuncParamList
    : Exp
        {
            $$ = new tree_func_paramlist();
            $$->_line_no = yyline+1;
            $$->exps.push_back(std::shared_ptr<tree_exp>($1));
        }
    | FuncParamList "," Exp
        {
            $1->exps.push_back(std::shared_ptr<tree_exp>($3));
            $$ = $1;
        }
    ;
/* jyx */


MulExp
    : UnaryExp
        {
            $$ = new tree_mul_exp();
            $$->_line_no = yyline+1;
            $$->unary_exp=std::shared_ptr<tree_unary_exp>($1);
        }
    | MulExp "*" UnaryExp
        {
            $$ = new tree_mul_exp();
            $$->_line_no = yyline+1;
            $$->mul_exp=std::shared_ptr<tree_mul_exp>($1);
            $$->unary_exp=std::shared_ptr<tree_unary_exp>($3);
            $$->oprt="*";
        }
    | MulExp "/" UnaryExp
        {
            $$ = new tree_mul_exp();
            $$->_line_no = yyline+1;
            $$->mul_exp=std::shared_ptr<tree_mul_exp>($1);
            $$->unary_exp=std::shared_ptr<tree_unary_exp>($3);
            $$->oprt="/";
        }
    | MulExp "%" UnaryExp
        {
            $$ = new tree_mul_exp();
            $$->_line_no = yyline+1;
            $$->mul_exp=std::shared_ptr<tree_mul_exp>($1);
            $$->unary_exp=std::shared_ptr<tree_unary_exp>($3);
            $$->oprt="%";
        }
    ;
AddExp
    : MulExp
        {
            $$ = new tree_add_exp();
            $$->_line_no = yyline+1;
            $$->mul_exp=std::shared_ptr<tree_mul_exp>($1);
        }
    | AddExp "+" MulExp
        {
            $$ = new tree_add_exp();
            $$->_line_no = yyline+1;
            $$->add_exp=std::shared_ptr<tree_add_exp>($1);
            $$->oprt="+";
            $$->mul_exp=std::shared_ptr<tree_mul_exp>($3);
        }
    | AddExp "-" MulExp
        {
            $$ = new tree_add_exp();
            $$->_line_no = yyline+1;
            $$->add_exp=std::shared_ptr<tree_add_exp>($1);
            $$->oprt="-";
            $$->mul_exp=std::shared_ptr<tree_mul_exp>($3);
        }
    ;
RelExp
    : AddExp
        {
            $$ = new tree_rel_exp();
            $$->_line_no = yyline+1;
            $$->add_exp=std::shared_ptr<tree_add_exp>($1);
        }
    | RelExp "<" AddExp
        {
            $$ = new tree_rel_exp();
            $$->_line_no = yyline+1;
            $$->rel_exp=std::shared_ptr<tree_rel_exp>($1);
            $$->oprt="<";
            $$->add_exp=std::shared_ptr<tree_add_exp>($3);
        }
    | RelExp ">" AddExp
        {
            $$ = new tree_rel_exp();
            $$->_line_no = yyline+1;
            $$->rel_exp=std::shared_ptr<tree_rel_exp>($1);
            $$->oprt=">";
            $$->add_exp=std::shared_ptr<tree_add_exp>($3);
        }
    | RelExp "<=" AddExp
        {
            $$ = new tree_rel_exp();
            $$->_line_no = yyline+1;
            $$->rel_exp=std::shared_ptr<tree_rel_exp>($1);
            $$->oprt="<=";
            $$->add_exp=std::shared_ptr<tree_add_exp>($3);
        }
    | RelExp ">=" AddExp
        {
            $$ = new tree_rel_exp();
            $$->_line_no = yyline+1;
            $$->rel_exp=std::shared_ptr<tree_rel_exp>($1);
            $$->oprt=">=";
            $$->add_exp=std::shared_ptr<tree_add_exp>($3);
        }
    ;
EqExp
    : RelExp
        {
            $$ = new tree_eq_exp();
            $$->_line_no = yyline+1;
            $$->rel_exp=std::shared_ptr<tree_rel_exp>($1);
        }
    | EqExp "==" RelExp
        {
            $$ = new tree_eq_exp();
            $$->_line_no = yyline+1;
            $$->eq_exp=std::shared_ptr<tree_eq_exp>($1);
            $$->oprt="==";
            $$->rel_exp=std::shared_ptr<tree_rel_exp>($3);
        }
    | EqExp "!=" RelExp
        {
            $$ = new tree_eq_exp();
            $$->_line_no = yyline+1;
            $$->eq_exp=std::shared_ptr<tree_eq_exp>($1);
            $$->oprt="!=";
            $$->rel_exp=std::shared_ptr<tree_rel_exp>($3);
        }
    ;
LAndExp
    : EqExp
        {
            $$ = new tree_l_and_exp();
            $$->_line_no = yyline+1;
            $$->eq_exp=std::shared_ptr<tree_eq_exp>($1);
        }
    | LAndExp "&&" EqExp
        {
            $$ = new tree_l_and_exp();
            $$->_line_no = yyline+1;
            $$->l_and_exp=std::shared_ptr<tree_l_and_exp>($1);
            $$->eq_exp=std::shared_ptr<tree_eq_exp>($3);
        }
    ;
LOrExp
    : LAndExp
        {
            $$ = new tree_l_or_exp();
            $$->_line_no = yyline+1;
            $$->l_and_exp=std::shared_ptr<tree_l_and_exp>($1);
        }
    | LOrExp "||" LAndExp
        {
            $$ = new tree_l_or_exp();
            $$->_line_no = yyline+1;
            $$->l_or_exp=std::shared_ptr<tree_l_or_exp>($1);
            $$->l_and_exp=std::shared_ptr<tree_l_and_exp>($3);
        }
    ;
%%
void insertVarible(std::string& type,std::string& id){
    VaribleTable.insert(std::make_pair<std::string, VaribleInfo>(std::string(id),VaribleInfo(type)));
}
void insertFunction(std::string& type,std::string& id){
    FunctionTable.insert(
        std::make_pair<std::string, FunctionInfo>
            (std::string(id),FunctionInfo(type,VaribleTable)));
    VaribleTable.clear();
}
