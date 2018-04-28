CC=gcc

install: gpxToKml.l
	flex gpxToKml.l
	$(CC) -o gpxToKml lex.yy.c

.PHONY: clean

clean:
	rm gpxToKml lex.yy.c
