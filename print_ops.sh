./snc test_map_imm.sn > test_map_imm.s
grep -A 10 Lemit_op_map_load src/codegen.s
