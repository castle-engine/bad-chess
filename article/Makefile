# ----------------------------------------------------------------------------
# Make the HTML and PDF versions of the article,
# from AsciiDoctor sources.
# Just run "make" on the command-line to make both HTML and PDF.
# ----------------------------------------------------------------------------

NAME:=castle_game_engine_bad_chess
ALL_OUTPUT:=$(NAME).html $(NAME).pdf $(NAME).xml
#TEST_BROWSER:=firefox
TEST_BROWSER:=x-www-browser

all: $(ALL_OUTPUT)

$(NAME).html: $(NAME).adoc
	asciidoctor $< -o $@
	$(TEST_BROWSER) $@ &

$(NAME).xml: $(NAME).adoc
	asciidoctor $(ASCIIDOCTOR_LANGUAGE) -b docbook5 $< -o $@

$(NAME).pdf: $(NAME).xml
	fopub $(NAME).xml

.PHONY: clean
clean:
	rm -f $(ALL_OUTPUT)
