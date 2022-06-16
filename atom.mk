
LOCAL_PATH := $(call my-dir)

ifneq ("$(HOST_OS)","windows")

###############################################################################
# Host part
###############################################################################

include $(CLEAR_VARS)

LOCAL_HOST_MODULE := protobuf

LOCAL_AUTOTOOLS_VERSION := 3.19.4
LOCAL_AUTOTOOLS_ARCHIVE := protobuf-all-$(LOCAL_AUTOTOOLS_VERSION).tar.gz
LOCAL_AUTOTOOLS_SUBDIR := protobuf-$(LOCAL_AUTOTOOLS_VERSION)

LOCAL_CFLAGS := -Wno-unused-local-typedefs

LOCAL_AUTOTOOLS_CONFIGURE_ARGS := \
	--without-zlib

LOCAL_EXPORT_LDLIBS := -lprotobuf

include $(BUILD_AUTOTOOLS)

###############################################################################
# Target part
###############################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := protobuf-base
LOCAL_DESCRIPTION := Protocol Buffers - Google data interchange format
LOCAL_CATEGORY_PATH := libs/protobuf

LOCAL_DEPENDS_HOST_MODULES := host.protobuf

LOCAL_CONFIG_FILES := Config.in
$(call load-config)

LOCAL_AUTOTOOLS_VERSION := 3.19.4
LOCAL_AUTOTOOLS_ARCHIVE := protobuf-all-$(LOCAL_AUTOTOOLS_VERSION).tar.gz
LOCAL_AUTOTOOLS_SUBDIR := protobuf-$(LOCAL_AUTOTOOLS_VERSION)

# Remove so version for android shared libraries
ifeq ("$(TARGET_OS_FLAVOUR)","android")
LOCAL_AUTOTOOLS_PATCHES := 0001-android_avoid_so_version.patch
endif

LOCAL_AUTOTOOLS_CONFIGURE_ARGS := \
	--without-zlib \
	--with-protoc=$(HOST_OUT_STAGING)/usr/bin/protoc

ifneq (,$(filter $(TARGET_OS)-$(TARGET_OS_FLAVOUR), darwin-iphoneos darwin-iphonesimulator linux-android))
  # Disable compilation of compiler, only compile runtime libs
  LOCAL_AUTOTOOLS_MAKE_BUILD_ARGS := \
	bin_PROGRAMS="" \
	lib_LTLIBRARIES="libprotobuf-lite.la libprotobuf.la"

  LOCAL_AUTOTOOLS_MAKE_INSTALL_ARGS := \
	bin_PROGRAMS="" \
	lib_LTLIBRARIES="libprotobuf-lite.la libprotobuf.la"
else
  # Export -lprotoc here, where we are sure it's being compiled, instead of downstream
  # meta-packages below
  LOCAL_EXPORT_LDLIBS := -lprotoc
endif

# Remove compiler from target, create usr/share/protobuf directory
define LOCAL_AUTOTOOLS_CMD_POST_INSTALL
	$(if $(filter-out $(TARGET_OS)-$(TARGET_OS_FLAVOUR), linux-native), \
		$(Q) rm -f $(TARGET_OUT_STAGING)/usr/bin/protoc)
	$(Q) mkdir -p $(TARGET_OUT_STAGING)/usr/share/protobuf
	$(Q) mkdir -p $(TARGET_OUT_STAGING)/usr/share/protobuf/google/protobuf
	$(Q) mkdir -p $(TARGET_OUT_STAGING)/usr/lib/python/site-packages/google/protobuf
	$(Q) cp -af $(TARGET_OUT_STAGING)/usr/include/google/protobuf/any.proto \
		 $(TARGET_OUT_STAGING)/usr/share/protobuf/google/protobuf/any.proto
	$(Q) cp -af $(TARGET_OUT_STAGING)/usr/include/google/protobuf/any.proto \
		 $(TARGET_OUT_STAGING)/usr/lib/python/site-packages/google/protobuf/any.proto
	$(Q) cp -af $(TARGET_OUT_STAGING)/usr/include/google/protobuf/empty.proto \
		 $(TARGET_OUT_STAGING)/usr/share/protobuf/google/protobuf/empty.proto
	$(Q) cp -af $(TARGET_OUT_STAGING)/usr/include/google/protobuf/empty.proto \
		 $(TARGET_OUT_STAGING)/usr/lib/python/site-packages/google/protobuf/empty.proto
	$(Q) cp -af $(TARGET_OUT_STAGING)/usr/include/google/protobuf/wrappers.proto \
		$(TARGET_OUT_STAGING)/usr/share/protobuf/google/protobuf/wrappers.proto
	$(Q) cp -af $(TARGET_OUT_STAGING)/usr/include/google/protobuf/wrappers.proto \
		$(TARGET_OUT_STAGING)/usr/lib/python/site-packages/google/protobuf/wrappers.proto
	$(Q) cp -af $(TARGET_OUT_STAGING)/usr/include/google/protobuf/descriptor.proto \
		$(TARGET_OUT_STAGING)/usr/share/protobuf/google/protobuf/descriptor.proto
	$(Q) cp -af $(TARGET_OUT_STAGING)/usr/include/google/protobuf/descriptor.proto \
		$(TARGET_OUT_STAGING)/usr/lib/python/site-packages/google/protobuf/descriptor.proto

