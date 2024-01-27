#$Header: M:/default/scripts/RCS/nfort.sh,v 1.33 2014/02/07 18:14:21 dsa Exp $
TK_ECHO_USE_BASH_BEHAVIOR=1
  
### Script Functionality: To compile NEMS FORTRAN source file and 
###                       to update complog files.

###  First, check to see if NEMS is locked

if [[ -a "$NEMS/freeze/freeze.defaults" ]]; then
 echo "NEMS Configuration Management System is temporarily disabled by:"
 cat $NEMS/freeze/freeze.defaults
 exit
fi

FLAGB="/check:bounds"
export FLAGB
FLAGO="/debug:full /optimize:0"  # ensure optimization default is set to debug
export FLAGO

### functions

Header()
{
 echo " "
 echo "#################################################"
 echo "#   NEMS Fortran Compilation Utility nfort      #"
 echo "#                                               #"
 echo "#   script usage: nfort                         #"
 echo "#          or   : nfort filename.f              #"
 echo "#################################################"
 echo " "
} #End of Header()

Process_Includes()
{
 trap "rm -f _*.$$;rm -f temp.z" 0
 ls -1d * | sed '/\./d;/complog/d;/[A-Z]/d' > _f0.$$
 #grep "includes default" $NEMS/logs/DEFAULTS > temp1.$$
 touch _f1.$$
 while read -u5 _filename
 do
  if [ -f "$_filename" ]
  then
   grep "^$_filename " temp1.$$ > temp.$$
   if [ "$?" -eq 0 ]
   then
    awk "{print}" temp.$$ >temp2.$$; read dummy _filetype dummy < temp2.$$
    rm -f temp2.$$
    if [ "$_filetype" = "includes" ]
    then echo $_filename >> _f1.$$
    fi
   fi
  fi
 done 5< _f0.$$
 rm -f temp.$$ temp1.$$
 touch _f2.$$
 while read -u5 _filename
 do
  if [ ! -w "$_filename" ]
  then
   grep -v '$Header' $NEMSINCLa/$_filename > file1
   grep -v '$Header' $PWD/$_filename > file2
   diff file1 file2 >/dev/null
   if [ "$?" -ne 0 ]
   then
     echo $_filename >> _f2.$$
   fi
   rm -f file1 file2
  fi
 done 5< _f1.$$
 if [ -s "_f2.$$" ]
 then
  echo " "
  echo The following include files have been revised
  echo by someone else since you checked them out:
  echo " "
  awk '{ printf("\t %s\n",$1) }' _f2.$$
  echo " "
  echo -n "Do you want to use include files in $NEMSINCLa [y|n|q](n) ==> ";read ans
  if [ "$ans" = "q" ]
  then
   exit
  fi
  if [ "$ans" = "y" ]
  then
   if [[ "$item" = "a" ]]
   then
    if [ -f makefile ];then mv -f  makefile makefile.$$;fi
    cp $NEMS/scripts/makefile makefile
#td    chmod ug+w makefile
   fi
   while read -u5 _filename
   do
    if [ -f "$_filename" ]
    then
     mv -f  $_filename ${_filename}_$$
     cp $NEMSINCLa/$_filename .
#td     chmod 444 $_filename
    fi
   done 5< _f2.$$
   touch _f3.$$
   while read -u5 _filename
   do
    echo ${_filename}_$$ >> _f3.$$
   done 5< _f2.$$
   echo " "
   echo The default version of above include files are copied to $PWD,
   echo and the local include files are re-named as:
   echo " "
   awk '{printf("\t%s\n",$1) }' _f3.$$
   echo " "
  fi
 fi
 if [ "$?" -ne 0 ]
 then continue
 fi
} #End of Process_Includes()

Process_Complog()
{
 typeset complog
 complog=$1
 if [[ "$ans" = "y" ]]
 then
  sh $NEMS/scripts/complog.sh $complog
  while read -u5 _filename
  do
   sh $NEMS/scripts/complog.sh $_filename $complog
  done 5< f2.$$
  rm -f f2.$$
 else
  sh $NEMS/scripts/complog.sh $complog
 fi
 echo "end of process_complog"
} #End of Process_Complog()

