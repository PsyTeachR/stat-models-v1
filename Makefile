htarg := docs

VAR2=$(shell printf '%02d' $(VAR))
REGEX=$(shell printf "^\./%s.*\.Rmd$$" $(VAR2))
CFILE=$(shell find ./ -type f -regextype posix-extended -regex '$(REGEX)')

.PHONY : book
book : clean 
	Rscript -e 'bookdown::render_book("index.Rmd", output_dir = "$(htarg)")'
	zip -r docs/offline-textbook.zip docs/

bookpdf :
	Rscript -e 'bookdown::render_book("index.Rmd", output_dir = "pdf", output_format = "bookdown::pdf_book")'

chapter :
	Rscript -e 'bookdown::preview_chapter("$(CFILE)", output_dir = "$(htarg)")' 

chapterpdf :
	Rscript -e 'bookdown::preview_chapter("$(CFILE)", output_dir = "pdf", output_format = "bookdown::pdf_book")'

clean :
	Rscript -e 'bookdown::clean_book(TRUE)'
