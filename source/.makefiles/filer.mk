# FILE IS CREATED AUTOMATICALLY BY MAKEFILE
filer.obj :  ../includes/hmmblk ../includes/commrep ../includes/tranrep ../includes/converge ../includes/comparm ../includes/coalprc ../includes/angtdm ../includes/ab32 ../includes/uefpout ../includes/coalout ../includes/mxpblk ../includes/mpblk ../includes/ponroad ../includes/ampblk ../includes/tcs45q ../includes/rggi ../includes/pmmftab ../includes/ngrpt ../includes/ghgrep ../includes/wrenew ../includes/dsmtfefp ../includes/udatout ../includes/rseff ../includes/convfact ../includes/ngtdmout ../includes/bifurc ../includes/dsmdimen ../includes/intout ../includes/qonroad ../includes/cdsparms ../includes/emmparm ../includes/eusprc ../includes/aponroad ../includes/e111d ../includes/resdrep ../includes/aeusprc ../includes/uettout ../includes/uldsmout ../includes/uefdout ../includes/qsblk ../includes/qblk ../includes/mxqblk ../includes/mcdetail ../includes/lfmmout ../includes/csapr ../includes/pmmout ../includes/macout ../includes/uso2grp ../includes/rscon ../includes/pqchar ../includes/uecpout ../includes/gamsglobalsf ../includes/fdict ../includes/bldglrn ../includes/indout ../includes/gdxiface ../includes/coalemm ../includes/epmbank ../includes/parametr ../includes/cogen ../includes/ncntrl ../includes/ngtdmrep filer.f ../includes/emablk ../includes/emission ../includes/emeblk ../includes/pmmrpt ../includes/indrep ../includes/coalrep ../includes/efpout ../includes/ogsmout ../includes/continew ../includes/acoalprc
	@echo "  > filer.obj"
	@ifort /O2 /debug:full /compile_only /nopdbfile /free /traceback /fpconstant /assume:byterecl /assume:source_include /nolist /static /Qsave /Qzero /heap-arrays0 filer.f /include:../includes -o filer.obj
