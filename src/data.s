#include "platform.inc"
.data
.global msg_usage
.global msg_version
.global version_flag
.global short_version_flag
.global msg_open_error
.global msg_read_error
.global msg_truncated
.global msg_on_line
.global msg_empty
.global msg_colon_space
.global msg_expected_stmt
.global msg_expected_name
.global msg_contract_not_found
.global msg_contract_method_missing
.global msg_module_load_error
.global msg_expected_expr
.global msg_expected_char
.global msg_unknown_stmt
.global msg_unknown_var
.global msg_duplicate_var
.global msg_loop_control
.global msg_divide_zero
.global msg_const_assign
.global msg_expected_type
.global msg_expected_list
.global msg_expected_map
.global msg_type_mismatch
.global msg_invalid_decimal
.global msg_decimal_scale
.global msg_unsupported_decimal
.global msg_too_many_vars
.global msg_too_many_prints
.global msg_too_many_ops
.global msg_spawn_ops
.global msg_spawn_nested
.global msg_spawn_params
.global msg_spawn_imported
.global msg_spawn_method
.global msg_too_many_fns
.global msg_too_many_params
.global msg_unknown_fn
.global msg_wrong_arg_count
.global msg_expected_arrow
.global msg_missing_return
.global msg_index_out_of_bounds
.global msg_key_not_found
.global kw_print
.global kw_print_noline
.global kw_printx
.global kw_let
.global kw_int
.global kw_bool
.global kw_const
.global kw_fn
.global kw_main
.global kw_if
.global kw_else
.global kw_while
.global kw_true
.global kw_false
.global kw_and
.global kw_or
.global kw_not
.global kw_str
.global kw_byte
.global kw_dec
.global kw_cast
.global kw_match
.global kw_default
.global kw_use
.global kw_only
.global kw_except
.global kw_list
.global kw_map
.global kw_length
.global kw_len
.global kw_add
.global kw_for
.global kw_stop
.global kw_skip
.global kw_in
.global kw_input
.global kw_return
.global kw_none
.global kw_otherwise
.global kw_file_read
.global kw_file_write
.global kw_system
.global kw_exec
.global kw_argc
.global kw_argv
.global kw_wait
.global kw_ord
.global kw_mem_live
.global kw_mem_bytes
.global kw_mem_collect
.global kw_builder_new
.global kw_builder_append
.global kw_builder_append_int
.global kw_builder_string
.global kw_builder_clear
.global kw_builder_length
.global kw_chan
.global kw_send
.global kw_receive
.global kw_close
.global kw_ref
.global kw_address
.global kw_value
.global kw_set
.global kw_alloc
.global kw_free
.global kw_push
.global kw_pop
.global kw_contains
.global kw_has
.global kw_keys
.global kw_values
.global kw_slice
.global kw_split
.global kw_blueprint
.global kw_new
.global kw_contract
.global kw_follows
.global kw_spawn
.global kw_open
.global kw_closed
.global kw_guarded
.global kw_from
.global kw_self
.global kw_create
.global kw_throw
.global kw_try
.global kw_catch
.global kw_error
.global kw_replace
.global kw_upper
.global kw_lower
.global kw_startswith
.global kw_endswith
.global kw_indexof
.global kw_trim
.global blueprint_count
.global blueprint_name_ptrs
.global blueprint_name_lens
.global blueprint_parent_ids
.global blueprint_field_counts
.global blueprint_field_names
.global blueprint_field_name_lens
.global blueprint_field_types
.global blueprint_field_metas
.global blueprint_field_default_flags
.global blueprint_field_default_values
.global blueprint_field_default_types
.global blueprint_field_default_metas
.global blueprint_method_counts
.global blueprint_method_names
.global blueprint_method_name_lens
.global blueprint_method_fn_ids
.global contract_count
.global contract_name_ptrs
.global contract_name_lens
.global contract_method_counts
.global contract_method_names
.global contract_method_name_lens
.global blueprint_contract_counts
.global blueprint_contract_ids
.global object_instance_count
.global object_blueprint_ids
.global object_field_var_idxs
.global blueprint_template_instances
.global inline_active
.global inline_result_slot
.global inline_end_label
.global inline_fn_stack
.global current_self_instance
.global current_self_type
.global current_self_meta
.global current_blueprint_parse
.global fn_name_override_ptr
.global fn_name_override_len
.global method_name_storage
.global hidden_var_name_storage
.global spawn_capture_fn_id
.global spawn_wait_used
.global channel_count
.global primary_module_name
.global primary_module_name_len
.global forced_call_fn_id_plus1
.global spawn_fn_op_counts
.global spawn_fn_op_kinds
.global spawn_fn_op_arg0
.global spawn_fn_op_arg1
.global spawn_fn_op_arg2
.global spawn_fn_op_arg3
.global spawn_fn_op_arg4
.global emit_tbl_kinds
.global emit_tbl_arg0
.global emit_tbl_arg1
.global emit_tbl_arg2
.global emit_tbl_arg3
.global emit_tbl_arg4
.global compilation_mode
.global asm_ret
.global asm_global_prefix
.global asm_prologue
.global asm_comment_prefix
.global msg_fn_body_stub
.global asm_bl_prefix
.global asm_header

.global asm_runtime_helpers
.global asm_memory_runtime
.global asm_call_mem_live
.global asm_call_mem_bytes
.global asm_call_mem_collect
.global asm_call_builder_new
.global asm_call_builder_append
.global asm_call_builder_append_int
.global asm_call_builder_string
.global asm_call_builder_clear
.global asm_call_builder_length
.global asm_sub_sp_prefix
.global asm_close_bracket
.global asm_mov_x10_x0
.global asm_load_x0_print_val_adrp
.global asm_load_x0_print_val_add
.global asm_load_x1_print_val_adrp
.global asm_load_x1_print_val_add
.global asm_load_x0_print_val_prefix
.global asm_load_x0_print_val_middle
.global asm_load_x0_print_val_suffix
.global asm_load_x1_print_val_prefix
.global asm_load_x1_print_val_middle
.global asm_load_x1_print_val_suffix
.global asm_load_x0_var
.global asm_load_x1_var
.global asm_store_x0_var
.global asm_ldur_reg_prefix
.global asm_stur_reg_prefix
.global asm_reg_frame_mid
.global asm_print_call_suffix_stack
.global asm_print_fmt_adrp
.global asm_print_val_adrp
.global asm_print_val_ldr
.global asm_print_str_val_adrp
.global asm_print_str_val_add
.global asm_print_call_suffix
.global asm_print_call_stack
.global asm_print_stack_only
.global asm_print_dec_call_stack
.global asm_main_epilogue
.global asm_dot_data_intro
.global asm_spawn_dispatch_head
.global asm_spawn_thr_glob
.global asm_spawn_thr_label_mid
.global asm_spawn_thr_enter
.global asm_spawn_thr_leave
.global asm_spawn_dispatch_cmp
.global asm_spawn_dispatch_beq
.global asm_spawn_dispatch_ret
.global asm_call_spawn_go
.global asm_call_spawn_wait
.global asm_spawn_wait_runtime
.global asm_channel_runtime
.global asm_call_chan_send
.global asm_call_chan_receive
.global asm_call_chan_close
.global asm_channel_init
#ifdef _WIN32
#else
.global asm_spawn_thread_runtime
#endif
.global asm_data_value_prefix
.global asm_data_value_mid
.global asm_data_value_mid_str
.global asm_data_value_suffix
.global asm_data_value_suffix_str
.global asm_align_3
.global asm_print_fmt_int_adrp
.global asm_print_fmt_int_noline_adrp
.global asm_print_fmt_str_adrp
.global asm_print_fmt_str_noline_adrp
.global asm_store_val_adrp
.global asm_store_val_ldr
.global asm_store_var_adrp
.global asm_store_var_str
.global asm_store_var_suffix
.global asm_print_var_adrp
.global asm_print_var_ldr
.global asm_print_fmt_dec_adrp
.global asm_dec_sign_empty_adrp
.global asm_dec_sign_minus_adrp
.global asm_mov_x3_imm_prefix
.global asm_mov_x12_imm_prefix
.global asm_mov_x14_imm_prefix
.global asm_dec_abs_x11_to_x13
.global asm_dec_select_sign_x1
.global asm_dec_split_x13_x14
.global asm_dec_mul_x11_x10_x12
.global asm_dec_div_x11_x10_x12
.global asm_math_var_x11_adrp
.global asm_math_var_x11_ldr
.global asm_math_var_x1_adrp
.global asm_math_var_x1_ldr
.global asm_math_var_x10_adrp
.global asm_math_var_x10_ldr
.global asm_math_store_x11_adrp
.global asm_math_store_x11_str
.global asm_input_store_x10_str
.global asm_input_store_x0_str
.global asm_load_list_pool_x11
.global asm_load_map_pool_x11
.global asm_add_x10_imm
.global asm_add_x10_x12
.global asm_load_pool_val_x10
.global asm_load_pool_len_x10
.global asm_store_pool_val_x12
.global asm_store_pool_len_x12
.global asm_mov_x12_x10
.global asm_mov_x10_x12
.global asm_mov_x0_imm
.global asm_mov_x1_imm
.global asm_mov_x4_imm
.global asm_call_map_lookup
.global asm_call_string_slice
.global asm_call_str_contains
.global asm_call_str_replace
.global asm_call_str_split
.global asm_call_str_upper
.global asm_call_str_lower
.global asm_call_str_char_at
.global asm_call_str_startswith
.global asm_call_str_endswith
.global asm_call_str_indexof
.global asm_call_str_trim
.global asm_string_slice_runtime
.global asm_string_methods_runtime
.global asm_string_char_at_runtime
.global asm_string_replace_runtime
.global asm_string_split_runtime
.global asm_string_scan_runtime
.global asm_string_trim_runtime
.global asm_file_write_fixed_runtime
.global asm_call_snl_file_write
.global asm_map_dynamic_runtime
.global asm_load_x2_var
.global asm_mov_x2_imm
.global asm_mov_x4_x10
.global asm_call_cstring_length
.global asm_ord_first_byte
.global asm_mov_x4_x0
.global asm_mov_x0_x10
.global asm_mov_x0_x1
.global asm_mov_x0_x4
.global asm_mov_x2_x10
.global asm_mov_x11_x2
.global asm_mov_x3_imm
.global asm_mov_x10_imm
.global asm_mov_x3_x0
.global asm_mov_x5_imm
.global asm_mov_x6_imm
.global asm_mov_x6_x0
.global asm_load_x4_var
.global asm_load_x4_print_val_prefix
.global asm_load_x4_print_val_middle
.global asm_load_x4_print_val_suffix
.global asm_call_map_store
.global asm_load_pool_val_x10_from_x12
.global asm_load_list_pool_lens_x11
.global asm_load_map_pool_lens_x11
.global asm_call_cstr_to_int
.global asm_newline
.global asm_math_add_x11_x10
.global asm_list_pool_values_label
.global asm_list_pool_lengths_label
.global asm_map_pool_keys_label
.global asm_map_pool_key_lengths_label
.global asm_map_pool_values_label
.global asm_map_pool_lengths_label
.global asm_map_key_prefix
.global asm_map_key_suffix
.global asm_quad_prefix
.global asm_math_sub_x11_x10
.global asm_math_mul_x11_x10
.global asm_math_div_x11_x10
.global asm_math_mod_x11_x10
.global asm_logic_and_x11_x10
.global asm_logic_or_x11_x10
.global asm_logic_not_x11
.global asm_math_add_x1_x10
.global asm_math_sub_x1_x10
.global asm_math_mul_x1_x10
.global asm_math_div_x1_x10
.global asm_math_mod_x1_x10
.global asm_var_slot_prefix
.global asm_store_data_prefix
.global asm_label_prefix
.global asm_label_suffix
.global asm_pageoff_suffix
.global asm_branch
.global asm_branch_zero
.global asm_branch_nonzero
.global asm_cmp_x11_x10
.global asm_cset_gt
.global asm_cset_lt
.global asm_cset_ge
.global asm_cset_le
.global asm_cset_eq
.global asm_cset_ne
.global asm_load_x11_var
.global asm_load_x10_var
.global asm_store_x11_var
.global asm_add_x11_imm
.global asm_sub_x11_imm
.global asm_call_write
.global asm_call_str_concat
.global asm_call_int_to_cstr
.global asm_call_file_read
.global asm_call_file_write
.global asm_call_system
.global asm_load_argc
.global asm_load_argv_index
.global asm_call_read
.global asm_input_prompt_prefix
.global asm_input_buffer_prefix
.global asm_input_prompt_adr
.global asm_input_prompt_pageoff
.global asm_input_buffer_adr
.global asm_input_buffer_pageoff
.global asm_input_write_fd
.global asm_input_read_fd
.global asm_input_len_prefix
.global asm_input_read_size
.global asm_input_strip_prefix
.global asm_input_strip_pageoff
.global asm_input_b_le_store
.global asm_input_b_ne_null
.global asm_input_b_store
.global asm_input_null_label_prefix
.global asm_input_store_label_prefix
.global asm_input_null_body
.global asm_input_store_x10_str
.global asm_input_buffer_space
.global asm_adrp_error_flag
.global asm_ldr_x11_error_flag
.global asm_str_x1_error_flag
.global asm_str_xzr_error_flag
.global asm_adrp_error_value
.global asm_str_x0_error_value
.global asm_cmp_x11_imm_0
.global asm_beq_label
.global asm_b_suffix
.global asm_mov_x1_imm_1
.global asm_exit_1
.global asm_error_flag_label
.global asm_error_value_label
.global asm_quad_0
.global error_flag
.global error_value
.global newline_char
.global zero_qword
.global single_char
.global close_brace_char
.global label_counter
.global current_label_id
.global current_loop_start
.global current_loop_end
.global loop_context_depth
.global current_catch_label
.global buffer
.global number_buffer
.global source_ptr
.global source_len
.global cursor_pos
.global current_line
.global var_count
.global print_count
.global print_noline_flag
.global op_count
.global var_name_ptrs
.global var_name_lens
.global var_values
.global var_lengths
.global var_const_flags
.global var_types
.global list_pool_count
.global list_pool_values
.global list_pool_lengths
.global list_base_counts
.global list_base_is_runtime
.global asm_list_base_counts_label
.global asm_load_list_base_counts_x11
.global map_pool_count
.global map_pool_keys
.global map_pool_key_lengths
.global map_pool_key_ptrs
.global map_pool_values
.global map_pool_lengths
.global slice_tmp_source_val
.global slice_tmp_source_len
.global slice_tmp_source_var
.global slice_tmp_start_val
.global slice_tmp_start_var
.global slice_tmp_end_val
.global slice_tmp_end_var
.global str_contains_tmp_substr_val
.global str_contains_tmp_substr_var
.global str_method_src_var
.global str_method_sub_len
.global member_src_val
.global member_src_len
.global member_src_var
.global str_replace_tmp_old_val
.global str_replace_tmp_old_var
.global str_replace_tmp_new_val
.global str_replace_tmp_new_var
.global str_split_tmp_sep_val
.global str_split_tmp_sep_var
.global module_count
.global module_names
.global module_paths
.global module_function_names
.global module_function_counts
.global module_search_paths
.global module_search_count
.global default_search_path_current
.global default_search_path_stdlib
.global module_file_path_buf
.global imported_function_names
.global imported_function_modules
.global imported_function_count
.global print_values
.global print_lengths
.global print_types
.global print_noline
.global print_capacity
.global op_kinds
.global op_arg0
.global op_arg1
.global op_arg2
.global op_arg3
.global op_arg4
.global op_capacity
.global var_capacity
.global fn_capacity
.global list_pool_capacity
.global map_pool_capacity
.global asm_mov_x2_imm
.global fn_count
.global fn_name_ptrs
.global fn_name_lens
.global fn_body_cursors
.global fn_body_lines
.global fn_source_ptrs
.global fn_source_lens
.global fn_param_counts
.global fn_param_types
.global fn_param_lengths
.global fn_param_name_ptrs
.global fn_param_name_lens
.global fn_param_default_flags
.global fn_param_default_values
.global fn_param_default_types
.global fn_param_default_lengths
.global fn_return_types
.global fn_return_decl_lengths
.global fn_return_extra_types
.global fn_return_extra_decl_lengths
.global fn_return_value
.global fn_return_length
.global fn_return_flag
.global fn_return_extra
.global fn_return_extra_type
.global fn_exec_depth
.global fn_op_starts
.global fn_op_counts
.global fn_scope_bases
.global fn_frame_sizes
.global fn_module_ids
.global fn_import_visible
.global cur_scope_base
.global last_call_result_slot
.global var_scope_base
.global max_var_count
.global saved_var_count
.global msg_debug_fn

msg_usage:         .asciz "usage: ./snc <source.sn>\n"
msg_version:       .asciz "SNlang compiler v0.2.1\n"
version_flag:      .asciz "--version"
short_version_flag: .asciz "-v"
msg_open_error:    .asciz "error: could not open "
msg_read_error:    .asciz "error: failed to read source input\n"
msg_truncated:     .asciz "warning: source truncated to 65535 bytes\n"
msg_on_line:       .asciz "line "
msg_empty:         .byte 0
msg_colon_space:   .asciz ": "
msg_expected_stmt: .asciz "error: expected statement on "
msg_expected_name: .asciz "error: expected variable name on "
msg_contract_not_found: .asciz "error: unknown contract in follows on "
msg_contract_method_missing: .asciz "error: blueprint does not implement required contract method on "
msg_module_load_error: .asciz "error: failed to load module on "
default_search_path_current: .asciz "."
default_search_path_stdlib: .asciz "stdlib"
msg_expected_expr: .asciz "error: expected expression on "
msg_expected_char: .asciz "error: expected character on "
msg_unknown_stmt:  .asciz "error: unknown statement on "
msg_unknown_var:   .asciz "error: unknown variable on "
msg_duplicate_var: .asciz "error: duplicate variable on "
msg_loop_control:  .asciz "error: loop control outside loop on "
msg_divide_zero:   .asciz "error: division by zero on "
msg_const_assign:  .asciz "error: cannot assign to const on "
msg_expected_type: .asciz "error: expected type on "
msg_expected_list: .asciz "error: expected list on "
msg_expected_map:  .asciz "error: expected map on "
msg_type_mismatch: .asciz "error: type mismatch on "
msg_invalid_decimal: .asciz "error: invalid decimal literal on "
msg_decimal_scale: .asciz "error: decimal scale mismatch on "
msg_unsupported_decimal: .asciz "error: unsupported decimal operation on "
msg_too_many_vars: .asciz "error: too many variables\n"
msg_too_many_prints: .asciz "error: too many print statements\n"
msg_too_many_ops:  .asciz "error: too many operations\n"
msg_spawn_ops:     .asciz "error: spawned function body too large (max 256 ops)\n"
msg_spawn_nested:  .asciz "error: nested spawn is not supported on "
msg_spawn_params:  .asciz "error: spawn requires a zero-argument function on "
msg_spawn_imported: .asciz "error: cannot spawn imported functions on "
msg_spawn_method:   .asciz "error: spawn of a method is not yet supported (only spawn fn()) on "
msg_too_many_fns:  .asciz "error: too many functions\n"
msg_too_many_params: .asciz "error: too many parameters on "
msg_unknown_fn:    .asciz "error: unknown function on "
msg_wrong_arg_count: .asciz "error: wrong number of arguments on "
msg_expected_arrow: .asciz "error: expected -> on "
msg_missing_return: .asciz "error: missing return in typed function on "
msg_index_out_of_bounds: .asciz "error: list index out of bounds on "
msg_key_not_found: .asciz "error: map key not found on "
kw_print:          .asciz "print"
kw_print_noline:   .asciz "printn"
kw_printx:        .asciz "printx"
kw_let:            .asciz "let"
kw_int:            .asciz "int"
kw_bool:           .asciz "bool"
kw_const:          .asciz "const"
kw_fn:             .asciz "fn"
kw_main:           .asciz "main"
kw_if:             .asciz "if"
kw_else:           .asciz "else"
kw_while:          .asciz "while"
kw_true:           .asciz "true"
kw_false:          .asciz "false"
kw_and:            .asciz "and"
kw_or:             .asciz "or"
kw_not:            .asciz "not"
kw_str:            .asciz "str"
kw_byte:           .asciz "byte"
kw_dec:            .asciz "dec"
kw_cast:           .asciz "cast"
kw_match:          .asciz "match"
kw_default:        .asciz "default"
kw_use:            .asciz "use"
kw_only:           .asciz "only"
kw_except:         .asciz "except"
kw_list:           .asciz "list"
kw_map:            .asciz "map"
kw_length:         .asciz "length"
kw_len:            .asciz "len"
kw_add:            .asciz "add"
kw_for:            .asciz "for"
kw_stop:           .asciz "stop"
kw_skip:           .asciz "skip"
kw_in:             .asciz "in"
kw_input:          .asciz "input"
kw_return:         .asciz "return"
kw_none:           .asciz "none"
kw_otherwise:      .asciz "otherwise"
kw_file_read:      .asciz "file_read"
kw_file_write:     .asciz "file_write"
kw_system:         .asciz "system"
kw_exec:           .asciz "exec"
kw_argc:           .asciz "argc"
kw_argv:           .asciz "argv"
kw_wait:           .asciz "wait"
kw_ord:            .asciz "ord"
kw_mem_live:       .asciz "mem_live"
kw_mem_bytes:      .asciz "mem_bytes"
kw_mem_collect:    .asciz "mem_collect"
kw_builder_new:    .asciz "builder_new"
kw_builder_append: .asciz "builder_append"
kw_builder_append_int: .asciz "builder_append_int"
kw_builder_string: .asciz "builder_string"
kw_builder_clear:  .asciz "builder_clear"
kw_builder_length: .asciz "builder_length"
kw_chan:           .asciz "chan"
kw_send:           .asciz "send"
kw_receive:        .asciz "receive"
kw_close:          .asciz "close"
kw_ref:            .asciz "ref"
kw_address:        .asciz "address"
kw_value:          .asciz "value"
kw_set:            .asciz "set"
kw_alloc:          .asciz "alloc"
kw_free:           .asciz "free"
kw_push:           .asciz "push"
kw_pop:            .asciz "pop"
kw_contains:      .asciz "contains"
kw_has:            .asciz "has"
kw_keys:          .asciz "keys"
kw_values:        .asciz "values"
kw_slice:         .asciz "slice"
kw_split:         .asciz "split"
kw_blueprint:     .asciz "blueprint"
kw_new:           .asciz "new"
kw_contract:      .asciz "contract"
kw_follows:       .asciz "follows"
kw_spawn:         .asciz "spawn"
kw_open:          .asciz "open"
kw_closed:        .asciz "closed"
kw_guarded:       .asciz "guarded"
kw_from:          .asciz "from"
kw_self:          .asciz "self"
kw_create:        .asciz "create"
kw_throw:         .asciz "throw"
kw_try:           .asciz "try"
kw_catch:         .asciz "catch"
kw_error:         .asciz "error"
kw_replace:       .asciz "replace"
kw_upper:         .asciz "upper"
kw_lower:         .asciz "lower"
kw_startswith:    .asciz "startswith"
kw_endswith:      .asciz "endswith"
kw_indexof:       .asciz "indexof"
kw_trim:          .asciz "trim"
asm_sub_sp_prefix:
    .asciz "    sub sp, sp, #"