endef

include $(BUILD_AUTOTOOLS)

###############################################################################
# Main part
###############################################################################

include $(CLEAR_VARS)
LOCAL_MODULE := protobuf
LOCAL_DESCRIPTION := Protocol Buffers - Google data interchange format - Full Runtime
LOCAL_CATEGORY_PATH := libs/protobuf
LOCAL_PUBLIC_LIBRARIES := protobuf-base
LOCAL_EXPORT_LDLIBS := -lprotobuf
LOCAL_EXPORT_CXXFLAGS := -std=c++11
include $(BUILD_META_PACKAGE)

include $(CLEAR_VARS)
LOCAL_MODULE := protobuf-lite
LOCAL_DESCRIPTION := Protocol Buffers - Google data interchange format - Lite Runtime
LOCAL_CATEGORY_PATH := libs/protobuf
LOCAL_PUBLIC_LIBRARIES := protobuf-base
LOCAL_EXPORT_LDLIBS := -lprotobuf-lite
include $(BUILD_META_PACKAGE)

include $(CLEAR_VARS)
LOCAL_MODULE := protobuf-python
LOCAL_DESCRIPTION := Protocol Buffers - Google data interchange format - Python Runtime
LOCAL_CATEGORY_PATH := libs/protobuf
LOCAL_AUTOTOOLS_VERSION := 3.19.4
LOCAL_AUTOTOOLS_ARCHIVE := protobuf-all-$(LOCAL_AUTOTOOLS_VERSION).tar.gz
LOCAL_AUTOTOOLS_SUBDIR := protobuf-$(LOCAL_AUTOTOOLS_VERSION)
LOCAL_PYTHONPKG_TYPE := setuptools
LOCAL_PYTHONPKG_SETUP_PY := python/setup.py
LOCAL_PYTHONPKG_ENV := PROTOC=$(HOST_OUT_STAGING)/usr/bin/protoc
LOCAL_PYTHONPKG_BUILD_ARGS := --cpp_implementation
LOCAL_DEPENDS_HOST_MODULES := host.protobuf
LOCAL_PRIVATE_LIBRARIES := \
	python-six \
	protobuf
include $(BUILD_PYTHON_PACKAGE)

include $(CLEAR_VARS)
LOCAL_HOST_MODULE := protobuf-python
LOCAL_DESCRIPTION := Protocol Buffers - Google data interchange format - Python Runtime
LOCAL_CATEGORY_PATH := libs/protobuf
LOCAL_AUTOTOOLS_VERSION := 3.19.4
LOCAL_AUTOTOOLS_ARCHIVE := protobuf-all-$(LOCAL_AUTOTOOLS_VERSION).tar.gz
LOCAL_AUTOTOOLS_SUBDIR := protobuf-$(LOCAL_AUTOTOOLS_VERSION)
LOCAL_PYTHONPKG_TYPE := setuptools
LOCAL_PYTHONPKG_SETUP_PY := python/setup.py
LOCAL_PYTHONPKG_ENV := PROTOC=$(HOST_OUT_STAGING)/usr/bin/protoc
LOCAL_DEPENDS_HOST_MODULES := host.protobuf
include $(BUILD_PYTHON_PACKAGE)

else

# Use prebuilt version on windows (mingw)
$(call register-prebuilt-pkg-config-module,protobuf,protobuf)
$(call register-prebuilt-pkg-config-module,protobuf-lite,protobuf-lite)

include $(CLEAR_VARS)
LOCAL_MODULE := protobuf-proto-files
define LOCAL_CMD_BUILD
	@( \
		srcdir=$$(dirname $$(which protoc))/../include/google/protobuf; \
		dstdir=$(TARGET_OUT_STAGING)/usr/share/protobuf/google/protobuf; \
		mkdir -p $${dstdir}; \
		for f in any descriptor empty wrappers; do \
			cp -af $${srcdir}/$${f}.proto $${dstdir}/; \
		done; \
	)
endef
include $(BUILD_CUSTOM)

endif

