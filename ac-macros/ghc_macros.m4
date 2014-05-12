# Copyright 2005,2008 David Roundy


# Redistribution and use in source and binary forms of this file, with or
# without modification, are permitted provided that redistributions of
# source code must retain the above copyright notice.

# TRY_COMPILE_GHC(PROGRAM, [ACTION-IF-TRUE], [ACTION-IF-FALSE])
# -----------
# Compile and link using ghc.
AC_DEFUN([TRY_COMPILE_GHC],[
cat << \EOF > conftest.hs
[$1]
-- this file generated by TRY-COMPILE-GHC
EOF
rm -f Main.hi Main.o
# Convert LDFLAGS and LIBS to the format GHC wants them in
GHCLDFLAGS=""
for f in $LDFLAGS ; do
  GHCLDFLAGS="$GHCLDFLAGS -optl$f"
done
GHCLIBS=""
for l in $LIBS ; do
  GHCLIBS="$GHCLIBS -optl$l"
done
if AC_TRY_COMMAND([$GHC $GHCFLAGS $GHCLDFLAGS -o conftest conftest.hs $GHCLIBS > /dev/null 2>&1]) && test -s conftest
then
dnl Don't remove the temporary files here, so they can be examined.
  ifelse([$2], , :, [$2])
else
  echo "configure: failed program was:" >&AS_MESSAGE_LOG_FD
  cat conftest.hs >&AS_MESSAGE_LOG_FD
  echo "end of failed program." >&AS_MESSAGE_LOG_FD
ifelse([$3], , , [ rm -f Main.hi Main.o
  $3
])dnl
fi])

# TRY_RUN_GHC(PROGRAM, [ACTION-IF-TRUE], [ACTION-IF-FALSE])
# -----------
# Compile, link and run using ghc.
AC_DEFUN([TRY_RUN_GHC],[
  TRY_COMPILE_GHC([$1],
    AS_IF([AC_TRY_COMMAND(./conftest)],[$2],[$3]),
    [$3])
])

# GHC_CHECK_ONE_MODULE(MODULE, [ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
# -----------
# Compile and link using ghc.
AC_DEFUN([GHC_CHECK_ONE_MODULE],[
TRY_COMPILE_GHC([import $1
main = seq ($2) (putStr "Hello world.\n")
                ],[$3],[$4])

])

# GHC_CHECK_MODULE(MODULE, PACKAGE, CODE, [ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
# -----------
# Compile and link using ghc.
AC_DEFUN([GHC_CHECK_MODULE],[
AC_MSG_CHECKING([for module $1])
GHC_CHECK_ONE_MODULE([$1], [$3], [AC_MSG_RESULT([yes])
$4], [
  check_module_save_GHCFLAGS=$GHCFLAGS
  GHCFLAGS="$GHCFLAGS -package $2"
  GHC_CHECK_ONE_MODULE([$1], [$3], [AC_MSG_RESULT([in package $2])
$4],[
    GHCFLAGS=$check_module_save_GHCFLAGS
    AC_MSG_RESULT(no; and neither in package $2)
    $5])
  ])
])

# GHC_COMPILE_FFI(IMPORT, TYPE, [ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
# -----------
# Compile and link ffi code using ghc.
AC_DEFUN([GHC_COMPILE_FFI],[
TRY_COMPILE_GHC([{-# OPTIONS -fffi #-}
module Main where

foreign import ccall unsafe "$1" fun :: $2

main = fun `seq` putStrLn "hello world"
],[$3],[$4])])

# GHC_CHECK_LIBRARY(LIBRARY, IMPORT, TYPE, [ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
# -----------
# Compile and link with C library using ghc.
AC_DEFUN([GHC_CHECK_LIBRARY],[
AC_MSG_CHECKING([for library $1])
GHC_COMPILE_FFI([$2], [$3], [AC_MSG_RESULT([yes])
$4], [
  check_library_save_LIBS=$LIBS
  LIBS="$LIBS -l$1"
  GHC_COMPILE_FFI([$2], [$3], [AC_MSG_RESULT([in -l$1])
  $4],[
    LIBS=$check_library_save_LIBS
    AC_MSG_RESULT(no; and not with -l$1 either)
    $5])
  ])
])
