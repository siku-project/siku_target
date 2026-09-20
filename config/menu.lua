MenuConfig = {
  --- Submenus
  ---
  --- Whether an option may open a submenu, one level deep: an option of a
  --- submenu always acts, it never opens another one. Off, the options
  --- carrying a submenu are left out and the menu only lists the ones
  --- that act.
  ---
  --- Default: true
  submenus = true,

  --- Visible rows
  ---
  --- How many options show at once; beyond that the list scrolls.
  ---
  --- Default: 6
  maxVisible = 6,

  --- Width
  ---
  --- The menu width in pixels.
  ---
  --- Default: 220
  width = 220,

  --- Offset
  ---
  --- The gap in pixels between the reticle or the pointer and the menu.
  ---
  --- Default: 18
  offset = 18,

  --- Close on select
  ---
  --- Whether the target closes once an option has acted. Off, the menu
  --- stays for another pick.
  ---
  --- Default: true
  closeOnSelect = true,
}