###############################################################################
## Custom macro that can be used in LOCAL_CUSTOM_MACROS of a module to
## create automatically rules to generate files from .proto.
## Note : in the context of the macro, LOCAL_XXX variables refer to the module
## that use the macro, not this module defining the macro.
## As the content of the macro is 'eval' after, most of variable ref shall be
## escaped (hence the $$). Only $1, $2... variables can be used directly.
## Note : no 'global' variable shall be used except the ones defined by
## alchemy (TARGET_XXX and HOST_XXX variables). Otherwise the macro will no
## work when integrated in a SDK (using local-register-custom-macro).
## Note : rules shoud NOT use any variables defined in the context of the
## macro (for the same reason PRIVATE_XXX variables shall be used in place of
## LOCAL_XXX variables).
## Note : if you need a script or a binary, please install it in host staging
## directory and execute it from there. This way it will also work in the
## context of a SDK.
###############################################################################

# $1: language (cpp|java|python).
# $2: output directory (Relative to build directory unless an absolute path is
#     given (ex LOCAL_PATH).
# $3: input .proto file
# $4: optional value for --proto_path, by default it is the directory of the
#     .proto file
define protoc-macro

# Setup some internal variables
protoc_in_file := $3
protoc_proto_path := $(call remove-trailing-slash,$(or $4,$(dir $3)))
# reproduce what -I/--proto_path does, so that we can have some sort of namespacing
protoc_out_subdir := $$(call remove-trailing-slash,$$(patsubst $$(protoc_proto_path)/%,%,$(dir $3)))

protoc_module_build_dir := $(call local-get-build-dir)
protoc_out_rootdir := $$(call remove-trailing-slash,$$(if $$(call is-path-absolute,$2),$2,$$(protoc_module_build_dir)/$2))
protoc_out_dir := $$(call remove-trailing-slash,$$(protoc_out_rootdir)/$$(protoc_out_subdir))
protoc_dep_file := $$(protoc_module_build_dir)/$$(subst $(colon),_,$$(subst /,_,$$(call path-from-top,$$(protoc_in_file)))).$1.d
protoc_aux_file := $$(protoc_module_build_dir)/$$(subst $(colon),_,$$(subst /,_,$$(call path-from-top,$$(protoc_in_file)))).$1.d.tmp
protoc_done_file := $$(protoc_module_build_dir)/$$(subst $(colon),_,$$(subst /,_,$$(call path-from-top,$$(protoc_in_file)))).$1.done

# Directory where to copy the input .proto file
protoc_out_cp_proto := $$(if $$(protoc_out_subdir), \
	$(TARGET_OUT_STAGING)/usr/share/protobuf/$$(protoc_out_subdir)/$(notdir $3), \
	$(TARGET_OUT_STAGING)/usr/share/protobuf/$(notdir $3) \
)

# The CPP generation case is handled here (endl is to force new line even if macro
# requires single line)
$(if $(call streq,$1,cpp), \
	protoc_src_file := $$(addprefix $$(protoc_out_dir)/,$$(patsubst %.proto,%.pb.cc,$(notdir $3))) $(endl) \
	protoc_inc_file := $$(addprefix $$(protoc_out_dir)/,$$(patsubst %.proto,%.pb.h,$(notdir $3))) $(endl) \
)

# the Java generation case is handled here (endl is to force new line even if macro
# requires single line)
$(if $(call streq,$1,java), \
	protoc_src_file := $$(addprefix $$(protoc_out_dir)/,$$(patsubst %.proto,%.java,$(notdir $3))) $(endl) \
	protoc_inc_file := $(endl) \
)

# the Python generation case is handled here (endl is to force new line even if macro
# requires single line)
$(if $(call streq,$1,python), \
	protoc_src_file := $$(addprefix $$(protoc_out_dir)/,$$(patsubst %.proto,%_pb2.py,$(notdir $3))) $(endl) \
	protoc_inc_file := $(endl) \
)

protoc_gen_files := $$(protoc_src_file) $$(protoc_inc_file)

# Create a dependency between generated files and .done file with an empty
# command to make sure regeneration is correctly triggered to files
# depending on them
$$(protoc_gen_files): $$(protoc_done_file)
	$(empty)

# Actual generation rule
$$(protoc_done_file): PRIVATE_OUT_ROOTDIR := $$(protoc_out_rootdir)
$$(protoc_done_file): PRIVATE_PROTO_PATH := $$(protoc_proto_path)
$$(protoc_done_file): PRIVATE_PROTO_SRC_FILE := $$(protoc_src_file)
$$(protoc_done_file): PRIVATE_PROTO_OUT_CP_PROTO := $$(protoc_out_cp_proto)
$$(protoc_done_file): PRIVATE_PROTO_DEP_FILE := $$(protoc_dep_file)
$$(protoc_done_file): PRIVATE_PROTO_AUX_FILE := $$(protoc_aux_file)

