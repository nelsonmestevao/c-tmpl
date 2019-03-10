CC      = gcc
LD      = gcc
CFLAGS  = -O2 -Wall -Wextra -Wno-unused-parameter -Wno-unused-function -Wno-unused-result -pedantic -g
BIN_DIR = bin
BLD_DIR = build
DOC_DIR = docs
OUT_DIR = out
SRC_DIR = src
TST_DIR = tests
SRC     = $(wildcard $(SRC_DIR)/*.c)
OBJS    = $(patsubst $(SRC_DIR)/%.c,$(BLD_DIR)/%.o,$(SRC))
DEPS    = $(patsubst $(BLD_DIR)/%.o,$(BLD_DIR)/%.d,$(OBJS))
PROGRAM = program

vpath %.c $(SRC_DIR)

.DEFAULT_GOAL = all

.PHONY: run fmt lint leak-check doc checkdirs all clean

$(BLD_DIR)/%.d: %.c
	$(CC) -M $(CFLAGS) $(INCLUDES) $< -o $@

$(BLD_DIR)/%.o: %.c
	$(CC) -c $(CFLAGS) $(INCLUDES) $< -o $@

$(BIN_DIR)/$(PROGRAM): $(DEPS) $(OBJS)
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ $(OBJS)

run: $(BIN_DIR)/$(PROGRAM)
	@./$(BIN_DIR)/$(PROGRAM)

fmt:
	@echo "C files:"
	@-clang-format -style="{BasedOnStyle: Google, IndentWidth: 4}" -verbose -i $(SRC_DIR)/*.c $(SRC_DIR)/*.h
	@echo "Shell files:"
	@shfmt -l -w -i 2 .

lint:
	@splint -retvalint -I $(SRC_DIR)/*.c $(SRC_DIR)/*.h

leak-check: $(BIN_DIR)/$(PROGRAM)
	@valgrind --vgdb=no --tool=memcheck --leak-check=yes ./$(BIN_DIR)/$(PROGRAM) $(input)

doc:
	@doxygen

test:
	@echo "Write some tests!"

checkdirs:
	@mkdir -p $(BLD_DIR)
	@mkdir -p $(BIN_DIR)
	@mkdir -p $(DOC_DIR)

all: checkdirs $(BIN_DIR)/$(PROGRAM)

clean:
	@echo "Cleaning..."
	@echo ""
	@-cat .art/maid.ascii
	@-rm -rd $(BLD_DIR)/* $(BIN_DIR)/* $(DOC_DIR)/* $(OUT_DIR)/*
	@echo ""
	@echo "...✓ done!"
