CC      = gcc
LD      = gcc
CFLAGS  = -O2 -Wall -Wextra
CFLAGS += -Wno-unused-parameter -Wno-unused-function -Wno-unused-result
INCLDS  = -I $(INC_DIR)
BIN_DIR = bin
BLD_DIR = build
DOC_DIR = docs
INC_DIR = includes
LOG_DIR = log
OUT_DIR = out
SRC_DIR = src
TST_DIR = tests
SRC     = $(wildcard $(SRC_DIR)/*.c)
OBJS    = $(patsubst $(SRC_DIR)/%.c,$(BLD_DIR)/%.o,$(SRC))
DEPS    = $(patsubst $(BLD_DIR)/%.o,$(BLD_DIR)/%.d,$(OBJS))
PROGRAM = program

vpath %.c $(SRC_DIR)

.DEFAULT_GOAL = build

.PHONY: build check setup clean debug doc fmt lint run test

$(BLD_DIR)/%.d: %.c
	$(CC) -M $(INCLDS) $(CFLAGS) $(INCLUDES) $< -o $@

$(BLD_DIR)/%.o: %.c
	$(CC) -c $(INCLDS) $(CFLAGS) $(INCLUDES) $< -o $@

$(BIN_DIR)/$(PROGRAM): $(DEPS) $(OBJS)
	$(CC) $(INCLDS) $(CFLAGS) $(INCLUDES) -o $@ $(OBJS)

build: setup $(BIN_DIR)/$(PROGRAM)

run: build
	@./$(BIN_DIR)/$(PROGRAM)

fmt:
	@echo "C and Headers files:"
	@-clang-format -style="{BasedOnStyle: Google, IndentWidth: 4}" -verbose -i \
		$(SRC_DIR)/* $(INC_DIR)/*
	@echo ""
	@echo "Shell files:"
	@shfmt -l -w -i 2 .

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

debug: CFLAGS = -Wall -Wextra -ansi -pedantic -O0 -g
debug: build
	gdb ./$(BIN_DIR)/$(PROGRAM)

doc:
	@doxygen $(DOC_DIR)/Doxyfile

test:
	@echo "Write some tests!"

setup:
	@mkdir -p $(BIN_DIR)
	@mkdir -p $(BLD_DIR)
	@mkdir -p $(DOC_DIR)
	@mkdir -p $(LOG_DIR)
	@mkdir -p $(OUT_DIR)

clean:
	@echo "Cleaning..."
	@echo ""
	@cat .art/maid.ascii
	@-rm -rf $(BLD_DIR)/* $(BIN_DIR)/* $(OUT_DIR)/* $(LOG_DIR)/* \
		$(DOC_DIR)/html $(DOC_DIR)/latex
	@echo ""
	@echo "...✓ done!"

