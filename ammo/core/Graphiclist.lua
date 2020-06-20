Graphiclist = class("Graphiclist")

function Graphiclist:initialize(allGraphics)
    self.allGraphics = allGraphics
end

function Graphiclist:update(dt)
     for _, v in pairs(self.allGraphics) do
         v.scroll = self.scroll
     end
end
