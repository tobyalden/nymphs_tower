local path = ({...})[1]:gsub("%.init", "")
require(path .. ".Tween")
require(path .. ".Delay")
require(path .. ".Alarm")
ease = require(path .. ".ease")
ammo.ext.tweens = true
