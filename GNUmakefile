EXTRA_INCLUDE := ./runtime
RUNTIME_DIR := ./runtime/ficus
RUNTIME_DEPS := $(wildcard $(RUNTIME_DIR)/*.h)
RUNTIME_IMPL_DEPS := $(wildcard $(RUNTIME_DIR)/impl/*.h)
RUNTIME_LIBFICUS_C := $(RUNTIME_DIR)/impl/libficus.c
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

COLOR_OK := \033[32;1m
COLOR_INFO := \033[34;1m
COLOR_NORMAL := \033[0m
MKDIR := mkdir -p
RM := rm -rf
CC := cc -Wno-unknown-warning-option -Wno-dangling-else -Wno-static-in-inline -O3
CFLAGS := -I$(EXTRA_INCLUDE) -c -o
LDFLAGS := -o
LDLIBS := -lm
BOOTSTRAP_OBJS := $(patsubst $(BOOTSTRAP_SRC)/%.c,$(BOOTSTRAP_BUILD_DIR)/%.o,$(BOOTSTRAP_SRCS)) $(BOOTSTRAP_BUILD_DIR)/libficus.o
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

FICUS_FLAGS := -verbose -O3

.PHONY: all clean final_note doc

all: $(FICUS0) $(FICUS) final_note

$(FICUS0): $(BOOTSTRAP_OBJS)
	@$(CC) $(LDFLAGS)$@ $^ $(LDLIBS)

$(BOOTSTRAP_BUILD_DIR)/fx.o: $(BOOTSTRAP_SRC)/fx.c $(RUNTIME_DEPS) $(RUNTIME_IMPL_DEPS)
	@echo CC fx.c
	@$(CC) $(CFLAGS) $@ $<

$(BOOTSTRAP_BUILD_DIR)/libficus.o: $(RUNTIME_LIBFICUS_C) $(RUNTIME_DEPS) $(RUNTIME_IMPL_DEPS)
	@echo CC libficus.c
	@$(CC) $(CFLAGS) $@ $<

$(BOOTSTRAP_BUILD_DIR)/%.o: $(BOOTSTRAP_SRC)/%.c $(RUNTIME_DEPS) | $(BOOTSTRAP_BUILD_DIR)
	@echo CC $<
	@$(CC) $(CFLAGS) $@ $<

$(FICUS): $(FICUS0) $(FICUS_SRCS) $(FICUS_STDLIB_SRCS)
	@echo "$(COLOR_INFO)Building fresh compiler from the actual ficus sources$(COLOR_NORMAL)"
	@echo #define FX_GIT_COMMIT $(GIT_COMMIT) > $(RUNTIME_DIR)/version.git_commit
	@$(MKDIR) $(FICUS_BIN)
	@$(FICUS0) $(FICUS_FLAGS) -o $(FICUS) $(FICUS_SRC)/fx.fx

$(BOOTSTRAP_BUILD_DIR):
	@echo "$(COLOR_INFO)Building reference compiler from the pre-generated .c sources$(COLOR_NORMAL)"
	@$(MKDIR) $(BUILD_DIR)
	@$(MKDIR) $(BOOTSTRAP_BUILD_DIR)

final_note: | $(FICUS)
	@echo ""
	@echo "$(COLOR_OK)./bin/ficus was built successfully.$(COLOR_NORMAL)"
	@echo "Now setup 'FICUS_PATH=<path_to_stdlib>' (lib subdirectory of the root directory)"
	@echo "and optionally 'FICUS_CFLAGS' and 'FICUS_LINK_LIBRARIES' to pass to C compiler."
	@echo "After that you can copy ficus to whatever directory you want and use it."
	@echo "When compiling an application, ficus creates __fxbuild__/<appname> subdirectory"
	@echo "in the current directory for the intermediate .c and .o files,"
	@echo "as well as the produced application".

doc: ficustut_a4.pdf ficustut_ru_a4.pdf

ficustut_a4.pdf: doc/ficustut.md doc/fxtemplate.latex Makefile
	pandoc                                        \
		-f markdown                           \
		--pdf-engine=xelatex                  \
		--resource-path=doc:.                 \
		-V geometry:margin=1in                \
		-V mainfont='Source Serif 4'          \
		-V fontsize=11pt                      \
		-V monofont='IBM Plex Mono'           \
		-V documentclass=article              \
		-V papersize=A4                       \
		-V title="Ficus\\\\[5pt]programming\\\\[5pt]language" \
		-V urlcolor=red                       \
		-V author="Vadim Pisarevsky"          \
		--listings                            \
		--template doc/fxtemplate.latex       \
		-o doc/ficustut_a4.pdf                \
		--toc                                 \
		doc/ficustut.md

ficustut_ru_a4.pdf: doc/ficustut_ru.md doc/fxtemplate.latex Makefile
	pandoc                                        \
		-V geometry:margin=1in                \
		-V mainfont='Source Serif 4'          \
		-V fontsize=11pt                      \
		-V monofont='IBM Plex Mono'           \
		-V documentclass=article              \
		-V papersize=A4                       \
		-V urlcolor=red                       \
		-V title="Язык\\\\[12pt]программирования\\\\[5pt]Ficus" \
		-V author="Вадим Писаревский"         \
		-V header-includes="\addto\captionsrussian{\renewcommand{\contentsname}{Содержание}}" \
		-V lang=ru                            \
		-f markdown                           \
		--pdf-engine=xelatex                  \
		--resource-path=doc:.                 \
		--listings                            \
		--template doc/fxtemplate.latex       \
		-o doc/ficustut_ru_a4.pdf             \
		--toc                                 \
		doc/ficustut_ru.md

ficustut_ru_a4.tex: doc/ficustut_ru.md doc/fxtemplate.latex Makefile
	pandoc                                        \
		-V geometry:margin=1in                \
		-V mainfont='Source Serif 4'          \
		-V fontsize=11pt                      \
		-V monofont='IBM Plex Mono'           \
		-V documentclass=article              \
		-V papersize=A4                       \
		-V urlcolor=red                       \
		-V title="Язык\\\\[12pt]программирования\\\\[5pt]Ficus" \
		-V author="Вадим Писаревский"         \
		-V header-includes="\addto\captionsrussian{\renewcommand{\contentsname}{Содержание}}" \
		-V lang=ru                            \
		-f markdown                           \
		--pdf-engine=xelatex                  \
		--resource-path=doc:.                 \
		--listings                            \
		--template doc/fxtemplate.latex       \
		-o doc/ficustut_ru_a4.tex             \
		--toc                                 \
		doc/ficustut_ru.md

clean:
	@$(RM) $(BOOTSTRAP_BUILD_DIR)
	@$(RM) $(BUILD_DIR)/ficus
	@$(RM) $(FICUS)
	@$(RM) doc/ficustut_a4.pdf