// Register-form frame allocation (see _emit_stack_alloc). `sub sp, sp, #imm`
// only encodes 0..4095 (or a <<12 multiple), so a big frame from many locals
// emitted an unassemblable `sub sp, sp, #16000`. Materialising the size in x16
// (a call-clobbered scratch reg) first works for any size up to 65535.
.global asm_mov_x16_prefix
asm_mov_x16_prefix:
    .asciz "    mov x16, #"
.global asm_sp_sub_x16
asm_sp_sub_x16:
    .asciz "\n    sub sp, sp, x16\n"
// Large stack-slot addressing. `sub x28, x29, #imm` only encodes 0..4095, so a
// slot past ~512 (offset > 4095) failed to assemble. Materialise the offset in
// x28 first, then subtract as a register — works for any offset up to 65535.
.global asm_x28_offset_prefix
asm_x28_offset_prefix:
    .asciz "    mov x28, #"
.global asm_x28_sub_suffix
asm_x28_sub_suffix:
    .asciz "\n    sub x28, x29, x28\n"
// movz/movk materialization for frame sizes / slot offsets that exceed 65535.
// `mov xN, #imm` (and the movz it becomes) only encodes a 16-bit immediate, so
// a frame or slot offset >= 65536 -- now reachable because the variable table
// grows past the old 4096-var cap -- emitted an unassemblable `mov x16, #80032`.
// A movz(low16) + movk(high16, lsl #16) pair materializes any value up to 2^32.
.global asm_movz_x16
asm_movz_x16:
    .asciz "    movz x16, #"
.global asm_movk_x16
asm_movk_x16:
    .asciz "\n    movk x16, #"
.global asm_movz_x28
asm_movz_x28:
    .asciz "    movz x28, #"
.global asm_movk_x28
asm_movk_x28:
    .asciz "\n    movk x28, #"
.global asm_lsl16
asm_lsl16:
    .asciz ", lsl #16"
asm_header:
#ifdef _WIN32
    .asciz ".global main\n.align 4\n.extern printf\n.extern read\n.extern write\n.extern malloc\n.extern free\n.extern open\n.extern close\n.extern lseek\n.extern str_concat\n.extern int_to_cstr\n.extern file_read\n.extern file_write\n\n.data\n.align 3\nsnc_argc: .quad 0\nsnc_argv: .quad 0\n\n.text\nmain:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    adrp x9, snc_argc\n    add x9, x9, :lo12:snc_argc\n    str x0, [x9]\n    adrp x9, snc_argv\n    add x9, x9, :lo12:snc_argv\n    str x1, [x9]\n"
#else
    .asciz ".global _main\n.align 4\n.extern _printf\n.extern _read\n.extern _write\n.extern _malloc\n.extern _free\n.extern _open\n.extern _close\n.extern _lseek\n.extern _str_concat\n.extern _int_to_cstr\n.extern _file_read\n.extern _file_write\n.extern _pthread_create\n.extern _pthread_join\n\n.data\n.align 3\n_snc_argc: .quad 0\n_snc_argv: .quad 0\n\n.text\n_main:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    adrp x9, _snc_argc@PAGE\n    add x9, x9, _snc_argc@PAGEOFF\n    str x0, [x9]\n    adrp x9, _snc_argv@PAGE\n    add x9, x9, _snc_argv@PAGEOFF\n    str x1, [x9]\n"
#endif

// Managed runtime heap used by values created by SNlang's string/file helpers
// and by StringBuilder. Each allocation has a private 32-byte header linked
// into a process-wide list. The tiny exclusive-load lock makes registration,
// individual release, counters, and bulk collection safe across spawn workers.
// Raw alloc()/free() intentionally keep calling libc directly and are not in
// this list. mem_collect() is an explicit arena reset; _main also calls it at
// shutdown after outstanding workers have been joined.
asm_memory_runtime:
#ifdef _WIN32
    .ascii "\n.text\n.align 4\n.global snc_mem_lock_acquire\nsnc_mem_lock_acquire:\n    adrp x9, snc_mem_lock\n    add x9, x9, :lo12:snc_mem_lock\nL_snc_mem_lock_retry:\n    ldaxr x10, [x9]\n    cbnz x10, L_snc_mem_lock_retry\n    mov x10, #1\n    stlxr w11, x10, [x9]\n    cbnz w11, L_snc_mem_lock_retry\n    ret\n.global snc_mem_lock_release\nsnc_mem_lock_release:\n    adrp x9, snc_mem_lock\n    add x9, x9, :lo12:snc_mem_lock\n    stlr xzr, [x9]\n    ret\n"
    .ascii ".global snc_managed_alloc\nsnc_managed_alloc:\n    stp x29, x30, [sp, #-48]!\n    mov x29, sp\n    stp x19, x20, [sp, #16]\n    str x21, [sp, #32]\n    mov x19, x0\n    cbnz x19, L_snc_ma_size_ok\n    mov x19, #1\nL_snc_ma_size_ok:\n    adds x0, x19, #32\n    b.cs L_snc_ma_fail\n    bl malloc\n    cbz x0, L_snc_ma_fail\n    mov x20, x0\n    str x19, [x20, #8]\n    bl snc_mem_lock_acquire\n    adrp x9, snc_mem_head\n    add x9, x9, :lo12:snc_mem_head\n    ldr x10, [x9]\n    str x10, [x20]\n    str x20, [x9]\n    adrp x9, snc_mem_live_count\n    add x9, x9, :lo12:snc_mem_live_count\n    ldr x10, [x9]\n    add x10, x10, #1\n    str x10, [x9]\n    adrp x9, snc_mem_byte_count\n    add x9, x9, :lo12:snc_mem_byte_count\n    ldr x10, [x9]\n    add x10, x10, x19\n    str x10, [x9]\n    bl snc_mem_lock_release\n    add x0, x20, #32\n    b L_snc_ma_done\nL_snc_ma_fail:\n    mov x0, #0\nL_snc_ma_done:\n    ldr x21, [sp, #32]\n    ldp x19, x20, [sp, #16]\n    ldp x29, x30, [sp], #48\n    ret\n"
    .ascii ".global snc_managed_free\nsnc_managed_free:\n    stp x29, x30, [sp, #-64]!\n    mov x29, sp\n    stp x19, x20, [sp, #16]\n    stp x21, x22, [sp, #32]\n    str x23, [sp, #48]\n    mov x19, x0\n    cbz x19, L_snc_mf_not_found\n    bl snc_mem_lock_acquire\n    adrp x9, snc_mem_head\n    add x9, x9, :lo12:snc_mem_head\n    ldr x20, [x9]\n    mov x21, #0\nL_snc_mf_scan:\n    cbz x20, L_snc_mf_unlock_not_found\n    add x22, x20, #32\n    cmp x19, x22\n    b.lo L_snc_mf_next\n    ldr x11, [x20, #8]\n    add x12, x22, x11\n    cmp x19, x12\n    b.lo L_snc_mf_found\nL_snc_mf_next:\n    mov x21, x20\n    ldr x20, [x20]\n    b L_snc_mf_scan\nL_snc_mf_found:\n    ldr x23, [x20]\n    cbz x21, L_snc_mf_set_head\n    str x23, [x21]\n    b L_snc_mf_unlinked\nL_snc_mf_set_head:\n    str x23, [x9]\nL_snc_mf_unlinked:\n    adrp x9, snc_mem_live_count\n    add x9, x9, :lo12:snc_mem_live_count\n    ldr x10, [x9]\n    sub x10, x10, #1\n    str x10, [x9]\n    ldr x11, [x20, #8]\n    adrp x9, snc_mem_byte_count\n    add x9, x9, :lo12:snc_mem_byte_count\n    ldr x10, [x9]\n    sub x10, x10, x11\n    str x10, [x9]\n    bl snc_mem_lock_release\n    mov x0, x20\n    bl free\n    mov x0, #1\n    b L_snc_mf_done\nL_snc_mf_unlock_not_found:\n    bl snc_mem_lock_release\nL_snc_mf_not_found:\n    mov x0, #0\nL_snc_mf_done:\n    ldr x23, [sp, #48]\n    ldp x21, x22, [sp, #32]\n    ldp x19, x20, [sp, #16]\n    ldp x29, x30, [sp], #64\n    ret\n"
    .ascii ".global snc_managed_size\nsnc_managed_size:\n    stp x29, x30, [sp, #-48]!\n    mov x29, sp\n    stp x19, x20, [sp, #16]\n    str x21, [sp, #32]\n    mov x19, x0\n    bl snc_mem_lock_acquire\n    adrp x9, snc_mem_head\n    add x9, x9, :lo12:snc_mem_head\n    ldr x20, [x9]\nL_snc_ms_scan:\n    cbz x20, L_snc_ms_not_found\n    add x21, x20, #32\n    cmp x21, x19\n    b.eq L_snc_ms_found\n    ldr x20, [x20]\n    b L_snc_ms_scan\nL_snc_ms_found:\n    ldr x19, [x20, #8]\n    b L_snc_ms_unlock\nL_snc_ms_not_found:\n    mov x19, #0\nL_snc_ms_unlock:\n    bl snc_mem_lock_release\n    mov x0, x19\n    ldr x21, [sp, #32]\n    ldp x19, x20, [sp, #16]\n    ldp x29, x30, [sp], #48\n    ret\n.global snc_mem_live\nsnc_mem_live:\n    adrp x9, snc_mem_live_count\n    add x9, x9, :lo12:snc_mem_live_count\n    ldr x0, [x9]\n    ret\n.global snc_mem_bytes\nsnc_mem_bytes:\n    adrp x9, snc_mem_byte_count\n    add x9, x9, :lo12:snc_mem_byte_count\n    ldr x0, [x9]\n    ret\n.global snc_memory_cleanup\nsnc_memory_cleanup:\n    stp x29, x30, [sp, #-48]!\n    mov x29, sp\n    stp x19, x20, [sp, #16]\n    str x21, [sp, #32]\n    bl snc_mem_lock_acquire\n    adrp x9, snc_mem_head\n    add x9, x9, :lo12:snc_mem_head\n    ldr x19, [x9]\n    str xzr, [x9]\n    adrp x9, snc_mem_live_count\n    add x9, x9, :lo12:snc_mem_live_count\n    ldr x20, [x9]\n    str xzr, [x9]\n    adrp x9, snc_mem_byte_count\n    add x9, x9, :lo12:snc_mem_byte_count\n    str xzr, [x9]\n    bl snc_mem_lock_release\nL_snc_mc_free_loop:\n    cbz x19, L_snc_mc_done\n    ldr x21, [x19]\n    mov x0, x19\n    bl free\n    mov x19, x21\n    b L_snc_mc_free_loop\nL_snc_mc_done:\n    mov x0, x20\n    ldr x21, [sp, #32]\n    ldp x19, x20, [sp, #16]\n    ldp x29, x30, [sp], #48\n    ret\n"
    .ascii ".global snc_builder_new\nsnc_builder_new:\n    stp x29, x30, [sp, #-32]!\n    mov x29, sp\n    str x19, [sp, #16]\n    mov x0, #32\n    bl snc_managed_alloc\n    cbz x0, L_snc_bn_fail\n    mov x19, x0\n    mov x0, #64\n    bl snc_managed_alloc\n    cbz x0, L_snc_bn_free_obj\n    str x0, [x19]\n    str xzr, [x19, #8]\n    mov x9, #64\n    str x9, [x19, #16]\n    mov x9, #21314\n    str x9, [x19, #24]\n    strb wzr, [x0]\n    mov x0, x19\n    b L_snc_bn_done\nL_snc_bn_free_obj:\n    mov x0, x19\n    bl snc_managed_free\nL_snc_bn_fail:\n    mov x0, #0\nL_snc_bn_done:\n    ldr x19, [sp, #16]\n    ldp x29, x30, [sp], #32\n    ret\n"
    .ascii ".global snc_builder_append\nsnc_builder_append:\n    stp x29, x30, [sp, #-96]!\n    mov x29, sp\n    stp x19, x20, [sp, #16]\n    stp x21, x22, [sp, #32]\n    stp x23, x24, [sp, #48]\n    stp x25, x26, [sp, #64]\n    stp x27, x28, [sp, #80]\n    mov x19, x0\n    mov x20, x1\n    cbz x19, L_snc_ba_fail\n    mov x0, x19\n    bl snc_managed_size\n    cmp x0, #32\n    b.ne L_snc_ba_fail\n    ldr x9, [x19, #24]\n    mov x10, #21314\n    cmp x9, x10\n    b.ne L_snc_ba_fail\n    cbz x20, L_snc_ba_fail\n    mov x0, x20\n    bl cstring_length\n    mov x21, x0\n    ldr x22, [x19, #8]\n    ldr x23, [x19, #16]\n    ldr x25, [x19]\n    adds x24, x22, x21\n    b.cs L_snc_ba_fail\n    adds x24, x24, #1\n    b.cs L_snc_ba_fail\n    cmp x24, x23\n    b.le L_snc_ba_copy_new\n    mov x26, x23\nL_snc_ba_grow_cap:\n    lsl x27, x26, #1\n    cmp x27, x26\n    b.ls L_snc_ba_fail\n    mov x26, x27\n    cmp x26, x24\n    b.lt L_snc_ba_grow_cap\n    mov x0, x26\n    bl snc_managed_alloc\n    cbz x0, L_snc_ba_fail\n    mov x27, x0\n    mov x28, #0\nL_snc_ba_copy_old:\n    cmp x28, x22\n    b.ge L_snc_ba_old_done\n    ldrb w9, [x25, x28]\n    strb w9, [x27, x28]\n    add x28, x28, #1\n    b L_snc_ba_copy_old\nL_snc_ba_old_done:\n    mov x0, x25\n    bl snc_managed_free\n    mov x25, x27\n    str x25, [x19]\n    str x26, [x19, #16]\nL_snc_ba_copy_new:\n    mov x28, #0\nL_snc_ba_copy_new_loop:\n    cmp x28, x21\n    b.ge L_snc_ba_copy_done\n    ldrb w9, [x20, x28]\n    add x10, x22, x28\n    strb w9, [x25, x10]\n    add x28, x28, #1\n    b L_snc_ba_copy_new_loop\nL_snc_ba_copy_done:\n    add x22, x22, x21\n    str x22, [x19, #8]\n    strb wzr, [x25, x22]\n    mov x0, #1\n    b L_snc_ba_done\nL_snc_ba_fail:\n    mov x0, #0\nL_snc_ba_done:\n    ldp x27, x28, [sp, #80]\n    ldp x25, x26, [sp, #64]\n    ldp x23, x24, [sp, #48]\n    ldp x21, x22, [sp, #32]\n    ldp x19, x20, [sp, #16]\n    ldp x29, x30, [sp], #96\n    ret\n"
    .ascii ".global snc_builder_append_int\nsnc_builder_append_int:\n    stp x29, x30, [sp, #-48]!\n    mov x29, sp\n    stp x19, x20, [sp, #16]\n    str x21, [sp, #32]\n    mov x19, x0\n    mov x0, x1\n    bl int_to_cstr\n    cbz x0, L_snc_bai_fail\n    mov x20, x0\n    mov x1, x20\n    mov x0, x19\n    bl snc_builder_append\n    mov x21, x0\n    mov x0, x20\n    bl snc_managed_free\n    mov x0, x21\n    b L_snc_bai_done\nL_snc_bai_fail:\n    mov x0, #0\nL_snc_bai_done:\n    ldr x21, [sp, #32]\n    ldp x19, x20, [sp, #16]\n    ldp x29, x30, [sp], #48\n    ret\n"
    .ascii ".global snc_builder_string\nsnc_builder_string:\n    stp x29, x30, [sp, #-64]!\n    mov x29, sp\n    stp x19, x20, [sp, #16]\n    stp x21, x22, [sp, #32]\n    str x23, [sp, #48]\n    mov x19, x0\n    cbz x19, L_snc_bs_fail\n    mov x0, x19\n    bl snc_managed_size\n    cmp x0, #32\n    b.ne L_snc_bs_fail\n    ldr x9, [x19, #24]\n    mov x10, #21314\n    cmp x9, x10\n    b.ne L_snc_bs_fail\n    ldr x20, [x19]\n    ldr x21, [x19, #8]\n    add x0, x21, #1\n    bl snc_managed_alloc\n    cbz x0, L_snc_bs_fail\n    mov x22, x0\n    mov x23, #0\nL_snc_bs_copy:\n    cmp x23, x21\n    b.gt L_snc_bs_done_copy\n    ldrb w9, [x20, x23]\n    strb w9, [x22, x23]\n    add x23, x23, #1\n    b L_snc_bs_copy\nL_snc_bs_done_copy:\n    mov x0, x22\n    b L_snc_bs_done\nL_snc_bs_fail:\n    mov x0, #0\nL_snc_bs_done:\n    ldr x23, [sp, #48]\n    ldp x21, x22, [sp, #32]\n    ldp x19, x20, [sp, #16]\n    ldp x29, x30, [sp], #64\n    ret\n"
    .ascii ".global snc_builder_clear\nsnc_builder_clear:\n    stp x29, x30, [sp, #-32]!\n    mov x29, sp\n    str x19, [sp, #16]\n    mov x19, x0\n    cbz x19, L_snc_bc_fail\n    bl snc_managed_size\n    cmp x0, #32\n    b.ne L_snc_bc_fail\n    ldr x9, [x19, #24]\n    mov x10, #21314\n    cmp x9, x10\n    b.ne L_snc_bc_fail\n    ldr x9, [x19]\n    cbz x9, L_snc_bc_fail\n    str xzr, [x19, #8]\n    strb wzr, [x9]\n    mov x0, #1\n    b L_snc_bc_done\nL_snc_bc_fail:\n    mov x0, #0\nL_snc_bc_done:\n    ldr x19, [sp, #16]\n    ldp x29, x30, [sp], #32\n    ret\n.global snc_builder_length\nsnc_builder_length:\n    stp x29, x30, [sp, #-32]!\n    mov x29, sp\n    str x19, [sp, #16]\n    mov x19, x0\n    cbz x19, L_snc_bl_fail\n    bl snc_managed_size\n    cmp x0, #32\n    b.ne L_snc_bl_fail\n    ldr x9, [x19, #24]\n    mov x10, #21314\n    cmp x9, x10\n    b.ne L_snc_bl_fail\n    ldr x0, [x19, #8]\n    b L_snc_bl_done\nL_snc_bl_fail:\n    mov x0, #0\nL_snc_bl_done:\n    ldr x19, [sp, #16]\n    ldp x29, x30, [sp], #32\n    ret\n"
    .asciz "\n.data\n.align 3\nsnc_mem_head: .quad 0\nsnc_mem_live_count: .quad 0\nsnc_mem_byte_count: .quad 0\nsnc_mem_lock: .quad 0\n"
