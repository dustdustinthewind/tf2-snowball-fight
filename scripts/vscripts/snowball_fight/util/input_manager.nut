::this_buttons <- {}
::last_tick_buttons <- {}

// update button tables each frame
AddListener("tick_frame", 1, function()
{
    foreach (player in GetValidPlayers())
	{
		if (player in this_buttons)
			last_tick_buttons[player] <- this_buttons[player]
		this_buttons[player] <- GetPropInt(player, "m_nButtons")
	}
})

// get current frame buttons
::CTFPlayer.buttons <- function()
{
	return this_buttons[this]
}
::CTFBot.buttons <- CTFPlayer.buttons

// get last frame buttons
::CTFPlayer.last_buttons <- function()
{
	return last_tick_buttons[this]
}
::CTFBot.last_buttons <- CTFPlayer.last_buttons

// is this button down
::CTFPlayer.button_down <- function(button)
{
	return (buttons() & button)
}
::CTFBot.button_down <- CTFPlayer.button_down

// was this button down last frame
::CTFPlayer.last_button_down <- function(button)
{
	return last_buttons() && (last_buttons() & button)
}
::CTFBot.last_button_down <- CTFPlayer.last_button_down

// is this button up
::CTFPlayer.button_up <- function(button)
{
	return !button_down(button)
}
::CTFBot.button_up <- CTFPlayer.button_up

// was this button up last frame
::CTFPlayer.last_button_up <- function(button)
{
	return !last_button_down(button)
}
::CTFBot.last_button_up <- CTFPlayer.last_button_up

// was this the frame the button pressed
::CTFPlayer.button_pressed <- function(button)
{
	return last_button_up(button) && button_down(button)
}
::CTFBot.button_pressed <- CTFPlayer.button_pressed

// was this the frame the button released
::CTFPlayer.button_released <- function(button)
{
	return last_button_down(button) && button_up(button)
}
::CTFBot.button_released <- CTFPlayer.button_released