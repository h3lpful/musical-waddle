ARCH?=x86_64-linux-musl
WD:=${PWD}
DL_DIR:=$(WD)/dl
CH_DIR:=$(WD)/chains
BUILD_DIR:=$(WD)/build
BL_DIR:=$(BUILD_DIR)/$(ARCH)

CHAIN_SOURCE:=http://musl.cc/
CHAIN_SUFFIX:=-cross
CHAIN_EXT:=.tgz

BR_SOURCE:=http://sources.buildroot.net

CH_PATH:=$(ARCH)$(CHAIN_SUFFIX)
CH_TAR:=$(CH_PATH)$(CHAIN_EXT)
CH_SRC:=$(CHAIN_SOURCE)$(CH_TAR)
CH_DL:=$(DL_DIR)/$(CH_TAR)
CHAIN:=$(CH_DIR)/$(CH_PATH)
CH_LIB:=$(CHAIN)/$(ARCH)

GCRYPT_VER:=1.10.3
GCRYPT_DIR:=libgcrypt-$(GCRYPT_VER)
GCRYPT_TAR:=$(GCRYPT_DIR).tar.bz2
GCRYPT_DL_SRC:=$(BR_SOURCE)/libgcrypt
GCRYPT_TAR_SRC:=$(GCRYPT_DL_SRC)/$(GCRYPT_TAR)
GCRYPT_DL:=$(DL_DIR)/$(GCRYPT_TAR)
GCRYPT_SRC:=$(BL_DIR)/$(GCRYPT_DIR)
GCRYPT_BUILD:=$(GCRYPT_SRC)/build
GCRYPT:=$(CH_LIB)/lib/libgcrypt.a

# http://sources.buildroot.net/libgpg-error/libgpg-error-1.47.tar.bz2

LGPG_VER:=1.47
LGPG_DIR:=libgpg-error-$(LGPG_VER)
LGPG_TAR:=$(LGPG_DIR).tar.bz2
LGPG_DL_SRC:=$(BR_SOURCE)/libgpg-error
LGPG_TAR_SRC:=$(LGPG_DL_SRC)/$(LGPG_TAR)
LGPG_DL:=$(DL_DIR)/$(LGPG_TAR)
LGPG_SRC:=$(BL_DIR)/$(LGPG_DIR)
LGPG_BUILD:=$(LGPG_SRC)/build
LGPG:=$(CH_LIB)/lib/libgpg-error.a

MTLS_VER:=2.28.7
MTLS_DIR:=mbedtls-$(MTLS_VER)
MTLS_TAR:=$(MTLS_DIR).tar.gz
MTLS_DL_SRC:=$(BR_SOURCE)/mbedtls
MTLS_TAR_SRC:=$(MTLS_DL_SRC)/$(MTLS_TAR)
MTLS_DL:=$(DL_DIR)/$(MTLS_TAR)
MTLS_SRC:=$(BL_DIR)/$(MTLS_DIR)
MTLS_BUILD:=$(MTLS_SRC)/build
MTLS:=$(CH_LIB)/lib/libmbedtls.a

# http://sources.buildroot.net/libzlib/zlib-1.3.1.tar.xz

ZLIB_VER:=1.3.1
ZLIB_DIR:=zlib-$(ZLIB_VER)
ZLIB_TAR:=$(ZLIB_DIR).tar.xz
ZLIB_DL_SRC:=$(BR_SOURCE)/libzlib
ZLIB_TAR_SRC:=$(ZLIB_DL_SRC)/$(ZLIB_TAR)
ZLIB_DL:=$(DL_DIR)/$(ZLIB_TAR)
ZLIB_SRC:=$(BL_DIR)/$(ZLIB_DIR)
ZLIB_BUILD:=$(ZLIB_SRC)/build
ZLIB:=$(CH_LIB)/lib/libz.a

# http://sources.buildroot.net/libssh/libssh-0.10.6.tar.xz

LSSH_VER:=0.10.6
LSSH_DIR:=libssh-$(LSSH_VER)
LSSH_TAR:=$(LSSH_DIR).tar.xz
LSSH_DL_SRC:=$(BR_SOURCE)/libssh
LSSH_TAR_SRC:=$(LSSH_DL_SRC)/$(LSSH_TAR)
LSSH_DL:=$(DL_DIR)/$(LSSH_TAR)
LSSH_SRC:=$(BL_DIR)/$(LSSH_DIR)
LSSH_BUILD:=$(LSSH_SRC)/build
LSSH_PRE:=$(LSSH_BUILD)/src/libssh.a
LSSH:=$(CH_LIB)/lib/libssh.a

BIN_DIR:=$(CHAIN)/bin
BIN_PRE:=$(BIN_DIR)/$(ARCH)

AR:=$(BIN_PRE)-ar
AS:=$(BIN_PRE)-as
CC:=$(BIN_PRE)-gcc
CXX:=$(BIN_PRE)-g++
LD:=$(BIN_PRE)-ld
STRIP:=$(BIN_PRE)-strip
RANLIB:=$(BIN_PRE)-ranlib