#else
    .ascii "\n.text\n.align 4\n.global _snc_mem_lock_acquire\n_snc_mem_lock_acquire:\n    adrp x9, _snc_mem_lock@PAGE\n    add x9, x9, _snc_mem_lock@PAGEOFF\nL_snc_mem_lock_retry:\n    ldaxr x10, [x9]\n    cbnz x10, L_snc_mem_lock_retry\n    mov x10, #1\n    stlxr w11, x10, [x9]\n    cbnz w11, L_snc_mem_lock_retry\n    ret\n.global _snc_mem_lock_release\n_snc_mem_lock_release:\n    adrp x9, _snc_mem_lock@PAGE\n    add x9, x9, _snc_mem_lock@PAGEOFF\n    stlr xzr, [x9]\n    ret\n"
    .ascii ".global _snc_managed_alloc\n_snc_managed_alloc:\n    stp x29, x30, [sp, #-48]!\n    mov x29, sp\n    stp x19, x20, [sp, #16]\n    str x21, [sp, #32]\n    mov x19, x0\n    cbnz x19, L_snc_ma_size_ok\n    mov x19, #1\nL_snc_ma_size_ok:\n    adds x0, x19, #32\n    b.cs L_snc_ma_fail\n    bl _malloc\n    cbz x0, L_snc_ma_fail\n    mov x20, x0\n    str x19, [x20, #8]\n    bl _snc_mem_lock_acquire\n    adrp x9, _snc_mem_head@PAGE\n    add x9, x9, _snc_mem_head@PAGEOFF\n    ldr x10, [x9]\n    str x10, [x20]\n    str x20, [x9]\n    adrp x9, _snc_mem_live_count@PAGE\n    add x9, x9, _snc_mem_live_count@PAGEOFF\n    ldr x10, [x9]\n    add x10, x10, #1\n    str x10, [x9]\n    adrp x9, _snc_mem_byte_count@PAGE\n    add x9, x9, _snc_mem_byte_count@PAGEOFF\n    ldr x10, [x9]\n    add x10, x10, x19\n    str x10, [x9]\n    bl _snc_mem_lock_release\n    add x0, x20, #32\n    b L_snc_ma_done\nL_snc_ma_fail:\n    mov x0, #0\nL_snc_ma_done:\n    ldr x21, [sp, #32]\n    ldp x19, x20, [sp, #16]\n    ldp x29, x30, [sp], #48\n    ret\n"
    .ascii ".global _snc_managed_free\n_snc_managed_free:\n    stp x29, x30, [sp, #-64]!\n    mov x29, sp\n    stp x19, x20, [sp, #16]\n    stp x21, x22, [sp, #32]\n    str x23, [sp, #48]\n    mov x19, x0\n    cbz x19, L_snc_mf_not_found\n    bl _snc_mem_lock_acquire\n    adrp x9, _snc_mem_head@PAGE\n    add x9, x9, _snc_mem_head@PAGEOFF\n    ldr x20, [x9]\n    mov x21, #0\nL_snc_mf_scan:\n    cbz x20, L_snc_mf_unlock_not_found\n    add x22, x20, #32\n    cmp x19, x22\n    b.lo L_snc_mf_next\n    ldr x11, [x20, #8]\n    add x12, x22, x11\n    cmp x19, x12\n    b.lo L_snc_mf_found\nL_snc_mf_next:\n    mov x21, x20\n    ldr x20, [x20]\n    b L_snc_mf_scan\nL_snc_mf_found:\n    ldr x23, [x20]\n    cbz x21, L_snc_mf_set_head\n    str x23, [x21]\n    b L_snc_mf_unlinked\nL_snc_mf_set_head:\n    str x23, [x9]\nL_snc_mf_unlinked:\n    adrp x9, _snc_mem_live_count@PAGE\n    add x9, x9, _snc_mem_live_count@PAGEOFF\n    ldr x10, [x9]\n    sub x10, x10, #1\n    str x10, [x9]\n    ldr x11, [x20, #8]\n    adrp x9, _snc_mem_byte_count@PAGE\n    add x9, x9, _snc_mem_byte_count@PAGEOFF\n    ldr x10, [x9]\n    sub x10, x10, x11\n    str x10, [x9]\n    bl _snc_mem_lock_release\n    mov x0, x20\n    bl _free\n    mov x0, #1\n    b L_snc_mf_done\nL_snc_mf_unlock_not_found:\n    bl _snc_mem_lock_release\nL_snc_mf_not_found:\n    mov x0, #0\nL_snc_mf_done:\n    ldr x23, [sp, #48]\n    ldp x21, x22, [sp, #32]\n    ldp x19, x20, [sp, #16]\n    ldp x29, x30, [sp], #64\n    ret\n"
    .ascii ".global _snc_managed_size\n_snc_managed_size:\n    stp x29, x30, [sp, #-48]!\n    mov x29, sp\n    stp x19, x20, [sp, #16]\n    str x21, [sp, #32]\n    mov x19, x0\n    bl _snc_mem_lock_acquire\n    adrp x9, _snc_mem_head@PAGE\n    add x9, x9, _snc_mem_head@PAGEOFF\n    ldr x20, [x9]\nL_snc_ms_scan:\n    cbz x20, L_snc_ms_not_found\n    add x21, x20, #32\n    cmp x21, x19\n    b.eq L_snc_ms_found\n    ldr x20, [x20]\n    b L_snc_ms_scan\nL_snc_ms_found:\n    ldr x19, [x20, #8]\n    b L_snc_ms_unlock\nL_snc_ms_not_found:\n    mov x19, #0\nL_snc_ms_unlock:\n    bl _snc_mem_lock_release\n    mov x0, x19\n    ldr x21, [sp, #32]\n    ldp x19, x20, [sp, #16]\n    ldp x29, x30, [sp], #48\n    ret\n.global _snc_mem_live\n_snc_mem_live:\n    adrp x9, _snc_mem_live_count@PAGE\n    add x9, x9, _snc_mem_live_count@PAGEOFF\n    ldr x0, [x9]\n    ret\n.global _snc_mem_bytes\n_snc_mem_bytes:\n    adrp x9, _snc_mem_byte_count@PAGE\n    add x9, x9, _snc_mem_byte_count@PAGEOFF\n    ldr x0, [x9]\n    ret\n.global _snc_memory_cleanup\n_snc_memory_cleanup:\n    stp x29, x30, [sp, #-48]!\n    mov x29, sp\n    stp x19, x20, [sp, #16]\n    str x21, [sp, #32]\n    bl _snc_mem_lock_acquire\n    adrp x9, _snc_mem_head@PAGE\n    add x9, x9, _snc_mem_head@PAGEOFF\n    ldr x19, [x9]\n    str xzr, [x9]\n    adrp x9, _snc_mem_live_count@PAGE\n    add x9, x9, _snc_mem_live_count@PAGEOFF\n    ldr x20, [x9]\n    str xzr, [x9]\n    adrp x9, _snc_mem_byte_count@PAGE\n    add x9, x9, _snc_mem_byte_count@PAGEOFF\n    str xzr, [x9]\n    bl _snc_mem_lock_release\nL_snc_mc_free_loop:\n    cbz x19, L_snc_mc_done\n    ldr x21, [x19]\n    mov x0, x19\n    bl _free\n    mov x19, x21\n    b L_snc_mc_free_loop\nL_snc_mc_done:\n    mov x0, x20\n    ldr x21, [sp, #32]\n    ldp x19, x20, [sp, #16]\n    ldp x29, x30, [sp], #48\n    ret\n"
    .ascii ".global _snc_builder_new\n_snc_builder_new:\n    stp x29, x30, [sp, #-32]!\n    mov x29, sp\n    str x19, [sp, #16]\n    mov x0, #32\n    bl _snc_managed_alloc\n    cbz x0, L_snc_bn_fail\n    mov x19, x0\n    mov x0, #64\n    bl _snc_managed_alloc\n    cbz x0, L_snc_bn_free_obj\n    str x0, [x19]\n    str xzr, [x19, #8]\n    mov x9, #64\n    str x9, [x19, #16]\n    mov x9, #21314\n    str x9, [x19, #24]\n    strb wzr, [x0]\n    mov x0, x19\n    b L_snc_bn_done\nL_snc_bn_free_obj:\n    mov x0, x19\n    bl _snc_managed_free\nL_snc_bn_fail:\n    mov x0, #0\nL_snc_bn_done:\n    ldr x19, [sp, #16]\n    ldp x29, x30, [sp], #32\n    ret\n"
    .ascii ".global _snc_builder_append\n_snc_builder_append:\n    stp x29, x30, [sp, #-96]!\n    mov x29, sp\n    stp x19, x20, [sp, #16]\n    stp x21, x22, [sp, #32]\n    stp x23, x24, [sp, #48]\n    stp x25, x26, [sp, #64]\n    stp x27, x28, [sp, #80]\n    mov x19, x0\n    mov x20, x1\n    cbz x19, L_snc_ba_fail\n    mov x0, x19\n    bl _snc_managed_size\n    cmp x0, #32\n    b.ne L_snc_ba_fail\n    ldr x9, [x19, #24]\n    mov x10, #21314\n    cmp x9, x10\n    b.ne L_snc_ba_fail\n    cbz x20, L_snc_ba_fail\n    mov x0, x20\n    bl _cstring_length\n    mov x21, x0\n    ldr x22, [x19, #8]\n    ldr x23, [x19, #16]\n    ldr x25, [x19]\n    adds x24, x22, x21\n    b.cs L_snc_ba_fail\n    adds x24, x24, #1\n    b.cs L_snc_ba_fail\n    cmp x24, x23\n    b.le L_snc_ba_copy_new\n    mov x26, x23\nL_snc_ba_grow_cap:\n    lsl x27, x26, #1\n    cmp x27, x26\n    b.ls L_snc_ba_fail\n    mov x26, x27\n    cmp x26, x24\n    b.lt L_snc_ba_grow_cap\n    mov x0, x26\n    bl _snc_managed_alloc\n    cbz x0, L_snc_ba_fail\n    mov x27, x0\n    mov x28, #0\nL_snc_ba_copy_old:\n    cmp x28, x22\n    b.ge L_snc_ba_old_done\n    ldrb w9, [x25, x28]\n    strb w9, [x27, x28]\n    add x28, x28, #1\n    b L_snc_ba_copy_old\nL_snc_ba_old_done:\n    mov x0, x25\n    bl _snc_managed_free\n    mov x25, x27\n    str x25, [x19]\n    str x26, [x19, #16]\nL_snc_ba_copy_new:\n    mov x28, #0\nL_snc_ba_copy_new_loop:\n    cmp x28, x21\n    b.ge L_snc_ba_copy_done\n    ldrb w9, [x20, x28]\n    add x10, x22, x28\n    strb w9, [x25, x10]\n    add x28, x28, #1\n    b L_snc_ba_copy_new_loop\nL_snc_ba_copy_done:\n    add x22, x22, x21\n    str x22, [x19, #8]\n    strb wzr, [x25, x22]\n    mov x0, #1\n    b L_snc_ba_done\nL_snc_ba_fail:\n    mov x0, #0\nL_snc_ba_done:\n    ldp x27, x28, [sp, #80]\n    ldp x25, x26, [sp, #64]\n    ldp x23, x24, [sp, #48]\n    ldp x21, x22, [sp, #32]\n    ldp x19, x20, [sp, #16]\n    ldp x29, x30, [sp], #96\n    ret\n"
    .ascii ".global _snc_builder_append_int\n_snc_builder_append_int:\n    stp x29, x30, [sp, #-48]!\n    mov x29, sp\n    stp x19, x20, [sp, #16]\n    str x21, [sp, #32]\n    mov x19, x0\n    mov x0, x1\n    bl _int_to_cstr\n    cbz x0, L_snc_bai_fail\n    mov x20, x0\n    mov x1, x20\n    mov x0, x19\n    bl _snc_builder_append\n    mov x21, x0\n    mov x0, x20\n    bl _snc_managed_free\n    mov x0, x21\n    b L_snc_bai_done\nL_snc_bai_fail:\n    mov x0, #0\nL_snc_bai_done:\n    ldr x21, [sp, #32]\n    ldp x19, x20, [sp, #16]\n    ldp x29, x30, [sp], #48\n    ret\n"
    .ascii ".global _snc_builder_string\n_snc_builder_string:\n    stp x29, x30, [sp, #-64]!\n    mov x29, sp\n    stp x19, x20, [sp, #16]\n    stp x21, x22, [sp, #32]\n    str x23, [sp, #48]\n    mov x19, x0\n    cbz x19, L_snc_bs_fail\n    mov x0, x19\n    bl _snc_managed_size\n    cmp x0, #32\n    b.ne L_snc_bs_fail\n    ldr x9, [x19, #24]\n    mov x10, #21314\n    cmp x9, x10\n    b.ne L_snc_bs_fail\n    ldr x20, [x19]\n    ldr x21, [x19, #8]\n    add x0, x21, #1\n    bl _snc_managed_alloc\n    cbz x0, L_snc_bs_fail\n    mov x22, x0\n    mov x23, #0\nL_snc_bs_copy:\n    cmp x23, x21\n    b.gt L_snc_bs_done_copy\n    ldrb w9, [x20, x23]\n    strb w9, [x22, x23]\n    add x23, x23, #1\n    b L_snc_bs_copy\nL_snc_bs_done_copy:\n    mov x0, x22\n    b L_snc_bs_done\nL_snc_bs_fail:\n    mov x0, #0\nL_snc_bs_done:\n    ldr x23, [sp, #48]\n    ldp x21, x22, [sp, #32]\n    ldp x19, x20, [sp, #16]\n    ldp x29, x30, [sp], #64\n    ret\n"
    .ascii ".global _snc_builder_clear\n_snc_builder_clear:\n    stp x29, x30, [sp, #-32]!\n    mov x29, sp\n    str x19, [sp, #16]\n    mov x19, x0\n    cbz x19, L_snc_bc_fail\n    bl _snc_managed_size\n    cmp x0, #32\n    b.ne L_snc_bc_fail\n    ldr x9, [x19, #24]\n    mov x10, #21314\n    cmp x9, x10\n    b.ne L_snc_bc_fail\n    ldr x9, [x19]\n    cbz x9, L_snc_bc_fail\n    str xzr, [x19, #8]\n    strb wzr, [x9]\n    mov x0, #1\n    b L_snc_bc_done\nL_snc_bc_fail:\n    mov x0, #0\nL_snc_bc_done:\n    ldr x19, [sp, #16]\n    ldp x29, x30, [sp], #32\n    ret\n.global _snc_builder_length\n_snc_builder_length:\n    stp x29, x30, [sp, #-32]!\n    mov x29, sp\n    str x19, [sp, #16]\n    mov x19, x0\n    cbz x19, L_snc_bl_fail\n    bl _snc_managed_size\n    cmp x0, #32\n    b.ne L_snc_bl_fail\n    ldr x9, [x19, #24]\n    mov x10, #21314\n    cmp x9, x10\n    b.ne L_snc_bl_fail\n    ldr x0, [x19, #8]\n    b L_snc_bl_done\nL_snc_bl_fail:\n    mov x0, #0\nL_snc_bl_done:\n    ldr x19, [sp, #16]\n    ldp x29, x30, [sp], #32\n    ret\n"
    .asciz "\n.data\n.align 3\n_snc_mem_head: .quad 0\n_snc_mem_live_count: .quad 0\n_snc_mem_byte_count: .quad 0\n_snc_mem_lock: .quad 0\n"
#endif

asm_call_mem_live:
#ifdef _WIN32
    .asciz "    bl snc_mem_live\n"
#else
    .asciz "    bl _snc_mem_live\n"
#endif
asm_call_mem_bytes:
#ifdef _WIN32
    .asciz "    bl snc_mem_bytes\n"
#else
    .asciz "    bl _snc_mem_bytes\n"
#endif
asm_call_mem_collect:
#ifdef _WIN32
    .asciz "    bl snc_memory_cleanup\n"
#else
    .asciz "    bl _snc_memory_cleanup\n"
#endif
asm_call_builder_new:
#ifdef _WIN32
    .asciz "    bl snc_builder_new\n"
#else
    .asciz "    bl _snc_builder_new\n"
#endif
asm_call_builder_append:
#ifdef _WIN32
    .asciz "    bl snc_builder_append\n"
#else
    .asciz "    bl _snc_builder_append\n"
#endif
asm_call_builder_append_int:
#ifdef _WIN32
    .asciz "    bl snc_builder_append_int\n"
#else
    .asciz "    bl _snc_builder_append_int\n"
#endif
asm_call_builder_string:
#ifdef _WIN32
    .asciz "    bl snc_builder_string\n"
#else
    .asciz "    bl _snc_builder_string\n"
#endif
asm_call_builder_clear:
#ifdef _WIN32
    .asciz "    bl snc_builder_clear\n"
#else
    .asciz "    bl _snc_builder_clear\n"
#endif
asm_call_builder_length:
#ifdef _WIN32
    .asciz "    bl snc_builder_length\n"
#else
    .asciz "    bl _snc_builder_length\n"
#endif

