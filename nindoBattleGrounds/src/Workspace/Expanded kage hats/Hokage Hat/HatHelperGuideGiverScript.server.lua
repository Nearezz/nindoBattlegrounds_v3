-- Guide to how to make a hat giver.

-- To adjust where your hat will be postioned on your head, go to the script line that says "h.AttachmentPos = Vector3.new(0,0,0)
-- The first number in the (0,0,0) will make your hat go to the left, or to the right, making the number positive will make your hat be
-- placed to the left, making it negative( ex. "-1") will make it be placed to the right. If your hat is pretty semetrical, you wont have to
-- adjust the first number, it stays usually in the middle, a zero.

-- The middle number adjusts how high/low the hat will be placed on the head. The higher the number is, the lower the hat will be
-- placed. If  you are at zero, and you want the hat to go  lower, make the number a negative. Negative numbers will make the hat
-- be place higher on your robloxian head.

-- The third number determines how far ahead/back your hat will be placed. Making the number positive will place the hat ahead of 
-- you, while making the number negative will place the hat behind you some.

-- NOTE, on the first, and last numbers, the ones that make your hat go left/right/ahead/back shouldn't be changed by whole numbers
-- to make your hat giver perfect, if you have to use those two numbers, move it slowly by ".1's"
-- This can also go for the middle number. If your hat is slightly higher than its supposed to be, than edit the number slightly. 
-- Do not change the numbers by whole numbers, or else it will go really far off.  Change the numbers by ".1's" and ".2's"



-- If you want to after how many seconds can you get another hat on your head, change the line that says "wait(5)"
-- Changing this will change after how many seconds can someone touch the giver, and get a hat. It's best to leave it as it is, 
-- Changing it really doesnt matter.

-- In build mode, after every time you change this script, copy the script, delete it, and paste it back into your hat, if you don't, 
-- nothing will change, I don't know why, but this is how I make my givers.

-- If you want to change the hat that you are trying on, change the "Mesh" Just delete the one in the brick that this script is in,
-- and copy a mesh from a different hat, that you want to try on with this script.

-- Do not rename the name of the "Mesh", leave it saying Mesh, or the giver wont work.


-- Ask any questions here:  http://www.roblox.com/Forum/ShowPost.aspx?PostID=13178947


-- If you want to know how to retexture a hat, read this:  http://www.roblox.com/Forum/ShowPost.aspx?PostID=10502388








debounce = true

function onTouched(hit)
	if (hit.Parent:findFirstChild("Humanoid") ~= nil and debounce == true) then
		debounce = false
		h = Instance.new("Hat")
		p = Instance.new("Part")
		h.Name = "Hat"   -- It doesn't make a difference, but if you want to make your place in Explorer neater, change this to the name of your hat.
		p.Parent = h
		p.Position = hit.Parent:findFirstChild("Head").Position
		p.Name = "Handle" 
		p.formFactor = 0
		p.Size = Vector3.new(-0,-0,-1) 
		p.BottomSurface = 0 
		p.TopSurface = 0 
		p.Locked = true 
		script.Parent.Mesh:clone().Parent = p
		h.Parent = hit.Parent
		h.AttachmentPos = Vector3.new(0, 0.2, 0.035) -- Change these to change the positiones of your hat, as I said earlier.
		wait(5)		debounce = true
	end
end

script.Parent.Touched:connect(onTouched)

-- Script Guide by HatHelper