CFG_FLAGS:=AR=$(AR) AS=$(AS) CC=$(CC) CXX=$(CXX) LD=$(LD) STRIP=$(STRIP) RANLIB=$(RANLIB) --host=$(ARCH) --prefix=$(CHAIN)/$(ARCH) --enable-static

CMAKE_FLAGS:=-DCMAKE_C_COMPILER=$(CC) -DCMAKE_CXX_COMPILER=$(CXX) -DCMAKE_INSTALL_PREFIX=$(CHAIN)/$(ARCH)/ -DCMAKE_C_FLAGS='-Os'

LSSH_FLAGS:=$(CMAKE_FLAGS) -DCMAKE_SYSTEM_LIBRARY_PATH=$(CHAIN)/$(ARCH) \
	-DCMAKE_REQUIRED_INCLUDES=$(CHAIN)/$(ARCH) \
	-DCMAKE_LIBRARY_PATH=$(CHAIN)/$(ARCH) \
	-DCMAKE_SYSROOT=$(CHAIN)/$(ARCH) \
	-DCMAKE_FIND_ROOT_PATH=$(CHAIN)/$(ARCH) \
	-DWITH_MBEDTLS=ON \
	-DWITH_EXAMPLES=OFF \
	-DBUILD_STATIC_LIB=ON

INCLUDE_DIR:=$(CHAIN)/$(ARCH)/include

.PHONY:all dist-clean $(LSSH)

all: $(LSSH)

$(DL_DIR):
	mkdir -p $@

$(CH_DIR):
	mkdir -p $@

$(BL_DIR):
	mkdir -p $@

$(CH_DL): $(DL_DIR)
	wget $(CH_SRC) -O $@

$(GCRYPT_DL): $(DL_DIR)
	wget $(GCRYPT_TAR_SRC) -O $@

$(CHAIN): $(CH_DL) $(CH_DIR)
	tar xvf $< -C $(CH_DIR)

#MTLS
$(MTLS_DL): $(DL_DIR)
	wget $(MTLS_TAR_SRC) -O $@

$(MTLS_SRC): $(MTLS_DL) $(BL_DIR)
	tar xvf $< -C $(BL_DIR)

$(MTLS_BUILD): $(MTLS_SRC)
	mkdir -p $@

$(MTLS): $(MTLS_BUILD) $(CHAIN)
	cd $< && cmake .. $(CMAKE_FLAGS) && make && make install

#ZLIB
$(ZLIB_DL): $(DL_DIR)
	wget $(ZLIB_TAR_SRC) -O $@

$(ZLIB_SRC): $(ZLIB_DL) $(BL_DIR)
	tar xvf $< -C $(BL_DIR)

$(ZLIB_BUILD): $(ZLIB_SRC)
	mkdir -p $@

$(ZLIB): $(ZLIB_BUILD) $(CHAIN)
	cd $< && cmake .. $(CMAKE_FLAGS) && make && make install

#LGPG
$(LGPG_DL): $(DL_DIR)
	wget $(LGPG_TAR_SRC) -O $@

$(LGPG_SRC): $(LGPG_DL) $(BL_DIR)
	tar xvf $< -C $(BL_DIR)

$(LGPG_BUILD): $(LGPG_SRC)
	mkdir -p $@

$(LGPG): $(LGPG_BUILD) $(CHAIN)
	cd $< && ../configure $(CFG_FLAGS) && make && make install

#GCRYPT
$(GCRYPT_DL): $(DL_DIR) $(ZLIB) $(LGPG)
	wget $(GCRYPT_TAR_SRC) -O $@

$(GCRYPT_SRC): $(GCRYPT_DL) $(BL_DIR)
	tar xvf $< -C $(BL_DIR)

$(GCRYPT_BUILD): $(GCRYPT_SRC)
	mkdir -p $@

$(GCRYPT): $(GCRYPT_BUILD) $(CHAIN)
	cd $< && ../configure $(CFG_FLAGS) && make && make install

#LSSH
$(LSSH_DL): $(DL_DIR)
	wget $(LSSH_TAR_SRC) -O $@

$(LSSH_SRC): $(LSSH_DL) $(BL_DIR)
	tar xvf $< -C $(BL_DIR)

$(LSSH_BUILD): $(LSSH_SRC)
	mkdir -p $@

$(LSSH_PRE): $(LSSH_BUILD) $(CHAIN) $(MTLS) $(ZLIB)
	cd $< && cmake .. $(LSSH_FLAGS) && make && make install

# build/x86_64-linux-musl/libssh-0.10.6/build/src/libssh.a
$(LSSH): $(LSSH_PRE)
	cp $< $@

dist-clean:
	rm -rf $(DL_DIR) $(CH_DIR) $(BUILD_DIR)