### trap
trap " if [ -f makefile.$$ ];then mv -f  makefile.$$ makefile;fi; \
       rm -f *.$$;rm -f temp.z;exit;" 0 1 2 15
echo 
echo 
echo 
echo 
echo 
echo 
echo 
echo 
echo 
echo "Select Fortran compiler:"
echo 
echo "1) Compaq Visual Fortran 6.1 (through 9/16/2005)"
echo "2) Intel Fortran Version 9.0 (from 9/2005 to 7/2007)"
echo "3) Intel Fortran Version 9.1 (from 7/2007 to 10/2010)"
echo "4) Intel Fortran Version 11.1 32-bit (10/2010 to 2/2014)"
echo "5) Intel Fortran Version 11.1 64-bit (default))"
echo " "
echo -n "  Your Selection [5] : ";read ans

if [ "$ans" = "1" ] ; then
  COMPILER="C:/Program Files/Microsoft Visual Studio/DF98/BIN/f90.exe";export COMPILER
  FLAGIO=' ';export FLAGIO

elif [ "$ans" = "2" ] ; then
  IVERS="9.0";export IVERS
  COMPILER="C:/Program Files/Intel/Compiler/Fortran/9.0/Ia32/Bin/ifort.exe";export COMPILER
  . $NEMS/scripts/ifortvars.sh
  FLAGIO='/fpscomp:ldio_spacing';export FLAGIO

elif [ "$ans" = "3" ] ; then
  IVERS="9.1";export IVERS
  if [ -a "c:/program files (x86)/intel" ] ; then
    echo "64-bit windows."
    COMPILER="C:/Program Files (x86)/Intel/Compiler/Fortran/9.1/Ia32/Bin/ifort.exe";export COMPILER
  . $NEMS/scripts/ifortvars64.sh
  else
    COMPILER="C:/Program Files/Intel/Compiler/Fortran/9.1/Ia32/Bin/ifort.exe";export COMPILER
  . $NEMS/scripts/ifortvars.sh
  fi
  FLAGIO='/fpscomp:ldio_spacing';export FLAGIO

elif [ "$ans" = "4" ] ; then
  IVERS="11.1";export IVERS
  if [ -a "c:/program files (x86)/intel" ] ; then
    echo "64-bit windows."
    COMPILER="C:/Program Files (x86)/Intel/Compiler/11.1/072/bin/Ia32/ifort.exe";export COMPILER
    . $NEMS/scripts/ifortvars64.sh
  else
    COMPILER="C:/Program Files/Intel/Compiler/11.1/072/bin/Ia32/ifort.exe";export COMPILER
    . $NEMS/scripts/ifortvars.sh
  fi
  FLAGIO='/fpscomp:ldio_spacing';export FLAGIO

else      #  elif [ "$ans" = "5" ]  ; then
  IVERS="11.1";export IVERS
  COMPILER="C:/Program Files (x86)/Intel/Compiler/11.1/072/bin/intel64/ifort.exe";export COMPILER
  . $NEMS/scripts/ifortvars64x64.sh
  FLAGIO='/fpscomp:ldio_spacing';export FLAGIO
  
fi
#echo "Compiler to be used is $COMPILER"


# check for /nocheck flag in makefile.  if not there, ask to replace
 if [ -f makefile ]; then 
    if [ $NEMS/scripts/makefile -nt makefile ]; then
       echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
     #  echo "We've updated the makefile.  Copying new default..."
     #  cp $NEMS/scripts/makefile .
     #  echo "If you've manually changed your makefile, you'll have to update the new one, but rest assured I'm done copying over it."
       echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    fi
 else
   echo "No makefile.  Using the default one..."
   echo -n "    Press <enter> to continue ";read notused
  # cp $NEMS/scripts/makefile .
 fi

FileSelected="FALSE"
#####
if [[ ! -z "$1" ]]; then
 case "$1" in  
  *\.f|*\.f90)
 #  grep "^$1" $NEMS/logs/DEFAULTS | fgrep source 1>/dev/null 2>/dev/null
   if [[ "$?" -eq 0 ]]; then FileSelected="TRUE"; fi
    ;;
 esac
fi

if [[ "$FileSelected" = "FALSE" ]]; then