ifeq ("$(HOST_OS)","windows")
$$(protoc_done_file): PRIVATE_PROTOC_EXE := protoc
else ifeq ("$(CONFIG_PROTOBUF_PACKAGE_PROTOC)","y")
$$(protoc_done_file): PRIVATE_PROTOC_EXE := $(HOST_OUT_STAGING)/usr/bin/protoc
else
$$(protoc_done_file): PRIVATE_PROTOC_EXE := protoc
endif

$$(protoc_done_file): $$(protoc_in_file) $$(PRIVATE_PROTOC_EXE)
	$$(call print-banner1,"Generating",$$(call path-from-top,$$(PRIVATE_PROTO_SRC_FILE)),$$(call path-from-top,$3))
	@mkdir -p $$(PRIVATE_OUT_ROOTDIR)

	$(Q) $$(PRIVATE_PROTOC_EXE) \
		--$1_out=$$(PRIVATE_OUT_ROOTDIR) \
		--proto_path=$$(PRIVATE_PROTO_PATH) \
		--proto_path=$(TARGET_OUT_STAGING)/usr/share/protobuf \
		$(foreach __dir,$(TARGET_SDK_DIRS), \
			$(if $(wildcard $(__dir)/usr/share/protobuf), \
				--proto_path=$(__dir)/usr/share/protobuf \
			) \
		) \
		--dependency_out=$$(PRIVATE_PROTO_DEP_FILE) \
		$3

#	Add a license file for generated code
	@echo "Generated code." > $$(PRIVATE_OUT_ROOTDIR)/.MODULE_LICENSE_BSD

#	Input file is in the form
#		a.cc a.h: c.proto d.proto ...
#	With potentially lines split with continuation lines '\'
#	We need to get the list of files after the ':' to generated a line of
#	this form for each dependency
#		c.proto:
#		d.proto:
#		....
#
#	Sed will see a single '$' for each '$$$$'.
#
#	The hard part is to be compatible with macos...
#
#	1: remove continuation lines and concatenates lines
#	2: remove everithinh before the ':'
#	3: split files one per line (the folowing sed fails on macos: 's/ */"\n"/g')
#	4: strip spaces on lines
#	5: remove empty lines
#	6: add ':' at the end of lines
	$(Q) sed -e ':x' -e '/\\$$$$/{N;bx' -e '}' -e 's/\\\n//g' \
		-e 's/.*://' \
		$$(PRIVATE_PROTO_DEP_FILE) \
		| fmt -1 \
		| sed -e 's/^ *//' \
		-e '/^$$$$/d' \
		-e 's/$$$$/:/' \
		> $$(PRIVATE_PROTO_AUX_FILE)

#	Add contents at the end of original file (with a new line before)
	@( \
		echo ""; \
		cat $$(PRIVATE_PROTO_AUX_FILE) \
	) >> $$(PRIVATE_PROTO_DEP_FILE)
	@rm $$(PRIVATE_PROTO_AUX_FILE)

#	The copy of .proto file is done via a temp copy and move to ensure atomicity
#	of copy in case of parallel copy of the same file
#	Use flock when possible to avoid race conditions in some mv implementations
	@mkdir -p $$(dir $$(PRIVATE_PROTO_OUT_CP_PROTO))
ifeq ("$(HOST_OS)","darwin")
	@( \
		tmpfile=`mktemp $$(PRIVATE_BUILD_DIR)/tmp.XXXXXXXX`; \
		cp -af $3 $$$${tmpfile}; \
		mv -f $$$${tmpfile} $$(PRIVATE_PROTO_OUT_CP_PROTO); \
	)
else
	@flock --wait 60 $$(dir $$(PRIVATE_PROTO_OUT_CP_PROTO)) cp -af $3 $$(PRIVATE_PROTO_OUT_CP_PROTO)
endif
	@mkdir -p $$(dir $$@)
	@touch $$@

-include $$(protoc_dep_file)

# Update either LOCAL_SRC_FILES or LOCAL_GENERATED_SRC_FILES
$(if $(call strneq,$1,python), \
$(if $(call is-path-absolute,$2), \
	LOCAL_SRC_FILES += $$(patsubst $$(LOCAL_PATH)/%,%,$$(protoc_src_file)) \
	, \
	LOCAL_GENERATED_SRC_FILES += $$(patsubst $$(protoc_module_build_dir)/%,%,$$(protoc_src_file)) \
))

# Update alchemy variables for the module
LOCAL_CLEAN_FILES += $$(protoc_done_file) $$(protoc_gen_files) $$(protoc_out_cp_proto) $$(protoc_dep_file)
LOCAL_EXPORT_PREREQUISITES += $$(protoc_gen_files) $$(protoc_done_file)

ifneq ("$(HOST_OS)","windows")
LOCAL_DEPENDS_HOST_MODULES += host.protobuf
endif

endef

# Register the macro in alchemy so it will be integrated in generated sdk
$(call local-register-custom-macro,protoc-macro)
