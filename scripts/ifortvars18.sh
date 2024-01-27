#  Sets the environment strings for Intel Fortran and MS Visual Studio linker
# This version selects the "intel64" version of the compiler, linker, libraries, and incldues.

# convert PATH from unix to mixed windows (ie, forward slashes, long name format)
  if [ "$SH" = "bash" ] ; then
    PATHDOS=`cygpath -pml "$PATH"`
  else
    PATHDOS=${PATH}
    export PATHDOS=$(echo -E $PATH | sed 's@\\@\/@g')
  fi

# assumes microsoft visual studo 14.0 (2015) for link, etc. Set path to find Visual Studio Common7/Tools and Common7/IDE
  export VSINSTALLDIR='C:\Progra~2\Microsoft Visual Studio 14.0'
  export VCINSTALLDIR=$VSINSTALLDIR'\VC'
  export WINDOWSSDKINSTALLDIR='C:\Progra~2\Windows Kits\10'
  export WINDOWSSDKVERSION='10.0.10240.0'
  export LIB=$VCINSTALLDIR'\lib\amd64;'$VSINSTALLDIR'\VC\lib\amd64;'$VSINSTALLDIR'\VC\atlmfc\lib\amd64;'$WINDOWSSDKINSTALLDIR'\Lib\'$WINDOWSSDKVERSION'\um\x64;'$WINDOWSSDKINSTALLDIR'\Lib\'$WINDOWSSDKVERSION'\ucrt\x64;'$LIB
  export INCLUDE=$VCINSTALLDIR'\atlmfc\include;'$VCINSTALLDIR'\include;'$VSINSTALLDIR'\include;'$INCLUDE
 
  export VSINSTALLDIR='C:/Progra~2/Microsoft Visual Studio 14.0'
  export VCINSTALLDIR=$VSINSTALLDIR'/VC'
  export PATHDOS=$VSINSTALLDIR'/Common7/IDE;'$VSINSTALLDIR'/VC/bin/amd64;'$VSINSTALLDIR'/Common7/Tools;'$VCINSTALLDIR'/BIN/amd64;'$WINDOWSSDKINSTALLDIR'/bin/x64;'$PATHDOS

# assumes "Intel 18.1 build 156" for fortran version
  export IFORT_COMPILER18='C:\PROGRA~2\IntelSWTools\Compilers_and_libraries_2018.1.156\windows'
  export LIB=$IFORT_COMPILER18'\compiler\lib\intel64_win;'$LIB
# for kernel32.lib:
  export LIB=$LIB';C:\Progra~2\Windows Kits\8.1\Lib\winv6.3\um\x64'
  export INCLUDE=$IFORT_COMPILER18'\mkl\Include;'$IFORT_COMPILER18'\Include;'$IFORT_COMPILER18'Include\intel64;'$INCLUDE
  export INTEL_LICENSE_FILE='C:\PROGRA~2\Common Files\Intel\Licenses'

  export IFORT_COMPILER18='C:/PROGRA~2/IntelSWTools/Compilers_and_libraries_2018.1.156/windows'
  export PATHDOS=$IFORT_COMPILER18'/mkl/bin;'$IFORT_COMPILER18'/bin/intel64;'$PATHDOS


if [ "$SH" = "bash" ] ; then
# Convert from windows to unix path convention for cygwin's bash shell
  PATH=`cygpath -pu "$PATHDOS"`
else
  PATH=$(echo -E $PATHDOS | sed 's@\/@\\@g')
fi
