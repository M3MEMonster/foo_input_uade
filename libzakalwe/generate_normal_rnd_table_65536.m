printf("#include \"norm_inv_table_65536.h\"\n");
printf("\n");
printf("const float _ccul_norm_inv_table[65536] = {\n");
for i = 1:65536
  x = i / 65537;
  p = norminv(x, 0, 1);
  printf("\t%.8ff,\n", p);
endfor
printf("};\n");