### process FORTRAN files
ls -1  *.f90 > Dot_F_Files.$$  2>/dev/null
ls -1  *.f >> Dot_F_Files.$$  2>/dev/null
awk '{n++; printf("%3.0f) %s\n",n,$1)};' Dot_F_Files.$$ > frtfiles.$$

### determine number of FORTRAN source files
wc -l frtfiles.$$ >temp2.$$; read fnumber dummy < temp2.$$

### prepare main menu
echo " " > frtmenu.$$
echo "You may compile any of the following files:" >> frtmenu.$$
echo " " >> frtmenu.$$
if [[ `cat frtfiles.$$ | wc -l` -gt 10 ]]
then
 cat frtfiles.$$ | paste - - - - >> frtmenu.$$
else
 cat frtfiles.$$ >> frtmenu.$$
fi
echo " -----------------------" >> frtmenu.$$
echo "  a) Compile all of the above" >> frtmenu.$$
echo "  v) Read error messages " >> frtmenu.$$
echo "  q) Quit" >> frtmenu.$$
echo "  \n  Type an O (letter) before any compile option to use optimization level 2," >>frtmenu.$$
echo "  e.g. O1 to compile the first source code or Oa to compile all of them." >>frtmenu.$$ 
echo " " >>frtmenu.$$
echo "  ****** Note **** B for bounds checking is now the default option." >>frtmenu.$$ 
echo " " >> frtmenu.$$
echo "  a) Compile all of the above" >> frtfiles.$$
echo "  v) Read error message " >> frtfiles.$$
echo "  q) Quit" >> frtfiles.$$
echo "  Prepend an O before any compile option to use optimization level 2" >>frtfiles.$$
echo "  e.g. O1 or Oa " >>frtfiles.$$ 
else
FileSelected="TRUE"
fi
####

### main loop
while [ 1 ]
do
# create variable NEMSINCL with the default location for nems include files . change to backslash
# format for the f90 command syntax
# 
echo $2
if [ -z "$2" ] ; then
  NEMSINCLa="$NEMS/includes"
else
  echo "$2"
  NEMSINCLa="$2"
fi

echo $NEMSINCLa | sed 's/\/\//\\\\/g;s/\//\\/g' > temp.z
NEMSINCL=`cat temp.z`
rm temp.z

export NEMSINCL 
echo $NEMSINCL
####
if [[ "$FileSelected" = "FALSE" ]]; then

 ### header
 Header

 ### display main menu
 cat frtmenu.$$

 ### to prompt user to enter selection
 if [[ "$errmsg" -eq 1 ]];then echo "*** Invalid choice!";fi
 if [[ "$errmsg" -eq 2 ]];then echo "*** Error in compilation!";fi
 if [[ "$errmsg" -eq 3 ]];then echo "*** Compilation is done.";fi
 echo -n "Enter your choice (1|2|...|a|v|q)[q] ==> ";read choice
 if [[ -z "$choice" || "$choice" = "q" ]];then 
    echo " ";
    rm -f *.$$
    exit;
  fi
 case "$choice" in
  [0-9]*)
   if [[ "$choice" -gt 0 && "$choice" -le "$fnumber" ]];
   then
    errmsg=0
    FLAGB="/check:bounds"
    FLAGO="/debug:full /optimize:0"  
    grep "$choice[)]" frtfiles.$$ > temp.$$; sed "s/[ 0-9]*[)] //" temp.$$ > temp2.$$; read item dummy < temp2.$$
    rm -f temp.$$ temp2.$$
   else
    errmsg=1
    continue
   fi
   ;;
  O[0-9]*)
   choice=${choice#O}
   if [[ "$choice" -gt 0 && "$choice" -le "$fnumber" ]];
   then
    errmsg=0
    FLAGO="/nodebug /optimize:2"
    FLAGB=" "
    grep "$choice[)]" frtfiles.$$ > temp.$$; sed "s/[ 0-9]*[)] //" temp.$$ >temp2.$$; read item dummy < temp2.$$
    rm -f temp.$$ temp2.$$
   else
    errmsg=1
    continue
   fi
   ;;
  B[0-9]*)
   choice=${choice#B}
   if [[ "$choice" -gt 0 && "$choice" -le "$fnumber" ]];
   then
    errmsg=0
    FLAGO="/debug:full /optimize:0"
    FLAGB="/check:bounds"
    grep "$choice[)]" frtfiles.$$ > temp.$$; sed "s/[ 0-9]*[)] //" temp.$$ >temp2.$$; read item dummy < temp2.$$
    rm -f temp.$$ temp2.$$
   else
    errmsg=1
    continue
   fi
   ;;
 
  a)
   item="a"
   FLAGB="/check:bounds"
   FLAGO="/debug:full /optimize:0"   
   errmsg=0
   ;;
  Oa)
   item="a"
    FLAGB=" "
   FLAGO="/nodebug /optimize:2"
   errmsg=0
   ;;
  Ba)
   item="a"
   FLAGB="/check:bounds"  
   FLAGO="/debug:full /optimize:0" 
   errmsg=0
   ;;
  v)
   more -P "---More--- press q to exit;" ERROR
   continue
   ;;
  *)
   errmsg=1
   FLAGB="/check:bounds"
   FLAGO="/debug:full /optimize:0"  
   continue
   ;;
 esac
