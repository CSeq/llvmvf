; ModuleID = 'simple.bc'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64"
target triple = "x86_64-apple-darwin11.4"

@__func__.1467 = internal constant [8 x i8] c"assertc\00", align 8
@.str = private constant [9 x i8] c"simple.c\00", align 1
@.str1 = private constant [5 x i8] c"expr\00", align 1

define void @assertc(i32 %expr) nounwind ssp {
entry:
  %0 = icmp eq i32 %expr, 0
  br i1 %0, label %bb, label %return

bb:                                               ; preds = %entry
  tail call void @__assert_rtn(i8* getelementptr inbounds ([8 x i8]* @__func__.1467, i64 0, i64 0), i8* getelementptr inbounds ([9 x i8]* @.str, i64 0, i64 0), i32 4, i8* getelementptr inbounds ([5 x i8]* @.str1, i64 0, i64 0)) noreturn nounwind
  unreachable

return:                                           ; preds = %entry
  ret void
}

declare void @__assert_rtn(i8*, i8*, i32, i8*) noreturn

define i32 @main(i32 %argc, i8** nocapture %argv) nounwind ssp {
entry:
  tail call void @__assert_rtn(i8* getelementptr inbounds ([8 x i8]* @__func__.1467, i64 0, i64 0), i8* getelementptr inbounds ([9 x i8]* @.str, i64 0, i64 0), i32 4, i8* getelementptr inbounds ([5 x i8]* @.str1, i64 0, i64 0)) noreturn nounwind
  unreachable
}
