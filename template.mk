# 如果是生产环境请把DEBUG设为0
DEBUG ?= 1

CC := gcc
AR := ar
RANLIB := ranlib
VPATH := /opt/libjpeg-turbo/include:/opt/libwebp/include:/opt/libpng/include

ifeq ($(DEBUG), 1)
    CFLAGS := -g -Wall -std=gnu99 -DDEBUG
else
    CFLAGS := -O2 -std=gnu99 -DNDEBUG
endif

OPENCL_INC_PATH := -I/opt/AMDAPPSDK-3.0-0-Beta/include
OPENCL_LIB_PATH := -L/opt/AMDAPPSDK-3.0-0-Beta/lib/x86_64/sdk
# project root directory
PROJECT_ROOT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

IMAGE_INC_PATH := -I/opt/libjpeg-turbo/include -I/opt/libwebp/include -I/opt/libpng/include
IMAGE_LIB_PATH := -L/opt/libjpeg-turbo/lib64 -L/opt/libwebp/lib -L/opt/libpng/lib
INC_PATH := -I$(PROJECT_ROOT_DIR) $(IMAGE_INC_PATH)

IMAGE_LIBS := -ljpeg -lpng -lwebp

EXE_FILES := maker.so opencl-version

OBJS := maker.o curtain.o mirror.o new_cut_image.o semantic.o old_cut_image.o image_api.o mess.o matrix.o   \
       opencl.o util.o clutil.o pngfuncs.o jpegfuncs.o webpfuncs.o        \
       image_info.o wrapper.o pixel.o
SOURCES := $(OBJS:.o=.c)

all:  $(EXE_FILES)

maker.so: maker.o curtain.o  mirror.o semantic.o new_cut_image.o old_cut_image.o image_api.o mess.o matrix.o util.o \
	  pngfuncs.o jpegfuncs.o webpfuncs.o image_info.o wrapper.o pixel.o
	$(CC) -fPIC -shared $(IMAGE_LIB_PATH) -o $@ $^ $(IMAGE_LIBS) -lm -lz -lpthread -lpython2.7

opencl-version: opencl.o clutil.o util.o pngfuncs.o jpegfuncs.o webpfuncs.o \
	        image_info.o wrapper.o pixel.o matrix.o
	$(CC)  $(OPENCL_LIB_PATH) $(IMAGE_LIB_PATH) -o $@ $^ -lm -lz -lpthread  $(IMAGE_LIBS) -lOpenCL

semantic-opencl: semantic_opencl.o clutil.o util.o pngfuncs.o jpegfuncs.o webpfuncs.o \
	        image_info.o wrapper.o pixel.o matrix.o
	$(CC)  $(OPENCL_LIB_PATH) $(IMAGE_LIB_PATH) -o $@ $^ $(IMAGE_LIBS) -lOpenCL -lm -lz -lpthread

new: util.o pngfuncs.o jpegfuncs.o webpfuncs.o image_info.o pixel.o wrapper.o new_cut_image.o matrix.o
	$(CC) $(IMAGE_LIB_PATH) -o $@ $^ $(IMAGE_LIBS) -lm -lz -lpthread

mirror: util.o pngfuncs.o jpegfuncs.o webpfuncs.o image_info.o pixel.o wrapper.o mirror.o matrix.o
	$(CC) $(IMAGE_LIB_PATH) -o $@ $^ $(IMAGE_LIBS) -lm -lz -lpthread

curtain: util.o pngfuncs.o jpegfuncs.o webpfuncs.o image_info.o pixel.o wrapper.o curtain.o matrix.o
	$(CC) $(IMAGE_LIB_PATH) -o $@ $^ $(IMAGE_LIBS) -lm -lz -lpthread

%.o:%.c
	@echo "$(CC) -c $(CFLAGS) -o $@ $<"
	@$(CC) -fPIC -shared -c $(CFLAGS) $(CPPFLAGS) $< -o $@ $(OPENCL_INC_PATH) $(INC_PATH)

#自动处理头文件依赖
#SOURCES为所有的源文件列表
%.d: %.c
	@set -e; rm -f $@; \
	$(CC) -MM $(CPPFLAGS) $(IMAGE_INC_PATH) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$
# ignore the warn message "XXX.d: No such file or directory"
-include $(SOURCES:.c=.d)

install: all
	@if [ -d $(INSTDIR) ]; \
	then \
	cp myapp $(INSTDIR);\
	chmod a+x $(INSTDIR)/$(EXE_FILE);\
	chmod og-w $(INSTDIR)/$(EXE_FILE);\
	echo “Installed in $(INSTDIR)“;\
	else \
	echo “Sorry, $(INSTDIR) does not exist”;\
	fi

.PHONY: clean
clean:
	-rm -f *.o $(EXE_FILES) *.d *.d.* *.bin *.out new curtain mirror