// Runtime helpers included in emitted programs.
asm_runtime_helpers:
#ifdef _WIN32
    .asciz "\n\n.text\n.align 4\n.global cstring_length\ncstring_length:\n    mov x1, x0\n    mov x0, #0\nL_snl_strlen_loop:\n    ldrb w9, [x1, x0]\n    cbz w9, L_snl_strlen_done\n    add x0, x0, #1\n    b L_snl_strlen_loop\nL_snl_strlen_done:\n    ret\n\n.align 4\n.global str_concat_len\nstr_concat_len:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    stp x21, x22, [sp, #-16]!\n    stp x23, x24, [sp, #-16]!\n    stp x25, x26, [sp, #-16]!\n\n    mov x19, x0\n    mov x20, x1\n    mov x21, x2\n    mov x22, x3\n\n    add x0, x20, x22\n    add x0, x0, #1\n    bl snc_managed_alloc\n    cbz x0, L_snl_str_concat_len_fail\n    mov x23, x0\n\n    mov x24, #0\nL_snl_str_concat_len_copy1:\n    cmp x24, x20\n    b.ge L_snl_str_concat_len_copy2_start\n    ldrb w9, [x19, x24]\n    strb w9, [x23, x24]\n    add x24, x24, #1\n    b L_snl_str_concat_len_copy1\n\nL_snl_str_concat_len_copy2_start:\n    mov x9, #0\nL_snl_str_concat_len_copy2:\n    cmp x9, x22\n    b.ge L_snl_str_concat_len_done\n    ldrb w10, [x21, x9]\n    add x11, x24, x9\n    strb w10, [x23, x11]\n    add x9, x9, #1\n    b L_snl_str_concat_len_copy2\n\nL_snl_str_concat_len_done:\n    add x11, x24, x22\n    strb wzr, [x23, x11]\n    mov x0, x23\n    b L_snl_str_concat_len_return\n\nL_snl_str_concat_len_fail:\n    mov x0, #0\n\nL_snl_str_concat_len_return:\n    ldp x25, x26, [sp], #16\n    ldp x23, x24, [sp], #16\n    ldp x21, x22, [sp], #16\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n\n.align 4\n.global str_concat\nstr_concat:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n\n    mov x19, x0\n    mov x20, x1\n\n    mov x0, x19\n    bl cstring_length\n    mov x2, x0\n\n    mov x0, x20\n    bl cstring_length\n    mov x3, x0\n\n    mov x0, x19\n    mov x1, x2\n    mov x2, x20\n    bl str_concat_len\n\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n\n.align 4\n.global int_to_cstr\nint_to_cstr:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    stp x21, x22, [sp, #-16]!\n    stp x23, x24, [sp, #-16]!\n\n    mov x19, x0\n    mov x0, #32\n    bl snc_managed_alloc\n    cbz x0, L_snl_int_to_cstr_fail\n    mov x20, x0\n    add x21, x20, #31\n    strb wzr, [x21]\n    sub x21, x21, #1\n\n    mov x22, #0\n    cmp x19, #0\n    b.ge L_snl_int_to_cstr_abs_ready\n    mov x22, #1\n    neg x19, x19\n\nL_snl_int_to_cstr_abs_ready:\n    cbnz x19, L_snl_int_to_cstr_digits\n    mov w9, #'0'\n    strb w9, [x21]\n    sub x21, x21, #1\n    b L_snl_int_to_cstr_sign\n\nL_snl_int_to_cstr_digits:\n    mov x23, #10\nL_snl_int_to_cstr_loop:\n    udiv x24, x19, x23\n    msub x9, x24, x23, x19\n    add w9, w9, #'0'\n    strb w9, [x21]\n    sub x21, x21, #1\n    mov x19, x24\n    cbnz x19, L_snl_int_to_cstr_loop\n\nL_snl_int_to_cstr_sign:\n    cbz x22, L_snl_int_to_cstr_done\n    mov w9, #'-'\n    strb w9, [x21]\n    sub x21, x21, #1\n\nL_snl_int_to_cstr_done:\n    add x0, x21, #1\n    b L_snl_int_to_cstr_return\n\nL_snl_int_to_cstr_fail:\n    mov x0, #0\nL_snl_int_to_cstr_return:\n    ldp x23, x24, [sp], #16\n    ldp x21, x22, [sp], #16\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n\n.align 4\n.global file_read\nfile_read:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    stp x21, x22, [sp, #-16]!\n\n    mov x19, x0\n    mov x0, x19\n    mov x1, #0\n    bl open\n    cmp x0, #0\n    b.lt L_snl_file_read_fail\n    mov x20, x0\n\n    mov x0, x20\n    mov x1, #0\n    mov x2, #2\n    bl lseek\n    cmp x0, #0\n    b.lt L_snl_file_read_fail_close\n    mov x21, x0\n\n    mov x0, x20\n    mov x1, #0\n    mov x2, #0\n    bl lseek\n\n    add x0, x21, #1\n    bl snc_managed_alloc\n    cbz x0, L_snl_file_read_fail_close\n    mov x22, x0\n\n    mov x0, x20\n    mov x1, x22\n    mov x2, x21\n    bl read\n\n    add x9, x22, x21\n    strb wzr, [x9]\n\n    mov x0, x20\n    bl close\n\n    mov x0, x22\n    b L_snl_file_read_return\n\nL_snl_file_read_fail_close:\n    mov x0, x20\n    bl close\nL_snl_file_read_fail:\n    mov x0, #0\nL_snl_file_read_return:\n    ldp x21, x22, [sp], #16\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n\n.align 4\n.global file_write\nfile_write:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    stp x21, x22, [sp, #-16]!\n\n    mov x19, x0\n    mov x20, x1\n    mov x21, x2\n\n    mov x0, x19\n    mov x1, #0x601\n    mov x2, #0644\n    bl open\n    cmp x0, #0\n    b.lt L_snl_file_write_fail\n    mov x22, x0\n\n    mov x0, x22\n    mov x1, x20\n    mov x2, x21\n    bl write\n\n    mov x0, x22\n    bl close\n\n    mov x0, #1\n    b L_snl_file_write_return\n\nL_snl_file_write_fail:\n    mov x0, #0\nL_snl_file_write_return:\n    ldp x21, x22, [sp], #16\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n"
#else
    .asciz "\n\n.text\n.align 4\n.global _cstring_length\n_cstring_length:\n    mov x1, x0\n    mov x0, #0\nL_snl_strlen_loop:\n    ldrb w9, [x1, x0]\n    cbz w9, L_snl_strlen_done\n    add x0, x0, #1\n    b L_snl_strlen_loop\nL_snl_strlen_done:\n    ret\n\n.align 4\n.global _str_concat_len\n_str_concat_len:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    stp x21, x22, [sp, #-16]!\n    stp x23, x24, [sp, #-16]!\n    stp x25, x26, [sp, #-16]!\n\n    mov x19, x0\n    mov x20, x1\n    mov x21, x2\n    mov x22, x3\n\n    add x0, x20, x22\n    add x0, x0, #1\n    bl _snc_managed_alloc\n    cbz x0, L_snl_str_concat_len_fail\n    mov x23, x0\n\n    mov x24, #0\nL_snl_str_concat_len_copy1:\n    cmp x24, x20\n    b.ge L_snl_str_concat_len_copy2_start\n    ldrb w9, [x19, x24]\n    strb w9, [x23, x24]\n    add x24, x24, #1\n    b L_snl_str_concat_len_copy1\n\nL_snl_str_concat_len_copy2_start:\n    mov x9, #0\nL_snl_str_concat_len_copy2:\n    cmp x9, x22\n    b.ge L_snl_str_concat_len_done\n    ldrb w10, [x21, x9]\n    add x11, x24, x9\n    strb w10, [x23, x11]\n    add x9, x9, #1\n    b L_snl_str_concat_len_copy2\n\nL_snl_str_concat_len_done:\n    add x11, x24, x22\n    strb wzr, [x23, x11]\n    mov x0, x23\n    b L_snl_str_concat_len_return\n\nL_snl_str_concat_len_fail:\n    mov x0, #0\n\nL_snl_str_concat_len_return:\n    ldp x25, x26, [sp], #16\n    ldp x23, x24, [sp], #16\n    ldp x21, x22, [sp], #16\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n\n.align 4\n.global _str_concat\n_str_concat:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n\n    mov x19, x0\n    mov x20, x1\n\n    mov x0, x19\n    bl _cstring_length\n    mov x2, x0\n\n    mov x0, x20\n    bl _cstring_length\n    mov x3, x0\n\n    mov x0, x19\n    mov x1, x2\n    mov x2, x20\n    bl _str_concat_len\n\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n\n.align 4\n.global _int_to_cstr\n_int_to_cstr:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    stp x21, x22, [sp, #-16]!\n    stp x23, x24, [sp, #-16]!\n\n    mov x19, x0\n    mov x0, #32\n    bl _snc_managed_alloc\n    cbz x0, L_snl_int_to_cstr_fail\n    mov x20, x0\n    add x21, x20, #31\n    strb wzr, [x21]\n    sub x21, x21, #1\n\n    mov x22, #0\n    cmp x19, #0\n    b.ge L_snl_int_to_cstr_abs_ready\n    mov x22, #1\n    neg x19, x19\n\nL_snl_int_to_cstr_abs_ready:\n    cbnz x19, L_snl_int_to_cstr_digits\n    mov w9, #'0'\n    strb w9, [x21]\n    sub x21, x21, #1\n    b L_snl_int_to_cstr_sign\n\nL_snl_int_to_cstr_digits:\n    mov x23, #10\nL_snl_int_to_cstr_loop:\n    udiv x24, x19, x23\n    msub x9, x24, x23, x19\n    add w9, w9, #'0'\n    strb w9, [x21]\n    sub x21, x21, #1\n    mov x19, x24\n    cbnz x19, L_snl_int_to_cstr_loop\n\nL_snl_int_to_cstr_sign:\n    cbz x22, L_snl_int_to_cstr_done\n    mov w9, #'-'\n    strb w9, [x21]\n    sub x21, x21, #1\n\nL_snl_int_to_cstr_done:\n    add x0, x21, #1\n    b L_snl_int_to_cstr_return\n\nL_snl_int_to_cstr_fail:\n    mov x0, #0\nL_snl_int_to_cstr_return:\n    ldp x23, x24, [sp], #16\n    ldp x21, x22, [sp], #16\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n\n.align 4\n.global _file_read\n_file_read:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    stp x21, x22, [sp, #-16]!\n\n    mov x19, x0\n    mov x0, x19\n    mov x1, #0\n    bl _open\n    cmp x0, #0\n    b.lt L_snl_file_read_fail\n    mov x20, x0\n\n    mov x0, x20\n    mov x1, #0\n    mov x2, #2\n    bl _lseek\n    cmp x0, #0\n    b.lt L_snl_file_read_fail_close\n    mov x21, x0\n\n    mov x0, x20\n    mov x1, #0\n    mov x2, #0\n    bl _lseek\n\n    add x0, x21, #1\n    bl _snc_managed_alloc\n    cbz x0, L_snl_file_read_fail_close\n    mov x22, x0\n\n    mov x0, x20\n    mov x1, x22\n    mov x2, x21\n    bl _read\n\n    add x9, x22, x21\n    strb wzr, [x9]\n\n    mov x0, x20\n    bl _close\n\n    mov x0, x22\n    b L_snl_file_read_return\n\nL_snl_file_read_fail_close:\n    mov x0, x20\n    bl _close\nL_snl_file_read_fail:\n    mov x0, #0\nL_snl_file_read_return:\n    ldp x21, x22, [sp], #16\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n\n.align 4\n.global _file_write\n_file_write:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    stp x21, x22, [sp, #-16]!\n\n    mov x19, x0\n    mov x20, x1\n    mov x21, x2\n\n    mov x0, x19\n    mov x1, #0x601\n    mov x2, #0644\n    sub sp, sp, #16\n    str x2, [sp]\n    bl _open\n    add sp, sp, #16\n    cmp x0, #0\n    b.lt L_snl_file_write_fail\n    mov x22, x0\n\n    mov x0, x22\n    mov x1, x20\n    mov x2, x21\n    bl _write\n\n    mov x0, x22\n    bl _close\n\n    mov x0, #1\n    b L_snl_file_write_return\n\nL_snl_file_write_fail:\n    mov x0, #0\nL_snl_file_write_return:\n    ldp x21, x22, [sp], #16\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n\n.align 4\n.global _cstr_to_int\n_cstr_to_int:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    mov x1, x0\n    mov x0, #0\n    mov x2, #0\n    ldrb w3, [x1]\n    cmp w3, #'-'\n    b.ne L_snl_cstr_to_int_loop\n    mov x2, #1\n    add x1, x1, #1\nL_snl_cstr_to_int_loop:\n    ldrb w3, [x1], #1\n    cbz w3, L_snl_cstr_to_int_done\n    sub w3, w3, #'0'\n    cmp w3, #9\n    b.hi L_snl_cstr_to_int_done\n    mov x4, #10\n    mul x0, x0, x4\n    add x0, x0, x3\n    b L_snl_cstr_to_int_loop\nL_snl_cstr_to_int_done:\n    cbz x2, L_snl_cstr_to_int_ret\n    neg x0, x0\nL_snl_cstr_to_int_ret:\n    ldp x29, x30, [sp], #16\n    ret\n\n.align 4\n.global _runtime_match_span_span\n_runtime_match_span_span:\n    cbz x1, L_rmss_match\nL_rmss_loop:\n    ldrb w9, [x0], #1\n    ldrb w10, [x2], #1\n    cmp w9, w10\n    b.ne L_rmss_fail\n    sub x1, x1, #1\n    cbnz x1, L_rmss_loop\nL_rmss_match:\n    mov x0, #1\n    ret\nL_rmss_fail:\n    mov x0, #0\n    ret\n\n.align 4\n.global _map_lookup\n_map_lookup:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    stp x21, x22, [sp, #-16]!\n    stp x23, x24, [sp, #-16]!\n    stp x25, x26, [sp, #-16]!\n    mov x19, x0\n    mov x20, x1\n    mov x21, x2\n    mov x22, x3\n    mov x23, x4\n    mov x24, #0\nL_map_lookup_loop:\n    cmp x24, x20\n    b.ge L_map_lookup_fail\n    add x25, x19, x24\n    adrp x26, map_pool_keys@PAGE\n    add x26, x26, map_pool_keys@PAGEOFF\n    ldr x9, [x26, x25, lsl #3]\n    cmp x22, #2\n    b.eq L_map_lookup_str\n    cmp x9, x21\n    b.eq L_map_lookup_found\n    b L_map_lookup_next\nL_map_lookup_str:\n    adrp x26, map_pool_key_lengths@PAGE\n    add x26, x26, map_pool_key_lengths@PAGEOFF\n    ldr x10, [x26, x25, lsl #3]\n    cmp x10, x23\n    b.ne L_map_lookup_next\n    mov x0, x9\n    mov x1, x10\n    mov x2, x21\n    bl _runtime_match_span_span\n    cbnz x0, L_map_lookup_found\nL_map_lookup_next:\n    add x24, x24, #1\n    b L_map_lookup_loop\nL_map_lookup_found:\n    adrp x26, map_pool_values@PAGE\n    add x26, x26, map_pool_values@PAGEOFF\n    ldr x19, [x26, x25, lsl #3]\n    adrp x26, map_pool_lengths@PAGE\n    add x26, x26, map_pool_lengths@PAGEOFF\n    ldr x20, [x26, x25, lsl #3]\n    mov x0, x19\n    mov x1, x20\n    mov x2, #1\n    b L_map_lookup_ret\nL_map_lookup_fail:\n    mov x0, #0\n    mov x1, #0\n    mov x2, #0\nL_map_lookup_ret:\n    ldp x25, x26, [sp], #16\n    ldp x23, x24, [sp], #16\n    ldp x21, x22, [sp], #16\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n"
#endif
asm_print_fmt_int_adrp:
#ifdef _WIN32
    .asciz "    adrp x0, print_fmt_int\n    add x0, x0, :lo12:print_fmt_int\n"
#else
    .asciz "    adrp x0, print_fmt_int@PAGE\n    add x0, x0, print_fmt_int@PAGEOFF\n"
#endif
asm_print_fmt_int_noline_adrp:
#ifdef _WIN32
    .asciz "    adrp x0, print_fmt_int_noline\n    add x0, x0, :lo12:print_fmt_int_noline\n"
#else
    .asciz "    adrp x0, print_fmt_int_noline@PAGE\n    add x0, x0, print_fmt_int_noline@PAGEOFF\n"
#endif
asm_print_fmt_str_adrp:
#ifdef _WIN32
    .asciz "    adrp x0, print_fmt_str\n    add x0, x0, :lo12:print_fmt_str\n"
#else
    .asciz "    adrp x0, print_fmt_str@PAGE\n    add x0, x0, print_fmt_str@PAGEOFF\n"
#endif
asm_print_fmt_str_noline_adrp:
#ifdef _WIN32
    .asciz "    adrp x0, print_fmt_str_noline\n    add x0, x0, :lo12:print_fmt_str_noline\n"
#else
    .asciz "    adrp x0, print_fmt_str_noline@PAGE\n    add x0, x0, print_fmt_str_noline@PAGEOFF\n"
#endif
asm_print_val_adrp:
    .asciz "    adrp x9, print_val_"
asm_print_val_ldr:
#ifdef _WIN32
    .asciz "\n    ldr x1, [x9, :lo12:print_val_"
#else
    .asciz "@PAGE\n    ldr x1, [x9, print_val_"
#endif
asm_print_str_val_adrp:
    .asciz "    adrp x1, print_val_"
asm_print_str_val_add:
#ifdef _WIN32
    .asciz "\n    add x1, x1, :lo12:print_val_"
#else
    .asciz "@PAGE\n    add x1, x1, print_val_"
#endif
asm_print_call_suffix_stack:
#ifdef _WIN32
    .asciz "]\n    sub sp, sp, #16\n    str x1, [sp]\n    bl printf\n    add sp, sp, #16\n"
#else
    .asciz "]\n    sub sp, sp, #16\n    str x1, [sp]\n    bl _printf\n    add sp, sp, #16\n"
#endif
asm_print_call_suffix:
#ifdef _WIN32
    .asciz "]\n    sub sp, sp, #16\n    str x1, [sp]\n    bl printf\n    add sp, sp, #16\n"
#else
    .asciz "@PAGEOFF]\n    sub sp, sp, #16\n    str x1, [sp]\n    bl _printf\n    add sp, sp, #16\n"
#endif
asm_print_call_stack:
#ifdef _WIN32
    .asciz "\n    sub sp, sp, #16\n    str x1, [sp]\n    bl printf\n    add sp, sp, #16\n"
#else
    .asciz "@PAGEOFF\n    sub sp, sp, #16\n    str x1, [sp]\n    bl _printf\n    add sp, sp, #16\n"
#endif
asm_print_stack_only:
#ifdef _WIN32
    .asciz "    sub sp, sp, #16\n    str x1, [sp]\n    bl printf\n    add sp, sp, #16\n"
#else
    .asciz "    sub sp, sp, #16\n    str x1, [sp]\n    bl _printf\n    add sp, sp, #16\n"
#endif
asm_print_dec_call_stack:
#ifdef _WIN32
    .asciz "    sub sp, sp, #32\n    stp x1, x2, [sp]\n    stp x3, x4, [sp, #16]\n    bl printf\n    add sp, sp, #32\n"
#else
    .asciz "    sub sp, sp, #32\n    stp x1, x2, [sp]\n    stp x3, x4, [sp, #16]\n    bl _printf\n    add sp, sp, #32\n"
#endif

.global asm_print_noline_call_stack
.global asm_print_noline_call_suffix
.global asm_print_noline_call_suffix_stack
.global asm_print_noline_stack_only
.global asm_call_free
.global asm_call_malloc
.global asm_ldr_x10_x11
.global asm_ldrb_w10_x11
.global asm_mov_x0_imm_prefix
.global asm_store_val_ldr_x10
.global asm_str_x10_x11
.global asm_strb_w10_x11
.global asm_sub_x10_x29_imm
asm_print_noline_call_stack:
#ifdef _WIN32
    .asciz "@PAGEOFF\n    sub sp, sp, #16\n    str x1, [sp]\n    bl printf\n    add sp, sp, #16\n"
#else
    .asciz "@PAGEOFF\n    sub sp, sp, #16\n    str x1, [sp]\n    bl _printf\n    add sp, sp, #16\n"
#endif
asm_print_noline_call_suffix:
#ifdef _WIN32
    .asciz "]    sub sp, sp, #16\n    str x1, [sp]\n    bl printf\n    add sp, sp, #16\n"
#else
    .asciz "@PAGEOFF]    sub sp, sp, #16\n    str x1, [sp]\n    bl _printf\n    add sp, sp, #16\n"
#endif
asm_print_noline_call_suffix_stack:
#ifdef _WIN32
    .asciz "]    sub sp, sp, #16\n    str x1, [sp]\n    bl printf\n    add sp, sp, #16\n"
#else
    .asciz "@PAGEOFF]    sub sp, sp, #16\n    str x1, [sp]\n    bl _printf\n    add sp, sp, #16\n"
#endif
asm_print_noline_stack_only:
#ifdef _WIN32
    .asciz "    sub sp, sp, #16\n    str x1, [sp]\n    bl printf\n    add sp, sp, #16\n"
#else
    .asciz "    sub sp, sp, #16\n    str x1, [sp]\n    bl _printf\n    add sp, sp, #16\n"
#endif
asm_store_val_adrp:
    .asciz "    adrp x9, store_val_"
asm_store_val_ldr:
#ifdef _WIN32
    .asciz "\n    ldr x10, [x9, :lo12:store_val_"
#else
    .asciz "@PAGE\n    ldr x10, [x9, store_val_"
#endif
asm_store_var_adrp:
#ifdef _WIN32
    .asciz "]\n    adrp x11, var_slot_"
#else
    .asciz "@PAGEOFF]\n    adrp x11, var_slot_"
#endif
asm_store_var_str:
#ifdef _WIN32
    .asciz "]\n    stur x10, [x29, #-"
#else
    .asciz "@PAGEOFF]\n    stur x10, [x29, #-"
#endif
asm_store_var_suffix:
#ifdef _WIN32
    .asciz "]\n"
#else
    .asciz "@PAGEOFF]\n"
#endif
asm_close_bracket:
    .asciz "]\n"
asm_mov_x10_x0:
    .asciz "    mov x10, x0\n"
asm_load_x0_print_val_prefix:
#ifdef _WIN32
    .asciz "    adrp x0, print_val_"
#else
    .asciz "    adrp x0, print_val_"
#endif
asm_load_x0_print_val_middle:
#ifdef _WIN32
    .asciz "\n    add x0, x0, :lo12:print_val_"
#else
    .asciz "@PAGE\n    add x0, x0, print_val_"
#endif
asm_load_x0_print_val_suffix:
#ifdef _WIN32
    .asciz "\n"
#else
    .asciz "@PAGEOFF\n"
#endif

asm_load_x1_print_val_prefix:
#ifdef _WIN32
    .asciz "    adrp x1, print_val_"
#else
    .asciz "    adrp x1, print_val_"