else
 FLAGB="/check:bounds"
 echo "Compiling $1 ... "
 item=$1
fi
####

 ## process user's input
 case "$item" in  
  *\.f)
     item2="${item%.f}.obj"
     ;;
   *\.f90)
     item2="${item%.f90}.obj"
     ;;
 esac
 case "$item" in  
  *\.f|*\.f90)
   Process_Includes
   touch $item
   echo " "
   if [[ "$FLAGB" = "/check:bounds" ]] ; then
     echo "Compiling ${item2} now with bounds checking on, debug, and no optimization"
   fi
   export FLAGB
   if [[ "$FLAGO" = "/debug:full /optimize:0" ]] ; then
     echo "Compiling ${item} now with debug and no optimization "
   elif  [[ "$FLAGO" = "/nodebug /optimize:2" ]] ; then
     echo "Compiling ${item2} now with optimization level 2"
   else 
     echo "optimization is $FLAGO "
   fi 
   export FLAGO
   make $item2 

   grep -i "error" ERROR 1>/dev/null 2>/dev/null
   if [[ "$?" -eq 0 ]]
   then errmsg=2
   else
    errmsg=3
   # echo "Processing complog_${item2%.obj} now ..."
   # Process_Complog "${item}"
   fi
   echo " "
   echo -n "Compilation is done, press RETURN key to continue ... ";read answer
#####
if [[ "$FileSelected" = "TRUE" ]]; then exit ; fi
#####
   ;;
  a)
   if [[ -f ERROR ]];then rm -f ERROR;fi
   export FLAGB
   export FLAGO
   Process_Includes
   let leftnumber=$fnumber-1
   while read file
   do
    touch $file
    case "$file" in
      *\.f)
        fileobj="${file%.f}.obj"
        filecomplog="complog_${file%.f}"
        ;;
      *\.f90)
        fileobj="${file%.f90}.obj"
        filecomplog="complog_${file%.f90}"
        ;;
    esac
    echo " "
    echo "Compiling $file now with $FLAGO and $FLAGB ... $leftnumber more file(s) left"
    make "$fileobj"
    if [[ -f ERROR ]];then cat ERROR >> ERROR.$$;fi
     grep -i "error" ERROR 1>/dev/null 2>/dev/null
    #if [[ "$?" -ne 0 ]]
    #then
     # echo "Processing $filecomplog now ..."
     #Process_Complog $file
    #fi
    let leftnumber=leftnumber-1
   done < Dot_F_Files.$$
   if [ -f make1.$$ ] ; then
     mv make1.$$ makefile
   fi
   mv -f ERROR.$$ ERROR
   echo " "
   echo -n "Compilations are done, press RETURN key to continue ... ";read answer
   grep -i "error" ERROR 1>/dev/null 2>/dev/null
   if [[ "$?" -eq 0 ]];then errmsg=2;else errmsg=3;fi
   continue
   ;;
  *)
   continue
   ;;
 esac
### end of main loop
done
 rm -f Dot_F_Files.$$
