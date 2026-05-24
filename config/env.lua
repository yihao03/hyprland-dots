-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "18")
hl.env("HYPRCURSOR_SIZE", "18")
hl.env("XDG_MENU_PREFIX", "arch-")
hl.env("GTK_USE_PORTAL", "1")
hl.env("EDITOR", "nvim")

-- input method framework
-- hl.env("GTK_IM_MODULE", "fcitx")
-- hl.env("QT_IM_MODULE", "fcitx")

-- dark theme
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_QPA_PLATFORM", "wayland")
