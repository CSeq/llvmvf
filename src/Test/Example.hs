module Test.Example where

import Language.LLVMIR 
import Data.Map
{-
test = Module {id_Module_Module = "fpo.bc", layout_Module_Module = DataLayout {s_DataLayout_DataLayout = ["e","p:64:64:64","i1:8:8","i8:8:8","i16:16:16","i32:32:32","i64:64:64","f32:32:32","f64:64:64","v64:64:64","v128:128:128","a0:0:64","s0:64:64","f80:128:128","n8:16:32:64","S128"]}, target_Module_Module = TargetData {s_TargetData_TargetData = "x86_64-redhat-linux-gnu", t_TargetData_TargetData = Linux}, gvars_Module_Module = [GlobalVar {name_Global_GlobalVar = Global {name_Identifier_Global = ".str"}, linkage_Global_GlobalVar = PrivateLinkage, isConst_Global_GlobalVar = True, isUaddr_Global_GlobalVar = True, ty_Global_GlobalVar = TyPointer {ty_Type_TyPointer = TyArray {numEl_Type_TyArray = 6, ty_Type_TyArray = TyInt {p_Type_TyInt = 8}}}, ival_Global_GlobalVar = Just (CmpConst {cc_Constant_CmpConst = ConstantDataSequential {cds_ComplexConstant_ConstantDataSequential = ConstantDataArray {ty_ConstantDataSequential_ConstantDataArray = TyArray {numEl_Type_TyArray = 6, ty_Type_TyArray = TyInt {p_Type_TyInt = 8}}, val_ConstantDataSequential_ConstantDataArray = "DoIt\n"}}}), align_Global_GlobalVar = Align {n_Align_Align = 1}},GlobalVar {name_Global_GlobalVar = Global {name_Identifier_Global = ".str1"}, linkage_Global_GlobalVar = PrivateLinkage, isConst_Global_GlobalVar = True, isUaddr_Global_GlobalVar = True, ty_Global_GlobalVar = TyPointer {ty_Type_TyPointer = TyArray {numEl_Type_TyArray = 4, ty_Type_TyArray = TyInt {p_Type_TyInt = 8}}}, ival_Global_GlobalVar = Just (CmpConst {cc_Constant_CmpConst = ConstantDataSequential {cds_ComplexConstant_ConstantDataSequential = ConstantDataArray {ty_ConstantDataSequential_ConstantDataArray = TyArray {numEl_Type_TyArray = 4, ty_Type_TyArray = TyInt {p_Type_TyInt = 8}}, val_ConstantDataSequential_ConstantDataArray = "%d\n"}}}), align_Global_GlobalVar = Align {n_Align_Align = 1}}], funs_Module_Module = fromList [("DoIt",FunctionDef {name_Function_FunctionDef = Global {name_Identifier_Global = "DoIt"}, linkage_Function_FunctionDef = ExternalLinkage, retty_Function_FunctionDef = TyInt {p_Type_TyInt = 32}, isVar_Function_FunctionDef = False, params_Function_FunctionDef = [Parameter {var_Parameter_Parameter = Local {name_Identifier_Local = "a"}, ty_Parameter_Parameter = TyFloatPoint {p_Type_TyFloatPoint = TyFloat}},Parameter {var_Parameter_Parameter = Local {name_Identifier_Local = "b"}, ty_Parameter_Parameter = TyInt {p_Type_TyInt = 8}},Parameter {var_Parameter_Parameter = Local {name_Identifier_Local = "c"}, ty_Parameter_Parameter = TyInt {p_Type_TyInt = 8}}], body_Function_FunctionDef = [BasicBlock {label_BasicBlock_BasicBlock = Local {name_Identifier_Local = "bb"}, instrs_BasicBlock_BasicBlock = [Alloca {pc_Instruction_Alloca = 1, id_Instruction_Alloca = Local {name_Identifier_Local = "tmp"}, ty_Instruction_Alloca = TyFloatPoint {p_Type_TyFloatPoint = TyFloat}, align_Instruction_Alloca = Align {n_Align_Align = 4}},Alloca {pc_Instruction_Alloca = 2, id_Instruction_Alloca = Local {name_Identifier_Local = "tmp1"}, ty_Instruction_Alloca = TyInt {p_Type_TyInt = 8}, align_Instruction_Alloca = Align {n_Align_Align = 1}},Alloca {pc_Instruction_Alloca = 3, id_Instruction_Alloca = Local {name_Identifier_Local = "tmp2"}, ty_Instruction_Alloca = TyInt {p_Type_TyInt = 8}, align_Instruction_Alloca = Align {n_Align_Align = 1}},Store {pc_Instruction_Store = 4, ty_Instruction_Store = TyVoid, v1_Instruction_Store = Id {v_Value_Id = Local {name_Identifier_Local = "a"}, ty_Value_Id = TyFloatPoint {p_Type_TyFloatPoint = TyFloat}}, v2_Instruction_Store = Id {v_Value_Id = Local {name_Identifier_Local = "tmp"}, ty_Value_Id = TyPointer {ty_Type_TyPointer = TyFloatPoint {p_Type_TyFloatPoint = TyFloat}}}, align_Instruction_Store = Align {n_Align_Align = 4}},Store {pc_Instruction_Store = 5, ty_Instruction_Store = TyVoid, v1_Instruction_Store = Id {v_Value_Id = Local {name_Identifier_Local = "b"}, ty_Value_Id = TyInt {p_Type_TyInt = 8}}, v2_Instruction_Store = Id {v_Value_Id = Local {name_Identifier_Local = "tmp1"}, ty_Value_Id = TyPointer {ty_Type_TyPointer = TyInt {p_Type_TyInt = 8}}}, align_Instruction_Store = Align {n_Align_Align = 1}},Store {pc_Instruction_Store = 6, ty_Instruction_Store = TyVoid, v1_Instruction_Store = Id {v_Value_Id = Local {name_Identifier_Local = "c"}, ty_Value_Id = TyInt {p_Type_TyInt = 8}}, v2_Instruction_Store = Id {v_Value_Id = Local {name_Identifier_Local = "tmp2"}, ty_Value_Id = TyPointer {ty_Type_TyPointer = TyInt {p_Type_TyInt = 8}}}, align_Instruction_Store = Align {n_Align_Align = 1}},Call {pc_Instruction_Call = 7, mres_Instruction_Call = Local {name_Identifier_Local = "tmp3"}, ty_Instruction_Call = TyInt {p_Type_TyInt = 32}, callee_Instruction_Call = Global {name_Identifier_Global = "printf"}, args_Instruction_Call = [Constant {c_Value_Constant = ConstantExpr {expr_Constant_ConstantExpr = GetElementPtrConstantExpr {struct_ConstantExpr_GetElementPtrConstantExpr = Constant {c_Value_Constant = GlobalValue {gv_Constant_GlobalValue = GlobalVariable {n_GlobalValue_GlobalVariable = Global {name_Identifier_Global = ".str"}, ty_GlobalValue_GlobalVariable = TyPointer {ty_Type_TyPointer = TyArray {numEl_Type_TyArray = 6, ty_Type_TyArray = TyInt {p_Type_TyInt = 8}}}}}}, idxs_ConstantExpr_GetElementPtrConstantExpr = [Constant {c_Value_Constant = SmpConst {sc_Constant_SmpConst = ConstantInt {iv_SimpleConstant_ConstantInt = 0, ty_SimpleConstant_ConstantInt = TyInt {p_Type_TyInt = 32}}}},Constant {c_Value_Constant = SmpConst {sc_Constant_SmpConst = ConstantInt {iv_SimpleConstant_ConstantInt = 6, ty_SimpleConstant_ConstantInt = TyInt {p_Type_TyInt = 32}}}}]}}}]},Load {pc_Instruction_Load = 8, id_Instruction_Load = Local {name_Identifier_Local = "tmp4"}, v_Instruction_Load = Id {v_Value_Id = Local {name_Identifier_Local = "tmp"}, ty_Value_Id = TyPointer {ty_Type_TyPointer = TyFloatPoint {p_Type_TyFloatPoint = TyFloat}}}, align_Instruction_Load = Align {n_Align_Align = 4}},Load {pc_Instruction_Load = 9, id_Instruction_Load = Local {name_Identifier_Local = "tmp5"}, v_Instruction_Load = Id {v_Value_Id = Local {name_Identifier_Local = "tmp1"}, ty_Value_Id = TyPointer {ty_Type_TyPointer = TyInt {p_Type_TyInt = 8}}}, align_Instruction_Load = Align {n_Align_Align = 1}},SExt {pc_Instruction_SExt = 10, id_Instruction_SExt = Local {name_Identifier_Local = "tmp6"}, v_Instruction_SExt = Id {v_Value_Id = Local {name_Identifier_Local = "tmp5"}, ty_Value_Id = TyInt {p_Type_TyInt = 8}}, ty_Instruction_SExt = TyInt {p_Type_TyInt = 32}},SIToFP {pc_Instruction_SIToFP = 11, id_Instruction_SIToFP = Local {name_Identifier_Local = "tmp7"}, v_Instruction_SIToFP = Id {v_Value_Id = Local {name_Identifier_Local = "tmp6"}, ty_Value_Id = TyInt {p_Type_TyInt = 32}}, ty_Instruction_SIToFP = TyFloatPoint {p_Type_TyFloatPoint = TyFloat}},FAdd {pc_Instruction_FAdd = 12, id_Instruction_FAdd = Local {name_Identifier_Local = "tmp8"}, ty_Instruction_FAdd = TyFloatPoint {p_Type_TyFloatPoint = TyFloat}, op1_Instruction_FAdd = Id {v_Value_Id = Local {name_Identifier_Local = "tmp4"}, ty_Value_Id = TyFloatPoint {p_Type_TyFloatPoint = TyFloat}}, op2_Instruction_FAdd = Id {v_Value_Id = Local {name_Identifier_Local = "tmp7"}, ty_Value_Id = TyFloatPoint {p_Type_TyFloatPoint = TyFloat}}},Load {pc_Instruction_Load = 13, id_Instruction_Load = Local {name_Identifier_Local = "tmp9"}, v_Instruction_Load = Id {v_Value_Id = Local {name_Identifier_Local = "tmp2"}, ty_Value_Id = TyPointer {ty_Type_TyPointer = TyInt {p_Type_TyInt = 8}}}, align_Instruction_Load = Align {n_Align_Align = 1}},SExt {pc_Instruction_SExt = 14, id_Instruction_SExt = Local {name_Identifier_Local = "tmp10"}, v_Instruction_SExt = Id {v_Value_Id = Local {name_Identifier_Local = "tmp9"}, ty_Value_Id = TyInt {p_Type_TyInt = 8}}, ty_Instruction_SExt = TyInt {p_Type_TyInt = 32}},SIToFP {pc_Instruction_SIToFP = 15, id_Instruction_SIToFP = Local {name_Identifier_Local = "tmp11"}, v_Instruction_SIToFP = Id {v_Value_Id = Local {name_Identifier_Local = "tmp10"}, ty_Value_Id = TyInt {p_Type_TyInt = 32}}, ty_Instruction_SIToFP = TyFloatPoint {p_Type_TyFloatPoint = TyFloat}},FAdd {pc_Instruction_FAdd = 16, id_Instruction_FAdd = Local {name_Identifier_Local = "tmp12"}, ty_Instruction_FAdd = TyFloatPoint {p_Type_TyFloatPoint = TyFloat}, op1_Instruction_FAdd = Id {v_Value_Id = Local {name_Identifier_Local = "tmp8"}, ty_Value_Id = TyFloatPoint {p_Type_TyFloatPoint = TyFloat}}, op2_Instruction_FAdd = Id {v_Value_Id = Local {name_Identifier_Local = "tmp11"}, ty_Value_Id = TyFloatPoint {p_Type_TyFloatPoint = TyFloat}}},FPToSI {pc_Instruction_FPToSI = 17, id_Instruction_FPToSI = Local {name_Identifier_Local = "tmp13"}, v_Instruction_FPToSI = Id {v_Value_Id = Local {name_Identifier_Local = "tmp12"}, ty_Value_Id = TyFloatPoint {p_Type_TyFloatPoint = TyFloat}}, ty_Instruction_FPToSI = TyInt {p_Type_TyInt = 32}},Ret {pc_Instruction_Ret = 18, r_Instruction_Ret = ValueRet {v_RetInst_ValueRet = Id {v_Value_Id = Local {name_Identifier_Local = "tmp13"}, ty_Value_Id = TyInt {p_Type_TyInt = 32}}}}]}]}),("main",FunctionDef {name_Function_FunctionDef = Global {name_Identifier_Global = "main"}, linkage_Function_FunctionDef = ExternalLinkage, retty_Function_FunctionDef = TyInt {p_Type_TyInt = 32}, isVar_Function_FunctionDef = False, params_Function_FunctionDef = [], body_Function_FunctionDef = [BasicBlock {label_BasicBlock_BasicBlock = Local {name_Identifier_Local = "bb"}, instrs_BasicBlock_BasicBlock = [Alloca {pc_Instruction_Alloca = 19, id_Instruction_Alloca = Local {name_Identifier_Local = "tmp"}, ty_Instruction_Alloca = TyInt {p_Type_TyInt = 32}, align_Instruction_Alloca = Align {n_Align_Align = 4}},Alloca {pc_Instruction_Alloca = 20, id_Instruction_Alloca = Local {name_Identifier_Local = "pt2Function"}, ty_Instruction_Alloca = TyPointer {ty_Type_TyPointer = TyFunction {party_Type_TyFunction = [TyFloatPoint {p_Type_TyFloatPoint = TyFloat},TyInt {p_Type_TyInt = 8},TyInt {p_Type_TyInt = 8}], retty_Type_TyFunction = TyInt {p_Type_TyInt = 32}, isVar_Type_TyFunction = False}}, align_Instruction_Alloca = Align {n_Align_Align = 8}},Alloca {pc_Instruction_Alloca = 21, id_Instruction_Alloca = Local {name_Identifier_Local = "result1"}, ty_Instruction_Alloca = TyInt {p_Type_TyInt = 32}, align_Instruction_Alloca = Align {n_Align_Align = 4}},Store {pc_Instruction_Store = 22, ty_Instruction_Store = TyVoid, v1_Instruction_Store = Constant {c_Value_Constant = SmpConst {sc_Constant_SmpConst = ConstantInt {iv_SimpleConstant_ConstantInt = 0, ty_SimpleConstant_ConstantInt = TyInt {p_Type_TyInt = 32}}}}, v2_Instruction_Store = Id {v_Value_Id = Local {name_Identifier_Local = "tmp"}, ty_Value_Id = TyPointer {ty_Type_TyPointer = TyInt {p_Type_TyInt = 32}}}, align_Instruction_Store = Align {n_Align_Align = 0}},Store {pc_Instruction_Store = 23, ty_Instruction_Store = TyVoid, v1_Instruction_Store = Constant {c_Value_Constant = SmpConst {sc_Constant_SmpConst = ConstantPointerNull {ty_SimpleConstant_ConstantPointerNull = TyPointer {ty_Type_TyPointer = TyFunction {party_Type_TyFunction = [TyFloatPoint {p_Type_TyFloatPoint = TyFloat},TyInt {p_Type_TyInt = 8},TyInt {p_Type_TyInt = 8}], retty_Type_TyFunction = TyInt {p_Type_TyInt = 32}, isVar_Type_TyFunction = False}}}}}, v2_Instruction_Store = Id {v_Value_Id = Local {name_Identifier_Local = "pt2Function"}, ty_Value_Id = TyPointer {ty_Type_TyPointer = TyPointer {ty_Type_TyPointer = TyFunction {party_Type_TyFunction = [TyFloatPoint {p_Type_TyFloatPoint = TyFloat},TyInt {p_Type_TyInt = 8},TyInt {p_Type_TyInt = 8}], retty_Type_TyFunction = TyInt {p_Type_TyInt = 32}, isVar_Type_TyFunction = False}}}}, align_Instruction_Store = Align {n_Align_Align = 8}},Store {pc_Instruction_Store = 24, ty_Instruction_Store = TyVoid, v1_Instruction_Store = Constant {c_Value_Constant = GlobalValue {gv_Constant_GlobalValue = FunctionValue {n_GlobalValue_FunctionValue = Global {name_Identifier_Global = "DoIt"}, ty_GlobalValue_FunctionValue = TyPointer {ty_Type_TyPointer = TyFunction {party_Type_TyFunction = [TyFloatPoint {p_Type_TyFloatPoint = TyFloat},TyInt {p_Type_TyInt = 8},TyInt {p_Type_TyInt = 8}], retty_Type_TyFunction = TyInt {p_Type_TyInt = 32}, isVar_Type_TyFunction = False}}}}}, v2_Instruction_Store = Id {v_Value_Id = Local {name_Identifier_Local = "pt2Function"}, ty_Value_Id = TyPointer {ty_Type_TyPointer = TyPointer {ty_Type_TyPointer = TyFunction {party_Type_TyFunction = [TyFloatPoint {p_Type_TyFloatPoint = TyFloat},TyInt {p_Type_TyInt = 8},TyInt {p_Type_TyInt = 8}], retty_Type_TyFunction = TyInt {p_Type_TyInt = 32}, isVar_Type_TyFunction = False}}}}, align_Instruction_Store = Align {n_Align_Align = 8}},Load {pc_Instruction_Load = 25, id_Instruction_Load = Local {name_Identifier_Local = "tmp1"}, v_Instruction_Load = Id {v_Value_Id = Local {name_Identifier_Local = "pt2Function"}, ty_Value_Id = TyPointer {ty_Type_TyPointer = TyPointer {ty_Type_TyPointer = TyFunction {party_Type_TyFunction = [TyFloatPoint {p_Type_TyFloatPoint = TyFloat},TyInt {p_Type_TyInt = 8},TyInt {p_Type_TyInt = 8}], retty_Type_TyFunction = TyInt {p_Type_TyInt = 32}, isVar_Type_TyFunction = False}}}}, align_Instruction_Load = Align {n_Align_Align = 8}},Call {pc_Instruction_Call = 26, mres_Instruction_Call = Local {name_Identifier_Local = "tmp2"}, ty_Instruction_Call = TyInt {p_Type_TyInt = 32}, callee_Instruction_Call = Global {name_Identifier_Global = "tmp1"}, args_Instruction_Call = [Constant {c_Value_Constant = SmpConst {sc_Constant_SmpConst = ConstantFP {fp_SimpleConstant_ConstantFP = ConstantFPFloat {fpv_ConstantFP_ConstantFPFloat = 12.0, ty_ConstantFP_ConstantFPFloat = TyFloatPoint {p_Type_TyFloatPoint = TyFloat}}}}},Constant {c_Value_Constant = SmpConst {sc_Constant_SmpConst = ConstantInt {iv_SimpleConstant_ConstantInt = 97, ty_SimpleConstant_ConstantInt = TyInt {p_Type_TyInt = 8}}}},Constant {c_Value_Constant = SmpConst {sc_Constant_SmpConst = ConstantInt {iv_SimpleConstant_ConstantInt = 98, ty_SimpleConstant_ConstantInt = TyInt {p_Type_TyInt = 8}}}}]},Store {pc_Instruction_Store = 27, ty_Instruction_Store = TyVoid, v1_Instruction_Store = Id {v_Value_Id = Local {name_Identifier_Local = "tmp2"}, ty_Value_Id = TyInt {p_Type_TyInt = 32}}, v2_Instruction_Store = Id {v_Value_Id = Local {name_Identifier_Local = "result1"}, ty_Value_Id = TyPointer {ty_Type_TyPointer = TyInt {p_Type_TyInt = 32}}}, align_Instruction_Store = Align {n_Align_Align = 4}},Load {pc_Instruction_Load = 28, id_Instruction_Load = Local {name_Identifier_Local = "tmp3"}, v_Instruction_Load = Id {v_Value_Id = Local {name_Identifier_Local = "result1"}, ty_Value_Id = TyPointer {ty_Type_TyPointer = TyInt {p_Type_TyInt = 32}}}, align_Instruction_Load = Align {n_Align_Align = 4}},Call {pc_Instruction_Call = 29, mres_Instruction_Call = Local {name_Identifier_Local = "tmp4"}, ty_Instruction_Call = TyInt {p_Type_TyInt = 32}, callee_Instruction_Call = Global {name_Identifier_Global = "printf"}, args_Instruction_Call = [Constant {c_Value_Constant = ConstantExpr {expr_Constant_ConstantExpr = GetElementPtrConstantExpr {struct_ConstantExpr_GetElementPtrConstantExpr = Constant {c_Value_Constant = GlobalValue {gv_Constant_GlobalValue = GlobalVariable {n_GlobalValue_GlobalVariable = Global {name_Identifier_Global = ".str1"}, ty_GlobalValue_GlobalVariable = TyPointer {ty_Type_TyPointer = TyArray {numEl_Type_TyArray = 4, ty_Type_TyArray = TyInt {p_Type_TyInt = 8}}}}}}, idxs_ConstantExpr_GetElementPtrConstantExpr = [Constant {c_Value_Constant = SmpConst {sc_Constant_SmpConst = ConstantInt {iv_SimpleConstant_ConstantInt = 1, ty_SimpleConstant_ConstantInt = TyInt {p_Type_TyInt = 64}}}},Constant {c_Value_Constant = SmpConst {sc_Constant_SmpConst = ConstantInt {iv_SimpleConstant_ConstantInt = 1, ty_SimpleConstant_ConstantInt = TyInt {p_Type_TyInt = 32}}}}]}}},Id {v_Value_Id = Local {name_Identifier_Local = "tmp3"}, ty_Value_Id = TyInt {p_Type_TyInt = 32}}]},Ret {pc_Instruction_Ret = 30, r_Instruction_Ret = ValueRet {v_RetInst_ValueRet = Constant {c_Value_Constant = SmpConst {sc_Constant_SmpConst = ConstantInt {iv_SimpleConstant_ConstantInt = 0, ty_SimpleConstant_ConstantInt = TyInt {p_Type_TyInt = 32}}}}}}]}]}),("printf",FunctionDecl {name_Function_FunctionDecl = Global {name_Identifier_Global = "printf"}, linkage_Function_FunctionDecl = ExternalLinkage, retty_Function_FunctionDecl = TyInt {p_Type_TyInt = 32}, isVar_Function_FunctionDecl = True, params_Function_FunctionDecl = [Parameter {var_Parameter_Parameter = Local {name_Identifier_Local = "0x0000000003e4ddf0"}, ty_Parameter_Parameter = TyPointer {ty_Type_TyPointer = TyInt {p_Type_TyInt = 8}}}]})], nmdtys_Module_Module = fromList []}

gep :: Module
gep = Module {id_Module_Module = "so.bc", layout_Module_Module = DataLayout {s_DataLayout_DataLayout = ["e","p:64:64:64","i1:8:8","i8:8:8","i16:16:16","i32:32:32","i64:64:64","f32:32:32","f64:64:64","v64:64:64","v128:128:128","a0:0:64","s0:64:64","f80:128:128","n8:16:32:64","S128"]}, target_Module_Module = TargetData {s_TargetData_TargetData = "x86_64-redhat-linux-gnu", t_TargetData_TargetData = Linux}, gvars_Module_Module = [], funs_Module_Module = fromList [("foo",FunctionDef {name_Function_FunctionDef = Global {name_Identifier_Global = "foo"}, linkage_Function_FunctionDef = ExternalLinkage, retty_Function_FunctionDef = TyPointer {ty_Type_TyPointer = TyInt {p_Type_TyInt = 32}}, isVar_Function_FunctionDef = False, params_Function_FunctionDef = [Parameter {var_Parameter_Parameter = Local {name_Identifier_Local = "s"}, ty_Parameter_Parameter = TyPointer {ty_Type_TyPointer = TyStruct {name_Type_TyStruct = "struct.ST", numEl_Type_TyStruct = 3, tys_Type_TyStruct = []}}}], body_Function_FunctionDef = [BasicBlock {label_BasicBlock_BasicBlock = Local {name_Identifier_Local = "bb"}, instrs_BasicBlock_BasicBlock = [Alloca {pc_Instruction_Alloca = 1, id_Instruction_Alloca = Local {name_Identifier_Local = "tmp"}, ty_Instruction_Alloca = TyPointer {ty_Type_TyPointer = TyStruct {name_Type_TyStruct = "struct.ST", numEl_Type_TyStruct = 3, tys_Type_TyStruct = []}}, align_Instruction_Alloca = Align {n_Align_Align = 8}},Store {pc_Instruction_Store = 2, ty_Instruction_Store = TyVoid, v1_Instruction_Store = Id {v_Value_Id = Local {name_Identifier_Local = "s"}, ty_Value_Id = TyPointer {ty_Type_TyPointer = TyStruct {name_Type_TyStruct = "struct.ST", numEl_Type_TyStruct = 3, tys_Type_TyStruct = []}}}, v2_Instruction_Store = Id {v_Value_Id = Local {name_Identifier_Local = "tmp"}, ty_Value_Id = TyPointer {ty_Type_TyPointer = TyPointer {ty_Type_TyPointer = TyStruct {name_Type_TyStruct = "struct.ST", numEl_Type_TyStruct = 3, tys_Type_TyStruct = []}}}}, align_Instruction_Store = Align {n_Align_Align = 8}},Load {pc_Instruction_Load = 3, id_Instruction_Load = Local {name_Identifier_Local = "tmp1"}, v_Instruction_Load = Id {v_Value_Id = Local {name_Identifier_Local = "tmp"}, ty_Value_Id = TyPointer {ty_Type_TyPointer = TyPointer {ty_Type_TyPointer = TyStruct {name_Type_TyStruct = "struct.ST", numEl_Type_TyStruct = 3, tys_Type_TyStruct = []}}}}, align_Instruction_Load = Align {n_Align_Align = 8}},GetElementPtr {pc_Instruction_GetElementPtr = 4, id_Instruction_GetElementPtr = Local {name_Identifier_Local = "tmp2"}, ty_Instruction_GetElementPtr = TyPointer {ty_Type_TyPointer = TyStruct {name_Type_TyStruct = "struct.ST", numEl_Type_TyStruct = 3, tys_Type_TyStruct = []}}, struct_Instruction_GetElementPtr = Id {v_Value_Id = Local {name_Identifier_Local = "tmp1"}, ty_Value_Id = TyPointer {ty_Type_TyPointer = TyStruct {name_Type_TyStruct = "struct.ST", numEl_Type_TyStruct = 3, tys_Type_TyStruct = []}}}, idxs_Instruction_GetElementPtr = [Constant {c_Value_Constant = SmpConst {sc_Constant_SmpConst = ConstantInt {iv_SimpleConstant_ConstantInt = 1, ty_SimpleConstant_ConstantInt = TyInt {p_Type_TyInt = 64}}}}]},GetElementPtr {pc_Instruction_GetElementPtr = 5, id_Instruction_GetElementPtr = Local {name_Identifier_Local = "tmp3"}, ty_Instruction_GetElementPtr = TyPointer {ty_Type_TyPointer = TyStruct {name_Type_TyStruct = "struct.RT", numEl_Type_TyStruct = 3, tys_Type_TyStruct = []}}, struct_Instruction_GetElementPtr = Id {v_Value_Id = Local {name_Identifier_Local = "tmp2"}, ty_Value_Id = TyPointer {ty_Type_TyPointer = TyStruct {name_Type_TyStruct = "struct.ST", numEl_Type_TyStruct = 3, tys_Type_TyStruct = []}}}, idxs_Instruction_GetElementPtr = [Constant {c_Value_Constant = SmpConst {sc_Constant_SmpConst = ConstantInt {iv_SimpleConstant_ConstantInt = 0, ty_SimpleConstant_ConstantInt = TyInt {p_Type_TyInt = 32}}}},Constant {c_Value_Constant = SmpConst {sc_Constant_SmpConst = ConstantInt {iv_SimpleConstant_ConstantInt = 2, ty_SimpleConstant_ConstantInt = TyInt {p_Type_TyInt = 32}}}}]},GetElementPtr {pc_Instruction_GetElementPtr = 6, id_Instruction_GetElementPtr = Local {name_Identifier_Local = "tmp4"}, ty_Instruction_GetElementPtr = TyPointer {ty_Type_TyPointer = TyArray {numEl_Type_TyArray = 10, ty_Type_TyArray = TyArray {numEl_Type_TyArray = 20, ty_Type_TyArray = TyInt {p_Type_TyInt = 32}}}}, struct_Instruction_GetElementPtr = Id {v_Value_Id = Local {name_Identifier_Local = "tmp3"}, ty_Value_Id = TyPointer {ty_Type_TyPointer = TyStruct {name_Type_TyStruct = "struct.RT", numEl_Type_TyStruct = 3, tys_Type_TyStruct = []}}}, idxs_Instruction_GetElementPtr = [Constant {c_Value_Constant = SmpConst {sc_Constant_SmpConst = ConstantInt {iv_SimpleConstant_ConstantInt = 0, ty_SimpleConstant_ConstantInt = TyInt {p_Type_TyInt = 32}}}},Constant {c_Value_Constant = SmpConst {sc_Constant_SmpConst = ConstantInt {iv_SimpleConstant_ConstantInt = 1, ty_SimpleConstant_ConstantInt = TyInt {p_Type_TyInt = 32}}}}]},GetElementPtr {pc_Instruction_GetElementPtr = 7, id_Instruction_GetElementPtr = Local {name_Identifier_Local = "tmp5"}, ty_Instruction_GetElementPtr = TyPointer {ty_Type_TyPointer = TyArray {numEl_Type_TyArray = 20, ty_Type_TyArray = TyInt {p_Type_TyInt = 32}}}, struct_Instruction_GetElementPtr = Id {v_Value_Id = Local {name_Identifier_Local = "tmp4"}, ty_Value_Id = TyPointer {ty_Type_TyPointer = TyArray {numEl_Type_TyArray = 10, ty_Type_TyArray = TyArray {numEl_Type_TyArray = 20, ty_Type_TyArray = TyInt {p_Type_TyInt = 32}}}}}, idxs_Instruction_GetElementPtr = [Constant {c_Value_Constant = SmpConst {sc_Constant_SmpConst = ConstantInt {iv_SimpleConstant_ConstantInt = 0, ty_SimpleConstant_ConstantInt = TyInt {p_Type_TyInt = 32}}}},Constant {c_Value_Constant = SmpConst {sc_Constant_SmpConst = ConstantInt {iv_SimpleConstant_ConstantInt = 5, ty_SimpleConstant_ConstantInt = TyInt {p_Type_TyInt = 64}}}}]},GetElementPtr {pc_Instruction_GetElementPtr = 8, id_Instruction_GetElementPtr = Local {name_Identifier_Local = "tmp6"}, ty_Instruction_GetElementPtr = TyPointer {ty_Type_TyPointer = TyInt {p_Type_TyInt = 32}}, struct_Instruction_GetElementPtr = Id {v_Value_Id = Local {name_Identifier_Local = "tmp5"}, ty_Value_Id = TyPointer {ty_Type_TyPointer = TyArray {numEl_Type_TyArray = 20, ty_Type_TyArray = TyInt {p_Type_TyInt = 32}}}}, idxs_Instruction_GetElementPtr = [Constant {c_Value_Constant = SmpConst {sc_Constant_SmpConst = ConstantInt {iv_SimpleConstant_ConstantInt = 0, ty_SimpleConstant_ConstantInt = TyInt {p_Type_TyInt = 32}}}},Constant {c_Value_Constant = SmpConst {sc_Constant_SmpConst = ConstantInt {iv_SimpleConstant_ConstantInt = 13, ty_SimpleConstant_ConstantInt = TyInt {p_Type_TyInt = 64}}}}]},Ret {pc_Instruction_Ret = 9, r_Instruction_Ret = ValueRet {v_RetInst_ValueRet = Id {v_Value_Id = Local {name_Identifier_Local = "tmp6"}, ty_Value_Id = TyPointer {ty_Type_TyPointer = TyInt {p_Type_TyInt = 32}}}}}]}]})], nmdtys_Module_Module = fromList [("struct.RT",TyStruct {name_Type_TyStruct = "struct.RT", numEl_Type_TyStruct = 3, tys_Type_TyStruct = [TyInt {p_Type_TyInt = 8},TyArray {numEl_Type_TyArray = 10, ty_Type_TyArray = TyArray {numEl_Type_TyArray = 20, ty_Type_TyArray = TyInt {p_Type_TyInt = 32}}},TyInt {p_Type_TyInt = 8}]}),("struct.ST",TyStruct {name_Type_TyStruct = "struct.ST", numEl_Type_TyStruct = 3, tys_Type_TyStruct = [TyInt {p_Type_TyInt = 32},TyFloatPoint {p_Type_TyFloatPoint = TyDouble},TyStruct {name_Type_TyStruct = "struct.RT", numEl_Type_TyStruct = 3, tys_Type_TyStruct = []}]})]}
-}