#endif
asm_load_x1_print_val_middle:
#ifdef _WIN32
    .asciz "\n    add x1, x1, :lo12:print_val_"
#else
    .asciz "@PAGE\n    add x1, x1, print_val_"
#endif
asm_load_x1_print_val_suffix:
#ifdef _WIN32
    .asciz "\n"
#else
    .asciz "@PAGEOFF\n"
#endif
asm_load_x0_var:
    .asciz "    ldur x0, [x29, #-"
asm_load_x1_var:
    .asciz "    ldur x1, [x29, #-"
asm_load_x2_var:
    .asciz "    ldur x2, [x29, #-"
asm_store_x0_var:
    .asciz "    stur x0, [x29, #-"
asm_ldur_reg_prefix:
    .asciz "    ldur x"
asm_stur_reg_prefix:
    .asciz "    stur x"
asm_reg_frame_mid:
    .asciz ", [x29, #-"
asm_print_var_adrp:
    .asciz "    adrp x9, var_slot_"
asm_print_var_ldr:
    .asciz "    ldur x1, [x29, #-"
asm_print_fmt_dec_adrp:
#ifdef _WIN32
    .asciz "    adrp x0, print_fmt_dec\n    add x0, x0, :lo12:print_fmt_dec\n"
#else
    .asciz "    adrp x0, print_fmt_dec@PAGE\n    add x0, x0, print_fmt_dec@PAGEOFF\n"
#endif
asm_dec_sign_empty_adrp:
#ifdef _WIN32
    .asciz "    adrp x1, dec_sign_empty\n    add x1, x1, :lo12:dec_sign_empty\n"
#else
    .asciz "    adrp x1, dec_sign_empty@PAGE\n    add x1, x1, dec_sign_empty@PAGEOFF\n"
#endif
asm_dec_sign_minus_adrp:
#ifdef _WIN32
    .asciz "    adrp x2, dec_sign_minus\n    add x2, x2, :lo12:dec_sign_minus\n"
#else
    .asciz "    adrp x2, dec_sign_minus@PAGE\n    add x2, x2, dec_sign_minus@PAGEOFF\n"
#endif
asm_mov_x3_imm_prefix:
    .asciz "    mov x3, #"
asm_mov_x12_imm_prefix:
    .asciz "    mov x12, #"
asm_mov_x14_imm_prefix:
    .asciz "    mov x14, #"
asm_dec_abs_x11_to_x13:
    .asciz "    cmp x11, #0\n    cneg x13, x11, lt\n"
asm_dec_select_sign_x1:
    .asciz "    cmp x11, #0\n    csel x1, x2, x1, lt\n"
asm_dec_split_x13_x14:
    .asciz "    udiv x2, x13, x14\n    msub x4, x2, x14, x13\n"
asm_dec_mul_x11_x10_x12:
    .asciz "    mul x11, x11, x10\n    sdiv x11, x11, x12\n"
asm_dec_div_x11_x10_x12:
    .asciz "    mul x11, x11, x12\n    sdiv x11, x11, x10\n"
asm_math_var_x11_adrp:
    .asciz "    adrp x11, var_slot_"
asm_math_var_x11_ldr:
    .asciz "    ldur x11, [x29, #-"
asm_math_var_x1_adrp:
    .asciz "    adrp x11, var_slot_"
asm_math_var_x1_ldr:
    .asciz "    ldur x1, [x29, #-"
asm_math_var_x10_adrp:
    .asciz "    adrp x12, var_slot_"
asm_math_var_x10_ldr:
    .asciz "    ldur x10, [x29, #-"
asm_math_store_x11_adrp:
    .asciz "    adrp x12, var_slot_"
asm_math_store_x11_str:
    .asciz "    stur x11, [x29, #-"
asm_math_add_x11_x10:
    .asciz "    add x11, x11, x10\n"
asm_math_sub_x11_x10:
    .asciz "    sub x11, x11, x10\n"
asm_math_mul_x11_x10:
    .asciz "    mul x11, x11, x10\n"
asm_math_div_x11_x10:
    .asciz "    udiv x11, x11, x10\n"
asm_math_mod_x11_x10:
    .asciz "    udiv x13, x11, x10\n    msub x11, x13, x10, x11\n"
asm_math_add_x1_x10:
    .asciz "    add x1, x1, x10\n"
asm_math_sub_x1_x10:
    .asciz "    sub x1, x1, x10\n"
asm_math_mul_x1_x10:
    .asciz "    mul x1, x1, x10\n"
asm_math_div_x1_x10:
    .asciz "    udiv x1, x1, x10\n"
asm_math_mod_x1_x10:
    .asciz "    udiv x13, x1, x10\n    msub x1, x13, x10, x1\n"
asm_logic_and_x11_x10:
    .asciz "    cmp x11, #0\n    cset x11, ne\n    cmp x10, #0\n    cset x10, ne\n    and x11, x11, x10\n"
asm_logic_or_x11_x10:
    .asciz "    orr x11, x11, x10\n    cmp x11, #0\n    cset x11, ne\n"
asm_logic_not_x11:
    .asciz "    cmp x11, #0\n    cset x11, eq\n"
asm_main_epilogue:
#ifdef _WIN32
    .asciz "    bl snc_memory_cleanup\n    mov w0, #0\n    mov sp, x29\n    ldp x29, x30, [sp], #16\n    ret\n\n"
#else
    .asciz "    bl _snc_memory_cleanup\n    mov w0, #0\n    mov sp, x29\n    ldp x29, x30, [sp], #16\n    ret\n\n"
#endif
asm_dot_data_intro:
    .asciz ".data\nprint_fmt_int:\n    .asciz \"%lld\\n\"\nprint_fmt_str:\n    .asciz \"%s\\n\"\nprint_fmt_dec:\n    .asciz \"%s%lld.%0*lld\\n\"\nprint_fmt_int_noline:\n    .asciz \"%lld\"\nprint_fmt_str_noline:\n    .asciz \"%s\"\nprint_fmt_dec_noline:\n    .asciz \"%s%lld.%0*lld\"\ndec_sign_empty:\n    .asciz \"\"\ndec_sign_minus:\n    .asciz \"-\"\n.align 3\n"
asm_spawn_dispatch_head:
    .asciz "\n.globl _snc_spawn_dispatch\n.align 4\n_snc_spawn_dispatch:\n"
asm_spawn_thr_glob:
    .asciz "\n.globl _snc_thr_"
asm_spawn_thr_label_mid:
    .asciz "\n.align 4\n_snc_thr_"
asm_spawn_thr_enter:
    .asciz "    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n"
asm_spawn_thr_leave:
    .asciz "    mov sp, x29\n    ldp x29, x30, [sp], #16\n    ret\n\n"
asm_spawn_dispatch_cmp:
    .asciz "    cmp w0, #"
asm_spawn_dispatch_beq:
    .asciz "\n    b.eq _snc_thr_"
asm_spawn_dispatch_ret:
    .asciz "    ret\n\n"
asm_call_spawn_go:
#ifdef _WIN32
    .asciz ""
#else
    .asciz "    bl _snc_spawn_go\n"
#endif
asm_spawn_thread_runtime:
#ifdef _WIN32
    .asciz ""
#else
    .asciz "\n.text\n.align 4\n.global _snc_pthread_trampoline\n_snc_pthread_trampoline:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    bl _snc_spawn_dispatch\n    mov x0, xzr\n    ldp x29, x30, [sp], #16\n    ret\n\n.align 4\n.global _snc_spawn_go\n_snc_spawn_go:\n    stp x29, x30, [sp, #-32]!\n    mov x29, sp\n    mov x3, x0\n    add x0, sp, #16\n    mov x1, xzr\n    adrp x2, _snc_pthread_trampoline@PAGE\n    add x2, x2, _snc_pthread_trampoline@PAGEOFF\n    bl _pthread_create\n    cbnz w0, L_snc_sg_fail\n    adrp x9, _snc_spawn_ntids@PAGE\n    add x9, x9, _snc_spawn_ntids@PAGEOFF\n    ldr x10, [x9]\n    cmp x10, #256\n    b.ge L_snc_sg_detach\n    adrp x11, _snc_spawn_tids@PAGE\n    add x11, x11, _snc_spawn_tids@PAGEOFF\n    ldr x12, [sp, #16]\n    str x12, [x11, x10, lsl #3]\n    add x10, x10, #1\n    str x10, [x9]\n    mov sp, x29\n    ldp x29, x30, [sp], #32\n    ret\nL_snc_sg_detach:\n    ldr x0, [sp, #16]\n    bl _pthread_detach\n    mov sp, x29\n    ldp x29, x30, [sp], #32\n    ret\nL_snc_sg_fail:\n    mov sp, x29\n    ldp x29, x30, [sp], #32\n    ret\n"
#endif

asm_call_spawn_wait:
#ifdef _WIN32
    .asciz "    mov x0, #0\n"
#else
    .asciz "    bl _snc_spawn_wait\n"
#endif
asm_spawn_wait_runtime:
#ifdef _WIN32
    .asciz ""
#else
    .asciz "\n.text\n.align 4\n.global _snc_spawn_wait\n_snc_spawn_wait:\n    stp x29, x30, [sp, #-48]!\n    mov x29, sp\n    stp x19, x20, [sp, #16]\n    stp x21, x22, [sp, #32]\n    adrp x19, _snc_spawn_ntids@PAGE\n    add x19, x19, _snc_spawn_ntids@PAGEOFF\n    adrp x20, _snc_spawn_tids@PAGE\n    add x20, x20, _snc_spawn_tids@PAGEOFF\n    ldr x21, [x19]\n    mov x22, #0\nL_snc_sw_loop:\n    cmp x22, x21\n    b.ge L_snc_sw_done\n    ldr x0, [x20, x22, lsl #3]\n    mov x1, #0\n    bl _pthread_join\n    add x22, x22, #1\n    b L_snc_sw_loop\nL_snc_sw_done:\n    str xzr, [x19]\n    mov x0, x21\n    ldp x21, x22, [sp, #32]\n    ldp x19, x20, [sp, #16]\n    ldp x29, x30, [sp], #48\n    ret\n\n.data\n.align 3\n_snc_spawn_ntids:\n    .quad 0\n_snc_spawn_tids:\n    .space 2048\n"
#endif
// Bounded MPMC channel runtime: 64 channels x 64 machine-word values. A tiny
// AArch64 exclusive-load spinlock avoids relying on platform-specific pthread
// mutex/condition object layouts. send/receive block by retrying; close wakes
// retrying receivers logically (closed+empty returns zero) and rejects sends.
asm_channel_runtime:
#ifdef _WIN32
    .asciz "\n.text\n.align 4\n.global snc_chan_lock\nsnc_chan_lock:\n    adrp x9, snc_chan_locks\n    add x9, x9, :lo12:snc_chan_locks\n    add x9, x9, x0, lsl #3\nL_snc_ch_lock_retry:\n    ldaxr x10, [x9]\n    cbnz x10, L_snc_ch_lock_retry\n    mov x10, #1\n    stlxr w11, x10, [x9]\n    cbnz w11, L_snc_ch_lock_retry\n    ret\n\n.global snc_chan_unlock\nsnc_chan_unlock:\n    adrp x9, snc_chan_locks\n    add x9, x9, :lo12:snc_chan_locks\n    add x9, x9, x0, lsl #3\n    stlr xzr, [x9]\n    ret\n\n.global snc_chan_send\nsnc_chan_send:\n    stp x29, x30, [sp, #-48]!\n    mov x29, sp\n    stp x19, x20, [sp, #16]\n    str x21, [sp, #32]\n    mov x19, x0\n    mov x20, x1\nL_snc_ch_send_retry:\n    mov x0, x19\n    bl snc_chan_lock\n    adrp x9, snc_chan_closed\n    add x9, x9, :lo12:snc_chan_closed\n    ldr x10, [x9, x19, lsl #3]\n    cbnz x10, L_snc_ch_send_closed\n    adrp x21, snc_chan_counts\n    add x21, x21, :lo12:snc_chan_counts\n    ldr x10, [x21, x19, lsl #3]\n    cmp x10, #64\n    b.ge L_snc_ch_send_full\n    adrp x9, snc_chan_tails\n    add x9, x9, :lo12:snc_chan_tails\n    ldr x11, [x9, x19, lsl #3]\n    adrp x12, snc_chan_values\n    add x12, x12, :lo12:snc_chan_values\n    add x12, x12, x19, lsl #9\n    str x20, [x12, x11, lsl #3]\n    add x11, x11, #1\n    and x11, x11, #63\n    str x11, [x9, x19, lsl #3]\n    add x10, x10, #1\n    str x10, [x21, x19, lsl #3]\n    mov x0, x19\n    bl snc_chan_unlock\n    mov x0, #1\n    b L_snc_ch_send_return\nL_snc_ch_send_full:\n    mov x0, x19\n    bl snc_chan_unlock\n    b L_snc_ch_send_retry\nL_snc_ch_send_closed:\n    mov x0, x19\n    bl snc_chan_unlock\n    mov x0, #0\nL_snc_ch_send_return:\n    ldr x21, [sp, #32]\n    ldp x19, x20, [sp, #16]\n    ldp x29, x30, [sp], #48\n    ret\n\n.global snc_chan_receive\nsnc_chan_receive:\n    stp x29, x30, [sp, #-48]!\n    mov x29, sp\n    stp x19, x20, [sp, #16]\n    str x21, [sp, #32]\n    mov x19, x0\nL_snc_ch_recv_retry:\n    mov x0, x19\n    bl snc_chan_lock\n    adrp x21, snc_chan_counts\n    add x21, x21, :lo12:snc_chan_counts\n    ldr x10, [x21, x19, lsl #3]\n    cbnz x10, L_snc_ch_recv_value\n    adrp x9, snc_chan_closed\n    add x9, x9, :lo12:snc_chan_closed\n    ldr x11, [x9, x19, lsl #3]\n    cbnz x11, L_snc_ch_recv_closed\n    mov x0, x19\n    bl snc_chan_unlock\n    b L_snc_ch_recv_retry\nL_snc_ch_recv_value:\n    adrp x9, snc_chan_heads\n    add x9, x9, :lo12:snc_chan_heads\n    ldr x11, [x9, x19, lsl #3]\n    adrp x12, snc_chan_values\n    add x12, x12, :lo12:snc_chan_values\n    add x12, x12, x19, lsl #9\n    ldr x20, [x12, x11, lsl #3]\n    add x11, x11, #1\n    and x11, x11, #63\n    str x11, [x9, x19, lsl #3]\n    sub x10, x10, #1\n    str x10, [x21, x19, lsl #3]\n    mov x0, x19\n    bl snc_chan_unlock\n    mov x0, x20\n    b L_snc_ch_recv_return\nL_snc_ch_recv_closed:\n    mov x0, x19\n    bl snc_chan_unlock\n    mov x0, #0\nL_snc_ch_recv_return:\n    ldr x21, [sp, #32]\n    ldp x19, x20, [sp, #16]\n    ldp x29, x30, [sp], #48\n    ret\n\n.global snc_chan_close\nsnc_chan_close:\n    stp x29, x30, [sp, #-32]!\n    mov x29, sp\n    str x19, [sp, #16]\n    mov x19, x0\n    bl snc_chan_lock\n    adrp x9, snc_chan_closed\n    add x9, x9, :lo12:snc_chan_closed\n    ldr x10, [x9, x19, lsl #3]\n    cbnz x10, L_snc_ch_close_done\n    mov x10, #1\n    str x10, [x9, x19, lsl #3]\n    mov x0, x19\n    bl snc_chan_unlock\n    mov x0, #1\n    b L_snc_ch_close_return\nL_snc_ch_close_done:\n    mov x0, x19\n    bl snc_chan_unlock\n    mov x0, #0\nL_snc_ch_close_return:\n    ldr x19, [sp, #16]\n    ldp x29, x30, [sp], #32\n    ret\n\n.data\n.align 3\nsnc_chan_locks: .space 512\nsnc_chan_heads: .space 512\nsnc_chan_tails: .space 512\nsnc_chan_counts: .space 512\nsnc_chan_closed: .space 512\nsnc_chan_values: .space 32768\n"
#else
    .asciz "\n.text\n.align 4\n.global _snc_chan_lock\n_snc_chan_lock:\n    adrp x9, _snc_chan_locks@PAGE\n    add x9, x9, _snc_chan_locks@PAGEOFF\n    add x9, x9, x0, lsl #3\nL_snc_ch_lock_retry:\n    ldaxr x10, [x9]\n    cbnz x10, L_snc_ch_lock_retry\n    mov x10, #1\n    stlxr w11, x10, [x9]\n    cbnz w11, L_snc_ch_lock_retry\n    ret\n\n.global _snc_chan_unlock\n_snc_chan_unlock:\n    adrp x9, _snc_chan_locks@PAGE\n    add x9, x9, _snc_chan_locks@PAGEOFF\n    add x9, x9, x0, lsl #3\n    stlr xzr, [x9]\n    ret\n\n.global _snc_chan_send\n_snc_chan_send:\n    stp x29, x30, [sp, #-48]!\n    mov x29, sp\n    stp x19, x20, [sp, #16]\n    str x21, [sp, #32]\n    mov x19, x0\n    mov x20, x1\nL_snc_ch_send_retry:\n    mov x0, x19\n    bl _snc_chan_lock\n    adrp x9, _snc_chan_closed@PAGE\n    add x9, x9, _snc_chan_closed@PAGEOFF\n    ldr x10, [x9, x19, lsl #3]\n    cbnz x10, L_snc_ch_send_closed\n    adrp x21, _snc_chan_counts@PAGE\n    add x21, x21, _snc_chan_counts@PAGEOFF\n    ldr x10, [x21, x19, lsl #3]\n    cmp x10, #64\n    b.ge L_snc_ch_send_full\n    adrp x9, _snc_chan_tails@PAGE\n    add x9, x9, _snc_chan_tails@PAGEOFF\n    ldr x11, [x9, x19, lsl #3]\n    adrp x12, _snc_chan_values@PAGE\n    add x12, x12, _snc_chan_values@PAGEOFF\n    add x12, x12, x19, lsl #9\n    str x20, [x12, x11, lsl #3]\n    add x11, x11, #1\n    and x11, x11, #63\n    str x11, [x9, x19, lsl #3]\n    add x10, x10, #1\n    str x10, [x21, x19, lsl #3]\n    mov x0, x19\n    bl _snc_chan_unlock\n    mov x0, #1\n    b L_snc_ch_send_return\nL_snc_ch_send_full:\n    mov x0, x19\n    bl _snc_chan_unlock\n    b L_snc_ch_send_retry\nL_snc_ch_send_closed:\n    mov x0, x19\n    bl _snc_chan_unlock\n    mov x0, #0\nL_snc_ch_send_return:\n    ldr x21, [sp, #32]\n    ldp x19, x20, [sp, #16]\n    ldp x29, x30, [sp], #48\n    ret\n\n.global _snc_chan_receive\n_snc_chan_receive:\n    stp x29, x30, [sp, #-48]!\n    mov x29, sp\n    stp x19, x20, [sp, #16]\n    str x21, [sp, #32]\n    mov x19, x0\nL_snc_ch_recv_retry:\n    mov x0, x19\n    bl _snc_chan_lock\n    adrp x21, _snc_chan_counts@PAGE\n    add x21, x21, _snc_chan_counts@PAGEOFF\n    ldr x10, [x21, x19, lsl #3]\n    cbnz x10, L_snc_ch_recv_value\n    adrp x9, _snc_chan_closed@PAGE\n    add x9, x9, _snc_chan_closed@PAGEOFF\n    ldr x11, [x9, x19, lsl #3]\n    cbnz x11, L_snc_ch_recv_closed\n    mov x0, x19\n    bl _snc_chan_unlock\n    b L_snc_ch_recv_retry\nL_snc_ch_recv_value:\n    adrp x9, _snc_chan_heads@PAGE\n    add x9, x9, _snc_chan_heads@PAGEOFF\n    ldr x11, [x9, x19, lsl #3]\n    adrp x12, _snc_chan_values@PAGE\n    add x12, x12, _snc_chan_values@PAGEOFF\n    add x12, x12, x19, lsl #9\n    ldr x20, [x12, x11, lsl #3]\n    add x11, x11, #1\n    and x11, x11, #63\n    str x11, [x9, x19, lsl #3]\n    sub x10, x10, #1\n    str x10, [x21, x19, lsl #3]\n    mov x0, x19\n    bl _snc_chan_unlock\n    mov x0, x20\n    b L_snc_ch_recv_return\nL_snc_ch_recv_closed:\n    mov x0, x19\n    bl _snc_chan_unlock\n    mov x0, #0\nL_snc_ch_recv_return:\n    ldr x21, [sp, #32]\n    ldp x19, x20, [sp, #16]\n    ldp x29, x30, [sp], #48\n    ret\n\n.global _snc_chan_close\n_snc_chan_close:\n    stp x29, x30, [sp, #-32]!\n    mov x29, sp\n    str x19, [sp, #16]\n    mov x19, x0\n    bl _snc_chan_lock\n    adrp x9, _snc_chan_closed@PAGE\n    add x9, x9, _snc_chan_closed@PAGEOFF\n    ldr x10, [x9, x19, lsl #3]\n    cbnz x10, L_snc_ch_close_done\n    mov x10, #1\n    str x10, [x9, x19, lsl #3]\n    mov x0, x19\n    bl _snc_chan_unlock\n    mov x0, #1\n    b L_snc_ch_close_return\nL_snc_ch_close_done:\n    mov x0, x19\n    bl _snc_chan_unlock\n    mov x0, #0\nL_snc_ch_close_return:\n    ldr x19, [sp, #16]\n    ldp x29, x30, [sp], #32\n    ret\n\n.data\n.align 3\n_snc_chan_locks: .space 512\n_snc_chan_heads: .space 512\n_snc_chan_tails: .space 512\n_snc_chan_counts: .space 512\n_snc_chan_closed: .space 512\n_snc_chan_values: .space 32768\n"
