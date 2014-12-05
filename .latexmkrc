$pdflatex = 'xelatex --file-line-error --shell-escape -interaction=nonstopmode  %O %S';
$pdf_previewer = "start evince %O %S";
$pdf_update_method = 0;
$pdf_mode = 1;
$bibtex_use = 1;
$preview_continuous_mode = 1;

@default_files = ('thesis.tex');
