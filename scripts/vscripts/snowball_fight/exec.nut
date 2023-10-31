snowball_fight <- "snowball_fight/"

// thirdparty
// basically llzard lib from vsh (todo: add url)
//  includes modifications by dust
IncludeScript(momentus + "__lizardlib/util.nut")
// https://tf2maps.net/downloads/vscript-give_tf_weapon.14897/
Include("give_tf_weapon/_master.nut")
// https://github.com/ficool2/vscript_trace_filter
Include("ficool2/trace_filter.nut")

Include("/util/entities.nut")
Include("/util/debug.nut")
Include("/util/helpers.nut")
Include("/util/input_manager.nut")
Include("/util/weapon_helpers.nut")

Include("game_setup.nut")
//Include("tables.nut")
Include("weapons_and_traits.nut")

// TODO
//  fix need to rerun script twice to work
//  sometimes only need to run once on other systems ok