#endif
asm_call_chan_send:
#ifdef _WIN32
    .asciz "    bl snc_chan_send\n"
#else
    .asciz "    bl _snc_chan_send\n"
#endif
asm_call_chan_receive:
#ifdef _WIN32
    .asciz "    bl snc_chan_receive\n"
#else
    .asciz "    bl _snc_chan_receive\n"
#endif
asm_call_chan_close:
#ifdef _WIN32
    .asciz "    bl snc_chan_close\n"
#else
    .asciz "    bl _snc_chan_close\n"
#endif
asm_channel_init:
#ifdef _WIN32
    .asciz "    adrp x9, snc_chan_heads\n    add x9, x9, :lo12:snc_chan_heads\n    str xzr, [x9, x0, lsl #3]\n    adrp x9, snc_chan_tails\n    add x9, x9, :lo12:snc_chan_tails\n    str xzr, [x9, x0, lsl #3]\n    adrp x9, snc_chan_counts\n    add x9, x9, :lo12:snc_chan_counts\n    str xzr, [x9, x0, lsl #3]\n    adrp x9, snc_chan_closed\n    add x9, x9, :lo12:snc_chan_closed\n    str xzr, [x9, x0, lsl #3]\n"
#else
    .asciz "    adrp x9, _snc_chan_heads@PAGE\n    add x9, x9, _snc_chan_heads@PAGEOFF\n    str xzr, [x9, x0, lsl #3]\n    adrp x9, _snc_chan_tails@PAGE\n    add x9, x9, _snc_chan_tails@PAGEOFF\n    str xzr, [x9, x0, lsl #3]\n    adrp x9, _snc_chan_counts@PAGE\n    add x9, x9, _snc_chan_counts@PAGEOFF\n    str xzr, [x9, x0, lsl #3]\n    adrp x9, _snc_chan_closed@PAGE\n    add x9, x9, _snc_chan_closed@PAGEOFF\n    str xzr, [x9, x0, lsl #3]\n"
#endif
asm_ret:
    .asciz "    ret\n"
.global asm_fn_epilogue
asm_fn_epilogue:
    .asciz "    mov sp, x29\n    ldp x29, x30, [sp], #16\n    ret\n"
asm_global_prefix:
    .asciz ".global "
asm_prologue:
    .asciz "    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n"
asm_comment_prefix:
    .asciz "    // "
msg_fn_body_stub:
    .asciz "function body emission pending fix"
msg_debug_fn:
    .asciz "[DEBUG] Function "

asm_bl_prefix:
    .asciz "    bl "
asm_data_intro:
    .asciz "    mov w0, #0\n    mov sp, x29\n    ldp x29, x30, [sp], #16\n    ret\n\n.data\nprint_fmt_int:\n    .asciz \"%lld\\n\"\nprint_fmt_str:\n    .asciz \"%s\\n\"\nprint_fmt_dec:\n    .asciz \"%s%lld.%0*lld\\n\"\nprint_fmt_int_noline:\n    .asciz \"%lld\"\nprint_fmt_str_noline:\n    .asciz \"%s\"\nprint_fmt_dec_noline:\n    .asciz \"%s%lld.%0*lld\"\ndec_sign_empty:\n    .asciz \"\"\ndec_sign_minus:\n    .asciz \"-\"\n.align 3\n"

asm_data_value_prefix:
    .asciz "print_val_"
asm_data_value_mid:
    .asciz ":\n    .quad "
asm_list_pool_values_label:
    .asciz "list_pool_values:\n"
asm_list_pool_lengths_label:
    .asciz "list_pool_lengths:\n"
asm_list_base_counts_label:
    .asciz "list_base_counts:\n"
asm_map_pool_keys_label:
    .asciz "map_pool_keys:\n"
asm_map_pool_key_lengths_label:
    .asciz "map_pool_key_lengths:\n"
asm_map_pool_values_label:
    .asciz "map_pool_values:\n"
asm_map_pool_lengths_label:
    .asciz "map_pool_lengths:\n"
asm_map_key_prefix:
    .asciz "map_key_"
asm_map_key_suffix:
    .asciz ":\n    .asciz \""
asm_quad_prefix:
    .asciz "    .quad "
asm_data_value_mid_str:
    .asciz ":\n    .asciz \""
asm_data_value_suffix:
    .asciz "\n"
asm_data_value_suffix_str:
    .asciz "\"\n"
asm_align_3:
    .asciz ".align 3\n"
asm_var_slot_prefix:
    .asciz "var_slot_"
asm_store_data_prefix:
    .asciz "store_val_"
asm_label_prefix:
    .asciz "L_snl_"
asm_label_suffix:
    .asciz ":\n"
asm_pageoff_suffix:
    .asciz "@PAGEOFF\n"
asm_branch:
    .asciz "    b "
asm_branch_zero:
    .asciz "    cbz x11, "
asm_branch_nonzero:
    .asciz "    cbnz x11, "
asm_cmp_x11_x10:
    .asciz "    cmp x11, x10\n"
asm_cset_gt:
    .asciz "    cset x11, gt\n"
asm_cset_lt:
    .asciz "    cset x11, lt\n"
asm_cset_ge:
    .asciz "    cset x11, ge\n"
asm_cset_le:
    .asciz "    cset x11, le\n"
asm_cset_eq:
    .asciz "    cset x11, eq\n"
asm_cset_ne:
    .asciz "    cset x11, ne\n"
asm_load_x11_var:
    .asciz "    adrp x11, var_slot_"
asm_load_x10_var:
    .asciz "    adrp x12, var_slot_"
asm_store_x11_var:
    .asciz "    str x11, [x12, var_slot_"
asm_add_x11_imm:
    .asciz "    add x11, x11, #"
asm_sub_x11_imm:
    .asciz "    sub x11, x11, #"
asm_call_write:
#ifdef _WIN32
    .asciz "    bl write\n"
#else
    .asciz "    bl _write\n"
#endif
asm_call_str_concat:
#ifdef _WIN32
    .asciz "    bl str_concat\n"
#else
    .asciz "    bl _str_concat\n"
#endif
asm_call_int_to_cstr:
#ifdef _WIN32
    .asciz "    bl int_to_cstr\n"
#else
    .asciz "    bl _int_to_cstr\n"
#endif
asm_call_cstr_to_int:
#ifdef _WIN32
    .asciz "    bl cstr_to_int\n"
#else
    .asciz "    bl _cstr_to_int\n"
#endif
asm_call_file_read:
#ifdef _WIN32
    .asciz "    bl file_read\n"
#else
    .asciz "    bl _file_read\n"
#endif
asm_call_file_write:
#ifdef _WIN32
    .asciz "    bl file_write\n"
#else
    .asciz "    bl _file_write\n"
#endif
// system(cmd)/exec(cmd): call libc system(3). On POSIX system(3) returns a wait
// status; extract the child's exit code (WEXITSTATUS = (status>>8)&0xff) so the
// result matches the shell's `$?` and stays 0 on success. The `and w0,..` also
// zeroes the upper 32 bits of x0 (needed since w0's high bits are unspecified).
// On Windows system() already returns the plain exit code, so just sign-extend.
asm_call_system:
#ifdef _WIN32
    .asciz "    bl system\n    sxtw x0, w0\n"
#else
    .asciz "    bl _system\n    lsr w0, w0, #8\n    and w0, w0, #0xff\n"
#endif
// argc(): load the saved argument count into x0.
asm_load_argc:
#ifdef _WIN32
    .asciz "    adrp x9, snc_argc\n    add x9, x9, :lo12:snc_argc\n    ldr x0, [x9]\n"
#else
    .asciz "    adrp x9, _snc_argc@PAGE\n    add x9, x9, _snc_argc@PAGEOFF\n    ldr x0, [x9]\n"
#endif
// argv(i): index the saved argv[] (element index preloaded in x11) -> char* in x0.
asm_load_argv_index:
#ifdef _WIN32
    .asciz "    adrp x9, snc_argv\n    add x9, x9, :lo12:snc_argv\n    ldr x9, [x9]\n    ldr x0, [x9, x11, lsl #3]\n"
#else
    .asciz "    adrp x9, _snc_argv@PAGE\n    add x9, x9, _snc_argv@PAGEOFF\n    ldr x9, [x9]\n    ldr x0, [x9, x11, lsl #3]\n"
#endif
// Call the corrected file-write runtime (_snl_file_write) instead of the buggy
// _file_write in the giant helper blob (which opened files with mode `#0644`,
// assembled as DECIMAL 644 -> garbage permissions, e.g. no owner read/write, so
// re-reading a just-written file returned null). See asm_file_write_fixed_runtime.
asm_call_snl_file_write:
#ifdef _WIN32
    .asciz "    bl snl_file_write\n"
#else
    .asciz "    bl _snl_file_write\n"
#endif
// Compute strlen(data) into x2 before calling _file_write, preserving the
// path (x0) and data (x1). The emitted _file_write runtime does
// `_write(fd, data, x2)` but codegen never otherwise loads x2, so without
// this the write length was 0 (empty file). Uses the stack to save x0/x1
// across _cstring_length (which clobbers x0/x1/x9/x30).
.globl asm_file_write_len_prep
asm_file_write_len_prep:
#ifdef _WIN32
    .asciz "    stp x0, x1, [sp, #-16]!\n    mov x0, x1\n    bl cstring_length\n    mov x2, x0\n    ldp x0, x1, [sp], #16\n"
#else
    .asciz "    stp x0, x1, [sp, #-16]!\n    mov x0, x1\n    bl _cstring_length\n    mov x2, x0\n    ldp x0, x1, [sp], #16\n"
#endif
.globl asm_sub_x10_x29_imm
asm_sub_x10_x29_imm:
    .asciz "    sub x10, x29, #"
.globl asm_sub_x28_x29_imm
asm_sub_x28_x29_imm:
    .asciz "    sub x28, x29, #"
.globl asm_ldr_reg_prefix
asm_ldr_reg_prefix:
    .asciz "    ldr x"
.globl asm_str_reg_prefix
asm_str_reg_prefix:
    .asciz "    str x"
.globl asm_reg_x28_mem_suffix
asm_reg_x28_mem_suffix:
    .asciz ", [x28]\n"
.globl asm_ldr_x10_x11
asm_ldr_x10_x11:
    .asciz "    ldr x10, [x11]\n"
.globl asm_ldrb_w10_x11
asm_ldrb_w10_x11:
    .asciz "    ldrb w10, [x11]\n"
.globl asm_str_x10_x11
asm_str_x10_x11:
    .asciz "    str x10, [x11]\n"
.globl asm_strb_w10_x11
asm_strb_w10_x11:
    .asciz "    strb w10, [x11]\n"
.globl asm_store_val_ldr_x10
asm_store_val_ldr_x10:
#ifdef _WIN32
    .asciz "\n    ldr x10, [x9, :lo12:store_val_"
#else
    .asciz "@PAGE\n    ldr x10, [x9, store_val_"
#endif
.globl asm_call_malloc
asm_call_malloc:
#ifdef _WIN32
    .asciz "    bl malloc\n"
#else
    .asciz "    bl _malloc\n"
#endif
.globl asm_call_free
asm_call_free:
#ifdef _WIN32
    .asciz "    bl free\n"
#else
    .asciz "    bl _free\n"
#endif
asm_call_read:
#ifdef _WIN32
    .asciz "    bl read\n"
#else
    .asciz "    bl _read\n"
#endif
asm_input_prompt_prefix:
    .asciz "input_prompt_"
asm_input_buffer_prefix:
    .asciz "input_buf_"
asm_input_prompt_adr:
    .asciz "    adrp x1, input_prompt_"
asm_input_prompt_pageoff:
    .asciz "@PAGE\n    add x1, x1, input_prompt_"
asm_input_buffer_adr:
    .asciz "    adrp x1, input_buf_"
asm_input_buffer_pageoff:
    .asciz "@PAGE\n    add x1, x1, input_buf_"
asm_input_write_fd:
    .asciz "    mov x0, #1\n"
.globl asm_mov_x0_imm_prefix
asm_mov_x0_imm_prefix:
    .asciz "    mov x0, #"
asm_input_read_fd:
    .asciz "    mov x0, #0\n"
asm_input_len_prefix:
    .asciz "    mov x2, #"
asm_input_read_size:
    .asciz "    mov x2, #255\n"
asm_input_strip_prefix:
    .asciz "    mov x9, x0\n    adrp x10, input_buf_"
asm_input_strip_pageoff:
    .asciz "@PAGE\n    add x10, x10, input_buf_"
asm_input_b_le_store:
    .asciz "    cmp x9, #0\n    b.le L_input_store_"
asm_input_b_ne_null:
    .asciz "    sub x11, x9, #1\n    ldrb w12, [x10, x11]\n    cmp w12, #10\n    b.ne L_input_null_"
asm_input_b_store:
    .asciz "    strb wzr, [x10, x11]\n    b L_input_store_"
asm_input_null_label_prefix:
    .asciz "L_input_null_"
asm_input_store_label_prefix:
    .asciz "L_input_store_"
asm_input_null_body:
    .asciz "    add x11, x10, x9\n    strb wzr, [x11]\n"
asm_input_store_x10_str:
    .asciz "    stur x10, [x29, #-"
asm_input_store_x0_str:
    .asciz "    stur x0, [x29, #-"
asm_call_cstring_length:
#ifdef _WIN32
    .asciz "    bl cstring_length\n"
#else
    .asciz "    bl _cstring_length\n"
#endif
asm_mov_x4_x0:
    .asciz "    mov x4, x0\n"
asm_mov_x0_x10:
    .asciz "    mov x0, x10\n"
asm_mov_x0_imm:
    .asciz "    mov x0, #"
asm_mov_x1_imm:
    .asciz "    mov x1, #"
asm_mov_x2_imm:
    .asciz "    mov x2, #"
asm_mov_x4_imm:
    .asciz "    mov x4, #"
asm_call_map_lookup:
    .asciz "    bl _map_lookup_ext\n"

asm_call_string_slice:
    .asciz "    bl _string_slice\n"

asm_call_str_contains:
    .asciz "    bl _str_contains\n"

asm_call_str_replace:
    .asciz "    bl _str_replace\n"

asm_call_str_split:
    .asciz "    bl _str_split\n"

asm_call_str_upper:
    .asciz "    bl _str_upper\n"

asm_call_str_lower:
    .asciz "    bl _str_lower\n"

asm_call_str_char_at:
    .asciz "    bl _str_char_at\n"

// ord(s): x0 = string pointer on entry -> x0 = ASCII code of first byte, or 0
// for a NULL/empty string. Uses reusable numeric local labels (1:/2:) so this
// snippet can be emitted at every ord() call site without duplicate-label
// errors. No external symbols, so it is identical on macOS and Windows.
asm_ord_first_byte:
    .asciz "    cbz x0, 1f\n    ldrb w0, [x0]\n    b 2f\n1:\n    mov x0, #0\n2:\n"

asm_call_str_startswith:
    .asciz "    bl _str_startswith\n"

asm_call_str_endswith:
    .asciz "    bl _str_endswith\n"

asm_call_str_indexof:
    .asciz "    bl _str_indexof\n"

asm_call_str_trim:
    .asciz "    bl _str_trim\n"

asm_string_scan_runtime:
    .asciz "\n.align 4\n.global _str_startswith\n_str_startswith:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    mov x19, x0\n    mov x20, x1\n    cbz x19, Lssw_false\n    cbz x20, Lssw_true\n    mov x9, #0\nLssw_loop:\n    ldrb w10, [x20, x9]\n    cbz w10, Lssw_true\n    ldrb w11, [x19, x9]\n    cbz w11, Lssw_false\n    cmp w10, w11\n    b.ne Lssw_false\n    add x9, x9, #1\n    b Lssw_loop\nLssw_true:\n    mov x0, #1\n    b Lssw_ret\nLssw_false:\n    mov x0, #0\nLssw_ret:\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n.align 4\n.global _str_endswith\n_str_endswith:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    stp x21, x22, [sp, #-16]!\n    mov x19, x0\n    mov x20, x1\n    cbz x19, Lesw_false\n    cbz x20, Lesw_true\n    mov x0, x19\n    bl _cstring_length\n    mov x21, x0\n    mov x0, x20\n    bl _cstring_length\n    mov x22, x0\n    cmp x22, x21\n    b.gt Lesw_false\n    sub x9, x21, x22\n    mov x10, #0\nLesw_loop:\n    cmp x10, x22\n    b.ge Lesw_true\n    add x11, x19, x9\n    ldrb w12, [x11, x10]\n    ldrb w13, [x20, x10]\n    cmp w12, w13\n    b.ne Lesw_false\n    add x10, x10, #1\n    b Lesw_loop\nLesw_true:\n    mov x0, #1\n    b Lesw_ret\nLesw_false:\n    mov x0, #0\nLesw_ret:\n    ldp x21, x22, [sp], #16\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n.align 4\n.global _str_indexof\n_str_indexof:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    stp x21, x22, [sp, #-16]!\n    stp x23, x24, [sp, #-16]!\n    mov x19, x0\n    mov x20, x1\n    cbz x19, Lsio_notfound\n    cbz x20, Lsio_zero\n    mov x0, x19\n    bl _cstring_length\n    mov x21, x0\n    mov x0, x20\n    bl _cstring_length\n    mov x22, x0\n    cbz x22, Lsio_zero\n    cmp x22, x21\n    b.gt Lsio_notfound\n    sub x23, x21, x22\n    mov x24, #0\nLsio_outer:\n    cmp x24, x23\n    b.gt Lsio_notfound\n    mov x9, #0\nLsio_inner:\n    cmp x9, x22\n    b.ge Lsio_found\n    add x10, x19, x24\n    ldrb w11, [x10, x9]\n    ldrb w12, [x20, x9]\n    cmp w11, w12\n    b.ne Lsio_next\n    add x9, x9, #1\n    b Lsio_inner\nLsio_next:\n    add x24, x24, #1\n    b Lsio_outer\nLsio_found:\n    mov x0, x24\n    b Lsio_ret\nLsio_zero:\n    mov x0, #0\n    b Lsio_ret\nLsio_notfound:\n    mov x0, #-1\nLsio_ret:\n    ldp x23, x24, [sp], #16\n    ldp x21, x22, [sp], #16\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n"
