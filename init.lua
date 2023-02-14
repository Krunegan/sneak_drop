--[[

The MIT License (MIT)
Copyright (C) 2023 Acronymmk

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

]]


local pickup_range = 3 -- Pick up range
local pickup_delay = 0.5 -- Pick up delay (in seconds)
local pickup_speed = 5 -- Pick up speed (blocks per seconds)

minetest.register_globalstep(function(dtime)
    local player_list = minetest.get_connected_players()
    for i = 1, #player_list do
        local player = player_list[i]
        if player:get_player_control().sneak then
            local pos = player:get_pos()
            local objs = minetest.get_objects_inside_radius(pos, pickup_range)
            for j = 1, #objs do
                local obj = objs[j]
                if obj:get_luaentity() and obj:get_luaentity().name == "__builtin:item" then
                    local objpos = obj:get_pos()
                    local objdir = vector.direction(pos, objpos)
                    local objdist = vector.distance(pos, objpos)
                    if objdist < 1 then
                        local itemstack = obj:get_luaentity().itemstring
                        player:get_inventory():add_item("main", itemstack)
                        obj:remove()
                        minetest.sound_play("sneak_drop_pickup", {
                            pos = pos,
                            max_hear_distance = 16,
                            gain = 0.4,
                        })
                    else
                        obj:set_velocity(vector.multiply(objdir, -pickup_speed))
                    end
                end
            end
        end
    end
end)

minetest.register_on_joinplayer(function(player)
    player:set_physics_override({gravity = 0})
end)

minetest.register_on_leaveplayer(function(player)
    player:set_physics_override({gravity = 1})
end)

minetest.register_on_respawnplayer(function(player)
    player:set_physics_override({gravity = 0})
end)

minetest.register_globalstep(function(dtime)
    local player_list = minetest.get_connected_players()
    for i = 1, #player_list do
        local player = player_list[i]
        local pname = player:get_player_name()
        local pmeta = player:get_meta()
        local last_pickup_time = pmeta:get_float("last_pickup_time") or 0
        local current_time = minetest.get_gametime()
        if player:get_player_control().sneak and current_time - last_pickup_time >= pickup_delay then
            pmeta:set_float("last_pickup_time", current_time)
        end
    end
end)

