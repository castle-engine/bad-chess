# ----------------------------------------------------------------------------
# Make the HTML and PDF versions of the article,
# from AsciiDoctor sources.
# Just run "make" on the command-line to make both HTML and PDF.
# ----------------------------------------------------------------------------

NAME:=castle_game_engine_bad_chess_1
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

# Utilities to update on server ------------------------------------------------
#
# Update cge-www contents assuming they are in $CASTLE_ENGINE_PATH/../cge-www/ .
#
# The full sequence to do update:
# - make make-all-parts
# - commit and push cge-www repo,
# - www_synchronize_noimages.sh on sever.

# Variables (adjust CGE_WWW_PATH if it's not in the default location).
CGE_WWW_PATH:=$(CASTLE_ENGINE_PATH)/../cge-www/

# Make one article part and copy to cge-www
.PHONY: make-one-part
make-one-part: clean all
	cp -f $(NAME).html $(NAME).pdf $(CGE_WWW_PATH)htdocs/bad-chess/

# Make all article parts and copy to cge-www
.PHONY: make-all-parts
make-all-parts:
	rm -Rf $(CGE_WWW_PATH)htdocs/bad-chess/images_?
	cp -R images_? $(CGE_WWW_PATH)htdocs/bad-chess/
	$(MAKE) make-one-part NAME=castle_game_engine_bad_chess_1
	$(MAKE) make-one-part NAME=castle_game_engine_bad_chess_2
