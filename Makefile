CC ?= clang
ASFLAGS ?= -x assembler-with-cpp
LDFLAGS ?=
OUTDIR := /tmp
SRCS = src/main.s src/parser.s src/vars.s src/codegen.s src/lexer.s src/utils.s src/data.s
OBJS = $(SRCS:.s=.o)

ifeq ($(OS),Windows_NT)
EXEEXT := .exe
else
EXEEXT :=
endif

SNC = snc$(EXEEXT)

.DEFAULT_GOAL := $(SNC)

$(SNC): $(OBJS)
	$(CC) $(OBJS) $(LDFLAGS) -o $(SNC)

src/%.o: src/%.s src/platform.inc
	$(CC) $(ASFLAGS) -c $< -o $@

clean:
	rm -f $(SNC) src/*.o

run: $(SNC)
	./$(SNC) examples/math.sn

example: $(SNC)
	./$(SNC) examples/math.sn > $(OUTDIR)/snc_example.s
	$(CC) $(OUTDIR)/snc_example.s -o $(OUTDIR)/snc_example$(EXEEXT)
	$(OUTDIR)/snc_example$(EXEEXT)

test: $(SNC)
	./$(SNC) examples/math.sn > $(OUTDIR)/snc_math.s
	$(CC) $(OUTDIR)/snc_math.s -o $(OUTDIR)/snc_math$(EXEEXT)
	$(OUTDIR)/snc_math$(EXEEXT)
	./$(SNC) examples/grouping.sn > $(OUTDIR)/snc_grouping.s
	$(CC) $(OUTDIR)/snc_grouping.s -o $(OUTDIR)/snc_grouping$(EXEEXT)
	$(OUTDIR)/snc_grouping$(EXEEXT)
	./$(SNC) examples/spec_slice.sn > $(OUTDIR)/snc_spec_slice.s
	$(CC) $(OUTDIR)/snc_spec_slice.s -o $(OUTDIR)/snc_spec_slice$(EXEEXT)
	$(OUTDIR)/snc_spec_slice$(EXEEXT)
	./$(SNC) examples/if_else.sn > $(OUTDIR)/snc_if_else.s
	$(CC) $(OUTDIR)/snc_if_else.s -o $(OUTDIR)/snc_if_else$(EXEEXT)
	$(OUTDIR)/snc_if_else$(EXEEXT)
	./$(SNC) examples/state_logic.sn > $(OUTDIR)/snc_state_logic.s
	$(CC) $(OUTDIR)/snc_state_logic.s -o $(OUTDIR)/snc_state_logic$(EXEEXT)
	$(OUTDIR)/snc_state_logic$(EXEEXT)
	./$(SNC) examples/strings.sn > $(OUTDIR)/snc_strings.s
	$(CC) $(OUTDIR)/snc_strings.s -o $(OUTDIR)/snc_strings$(EXEEXT)
	$(OUTDIR)/snc_strings$(EXEEXT)
	./$(SNC) examples/string_concat.sn > $(OUTDIR)/snc_string_concat.s
	$(CC) $(OUTDIR)/snc_string_concat.s -o $(OUTDIR)/snc_string_concat$(EXEEXT)
	$(OUTDIR)/snc_string_concat$(EXEEXT)
	./$(SNC) examples/else_if.sn > $(OUTDIR)/snc_else_if.s
	$(CC) $(OUTDIR)/snc_else_if.s -o $(OUTDIR)/snc_else_if$(EXEEXT)
	$(OUTDIR)/snc_else_if$(EXEEXT)
	./$(SNC) examples/while_loop.sn > $(OUTDIR)/snc_while_loop.s
	$(CC) $(OUTDIR)/snc_while_loop.s -o $(OUTDIR)/snc_while_loop$(EXEEXT)
	$(OUTDIR)/snc_while_loop$(EXEEXT)
	./$(SNC) examples/runtime_vars.sn > $(OUTDIR)/snc_runtime_vars.s
	$(CC) $(OUTDIR)/snc_runtime_vars.s -o $(OUTDIR)/snc_runtime_vars$(EXEEXT)
	$(OUTDIR)/snc_runtime_vars$(EXEEXT)
	./$(SNC) examples/runtime_exprs.sn > $(OUTDIR)/snc_runtime_exprs.s
	$(CC) $(OUTDIR)/snc_runtime_exprs.s -o $(OUTDIR)/snc_runtime_exprs$(EXEEXT)
	$(OUTDIR)/snc_runtime_exprs$(EXEEXT)
	./$(SNC) examples/runtime_var_math.sn > $(OUTDIR)/snc_runtime_var_math.s
	$(CC) $(OUTDIR)/snc_runtime_var_math.s -o $(OUTDIR)/snc_runtime_var_math$(EXEEXT)
	$(OUTDIR)/snc_runtime_var_math$(EXEEXT)
	./$(SNC) examples/runtime_target_math.sn > $(OUTDIR)/snc_runtime_target_math.s
	$(CC) $(OUTDIR)/snc_runtime_target_math.s -o $(OUTDIR)/snc_runtime_target_math$(EXEEXT)
	$(OUTDIR)/snc_runtime_target_math$(EXEEXT)
	./$(SNC) examples/spec_batch.sn > $(OUTDIR)/snc_spec_batch.s
	$(CC) $(OUTDIR)/snc_spec_batch.s -o $(OUTDIR)/snc_spec_batch$(EXEEXT)
	$(OUTDIR)/snc_spec_batch$(EXEEXT)
	./$(SNC) examples/for_loop.sn > $(OUTDIR)/snc_for_loop.s
	$(CC) $(OUTDIR)/snc_for_loop.s -o $(OUTDIR)/snc_for_loop$(EXEEXT)
	$(OUTDIR)/snc_for_loop$(EXEEXT)
	./$(SNC) examples/functions.sn > $(OUTDIR)/snc_functions.s
	$(CC) $(OUTDIR)/snc_functions.s -o $(OUTDIR)/snc_functions$(EXEEXT)
	$(OUTDIR)/snc_functions$(EXEEXT)
	./$(SNC) examples/multi_return.sn > $(OUTDIR)/snc_multi_return.s
	$(CC) $(OUTDIR)/snc_multi_return.s -o $(OUTDIR)/snc_multi_return$(EXEEXT)
	$(OUTDIR)/snc_multi_return$(EXEEXT)
	./$(SNC) examples/list_exprs.sn > $(OUTDIR)/snc_list_exprs.s
	$(CC) $(OUTDIR)/snc_list_exprs.s -o $(OUTDIR)/snc_list_exprs$(EXEEXT)
	$(OUTDIR)/snc_list_exprs$(EXEEXT)
	./$(SNC) examples/list_functions.sn > $(OUTDIR)/snc_list_functions.s
	$(CC) $(OUTDIR)/snc_list_functions.s -o $(OUTDIR)/snc_list_functions$(EXEEXT)
	$(OUTDIR)/snc_list_functions$(EXEEXT)
	./$(SNC) examples/nullable_basic.sn > $(OUTDIR)/snc_nullable_basic.s
	$(CC) $(OUTDIR)/snc_nullable_basic.s -o $(OUTDIR)/snc_nullable_basic$(EXEEXT)
	$(OUTDIR)/snc_nullable_basic$(EXEEXT)
	./$(SNC) examples/nullable_compare_none.sn > $(OUTDIR)/snc_nullable_compare_none.s
	$(CC) $(OUTDIR)/snc_nullable_compare_none.s -o $(OUTDIR)/snc_nullable_compare_none$(EXEEXT)
	$(OUTDIR)/snc_nullable_compare_none$(EXEEXT)
	./$(SNC) examples/nullable_list_direct.sn > $(OUTDIR)/snc_nullable_list_direct.s
	$(CC) $(OUTDIR)/snc_nullable_list_direct.s -o $(OUTDIR)/snc_nullable_list_direct$(EXEEXT)
	$(OUTDIR)/snc_nullable_list_direct$(EXEEXT)
	./$(SNC) examples/nullable_decimal.sn > $(OUTDIR)/snc_nullable_decimal.s
	$(CC) $(OUTDIR)/snc_nullable_decimal.s -o $(OUTDIR)/snc_nullable_decimal$(EXEEXT)
	$(OUTDIR)/snc_nullable_decimal$(EXEEXT)
	./$(SNC) examples/nullable_functions.sn > $(OUTDIR)/snc_nullable_functions.s
	$(CC) $(OUTDIR)/snc_nullable_functions.s -o $(OUTDIR)/snc_nullable_functions$(EXEEXT)
	$(OUTDIR)/snc_nullable_functions$(EXEEXT)
	./$(SNC) examples/default_params.sn > $(OUTDIR)/snc_default_params.s
	$(CC) $(OUTDIR)/snc_default_params.s -o $(OUTDIR)/snc_default_params$(EXEEXT)
	$(OUTDIR)/snc_default_params$(EXEEXT)
	./$(SNC) examples/batch2_verify.sn > $(OUTDIR)/snc_batch2_verify.s
	$(CC) $(OUTDIR)/snc_batch2_verify.s -o $(OUTDIR)/snc_batch2_verify$(EXEEXT)
	$(OUTDIR)/snc_batch2_verify$(EXEEXT)
	./$(SNC) examples/file_io.sn > $(OUTDIR)/snc_file_io.s
	$(CC) $(OUTDIR)/snc_file_io.s -o $(OUTDIR)/snc_file_io$(EXEEXT)
	$(OUTDIR)/snc_file_io$(EXEEXT)
	./$(SNC) examples/otherwise.sn > $(OUTDIR)/snc_otherwise.s
	$(CC) $(OUTDIR)/snc_otherwise.s -o $(OUTDIR)/snc_otherwise$(EXEEXT)
	$(OUTDIR)/snc_otherwise$(EXEEXT)
	./$(SNC) examples/decimals.sn > $(OUTDIR)/snc_decimals.s
	$(CC) $(OUTDIR)/snc_decimals.s -o $(OUTDIR)/snc_decimals$(EXEEXT)
	$(OUTDIR)/snc_decimals$(EXEEXT)
	./$(SNC) examples/decimals_fractional.sn > $(OUTDIR)/snc_decimals_fractional.s
	$(CC) $(OUTDIR)/snc_decimals_fractional.s -o $(OUTDIR)/snc_decimals_fractional$(EXEEXT)
	$(OUTDIR)/snc_decimals_fractional$(EXEEXT)
	./$(SNC) examples/decimals_invalid_type.sn >$(OUTDIR)/snc_dec_invalid_type.s 2>$(OUTDIR)/snc_dec_invalid_type.err; test $$? -ne 0
	./$(SNC) examples/decimals_invalid_literal.sn >$(OUTDIR)/snc_dec_invalid_literal.s 2>$(OUTDIR)/snc_dec_invalid_literal.err; test $$? -ne 0
	./$(SNC) examples/decimals_invalid_scale.sn >$(OUTDIR)/snc_dec_invalid_scale.s 2>$(OUTDIR)/snc_dec_invalid_scale.err; test $$? -ne 0
	./$(SNC) examples/decimals_invalid_mixed.sn >$(OUTDIR)/snc_dec_invalid_mixed.s 2>$(OUTDIR)/snc_dec_invalid_mixed.err; test $$? -ne 0
	./$(SNC) examples/decimals_invalid_mod.sn >$(OUTDIR)/snc_dec_invalid_mod.s 2>$(OUTDIR)/snc_dec_invalid_mod.err; test $$? -ne 0
	./$(SNC) examples/decimals_invalid_arg.sn >$(OUTDIR)/snc_dec_invalid_arg.s 2>$(OUTDIR)/snc_dec_invalid_arg.err; test $$? -ne 0
