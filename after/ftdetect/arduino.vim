" Detección de tipo de archivo para Arduino
" Detectar archivos .ino como Arduino
autocmd BufRead,BufNewFile *.ino setfiletype arduino

" Detectar archivos .pde como Arduino (formato antiguo)
autocmd BufRead,BufNewFile *.pde setfiletype arduino

" Para archivos sin extensión en proyectos Arduino
autocmd BufRead,BufNewFile * if search('void setup()', 'nw') && search('void loop()', 'nw') | setfiletype arduino | endif
