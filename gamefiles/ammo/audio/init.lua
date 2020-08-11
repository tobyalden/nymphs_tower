local path = ({...})[1]:gsub("%.init", "")
require(path .. ".Sound")
ammo.ext.audio = true
