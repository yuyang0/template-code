#===============================================================================
#      Filename:  Makefile
#        Author:  Yu Yang
#         Email:  yy2012cn@gmail.com
#       Created:  2014-10-12 15:41:25
#===============================================================================

all: force-look
	cd c; \
	make; \
	cp opencl-version ../;\
	cp maker.so ../

maker.so: force-look
	rm -f maker.so; \
	cd c; \
	make maker.so;  \
	cp maker.so ../

opencl-version: force-look
	cd c; \
	make opencl-version;\
	cp opencl-version ../

clean:
	rm -f maker.so opencl-version; \
	cd c;\
	make clean

force-look:
	true
