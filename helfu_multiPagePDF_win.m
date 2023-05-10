function helfu_multiPagePDF_win(input, output, ghost_exe)
flag0 = ['"' ghost_exe '"'];
flag1 = ' -q -dNOPAUSE -dBATCH -dFIXEDMEDIA -sDEVICE=pdfwrite ';
flag2 = '-sPAPERSIZE=a4 -dPDFSETTINGS=/prepress -dAutoRotatePages=/All ';
flag3 = '-dCompatibilityLevel=1.4 ';
flag4 = ['-sOutputFile="' output '" -c save pop '];
flag5 = ['-f "' input '"'];
[errflag, msg] = system([flag0, flag1, flag2, flag3, flag4, flag5]);
