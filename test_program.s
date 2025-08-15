addi x2, x0, 7 
sh x2, 4(x0) 
lh x1, 4(x0) 
add x2, x1, x0 
add x1, x1, x2 
add x1, x1, x2 
sub x1, x1, x2 
sub x1, x1, x2 
beq x1, x2, SAIDA 
add x1, x1, x1 
sh x1, 0(x0) 
SAIDA: 
and x1, x1, x2 
or x1, x1, x0 
sh x1, 0(x0)
