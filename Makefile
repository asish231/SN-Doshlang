CC ?= clang
ASFLAGS ?= -x assembler-with-cpp
LDFLAGS ?=
TMPDIR ?= /tmp
SRCS = src/main.s src/parser.s src/vars.s src/codegen.s src/lexer.s src/utils.s src/data.s
OBJS = $(SRCS:.s=.o)

ifeq ($(OS),Windows_NT)
EXEEXT := .exe
else
EXEEXT :=
endif

SNC = snc$(EXEEXT)

$(TMPDIR):
	mkdir -p $(TMPDIR)

$(SNC): $(OBJS)
	$(CC) $(OBJS) $(LDFLAGS) -o $(SNC)

src/%.o: src/%.s src/platform.inc
	$(CC) $(ASFLAGS) -c $< -o $@

clean:
	rm -f $(SNC) src/*.o

run: $(SNC)
	./$(SNC) examples/math.sn

example: $(SNC)
	./$(SNC) examples/math.sn > $(TMPDIR)/snc_example.s
	$(CC) $(TMPDIR)/snc_example.s -o $(TMPDIR)/snc_example$(EXEEXT)
	$(TMPDIR)/snc_example$(EXEEXT)

test: $(SNC)
	./$(SNC) examples/math.sn > $(TMPDIR)/snc_math.s
	$(CC) $(TMPDIR)/snc_math.s -o $(TMPDIR)/snc_math$(EXEEXT)
	$(TMPDIR)/snc_math$(EXEEXT)
	./$(SNC) examples/grouping.sn > $(TMPDIR)/snc_grouping.s
	$(CC) $(TMPDIR)/snc_grouping.s -o $(TMPDIR)/snc_grouping$(EXEEXT)
	$(TMPDIR)/snc_grouping$(EXEEXT)
	./$(SNC) examples/spec_slice.sn > $(TMPDIR)/snc_spec_slice.s
	$(CC) $(TMPDIR)/snc_spec_slice.s -o $(TMPDIR)/snc_spec_slice$(EXEEXT)
	$(TMPDIR)/snc_spec_slice$(EXEEXT)
	./$(SNC) examples/if_else.sn > $(TMPDIR)/snc_if_else.s
	$(CC) $(TMPDIR)/snc_if_else.s -o $(TMPDIR)/snc_if_else$(EXEEXT)
	$(TMPDIR)/snc_if_else$(EXEEXT)
	./$(SNC) examples/state_logic.sn > $(TMPDIR)/snc_state_logic.s
	$(CC) $(TMPDIR)/snc_state_logic.s -o $(TMPDIR)/snc_state_logic$(EXEEXT)
	$(TMPDIR)/snc_state_logic$(EXEEXT)
	./$(SNC) examples/strings.sn > $(TMPDIR)/snc_strings.s
	$(CC) $(TMPDIR)/snc_strings.s -o $(TMPDIR)/snc_strings$(EXEEXT)
	$(TMPDIR)/snc_strings$(EXEEXT)
	./$(SNC) examples/string_concat.sn > $(TMPDIR)/snc_string_concat.s
	$(CC) $(TMPDIR)/snc_string_concat.s -o $(TMPDIR)/snc_string_concat$(EXEEXT)
	$(TMPDIR)/snc_string_concat$(EXEEXT)
	./$(SNC) examples/else_if.sn > $(TMPDIR)/snc_else_if.s
	$(CC) $(TMPDIR)/snc_else_if.s -o $(TMPDIR)/snc_else_if$(EXEEXT)
	$(TMPDIR)/snc_else_if$(EXEEXT)
	./$(SNC) examples/while_loop.sn > $(TMPDIR)/snc_while_loop.s
	$(CC) $(TMPDIR)/snc_while_loop.s -o $(TMPDIR)/snc_while_loop$(EXEEXT)
	$(TMPDIR)/snc_while_loop$(EXEEXT)
	./$(SNC) examples/runtime_vars.sn > $(TMPDIR)/snc_runtime_vars.s
	$(CC) $(TMPDIR)/snc_runtime_vars.s -o $(TMPDIR)/snc_runtime_vars$(EXEEXT)
	$(TMPDIR)/snc_runtime_vars$(EXEEXT)
	./$(SNC) examples/runtime_exprs.sn > $(TMPDIR)/snc_runtime_exprs.s
	$(CC) $(TMPDIR)/snc_runtime_exprs.s -o $(TMPDIR)/snc_runtime_exprs$(EXEEXT)
	$(TMPDIR)/snc_runtime_exprs$(EXEEXT)
	./$(SNC) examples/runtime_var_math.sn > $(TMPDIR)/snc_runtime_var_math.s
	$(CC) $(TMPDIR)/snc_runtime_var_math.s -o $(TMPDIR)/snc_runtime_var_math$(EXEEXT)
	$(TMPDIR)/snc_runtime_var_math$(EXEEXT)
	./$(SNC) examples/runtime_target_math.sn > $(TMPDIR)/snc_runtime_target_math.s
	$(CC) $(TMPDIR)/snc_runtime_target_math.s -o $(TMPDIR)/snc_runtime_target_math$(EXEEXT)
	$(TMPDIR)/snc_runtime_target_math$(EXEEXT)
	./$(SNC) examples/spec_batch.sn > $(TMPDIR)/snc_spec_batch.s
	$(CC) $(TMPDIR)/snc_spec_batch.s -o $(TMPDIR)/snc_spec_batch$(EXEEXT)
	$(TMPDIR)/snc_spec_batch$(EXEEXT)
	./$(SNC) examples/for_loop.sn > $(TMPDIR)/snc_for_loop.s
	$(CC) $(TMPDIR)/snc_for_loop.s -o $(TMPDIR)/snc_for_loop$(EXEEXT)
	$(TMPDIR)/snc_for_loop$(EXEEXT)
	./$(SNC) examples/functions.sn > $(TMPDIR)/snc_functions.s
	$(CC) $(TMPDIR)/snc_functions.s -o $(TMPDIR)/snc_functions$(EXEEXT)
	$(TMPDIR)/snc_functions$(EXEEXT)
	./$(SNC) examples/multi_return.sn > $(TMPDIR)/snc_multi_return.s
	$(CC) $(TMPDIR)/snc_multi_return.s -o $(TMPDIR)/snc_multi_return$(EXEEXT)
	$(TMPDIR)/snc_multi_return$(EXEEXT)
	./$(SNC) examples/list_exprs.sn > $(TMPDIR)/snc_list_exprs.s
	$(CC) $(TMPDIR)/snc_list_exprs.s -o $(TMPDIR)/snc_list_exprs$(EXEEXT)
	$(TMPDIR)/snc_list_exprs$(EXEEXT)
	./$(SNC) examples/list_functions.sn > $(TMPDIR)/snc_list_functions.s
	$(CC) $(TMPDIR)/snc_list_functions.s -o $(TMPDIR)/snc_list_functions$(EXEEXT)
	$(TMPDIR)/snc_list_functions$(EXEEXT)
	./$(SNC) examples/nullable_basic.sn > $(TMPDIR)/snc_nullable_basic.s
	$(CC) $(TMPDIR)/snc_nullable_basic.s -o $(TMPDIR)/snc_nullable_basic$(EXEEXT)
	$(TMPDIR)/snc_nullable_basic$(EXEEXT)
	./$(SNC) examples/nullable_compare_none.sn > $(TMPDIR)/snc_nullable_compare_none.s
	$(CC) $(TMPDIR)/snc_nullable_compare_none.s -o $(TMPDIR)/snc_nullable_compare_none$(EXEEXT)
	$(TMPDIR)/snc_nullable_compare_none$(EXEEXT)
	./$(SNC) examples/nullable_list_direct.sn > $(TMPDIR)/snc_nullable_list_direct.s
	$(CC) $(TMPDIR)/snc_nullable_list_direct.s -o $(TMPDIR)/snc_nullable_list_direct$(EXEEXT)
	$(TMPDIR)/snc_nullable_list_direct$(EXEEXT)
	./$(SNC) examples/nullable_decimal.sn > $(TMPDIR)/snc_nullable_decimal.s
	$(CC) $(TMPDIR)/snc_nullable_decimal.s -o $(TMPDIR)/snc_nullable_decimal$(EXEEXT)
	$(TMPDIR)/snc_nullable_decimal$(EXEEXT)
	./$(SNC) examples/nullable_functions.sn > $(TMPDIR)/snc_nullable_functions.s
	$(CC) $(TMPDIR)/snc_nullable_functions.s -o $(TMPDIR)/snc_nullable_functions$(EXEEXT)
	$(TMPDIR)/snc_nullable_functions$(EXEEXT)
	./$(SNC) examples/default_params.sn > $(TMPDIR)/snc_default_params.s
	$(CC) $(TMPDIR)/snc_default_params.s -o $(TMPDIR)/snc_default_params$(EXEEXT)
	$(TMPDIR)/snc_default_params$(EXEEXT)
	./$(SNC) examples/batch2_verify.sn > $(TMPDIR)/snc_batch2_verify.s
	$(CC) $(TMPDIR)/snc_batch2_verify.s -o $(TMPDIR)/snc_batch2_verify$(EXEEXT)
	$(TMPDIR)/snc_batch2_verify$(EXEEXT)
	./$(SNC) examples/file_io.sn > $(TMPDIR)/snc_file_io.s
	$(CC) $(TMPDIR)/snc_file_io.s -o $(TMPDIR)/snc_file_io$(EXEEXT)
	$(TMPDIR)/snc_file_io$(EXEEXT)
	./$(SNC) examples/otherwise.sn > $(TMPDIR)/snc_otherwise.s
	$(CC) $(TMPDIR)/snc_otherwise.s -o $(TMPDIR)/snc_otherwise$(EXEEXT)
	$(TMPDIR)/snc_otherwise$(EXEEXT)
	./$(SNC) examples/decimals.sn > $(TMPDIR)/snc_decimals.s
	$(CC) $(TMPDIR)/snc_decimals.s -o $(TMPDIR)/snc_decimals$(EXEEXT)
	$(TMPDIR)/snc_decimals$(EXEEXT)
	./$(SNC) examples/decimals_fractional.sn > $(TMPDIR)/snc_decimals_fractional.s
	$(CC) $(TMPDIR)/snc_decimals_fractional.s -o $(TMPDIR)/snc_decimals_fractional$(EXEEXT)
	$(TMPDIR)/snc_decimals_fractional$(EXEEXT)
	./$(SNC) examples/decimals_invalid_type.sn >$(TMPDIR)/snc_dec_invalid_type.s 2>$(TMPDIR)/snc_dec_invalid_type.err; test $$? -ne 0
	./$(SNC) examples/decimals_invalid_literal.sn >$(TMPDIR)/snc_dec_invalid_literal.s 2>$(TMPDIR)/snc_dec_invalid_literal.err; test $$? -ne 0
	./$(SNC) examples/decimals_invalid_scale.sn >$(TMPDIR)/snc_dec_invalid_scale.s 2>$(TMPDIR)/snc_dec_invalid_scale.err; test $$? -ne 0
	./$(SNC) examples/decimals_invalid_mixed.sn >$(TMPDIR)/snc_dec_invalid_mixed.s 2>$(TMPDIR)/snc_dec_invalid_mixed.err; test $$? -ne 0
	./$(SNC) examples/decimals_invalid_mod.sn >$(TMPDIR)/snc_dec_invalid_mod.s 2>$(TMPDIR)/snc_dec_invalid_mod.err; test $$? -ne 0
	./$(SNC) examples/decimals_invalid_arg.sn >$(TMPDIR)/snc_dec_invalid_arg.s 2>$(TMPDIR)/snc_dec_invalid_arg.err; test $$? -ne 0
