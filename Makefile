#==============================================================================
SHELL   = sh
#------------------------------------------------------------------------------
NO_COLOR=\x1b[0m
OK_COLOR=\x1b[32m
ERROR_COLOR=\x1b[31m
WARN_COLOR=\x1b[33m
OK_STRING=$(OK_COLOR)✓$(NO_COLOR)
ERROR_STRING=$(ERROR_COLOR)⨯$(NO_COLOR)
WARN_STRING=$(WARN_COLOR)problems$(NO_COLOR)
#------------------------------------------------------------------------------
CC      = gcc
LD      = gcc
CFLAGS  = -O2 -Wall -Wextra
CFLAGS += -Wno-unused-parameter -Wno-unused-function -Wno-unused-result
LIBS    = `pkg-config --cflags --libs glib-2.0`
INCLDS  = -I $(INC_DIR)
#------------------------------------------------------------------------------
BIN_DIR = bin
BLD_DIR = build
DOC_DIR = docs
INC_DIR = includes
LOG_DIR = log
OUT_DIR = out
SRC_DIR = src
TST_DIR = tests
UTI_DIR = scripts
#------------------------------------------------------------------------------
TRASH   = $(BIN_DIR) $(BLD_DIR) $(DOC_DIR)/{html,latex} $(LOG_DIR) $(OUT_DIR)
#------------------------------------------------------------------------------
SRC     = $(wildcard $(SRC_DIR)/*.c)
OBJS    = $(patsubst $(SRC_DIR)/%.c,$(BLD_DIR)/%.o,$(SRC))
DEPS    = $(patsubst $(BLD_DIR)/%.o,$(BLD_DIR)/%.d,$(OBJS))
#------------------------------------------------------------------------------
PROGRAM = program
#==============================================================================

vpath %.c $(SRC_DIR)

.DEFAULT_GOAL = build

define show
@./$(UTI_DIR)/fmt.sh --color $(1) --type $(2) $(3)
endef

$(BLD_DIR)/%.d: %.c
	-$(call show,cyan,reset,"Generating $(shell basename $@) ... ")
	@$(CC) -M $(INCLDS) $(LIBS) $(CFLAGS) $< -o $@
	@echo -e "$(OK_STRING)"

$(BLD_DIR)/%.o: %.c
	-$(call show,blue,reset,"Building $(shell basename $@) ... ")
	@$(CC) -c $(INCLDS) $(LIBS) $(CFLAGS) $< -o $@
	@echo -e "$(OK_STRING)"

$(BIN_DIR)/$(PROGRAM): $(DEPS) $(OBJS)
	-$(call show,green,bold,"Compiling $(shell basename $@) ... ")
	@$(CC) $(INCLDS) $(LIBS) $(CFLAGS) -o $@ $(OBJS)
	@echo -e "$(OK_STRING)"

.PHONY: build # Compile the binary program
build compile: setup $(BIN_DIR)/$(PROGRAM)

run go: build
	@./$(BIN_DIR)/$(PROGRAM) argumento1 "string 1" "string 2"

.PHONY: format fmt # Format source files and scripts
format fmt:
	-$(call show,yellow,reset,"C and Headers files")
	@echo ":"
	@-clang-format -verbose -i $(SRC_DIR)/* $(INC_DIR)/*
	@echo ""
	-$(call show,yellow,reset,"Shell files")
	@echo ":"
	@shfmt -w -i 2 -l -ci .

.PHONY: lint # Lint your code
lint:
	@splint -retvalint -hints -I $(INC_DIR) \
		$(SRC_DIR)/*

check: LOG = $(LOG_DIR)/`date +%Y-%m-%d_%H:%M:%S`
check: CFLAGS += -pg
check: build
	@memusage --data=$(LOG).dat --png=$(LOG).png $(BIN_DIR)/$(PROGRAM)
	@gprof $(BIN_DIR)/$(PROGRAM) gmon.out > $(LOG).txt
	@valgrind --tool=memcheck --leak-check=full --show-leak-kinds=all \
		--log-file=$(LOG).log ./$(BIN_DIR)/$(PROGRAM)

.PHONY: debug # Run your program with the debugger
debug: CFLAGS = -Wall -Wextra -ansi -pedantic -O0 -g
debug: build
	gdb ./$(BIN_DIR)/$(PROGRAM)

.PHONY: doc # Generate the documentation
documentation doc:
	@doxygen $(DOC_DIR)/Doxyfile

.PHONY: test # Run the tests
test:
	@echo "Write some tests!"

setup:
	@mkdir -p $(BIN_DIR)
	@mkdir -p $(BLD_DIR)
	@mkdir -p $(LOG_DIR)
	@mkdir -p $(OUT_DIR)

.PHONY: clean # Delete build artifacts
clean:
	@cat .art/maid.ascii
	@echo -n "Cleaning ... "
	@-rm -rf $(TRASH)
	@echo -e "$(OK_STRING)"

.PHONY: help # Generate list of targets with descriptions
help:
	@grep '^.PHONY: .* #' Makefile | sed 's/\.PHONY: \(.*\) # \(.*\)/    \1 \t \2/'
