
cd ..\disk
del *.dsk
cd ..
cd binaries

..\tools\DskTool.exe a ..\disk\dome.dsk *.bin *.com

cd ..\tools