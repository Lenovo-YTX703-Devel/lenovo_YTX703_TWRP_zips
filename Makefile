FOLDERS = $(wildcard */)
ZIPS    = $(patsubst %/, %.zip, $(FOLDERS))

all: $(ZIPS)

clean:
	rm -f $(ZIPS)

%.zip: %
	(cd $^; zip -r ../$@ *)

.PHONY: all clean