asm_string_trim_runtime:
    .asciz "\n.align 4\n.global _str_trim\n_str_trim:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    stp x21, x22, [sp, #-16]!\n    stp x23, x24, [sp, #-16]!\n    mov x19, x0\n    cbz x19, Ltrim_empty\n    mov x0, x19\n    bl _cstring_length\n    mov x20, x0\n    mov x21, #0\nLtrim_lead:\n    cmp x21, x20\n    b.ge Ltrim_empty\n    ldrb w9, [x19, x21]\n    cmp w9, #32\n    b.eq Ltrim_lead_adv\n    cmp w9, #9\n    b.eq Ltrim_lead_adv\n    cmp w9, #10\n    b.eq Ltrim_lead_adv\n    cmp w9, #13\n    b.eq Ltrim_lead_adv\n    b Ltrim_lead_done\nLtrim_lead_adv:\n    add x21, x21, #1\n    b Ltrim_lead\nLtrim_lead_done:\n    mov x22, x20\nLtrim_trail:\n    cmp x22, x21\n    b.le Ltrim_trail_done\n    sub x9, x22, #1\n    ldrb w10, [x19, x9]\n    cmp w10, #32\n    b.eq Ltrim_trail_dec\n    cmp w10, #9\n    b.eq Ltrim_trail_dec\n    cmp w10, #10\n    b.eq Ltrim_trail_dec\n    cmp w10, #13\n    b.eq Ltrim_trail_dec\n    b Ltrim_trail_done\nLtrim_trail_dec:\n    sub x22, x22, #1\n    b Ltrim_trail\nLtrim_trail_done:\n    sub x23, x22, x21\n    cmp x23, #0\n    b.le Ltrim_empty\n    add x0, x23, #1\n    bl _snc_managed_alloc\n    cbz x0, Ltrim_ret\n    mov x24, x0\n    mov x9, #0\nLtrim_copy:\n    cmp x9, x23\n    b.ge Ltrim_copy_done\n    add x10, x19, x21\n    ldrb w11, [x10, x9]\n    strb w11, [x24, x9]\n    add x9, x9, #1\n    b Ltrim_copy\nLtrim_copy_done:\n    strb wzr, [x24, x23]\n    mov x0, x24\n    b Ltrim_ret\nLtrim_empty:\n    mov x0, #1\n    bl _snc_managed_alloc\n    cbz x0, Ltrim_ret\n    strb wzr, [x0]\nLtrim_ret:\n    ldp x23, x24, [sp], #16\n    ldp x21, x22, [sp], #16\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n"
asm_string_slice_runtime:
    .asciz "\n.align 4\n.global _string_slice\n_string_slice:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    stp x21, x22, [sp, #-16]!\n    stp x23, x24, [sp, #-16]!\n    mov x19, x0\n    mov x20, x1\n    mov x21, x2\n    cbz x19, Lslice_empty\n    cmp x20, #0\n    b.ge Lslice_start_ok\n    mov x20, #0\nLslice_start_ok:\n    mov x0, x19\n    bl _cstring_length\n    mov x24, x0\n    cmp x20, x24\n    b.ge Lslice_empty\n    cmp x21, x20\n    b.ge Lslice_end_order_ok\n    b Lslice_empty\nLslice_end_order_ok:\n    cmp x21, x24\n    b.le Lslice_end_clamped\n    mov x21, x24\nLslice_end_clamped:\n    sub x22, x21, x20\n    cmp x22, #0\n    b.le Lslice_empty\n    add x0, x22, #1\n    bl _snc_managed_alloc\n    cbz x0, Lslice_ret\n    mov x23, x0\n    mov x24, #0\nLslice_copy:\n    cmp x24, x22\n    b.ge Lslice_done\n    add x9, x19, x20\n    ldrb w10, [x9, x24]\n    strb w10, [x23, x24]\n    add x24, x24, #1\n    b Lslice_copy\nLslice_done:\n    strb wzr, [x23, x22]\n    mov x0, x23\n    b Lslice_ret\nLslice_empty:\n    mov x0, #1\n    bl _snc_managed_alloc\n    cbz x0, Lslice_ret\n    strb wzr, [x0]\nLslice_ret:\n    ldp x23, x24, [sp], #16\n    ldp x21, x22, [sp], #16\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n"
asm_string_methods_runtime:
    .asciz "\n.align 4\n.global _str_upper\n_str_upper:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    stp x21, x22, [sp, #-16]!\n    mov x19, x0\n    cbz x19, Lsm_up_empty\n    mov x0, x19\n    bl _cstring_length\n    mov x20, x0\n    add x0, x20, #1\n    bl _snc_managed_alloc\n    cbz x0, Lsm_up_ret\n    mov x21, x0\n    mov x22, #0\nLsm_up_loop:\n    cmp x22, x20\n    b.ge Lsm_up_done\n    ldrb w9, [x19, x22]\n    cmp w9, #97\n    b.lt Lsm_up_store\n    cmp w9, #122\n    b.gt Lsm_up_store\n    sub w9, w9, #32\nLsm_up_store:\n    strb w9, [x21, x22]\n    add x22, x22, #1\n    b Lsm_up_loop\nLsm_up_done:\n    strb wzr, [x21, x20]\n    mov x0, x21\n    b Lsm_up_ret\nLsm_up_empty:\n    mov x0, #1\n    bl _snc_managed_alloc\n    cbz x0, Lsm_up_ret\n    strb wzr, [x0]\nLsm_up_ret:\n    ldp x21, x22, [sp], #16\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n\n.align 4\n.global _str_lower\n_str_lower:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    stp x21, x22, [sp, #-16]!\n    mov x19, x0\n    cbz x19, Lsm_lo_empty\n    mov x0, x19\n    bl _cstring_length\n    mov x20, x0\n    add x0, x20, #1\n    bl _snc_managed_alloc\n    cbz x0, Lsm_lo_ret\n    mov x21, x0\n    mov x22, #0\nLsm_lo_loop:\n    cmp x22, x20\n    b.ge Lsm_lo_done\n    ldrb w9, [x19, x22]\n    cmp w9, #65\n    b.lt Lsm_lo_store\n    cmp w9, #90\n    b.gt Lsm_lo_store\n    add w9, w9, #32\nLsm_lo_store:\n    strb w9, [x21, x22]\n    add x22, x22, #1\n    b Lsm_lo_loop\nLsm_lo_done:\n    strb wzr, [x21, x20]\n    mov x0, x21\n    b Lsm_lo_ret\nLsm_lo_empty:\n    mov x0, #1\n    bl _snc_managed_alloc\n    cbz x0, Lsm_lo_ret\n    strb wzr, [x0]\nLsm_lo_ret:\n    ldp x21, x22, [sp], #16\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n\n.align 4\n.global _str_contains\n_str_contains:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    stp x21, x22, [sp, #-16]!\n    stp x23, x24, [sp, #-16]!\n    mov x19, x0\n    mov x20, x1\n    cbz x19, Lsm_co_no\n    cbz x20, Lsm_co_yes\n    mov x0, x19\n    bl _cstring_length\n    mov x21, x0\n    mov x0, x20\n    bl _cstring_length\n    mov x22, x0\n    cbz x22, Lsm_co_yes\n    cmp x22, x21\n    b.gt Lsm_co_no\n    mov x23, #0\nLsm_co_outer:\n    sub x9, x21, x22\n    cmp x23, x9\n    b.gt Lsm_co_no\n    mov x24, #0\nLsm_co_inner:\n    cmp x24, x22\n    b.ge Lsm_co_yes\n    add x9, x23, x24\n    ldrb w10, [x19, x9]\n    ldrb w11, [x20, x24]\n    cmp w10, w11\n    b.ne Lsm_co_next\n    add x24, x24, #1\n    b Lsm_co_inner\nLsm_co_next:\n    add x23, x23, #1\n    b Lsm_co_outer\nLsm_co_yes:\n    mov x0, #1\n    b Lsm_co_ret\nLsm_co_no:\n    mov x0, #0\nLsm_co_ret:\n    ldp x23, x24, [sp], #16\n    ldp x21, x22, [sp], #16\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n"
asm_string_char_at_runtime:
    .asciz "\n.align 4\n.global _str_char_at\n_str_char_at:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    mov x19, x0\n    mov x20, x1\n    cbz x19, Lsca_empty\n    cmp x20, #0\n    b.lt Lsca_empty\n    mov x0, x19\n    bl _cstring_length\n    cmp x20, x0\n    b.ge Lsca_empty\n    mov x0, #2\n    bl _snc_managed_alloc\n    cbz x0, Lsca_ret\n    ldrb w9, [x19, x20]\n    strb w9, [x0]\n    strb wzr, [x0, #1]\n    b Lsca_ret\nLsca_empty:\n    mov x0, #1\n    bl _snc_managed_alloc\n    cbz x0, Lsca_ret\n    strb wzr, [x0]\nLsca_ret:\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n"
asm_string_replace_runtime:
    .asciz "\n.align 4\n.global _str_replace\n_str_replace:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    stp x21, x22, [sp, #-16]!\n    stp x23, x24, [sp, #-16]!\n    stp x25, x26, [sp, #-16]!\n    stp x27, x28, [sp, #-16]!\n    mov x19, x0\n    mov x20, x1\n    mov x21, x2\n    cbz x19, Lsr_empty\n    mov x0, x19\n    bl _cstring_length\n    mov x22, x0\n    cbz x20, Lsr_copy\n    mov x0, x20\n    bl _cstring_length\n    mov x23, x0\n    cbz x23, Lsr_copy\n    mov x24, #0\n    cbz x21, Lsr_new_done\n    mov x0, x21\n    bl _cstring_length\n    mov x24, x0\nLsr_new_done:\n    mov x25, #0\n    mov x26, #0\nLsr_count_loop:\n    add x9, x26, x23\n    cmp x9, x22\n    b.gt Lsr_count_done\n    mov x10, #0\nLsr_count_cmp:\n    cmp x10, x23\n    b.ge Lsr_count_match\n    add x11, x19, x26\n    ldrb w12, [x11, x10]\n    ldrb w13, [x20, x10]\n    cmp w12, w13\n    b.ne Lsr_count_nomatch\n    add x10, x10, #1\n    b Lsr_count_cmp\nLsr_count_match:\n    add x25, x25, #1\n    add x26, x26, x23\n    b Lsr_count_loop\nLsr_count_nomatch:\n    add x26, x26, #1\n    b Lsr_count_loop\nLsr_count_done:\n    sub x9, x24, x23\n    mul x9, x9, x25\n    add x9, x22, x9\n    add x0, x9, #1\n    bl _snc_managed_alloc\n    cbz x0, Lsr_ret\n    mov x27, x0\n    mov x26, #0\n    mov x28, #0\nLsr_build_loop:\n    cmp x26, x22\n    b.ge Lsr_build_done\n    add x9, x26, x23\n    cmp x9, x22\n    b.gt Lsr_build_copychar\n    mov x10, #0\nLsr_build_cmp:\n    cmp x10, x23\n    b.ge Lsr_build_domatch\n    add x11, x19, x26\n    ldrb w12, [x11, x10]\n    ldrb w13, [x20, x10]\n    cmp w12, w13\n    b.ne Lsr_build_copychar\n    add x10, x10, #1\n    b Lsr_build_cmp\nLsr_build_domatch:\n    mov x10, #0\nLsr_build_copynew:\n    cmp x10, x24\n    b.ge Lsr_build_newdone\n    ldrb w12, [x21, x10]\n    add x11, x27, x28\n    strb w12, [x11]\n    add x28, x28, #1\n    add x10, x10, #1\n    b Lsr_build_copynew\nLsr_build_newdone:\n    add x26, x26, x23\n    b Lsr_build_loop\nLsr_build_copychar:\n    add x11, x19, x26\n    ldrb w12, [x11]\n    add x11, x27, x28\n    strb w12, [x11]\n    add x28, x28, #1\n    add x26, x26, #1\n    b Lsr_build_loop\nLsr_build_done:\n    add x11, x27, x28\n    strb wzr, [x11]\n    mov x0, x27\n    b Lsr_ret\nLsr_copy:\n    add x0, x22, #1\n    bl _snc_managed_alloc\n    cbz x0, Lsr_ret\n    mov x27, x0\n    mov x26, #0\nLsr_copy_loop:\n    cmp x26, x22\n    b.ge Lsr_copy_done\n    ldrb w12, [x19, x26]\n    strb w12, [x27, x26]\n    add x26, x26, #1\n    b Lsr_copy_loop\nLsr_copy_done:\n    strb wzr, [x27, x22]\n    mov x0, x27\n    b Lsr_ret\nLsr_empty:\n    mov x0, #1\n    bl _snc_managed_alloc\n    cbz x0, Lsr_ret\n    strb wzr, [x0]\nLsr_ret:\n    ldp x27, x28, [sp], #16\n    ldp x25, x26, [sp], #16\n    ldp x23, x24, [sp], #16\n    ldp x21, x22, [sp], #16\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n"
asm_string_split_runtime:
    .asciz "\n.align 4\n.global _str_split\n_str_split:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    stp x21, x22, [sp, #-16]!\n    stp x23, x24, [sp, #-16]!\n    stp x25, x26, [sp, #-16]!\n    stp x27, x28, [sp, #-16]!\n    mov x19, x0\n    mov x20, x1\n    mov x21, x2\n    adrp x24, list_pool_values@PAGE\n    add x24, x24, list_pool_values@PAGEOFF\n    add x24, x24, x21, lsl #3\n    mov x23, #0\n    cbz x19, Lsplit_finish\n    cbz x20, Lsplit_whole\n    mov x0, x20\n    bl _cstring_length\n    mov x22, x0\n    cbz x22, Lsplit_whole\n    mov x25, x19\n    mov x26, x19\nLsplit_scan:\n    ldrb w9, [x25]\n    cbz w9, Lsplit_last\n    mov x10, #0\nLsplit_match:\n    cmp x10, x22\n    b.ge Lsplit_hit\n    ldrb w11, [x25, x10]\n    cbz w11, Lsplit_nomatch\n    ldrb w12, [x20, x10]\n    cmp w11, w12\n    b.ne Lsplit_nomatch\n    add x10, x10, #1\n    b Lsplit_match\nLsplit_hit:\n    sub x0, x25, x26\n    mov x1, x26\n    bl Lsplit_push\n    add x25, x25, x22\n    mov x26, x25\n    b Lsplit_scan\nLsplit_nomatch:\n    add x25, x25, #1\n    b Lsplit_scan\nLsplit_last:\n    sub x0, x25, x26\n    mov x1, x26\n    bl Lsplit_push\n    b Lsplit_finish\nLsplit_whole:\n    mov x0, x19\n    bl _cstring_length\n    mov x1, x19\n    bl Lsplit_push\n    b Lsplit_finish\nLsplit_finish:\n    adrp x9, list_base_counts@PAGE\n    add x9, x9, list_base_counts@PAGEOFF\n    str x23, [x9, x21, lsl #3]\n    ldp x27, x28, [sp], #16\n    ldp x25, x26, [sp], #16\n    ldp x23, x24, [sp], #16\n    ldp x21, x22, [sp], #16\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\nLsplit_push:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    cmp x23, #64\n    b.ge Lsplit_push_ret\n    mov x27, x0\n    mov x28, x1\n    add x0, x0, #1\n    bl _snc_managed_alloc\n    cbz x0, Lsplit_push_ret\n    mov x9, #0\nLsplit_push_copy:\n    cmp x9, x27\n    b.ge Lsplit_push_term\n    ldrb w10, [x28, x9]\n    strb w10, [x0, x9]\n    add x9, x9, #1\n    b Lsplit_push_copy\nLsplit_push_term:\n    strb wzr, [x0, x27]\n    str x0, [x24, x23, lsl #3]\n    add x23, x23, #1\nLsplit_push_ret:\n    ldp x29, x30, [sp], #16\n    ret\n"
asm_map_dynamic_runtime:
    .asciz "\n.bss\n.align 3\ndyn_map_count:\n    .quad 0\ndyn_map_base:\n    .space 8192\ndyn_map_key:\n    .space 8192\ndyn_map_key_len:\n    .space 8192\ndyn_map_key_type:\n    .space 8192\ndyn_map_val:\n    .space 8192\ndyn_map_val_len:\n    .space 8192\ndyn_map_val_type:\n    .space 8192\n\n.text\n.align 4\n.global _map_lookup_ext\n_map_lookup_ext:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    stp x21, x22, [sp, #-16]!\n    stp x23, x24, [sp, #-16]!\n    stp x25, x26, [sp, #-16]!\n    stp x27, x28, [sp, #-16]!\n    mov x19, x0\n    mov x20, x1\n    mov x21, x2\n    mov x22, x3\n    mov x23, x4\n    adrp x24, dyn_map_count@PAGE\n    add x24, x24, dyn_map_count@PAGEOFF\n    ldr x25, [x24]\n    mov x26, #0\nL_dyn_lookup_loop:\n    cmp x26, x25\n    b.ge L_dyn_lookup_miss\n    adrp x24, dyn_map_base@PAGE\n    add x24, x24, dyn_map_base@PAGEOFF\n    ldr x27, [x24, x26, lsl #3]\n    cmp x27, x19\n    b.ne L_dyn_lookup_next\n    adrp x24, dyn_map_key_type@PAGE\n    add x24, x24, dyn_map_key_type@PAGEOFF\n    ldr x27, [x24, x26, lsl #3]\n    cmp x27, x22\n    b.ne L_dyn_lookup_next\n    cmp x22, #2\n    b.eq L_dyn_lookup_cmp_str\n    adrp x24, dyn_map_key@PAGE\n    add x24, x24, dyn_map_key@PAGEOFF\n    ldr x27, [x24, x26, lsl #3]\n    cmp x27, x21\n    b.eq L_dyn_lookup_found\n    b L_dyn_lookup_next\nL_dyn_lookup_cmp_str:\n    adrp x24, dyn_map_key_len@PAGE\n    add x24, x24, dyn_map_key_len@PAGEOFF\n    ldr x27, [x24, x26, lsl #3]\n    cmp x27, x23\n    b.ne L_dyn_lookup_next\n    adrp x24, dyn_map_key@PAGE\n    add x24, x24, dyn_map_key@PAGEOFF\n    ldr x0, [x24, x26, lsl #3]\n    mov x1, x27\n    mov x2, x21\n    bl _runtime_match_span_span\n    cbz x0, L_dyn_lookup_next\nL_dyn_lookup_found:\n    adrp x24, dyn_map_val@PAGE\n    add x24, x24, dyn_map_val@PAGEOFF\n    ldr x0, [x24, x26, lsl #3]\n    adrp x24, dyn_map_val_len@PAGE\n    add x24, x24, dyn_map_val_len@PAGEOFF\n    ldr x1, [x24, x26, lsl #3]\n    mov x2, #1\n    b L_dyn_lookup_ret\nL_dyn_lookup_next:\n    add x26, x26, #1\n    b L_dyn_lookup_loop\nL_dyn_lookup_miss:\n    mov x0, x19\n    mov x1, x20\n    mov x2, x21\n    mov x3, x22\n    mov x4, x23\n    bl _map_lookup\nL_dyn_lookup_ret:\n    ldp x27, x28, [sp], #16\n    ldp x25, x26, [sp], #16\n    ldp x23, x24, [sp], #16\n    ldp x21, x22, [sp], #16\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n\n.align 4\n.global _map_store\n_map_store:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    stp x21, x22, [sp, #-16]!\n    stp x23, x24, [sp, #-16]!\n    stp x25, x26, [sp, #-16]!\n    stp x27, x28, [sp, #-16]!\n    mov x19, x0\n    mov x20, x1\n    mov x21, x2\n    mov x22, x3\n    mov x23, x4\n    mov x24, x5\n    mov x25, x6\n    adrp x26, dyn_map_count@PAGE\n    add x26, x26, dyn_map_count@PAGEOFF\n    ldr x27, [x26]\n    mov x28, #0\nL_dyn_store_find:\n    cmp x28, x27\n    b.ge L_dyn_store_append\n    adrp x9, dyn_map_base@PAGE\n    add x9, x9, dyn_map_base@PAGEOFF\n    ldr x10, [x9, x28, lsl #3]\n    cmp x10, x19\n    b.ne L_dyn_store_next\n    adrp x9, dyn_map_key_type@PAGE\n    add x9, x9, dyn_map_key_type@PAGEOFF\n    ldr x10, [x9, x28, lsl #3]\n    cmp x10, x21\n    b.ne L_dyn_store_next\n    cmp x21, #2\n    b.eq L_dyn_store_cmp_str\n    adrp x9, dyn_map_key@PAGE\n    add x9, x9, dyn_map_key@PAGEOFF\n    ldr x10, [x9, x28, lsl #3]\n    cmp x10, x20\n    b.eq L_dyn_store_write\n    b L_dyn_store_next\nL_dyn_store_cmp_str:\n    adrp x9, dyn_map_key_len@PAGE\n    add x9, x9, dyn_map_key_len@PAGEOFF\n    ldr x10, [x9, x28, lsl #3]\n    cmp x10, x22\n    b.ne L_dyn_store_next\n    adrp x9, dyn_map_key@PAGE\n    add x9, x9, dyn_map_key@PAGEOFF\n    ldr x0, [x9, x28, lsl #3]\n    mov x1, x10\n    mov x2, x20\n    bl _runtime_match_span_span\n    cbnz x0, L_dyn_store_write\nL_dyn_store_next:\n    add x28, x28, #1\n    b L_dyn_store_find\nL_dyn_store_append:\n    cmp x27, #1024\n    b.ge L_dyn_store_ret\n    mov x28, x27\n    add x27, x27, #1\n    str x27, [x26]\n    adrp x9, dyn_map_base@PAGE\n    add x9, x9, dyn_map_base@PAGEOFF\n    str x19, [x9, x28, lsl #3]\n    adrp x9, dyn_map_key@PAGE\n    add x9, x9, dyn_map_key@PAGEOFF\n    str x20, [x9, x28, lsl #3]\n    adrp x9, dyn_map_key_len@PAGE\n    add x9, x9, dyn_map_key_len@PAGEOFF\n    str x22, [x9, x28, lsl #3]\n    adrp x9, dyn_map_key_type@PAGE\n    add x9, x9, dyn_map_key_type@PAGEOFF\n    str x21, [x9, x28, lsl #3]\nL_dyn_store_write:\n    adrp x9, dyn_map_val@PAGE\n    add x9, x9, dyn_map_val@PAGEOFF\n    str x23, [x9, x28, lsl #3]\n    adrp x9, dyn_map_val_len@PAGE\n    add x9, x9, dyn_map_val_len@PAGEOFF\n    str x25, [x9, x28, lsl #3]\n    adrp x9, dyn_map_val_type@PAGE\n    add x9, x9, dyn_map_val_type@PAGEOFF\n    str x24, [x9, x28, lsl #3]\nL_dyn_store_ret:\n    ldp x27, x28, [sp], #16\n    ldp x25, x26, [sp], #16\n    ldp x23, x24, [sp], #16\n    ldp x21, x22, [sp], #16\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n"
