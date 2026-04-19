# NPC Aseprite scripts

Author NPC `.aseprite` sources with **Cursor MCP server `user-aseprite`** (pixel-mcp + local Aseprite), using the **Pixel Art Creator** and **Pixel Art Animator** skills: `create_canvas`, `draw_rectangle` / `draw_pixels`, `add_frame`, `create_tag`, `save_as` into `../source/`, then `export_spritesheet` (+ JSON) and optional `export_sprite` into `../../export/npc/`.

Batch Lua under CLI is optional; the MCP path avoids `gui.xml` / timeout issues on headless hosts.
