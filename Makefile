CHAPTERS = $(wildcard chapters/*.md)
CHAPTERS = $(shell cat README.md | egrep ^1 | cut -d '(' -f 2 | tr -d ')' | cut -d / -f 2 )

EPUB_FILE = ../book/docker-para-desenvolvedores-by-rafael-gomes.epub

.PHONY: all
all: $(EPUB_FILE) 

.PHONY: clean
clean:
	$(RM) -r ./book

.PHONY: epub
epub: $(EPUB_FILE)


$(EPUB_FILE): clean #$(CHAPTERS) 
	cd manuscript && \
	mkdir -p ../book && \
	pandoc \
		-o $(EPUB_FILE) \
		meta/title.txt \
		$(CHAPTERS) \
		--epub-cover-image=meta/docker-para-desenvolvedores-1a-edicao-rafael-gomes.png \
		--epub-stylesheet=meta/stylesheet.css \
		--epub-metadata=meta/metadata.xml \
		--table-of-contents \
		--write=epub3

$(PDF_FILE): $(CHAPTERS) meta/title.txt
	pandoc \
		-o $(PDF_FILE) \
		meta/title.txt \
		$(CHAPTERS) \
		--toc


$(MOBI_FILE): $(EPUB_FILE)
	kindlegen $(EPUB_FILE)
