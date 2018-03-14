local silo_script = require("silo-script")
local mod_gui = require("mod-gui")
local version = 1


local gridsize = 10 -- half grid size, goes out in all directions this far,for a total of 2n+1 * 2n+1 copies
local size = {x=40,y=6} -- size of blueprint. TODO: calculate this automatically
local printstring = "0eNrNnEFv4zYQhf9KwbNciOQMSflWoMeip96KRSA7akPAlg1ZDhIE/u+VY3QbbEqTj1hg9pLAtiw9caw3/B5lv6nN7jwcpzjOav2m4vYwntT6zzd1in+P/e763Px6HNRaxXnYq0aN/f76aIwvcVjN582w6nfHp15dGhXHx+FFrfWlyb69n+L8tB/muF1tD/tNHPv5MH3Yh7l8adQwznGOw03P+4PXh/G83wzTcpC0kkYdD6fljYfxevhlZyvtGvV6/f8zL4dYTnEcttfXT9cN9PXPNDx+PEpcHllaNo3T9hzn98eLpMvlemrfKDGQEq5RYsuUWEgJ1ShxZUoIUmJrlHCZEoaUmBolvkyJg5ToGiWhTIlHlHQ1QroyIQEakrZCCbVlSjpESagRosuEXM+yXImvUWIKlUAWW+OwVOiwGrLYGoelQofVkMXWOCwV+pqGLLbGYanQ6zVksTUOS4W+pjGLrVFS6PUasdgqXyt0WI1YbM2IcKHBasRhaz4kXGhrBjHYmuuGC53eIP5aYyVcaGoGsdcad+XSmTTirjUNhwvN1SDmWtODudBbDeKtNdMSLrRWg1hrzZSRC53VIM5aNYvmQms1kLXWmLwr9FaDeGsV47hCc7WIuVZxnyt0V4u4axULu0JXs4i9VuUDrjQfsJn8JZlXtP/KmafD7mEzPPXPcdl+2ei/HT0sLz/Gr2L/itNpfvgUAz3HaT4vz3xVcttiNfTbJ3U7xmnur2HUMmyH4zD1Nznql99/Xd50OM/HM7zbS33qoz+M4/8lIHoZ60aZxN6SlSC8Ek6sElqmEhYZaZ0aacZH2oqNdJAZaZf5zHukEpSqhMMrQWKVoB/kM9/cTT3vV8KmKuHxShg593EypeBMKQJSCk6VIuCl0GKlsEI92d8vxbch7/1SuFQpOrgUndxFYWRaxeehbu7G3PdL4VPLRy1+VbRitXBCvSJkDKpDShFSpdBwKYIcMrBQr+gyV4VBStGlSmHgUnixUrCW6RWfDai5u+aUoYo2VQscpQVJuiWhbpGBaYKmszp5twFO04Iw3RqZfvHZhJq7a6CZYqSAm3DgFqS8tpPpGJQBPYJiJp0iPcKZWzD80J1Qz8igHkGop1MBCFVgtyDqeSfUNDLzWoLmtTqFe4STt2QGYoNQ1/Df1ahSOQjB8C3Ie8zW/ZDFYCgI0Sn8Zhi/5XxKW916obaRoT6GqE+nCJxhApdr4WzIBJm2wZnpLUPTW5MCP4YhXK5rGGc0ybQNzuSEDOWEOhWJMIzhJAh+FNjLNA7OpCIMpSImxX4Mg7hkKNJ5zTKdgzP0x1AuYpLffYBRXC4WId2RbYXMKhNTMXbPRwrGGYZxufg22BBcK9TJMzjOEI6bFI4zjONyy33WMhMJLb9yBsgdRB0mBeQMA3kQ5HHvvRG6M4Ezt+swdLuOSSE5w0iuJTGQjF5KIuNYLjPbdRAJmhSXO5zLBVMSr9ulhwh19FxQAmWIJoXmDkZzwXsL2brg205oXdZl8NxBBGJTeO5gPNeSfB7IMgndtMCZ+MpBiG5SiO5gRBe853xlNHkK1gktmINXQfKr5jCHa8lcxFtPOggti7tMNOKg3NDeopEvze33LtYffl2jUbt+MyznoP4YXuaffovjsDz3PEyn9/N1RMZ1XRfacLn8Ax4K6uk="

-- " -- atom struggles with the extra long string, extra quote to let it format the rest...

script.on_event(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]
  local character = player.character

  player.force.research_all_technologies()
  player.cheat_mode = true
  player.surface.always_day = true

  player.character = nil
  if character then
    character.destroy()
  end


  player.force.chart(player.surface, {{player.position.x - size.x*(gridsize+2), player.position.y - size.y*(gridsize+2)}, {player.position.x + size.x*(gridsize+2), player.position.y + size.y*(gridsize+2)}})
  player.surface.request_to_generate_chunks({0,0},10) --TODO: may need more chunks for large print
  player.surface.force_generate_chunk_requests()
  if (#game.players <= 1) then
    player.cursor_stack.import_stack(printstring)

    if player.cursor_stack.valid_for_read and player.cursor_stack.name == "blueprint" then
      for x=-gridsize,gridsize do
        for y = -gridsize,gridsize do
          for _,ent in pairs(player.cursor_stack.build_blueprint{
            surface = player.surface,
            force = player.force,
            position = {
              x * size.x,
              y * size.y
            },
            force_build = true,
            skip_fog_of_war = false
          }) do
            ent.revive()
          end
        end
      end
    end
    player.cursor_stack.clear()
  end

  silo_script.on_player_created(event)
end)

script.on_init(function()
  global.version = version
  silo_script.on_init()
end)

script.on_configuration_changed(function(event)
  if global.version ~= version then
    global.version = version;
    local forces = game.forces
    if global.satellite_sent ~= nil then
      for force_name,rockets_launched in pairs(global.satellite_sent) do
        local force = forces[force_name]
        if force ~= nil then
          force.rockets_launched = rockets_launched
        end
      end
    end
  end
  silo_script.on_configuration_changed(event)
end)

script.on_event(defines.events.on_rocket_launched, function(event)
  silo_script.on_rocket_launched(event)
end)

silo_script.add_remote_interface()
silo_script.add_commands()

script.on_event(defines.events.on_gui_click, function(event)
  silo_script.on_gui_click(event)
end)
