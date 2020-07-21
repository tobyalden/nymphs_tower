FuelUpgrade = class("FuelUpgrade", Entity)

FuelUpgrade.static.FUEL_AMOUNT = 50

function FuelUpgrade:initialize(x, y, addFlag)
    Entity.initialize(self, x, y)
    self.types = {"fuel_upgrade"}
    self.graphic = Sprite:new("fuelupgrade.png")
    self.mask = Hitbox:new(self, 24, 24)
    self.addFlag = addFlag
end

