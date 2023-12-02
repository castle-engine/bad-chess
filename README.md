# The bad way to play chess: 3D physics fun using Castle Game Engine

Article and related demo project showcasing [Castle Game Engine](https://castle-engine.io/). For publication in [Blaise Pascal Magazine](https://www.blaisepascalmagazine.eu/) in 2023.

The `article` directory contains the article sources, written using AsciiDoctor markup.

The article is split into 2 parts,

1. `article/castle_game_engine_bad_chess_1.adoc` - introduction and designing game in editor.

    Output: https://castle-engine.io/bad-chess/castle_game_engine_bad_chess_1.html

    Output (PDF): https://castle-engine.io/bad-chess/castle_game_engine_bad_chess_1.pdf

2. `article/castle_game_engine_bad_chess_2.adoc` - coding the game logic.

    Output: https://castle-engine.io/bad-chess/castle_game_engine_bad_chess_2.html

    Output (PDF): https://castle-engine.io/bad-chess/castle_game_engine_bad_chess_2.pdf

The `project` directory contains working demo projects, described in the article. Just like there are 2 article parts, there are 2 demo projects, showing the game state after each article part:

- `project/version_1_designed_in_editor` - game designed in editor, following 1st article part.

    There's also additional (unused in compiled game) design called `gameviewmain_more_random_arrangement.castle-user-interface` which you can open and run _"Physics Simulation"_ in CGE editor. The chess pieces are deliberately more randomly distributed in that design, to show that we can test crazy things in editor.

- `project/version_2_with_code` - game logic coded. This started from the state of `version_1_designed_in_editor` and then I added the code described in the 2nd article part.

Open, compile and run projects using [Castle Game Engine](https://castle-engine.io/) editor. Do _"Open Project"_ from CGE editor and point to the `CastleEngineManifest.xml` in each project's subdirectory.

## License and copyright (for both the article and the demo project)

Permissive "modified BSD (3-clause)" license.

Author: Michalis Kamburelis.

Exceptions: the chess 3D data has been created by other people and graciously shared on various versions of the _Creative Commons_ licenses. They have been listed in the `project/data/AUTHORS.md` file.