asm_mov_x4_x10:
    .asciz "    mov x4, x10\n"
asm_mov_x0_x1:
    .asciz "    mov x0, x1\n"
asm_mov_x0_x4:
    .asciz "    mov x0, x4\n"
asm_mov_x2_x10:
    .asciz "    mov x2, x10\n"
asm_mov_x11_x2:
    .asciz "    mov x11, x2\n"
asm_mov_x10_imm:
    .asciz "    mov x10, #"
asm_mov_x3_imm:
    .asciz "    mov x3, #"
asm_mov_x3_x0:
    .asciz "    mov x3, x0\n"
asm_mov_x5_imm:
    .asciz "    mov x5, #"
asm_mov_x6_imm:
    .asciz "    mov x6, #"
asm_mov_x6_x0:
    .asciz "    mov x6, x0\n"
asm_load_x4_var:
    .asciz "    ldur x4, [x29, #-"
asm_load_x4_print_val_prefix:
    .asciz "    adrp x4, print_val_"
asm_load_x4_print_val_middle:
    .asciz "@PAGE\n    add x4, x4, print_val_"
asm_load_x4_print_val_suffix:
    .asciz "@PAGEOFF\n"
asm_call_map_store:
    .asciz "    bl _map_store\n"
asm_newline:
    .asciz "\n"
asm_load_list_pool_x11:
    .asciz "    adrp x11, list_pool_values@PAGE\n    add x11, x11, list_pool_values@PAGEOFF\n"
asm_load_map_pool_x11:
    .asciz "    adrp x11, map_pool_values@PAGE\n    add x11, x11, map_pool_values@PAGEOFF\n"
asm_add_x10_imm:
    .asciz "    add x10, x10, #"
.global asm_add_x10_1
asm_add_x10_1:
    .asciz "    add x10, x10, #1\n"
asm_add_x10_x12:
    .asciz "    add x10, x10, x12\n"
asm_load_pool_val_x10:
    .asciz "    ldr x10, [x11, x10, lsl #3]\n"
asm_load_pool_len_x10:
    .asciz "    ldr x10, [x11, x10, lsl #3]\n"
asm_store_pool_val_x12:
    .asciz "    str x12, [x11, x10, lsl #3]\n"
asm_store_pool_len_x12:
    .asciz "    str x12, [x11, x10, lsl #3]\n"
asm_mov_x12_x10:
    .asciz "    mov x12, x10\n"
asm_mov_x10_x12:
    .asciz "    mov x10, x12\n"
asm_load_pool_val_x10_from_x12:
    .asciz "    ldr x10, [x11, x12, lsl #3]\n"
asm_load_list_pool_lens_x11:
    .asciz "    adrp x11, list_pool_lengths@PAGE\n    add x11, x11, list_pool_lengths@PAGEOFF\n"
asm_load_list_base_counts_x11:
    .asciz "    adrp x11, list_base_counts@PAGE\n    add x11, x11, list_base_counts@PAGEOFF\n"
asm_load_map_pool_lens_x11:
    .asciz "    adrp x11, map_pool_lengths@PAGE\n    add x11, x11, map_pool_lengths@PAGEOFF\n"
asm_input_buffer_space:
    .asciz ":\n    .space 256\n"

// Error handling assembly strings
#ifdef _WIN32
asm_adrp_error_flag:
    .asciz "    adrp x11, error_flag\n    add x11, x11, :lo12:error_flag\n"
asm_ldr_x11_error_flag:
    .asciz "    ldr x11, [x11]\n"
asm_str_x1_error_flag:
    .asciz "    str x1, [x11]\n"
asm_str_xzr_error_flag:
    .asciz "    str xzr, [x11]\n"
asm_adrp_error_value:
    .asciz "    adrp x12, error_value\n    add x12, x12, :lo12:error_value\n"
asm_str_x0_error_value:
    .asciz "    str x0, [x12]\n"
#else
asm_adrp_error_flag:
    .asciz "    adrp x11, error_flag@PAGE\n    add x11, x11, error_flag@PAGEOFF\n"
asm_ldr_x11_error_flag:
    .asciz "    ldr x11, [x11]\n"
asm_str_x1_error_flag:
    .asciz "    str x1, [x11]\n"
asm_str_xzr_error_flag:
    .asciz "    str xzr, [x11]\n"
asm_adrp_error_value:
    .asciz "    adrp x12, error_value@PAGE\n    add x12, x12, error_value@PAGEOFF\n"
asm_str_x0_error_value:
    .asciz "    str x0, [x12]\n"
#endif
asm_cmp_x11_imm_0:
    .asciz "    cmp x11, #0\n"
.global asm_ldr_x0_error_value
asm_ldr_x0_error_value:
    .asciz "    ldr x0, [x12]\n"
asm_beq_label:
    .asciz "    b.ne L_snl_"
.global asm_bne_prefix
asm_bne_prefix:
    .asciz "    b.ne "
asm_b_suffix:
    .asciz "    b L_snl_"
asm_mov_x1_imm_1:
    .asciz "    mov x1, #1\n"
asm_exit_1:
#ifdef _WIN32
    .asciz "    bl snc_memory_cleanup\n    mov x0, #1\n    bl exit\n"
#else
    .asciz "    bl _snc_memory_cleanup\n    mov x0, #1\n    bl _exit\n"
#endif
asm_error_flag_label:
    .asciz "error_flag:\n"
asm_error_value_label:
    .asciz "error_value:\n"
asm_quad_0:
    .asciz "    .quad 0\n"

newline_char:      .byte 10
zero_qword:        .quad 0
single_char:       .byte 0
close_brace_char:  .byte 125
.align 3
label_counter:     .quad 1
current_label_id:  .quad 1
compilation_mode:  .quad 1
.global src_buffer_cap
src_buffer_cap: .quad 0   // source buffer content-byte capacity (0 until first alloc); SNC_SRC_BYTES is the initial size (see _snc_grow_src)

.bss
.align 4
buffer:         .space 8       // POINTER to the malloc-backed, growable source input buffer (see _snc_grow_src); reads no longer truncate at a fixed size
number_buffer:  .space 32
// Persistent bump-arena for compile-time-generated string literals (currently
// str(list) formatting). _record_data_value stores the byte pointer without
// copying, so each generated string needs storage that outlives parsing; the
// scratch number_buffer cannot be reused. list_str_arena_pos is the next free
// offset. 64KB holds many formatted lists.
.global list_str_arena
.global list_str_arena_pos
list_str_arena_pos: .space 8
list_str_arena: .space 65536
source_ptr:     .space 8
source_len:     .space 8
cursor_pos:     .space 8
current_line:   .space 8
.global stmt_target_name
.global stmt_target_len
var_count:      .space 8
stmt_target_name: .quad 0
stmt_target_len: .quad 0
print_count:    .space 8
print_noline_flag: .space 8
op_count:       .space 8
error_flag:     .space 8        // 0 = no error, 1 = error occurred
error_value:    .space 8        // pointer to error message string
.global global_op_count
global_op_count: .space 8
.global compiler_alloc_head
compiler_alloc_head: .space 8
current_loop_start: .space 8
current_loop_end: .space 8
loop_context_depth: .space 8
// Innermost active block try's catch-label id (0 = not inside a try body).
// Used by `throw` to branch to the enclosing catch instead of exiting.
current_catch_label: .space 8
// Variable tables: now malloc-backed and GROWABLE (see _snc_grow_vars in
// vars.s). Each symbol holds a POINTER to a heap buffer (0 until the first
// allocation), NOT the storage itself, so the compiler's variable table can
// grow past the old fixed SNC_MAX_VARS cap by realloc instead of hard-failing
// with "too many variables". SNC_MAX_VARS is now merely the INITIAL capacity.
// All six arrays grow together and are 8 bytes/entry. Access sites use the
// LOAD_TBL macro (LOAD_ADDR + deref) so they always see the current buffer.
var_name_ptrs:  .quad 0
var_name_lens:  .quad 0
var_values:     .quad 0
var_lengths:    .quad 0
var_const_flags: .quad 0
var_types:       .quad 0
var_capacity:   .quad 0   // current allocated capacity (in entries) of the var tables
list_pool_count: .space 8
// List element pools: now malloc-backed and GROWABLE (see _snc_grow_list_pool
// in vars.s). Each symbol below holds a POINTER to a heap buffer (0 until the
// first allocation), NOT the storage itself, so the compile-time runtime-data
// pool can grow past the old fixed SNC_MAX_LIST_ELEMS cap via realloc instead of
// hard-failing. The grow routine ZEROES newly-added entries because codegen
// relies on these pools being zero-initialized (reserved-but-unfilled split
// slots, non-base count slots, and the default "not runtime" flag). SNC_MAX_LIST_ELEMS
// is now merely the INITIAL capacity. Access sites use the LOAD_TBL macro
// (LOAD_ADDR + deref) so they always see the current (possibly moved) buffer.
// list_pool_values/list_pool_lengths/list_base_counts are 8 bytes/entry.
list_pool_values: .quad 0
list_pool_lengths: .quad 0
list_base_counts: .quad 0     // per-base element count (runtime .length())
// 1 byte per pool base: 1 => the list at this base has a RUNTIME element count
// (its contents are filled at run time, e.g. by str.split), so .length()/for-in
// must read list_base_counts[base] at run time instead of folding a compile-time
// count. 0 => an ordinary compile-time list literal.
list_base_is_runtime: .quad 0
list_pool_capacity: .quad 0   // current allocated capacity (in entries) of the list pools
// Map element pools: malloc-backed and GROWABLE (see _snc_grow_map_pool in
// vars.s). Each symbol holds a POINTER to a heap buffer (0 until first alloc),
// NOT the storage. All five arrays are 8 bytes/entry and grow together; the grow
// routine ZEROES newly-added entries. SNC_MAX_MAP_ELEMS is the INITIAL capacity.
// Access sites use the LOAD_TBL macro.
map_pool_count:  .space 8
map_pool_keys:   .quad 0
map_pool_key_lengths: .quad 0
map_pool_key_ptrs: .quad 0
map_pool_values: .quad 0
map_pool_lengths: .quad 0
map_pool_capacity: .quad 0   // current allocated capacity (in entries) of the map pools
slice_tmp_source_val: .space 8
slice_tmp_source_len: .space 8
slice_tmp_source_var: .space 8
slice_tmp_start_val:  .space 8
slice_tmp_start_var:  .space 8
slice_tmp_end_val:    .space 8
slice_tmp_end_var:    .space 8
// String method temporary storage
str_contains_tmp_substr_val: .space 8
str_contains_tmp_substr_var: .space 8
str_method_src_var: .space 8
str_method_sub_len: .space 8
member_src_val: .space 8
member_src_len: .space 8
member_src_var: .space 8
str_replace_tmp_old_val:   .space 8
str_replace_tmp_old_var:   .space 8
str_replace_tmp_new_val:   .space 8
str_replace_tmp_new_var:   .space 8
str_split_tmp_sep_val:     .space 8
str_split_tmp_sep_var:     .space 8
module_count:    .space 8
module_names:    .space 2048      // 256 modules * 8 bytes (ptr)
module_paths:    .space 2048      // 256 modules * 8 bytes (ptr)
module_function_names: .space 16384  // 2048 function names * 8 bytes
module_function_counts: .space 2048  // 256 modules * 8 bytes (count)
module_search_paths: .space 1024
module_search_count: .space 8
module_file_path_buf: .space 512   // static buffer for module file paths
// Print/data literal tables: now malloc-backed and GROWABLE (see
// _snc_grow_prints in vars.s). Each symbol holds a POINTER to a heap buffer
// (0 until first allocation), NOT the storage itself, so the compiled program's
// literal print/data table can grow past the old fixed SNC_MAX_PRINTS cap
// instead of hard-failing with "too many print statements". SNC_MAX_PRINTS is
// now merely the INITIAL capacity. print_noline is a byte-per-entry buffer.
print_values:   .quad 0
print_lengths:  .quad 0
print_types:    .quad 0
print_noline:   .quad 0
print_capacity: .quad 0   // current allocated capacity (entries) of the print tables
// Operation tables: now malloc-backed and GROWABLE (see _snc_grow_ops in
// vars.s). Each of these symbols holds a POINTER to a heap buffer (0 until the
// first allocation), NOT the storage itself, so the recorded op stream can grow
// past the old fixed SNC_MAX_OPS cap by realloc instead of hard-failing with
// "too many operations". SNC_MAX_OPS is now merely the INITIAL capacity.
op_kinds:       .quad 0
op_arg0:        .quad 0
op_arg1:        .quad 0
op_arg2:        .quad 0
op_arg3:        .quad 0
op_arg4:        .quad 0
op_capacity:    .quad 0   // current allocated capacity (in entries) of the op tables
fn_count:       .space 8
.global current_table_id
current_table_id: .space 8
.global current_parse_fn_id
current_parse_fn_id: .space 8
// Function tables: now malloc-backed and GROWABLE (see _snc_grow_fns in
// vars.s). Each symbol below holds a POINTER to a heap buffer (0 until the
// first allocation), NOT the storage itself, so the compiler's function table
// can grow past the old fixed SNC_MAX_FUNCS cap via realloc. SNC_MAX_FUNCS is
// now merely the INITIAL capacity. Access sites use the LOAD_TBL macro
// (LOAD_ADDR + deref) so they always see the current buffer.
fn_name_ptrs:   .quad 0
fn_name_lens:   .quad 0
fn_body_cursors: .quad 0
fn_body_lines:  .quad 0
fn_source_ptrs: .quad 0
fn_source_lens: .quad 0
fn_param_counts: .quad 0
fn_return_types: .quad 0
fn_op_starts:    .quad 0
fn_op_counts:    .quad 0
fn_param_types: .quad 0
fn_param_lengths: .quad 0
fn_param_name_ptrs: .quad 0
fn_param_name_lens: .quad 0
fn_param_default_flags: .quad 0
fn_param_default_values: .quad 0
fn_param_default_types: .quad 0
fn_param_default_lengths: .quad 0
fn_return_decl_lengths: .quad 0
fn_return_extra_types: .quad 0
fn_return_extra_decl_lengths: .quad 0
.global fn_blueprint_ids
fn_blueprint_ids: .quad 0
// Owning module index for each function, or -1 for functions from the primary
// source file. Grows in lockstep with the other fn_* tables.
fn_module_ids:  .quad 0
// Whether an imported function is currently visible to unqualified calls.
// Module bodies remain available regardless, and qualified calls bypass this.
fn_import_visible: .quad 0
fn_capacity:     .quad 0   // current allocated capacity (in entries) of the fn tables
fn_return_value: .space 8
fn_return_length: .space 8
fn_return_flag:  .space 8
fn_scope_bases:  .quad 0
fn_frame_sizes:  .quad 0
cur_scope_base:  .space 8            // emit-time: slot base of the function being emitted
last_call_result_slot: .space 8      // parse-time: result slot of the last compiled call
fn_return_extra: .space 8
fn_return_extra_type: .space 8
fn_exec_depth:   .space 8
var_scope_base: .space 8
max_var_count:  .space 8
saved_var_count: .space 8
imported_function_names: .space 4096
imported_function_modules: .space 4096
imported_function_count: .space 8
blueprint_count:      .space 8
blueprint_name_ptrs:  .space 512         // 64 blueprints * 8 bytes
blueprint_name_lens:  .space 512
blueprint_parent_ids: .space 512
blueprint_field_counts: .space 512
blueprint_field_names: .space 4096        // 64 blueprints * 8 fields * 8 bytes
blueprint_field_name_lens: .space 4096
blueprint_field_types: .space 4096
blueprint_field_metas: .space 4096
blueprint_field_default_flags: .space 4096
blueprint_field_default_values: .space 4096
blueprint_field_default_types: .space 4096
blueprint_field_default_metas: .space 4096
blueprint_method_counts: .space 512
blueprint_method_names: .space 4096
blueprint_method_name_lens: .space 4096
blueprint_method_fn_ids: .space 4096
contract_count: .space 8
contract_name_ptrs: .space 512
contract_name_lens: .space 512
contract_method_counts: .space 512
contract_method_names: .space 4096
contract_method_name_lens: .space 4096
blueprint_contract_counts: .space 512
blueprint_contract_ids: .space 4096
object_instance_count: .space 8
object_blueprint_ids: .space 1024         // 128 instances * 8 bytes
object_field_var_idxs: .space 8192        // 128 instances * 8 fields * 8 bytes
// Per-blueprint DEFINITION-TIME template instance (id+1; 0 = none yet). Bound as
// `self` while a method body is compiled standalone so `self.field` resolves to
// valid var slots. Real calls inline the body with the caller's actual instance.
blueprint_template_instances: .space 512  // 64 blueprints * 8 bytes
current_self_instance: .space 8
current_self_type: .space 8
current_self_meta: .space 8
current_blueprint_parse: .space 8
.global last_fn_def_index
last_fn_def_index: .space 8               // fn table index of the fn just parsed by _parse_fn_definition
// --- Per-instance object-method INLINING state (see _inline_object_method) ---
// When >0, a method body is being re-parsed inline at a call site: the `return`
// statement then deposits its value into `inline_result_slot` and jumps to
// `inline_end_label` instead of emitting a function epilogue+ret. This lets
// `self.field` resolve to the ACTUAL caller instance's field slots (per-instance),
// rather than the once-compiled body's shared template slots. Fully gated: when
// `inline_active` is 0 (all normal compilation) behavior is byte-identical.
inline_active:      .space 8              // current inline nesting depth (0 = not inlining)
inline_result_slot: .space 8              // slot the inlined `return <v>` copies its value into
inline_end_label:   .space 8              // label id the inlined `return` jumps to
inline_fn_stack:    .space 128            // fn ids currently being inlined (recursion guard; 16 deep)
fn_name_override_ptr: .space 8
fn_name_override_len: .space 8
method_name_storage: .quad 0
hidden_var_name_storage: .quad 0     // malloc-backed; grows with the var tables (see _snc_grow_vars), 32 bytes/entry, indexed by the global var index
spawn_capture_fn_id:   .space 8
spawn_wait_used:       .space 8           // 1 if wait() builtin used -> emit _snc_spawn_wait
channel_count:         .space 8           // compile-time channel ids; emitted runtime supports 64
spawn_fn_op_counts:    .space 256         // 32 functions * 8 (op counts for spawn bodies)
spawn_fn_op_kinds:    .space 65536       // 32 * 256 * 8
spawn_fn_op_arg0:      .space 65536
spawn_fn_op_arg1:      .space 65536
spawn_fn_op_arg2:      .space 65536
spawn_fn_op_arg3:      .space 65536
spawn_fn_op_arg4:      .space 65536
primary_module_name:   .space 8           // Store module name ptr during qualified access
primary_module_name_len: .space 8         // Store module name length during qualified access
// One-shot qualified-call override. Zero means normal name lookup; otherwise
// the value is the exact function index plus one (so function 0 is representable).
forced_call_fn_id_plus1: .space 8
emit_tbl_kinds:        .space 8
emit_tbl_arg0:         .space 8
emit_tbl_arg1:         .space 8
emit_tbl_arg2:         .space 8
emit_tbl_arg3:         .space 8
emit_tbl_arg4:         .space 8
