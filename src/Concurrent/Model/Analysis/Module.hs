-------------------------------------------------------------------------------
-- Module    :  Concurrent.Model.Analysis.Module
-- Copyright :  (c) 2013 Marcelo Sousa
-------------------------------------------------------------------------------

module Concurrent.Model.Analysis.Module where

import Language.LLVMIR
import Concurrent.Model.Analysis.ControlFlow
import Concurrent.Model.Analysis.DataFlow
import Concurrent.Model.Analysis.Context
import Concurrent.Model.Analysis.Util
import qualified Data.Map   as M
import qualified Data.Maybe as MB

-- Use the State Monad
analyseModule :: String -> Module -> (Module, ControlFlow, DataFlow)
analyseModule ep (Module id layout target gvars funs nmdtys) =
  let fn = MB.fromMaybe (errorMsg ep $ M.keys funs) $ M.lookup ep funs 
      bb = MB.fromMaybe (errorMsg ep fn) $ entryBBFunction fn 
      pc = MB.fromMaybe (errorMsg (show bb) fn) $ entryPCFunction fn 
      iLoc  = Location ep bb pc
      iCore = Core nmdtys gvars funs
      env = Env iCore eCore eCFG eDF iLoc
      oenv  = evalContext (analyseFunction fn) env
      Core tys vars fs = coreout oenv
      fcfg  = ccfg oenv
      fdf   = df oenv 
      m     = Module id layout target vars fs tys
  in (m, fcfg, fdf)

errorMsg :: (Show b) => String -> b -> a
errorMsg msg b = error $ "analyseModule: " ++ msg ++ " " ++ show b

analyseFunction :: Function -> Context ()
analyseFunction fn = case fn of
  FunctionDecl name _ rty iv pms -> return ()
  FunctionDef  name _ rty iv pms body -> analyseBB $ head body

analyseBB :: BasicBlock -> Context ()
analyseBB (BasicBlock i instrs) = undefined

entryPCFunction :: Function -> Maybe PC
entryPCFunction fn = case fn of
  FunctionDecl name _ rty iv pms -> Nothing
  FunctionDef  name _ rty iv pms bbs -> 
    Just $ entryPCBB $ head bbs

entryBBFunction :: Function -> Maybe Identifier
entryBBFunction fn = case fn of
  FunctionDecl name _ rty iv pms -> Nothing
  FunctionDef  name _ rty iv pms bbs -> 
    case bbs of
	   [] -> Nothing
	   ((BasicBlock i _):_) -> Just i

entryPCBB :: BasicBlock -> PC
entryPCBB (BasicBlock _ instrs) = instrpc $ head instrs 