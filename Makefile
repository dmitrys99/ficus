EXTRA_INCLUDE := ./runtime
RUNTIME_DIR := ./runtime/ficus
RUNTIME_DEPS := $(wildcard $(RUNTIME_DIR)/*.h)
RUNTIME_IMPL_DEPS := $(wildcard $(RUNTIME_DIR)/impl/*.h)
BUILD_DIR := __fxbuild__
BOOTSTRAP_BUILD_DIR := $(BUILD_DIR)/bootstrap
BOOTSTRAP_SRC := ./compiler/bootstrap
BOOTSTRAP_SRCS := $(wildcard $(BOOTSTRAP_SRC)/*.c)
FICUS0  := $(BOOTSTRAP_BUILD_DIR)/ficus0
GIT_COMMIT := "$(shell git describe)"
FICUS_SRC := ./compiler
FICUS_SRCS := $(wildcard $(FICUS_SRC)/*.fx)
FICUS_STDLIB := ./lib
FICUS_STDLIB_SRCS := $(wildcard $(FICUS_STDLIB)/*.fx)
FICUS_BIN := ./bin
FICUS := $(FICUS_BIN)/ficus

ifeq ($(OS),Windows_NT)
	COLOR_OK :=
	COLOR_INFO :=
	COLOR_NORMAL :=
	IF_EXIST_FILE := if exist
	IF_EXIST := if exist
	IF_NOT_EXIST := if not exist
	MKDIR := (mkdir
	RMDIR := (rmdir /s /q
	RM := (del /s /q
	OBJ := obj
	CC := cl /nologo /MT /Ob2
    CFLAGS += /D WIN32 /D _WIN32 /I$(EXTRA_INCLUDE) /c /Fo
	LDFLAGS := /Fe
	LDLIBS := kernel32.lib advapi32.lib
	BOOTSTRAP_OBJS := $(patsubst $(BOOTSTRAP_SRC)/%.c,$(BOOTSTRAP_BUILD_DIR)/%.obj,$(BOOTSTRAP_SRCS))
else
	COLOR_OK := \033[32;1m
	COLOR_INFO := \033[34;1m
	COLOR_NORMAL := \033[0m
	IF_EXIST_FILE := test -f
	IF_EXIST := test -d
    IF_NOT_EXIST := test -d
	MKDIR := || (mkdir -p
	RMDIR := && (rm -rf
	OBJ := o
	CC := cc -Wno-unknown-warning-option -Wno-dangling-else -Wno-static-in-inline -O3
	CFLAGS := -I$(EXTRA_INCLUDE) -c -o
	LDFLAGS :=
	LDLIBS := -lm
	BOOTSTRAP_OBJS := $(patsubst $(BOOTSTRAP_SRC)/%.c,$(BOOTSTRAP_BUILD_DIR)/%.o,$(BOOTSTRAP_SRCS))
    UNAME_S := $(shell uname -s)
    UNAME_M := $(shell uname -m)
	ifeq ($(UNAME_S),Darwin)
		ifeq ($(UNAME_M),x86_64)
			CFLAGS := -Xclang -fopenmp $(CFLAGS)
			LDFLAGS := -Xclang -fopenmp $(LDFLAGS)
        	LDLIBS += -L./runtime/lib/macos_x64/ -lomp
		endif
		ifeq ($(UNAME_M),arm64)
			CFLAGS := -Xclang -fopenmp $(CFLAGS)
        	LDLIBS += -L./runtime/lib/macos_arm64/ -lomp
		endif
	endif
	ifeq ($(UNAME_S),Linux)
		CFLAGS := -fopenmp $(CFLAGS)
		LDFLAGS := -fopenmp $(LDFLAGS)
	endif
	LDFLAGS += -o
endif

FICUS_FLAGS := -verbose -O3

.PHONY: all clean final_note

all: $(FICUS0) $(FICUS) final_note

$(FICUS0): $(BOOTSTRAP_OBJS)
	@$(CC) $(LDFLAGS)$@ $^ $(LDLIBS)

$(BOOTSTRAP_BUILD_DIR)/ficus.$(OBJ): $(BOOTSTRAP_SRC)/ficus.c $(RUNTIME_DEPS) $(RUNTIME_IMPL_DEPS)
	@echo CC ficus.c
	@$(CC) $(CFLAGS) $@ $<

$(BOOTSTRAP_BUILD_DIR)/%.$(OBJ): $(BOOTSTRAP_SRC)/%.c | $(BOOTSTRAP_BUILD_DIR)
	@echo CC $<
	@$(CC) $(CFLAGS)$@ $<

$(FICUS): $(FICUS0) $(FICUS_SRCS) $(FICUS_STDLIB_SRCS)
	@echo "$(COLOR_INFO)Building fresh compiler from the actual ficus sources$(COLOR_NORMAL)"
	@echo #define FX_GIT_COMMIT $(GIT_COMMIT) > $(RUNTIME_DIR)/version.git_commit
	@$(IF_NOT_EXIST) "$(FICUS_BIN)" $(MKDIR) "$(FICUS_BIN)")
	@$(FICUS0) $(FICUS_FLAGS) -o $(FICUS) $(FICUS_SRC)/fx.fx

$(BOOTSTRAP_BUILD_DIR):
	@echo "$(COLOR_INFO)Building reference compiler from the pre-generated .c sources$(COLOR_NORMAL)"
	@$(IF_NOT_EXIST) "$(BUILD_DIR)" $(MKDIR) "$(BUILD_DIR)")
	@$(IF_NOT_EXIST) "$(BOOTSTRAP_BUILD_DIR)" $(MKDIR) "$(BOOTSTRAP_BUILD_DIR)")

final_note: | $(FICUS)
	@echo ""
	@echo "$(COLOR_OK)./bin/ficus was built successfully.$(COLOR_NORMAL)"
	@echo "Now setup 'FICUS_PATH=<path_to_stdlib>' (lib subdirectory of the root directory)"
	@echo "and optionally 'FICUS_CFLAGS' and 'FICUS_LINK_LIBRARIES' to pass to C compiler."
	@echo "After that you can copy ficus to whatever directory you want and use it."
	@echo "When compiling an application, ficus creates __fxbuild__/<appname> subdirectory"
	@echo "in the current directory for the intermediate .c and .o files,"
	@echo "as well as the produced application".

clean:
	@$(IF_EXIST) "$(BOOTSTRAP_BUILD_DIR)/" $(RMDIR) "$(BOOTSTRAP_BUILD_DIR)")
	@$(IF_EXIST) "$(BUILD_DIR)/ficus/" $(RMDIR) "$(BUILD_DIR)/ficus")
	@$(IF_EXIST_FILE) "$(FICUS)" $(RM) "$(FICUS)")
