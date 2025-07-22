# 1.1 (7/21/2025)
- Removed the ability to head back to the InitState in the Finished State: TODO: Fix the mod directory somehow being set to null when returning
- Added Results menu to the end of songs
- The outdated sub state no longer mentions the check for updates option in release builds
- Added support for compiling to Hashlink
- If there is only one song they don't play automatially anymore
- Added Difficulty Selector to the Song Selector
- Added "Add Camera Offset" event to the chart editor
- Added "Move Camera" event to the chart editor
- The outdated state sends you to the right URL now
- The outdated check happens in the Song Select
- (Debug) You can now access the Master Editor Menu from the Song Selector Menu by leaving the menu
- The Song Selector no longer displays "Mod Directory """ when selecting a song not from a mod
- (Debug) Added "Song Selector" to the Master Editor Menu

# 1.0.4 (7/21/2025)
- The keybind text in PlayState is modifyable with scripts now (idk if it was exactly modifyable before)
- The watermark text in PlayState is modifyable with scripts now
- Fixed the top mod's songs being the only you can play
- Fixed position of the missing chart text

# 1.0.3 (7/21/2025)
- Pressing backspace in the game over screen no longer sends you to freeplay (in release builds)
- The finished state text now says ", if you haven't already" at the end
- Fixed song selection not selecting the song properly
- Added "NO_TITLE" debug flag so you can test the song selection menu in debug builds
- Fixed songs being added to the song selection multiple times

# 1.0.2 (7/20/2025)
- Replaced more Psych engine things with Oneshot engine

# 1.0.1 (7/20/2025)
- Re-enabled Lua and Hscript script files

# 1.0 (7/20/2025)
- Base engine