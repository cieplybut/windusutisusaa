local http = require 'gamesense/http'



                        
                    -- @region LUASETTINGS start
                    local lua_name = "gengar"
                    local lua_color = {r = 190, g = 190, b = 255}
                        
                    local lua_banner = [[                                                                                                           
                                        _  __ _        _             
                                        (_)/ _(_)      | |            
                    ___ _ __ _   _  ___ _| |_ ___  __ | |_   _  __ _ 
                    / __| '__| | | |/ __| |  _| \ \/ / | | | | |/ _` |
                    | (__| |  | |_| | (__| | | | |>  < _| | |_| | (_| |
                    \___|_|   \__,_|\___|_|_| |_/_/\_(_)_|\__,_|\__,_|
                                                                        
                                                                                                                                                                                            
                    ]]
                    local function try_require(module, msg)
                        local success, result = pcall(require, module)
                        if success then return result else return error(msg) end
                    end
        
                    local images = try_require("gamesense/images", "Download images library: https://gamesense.pub/forums/viewtopic.php?id=22917")
                    local bit = try_require("bit")
                    local base64 = try_require("gamesense/base64", "Download base64 encode/decode library: https://gamesense.pub/forums/viewtopic.php?id=21619")
                    local antiaim_funcs = try_require("gamesense/antiaim_funcs", "Download anti-aim functions library: https://gamesense.pub/forums/viewtopic.php?id=29665")
                    local ffi = try_require("ffi", "Failed to require FFI, please make sure Allow unsafe scripts is enabled!")
                    local vector = try_require("vector", "Missing vector")
                    local http = try_require("gamesense/http", "Download HTTP library: https://gamesense.pub/forums/viewtopic.php?id=21619")
                    local clipboard = try_require("gamesense/clipboard", "Download Clipboard library: https://gamesense.pub/forums/viewtopic.php?id=28678")
                    local ent = try_require("gamesense/entity", "Download Entity Object library: https://gamesense.pub/forums/viewtopic.php?id=27529")
                    local csgo_weapons = try_require("gamesense/csgo_weapons", "Download CS:GO weapon data library: https://gamesense.pub/forums/viewtopic.php?id=18807")
                    local ent = try_require("gamesense/entity")
                    local steamworks = try_require("gamesense/steamworks") or error('Missing https://gamesense.pub/forums/viewtopic.php?id=26526')
        
                    local login = {
                        username = "user",
                        version = "1.0.0",
                        build = "free",
                    }
        
                    client.exec("clear")
                    client.color_log(255, 255, 255, " \n \n \n \n \n ")
                    client.color_log(lua_color.r, lua_color.g, lua_color.b, lua_banner)
                    client.color_log(255, 255, 255, " \n \n \n \n \n ")
                    client.color_log(255, 255, 255, "Welcome to\0")
                    client.color_log(lua_color.r, lua_color.g, lua_color.b, " gengar.lua\0")
                    client.color_log(255, 255, 255, ", " .. login.username)
                    local lua = {}
                    lua.database = {
                        configs = ":" .. lua_name .. "::configs:"
                    }
                    local presets = {}
                    -- @region USERDATA end
        
                    ffi.cdef [[
                        typedef unsigned long dword;
                        typedef unsigned int size_t;
        
                        typedef struct {
                            uint8_t r, g, b, a;
                        } color_t;
                    ]]
        
                    -- @region REFERENCES start
                    local refs = {
                        legit = ui.reference("LEGIT", "Aimbot", "Enabled"),
                        dmgOverride = {ui.reference("RAGE", "Aimbot", "Minimum damage override")},
                        fakeDuck = ui.reference("RAGE", "Other", "Duck peek assist"),
                        minDmg = ui.reference("RAGE", "Aimbot", "Minimum damage"),
                        hitChance = ui.reference("RAGE", "Aimbot", "Minimum hit chance"),
                        safePoint = ui.reference("RAGE", "Aimbot", "Force safe point"),
                        forceBaim = ui.reference("RAGE", "Aimbot", "Force body aim"),
                        dtLimit = ui.reference("RAGE", "Aimbot", "Double tap fake lag limit"),
                        quickPeek = {ui.reference("RAGE", "Other", "Quick peek assist")},
                        dt = {ui.reference("RAGE", "Aimbot", "Double tap")},
                        enabled = ui.reference("AA", "Anti-aimbot angles", "Enabled"),
                        pitch = {ui.reference("AA", "Anti-aimbot angles", "pitch")},
                        roll = ui.reference("AA", "Anti-aimbot angles", "roll"),
                        yawBase = ui.reference("AA", "Anti-aimbot angles", "Yaw base"),
                        yaw = {ui.reference("AA", "Anti-aimbot angles", "Yaw")},
                        flLimit = ui.reference("AA", "Fake lag", "Limit"),
                        fsBodyYaw = ui.reference("AA", "anti-aimbot angles", "Freestanding body yaw"),
                        edgeYaw = ui.reference("AA", "Anti-aimbot angles", "Edge yaw"),
                        yawJitter = {ui.reference("AA", "Anti-aimbot angles", "Yaw jitter")},
                        bodyYaw = {ui.reference("AA", "Anti-aimbot angles", "Body yaw")},
                        freeStand = {ui.reference("AA", "Anti-aimbot angles", "Freestanding")},
                        os = {ui.reference("AA", "Other", "On shot anti-aim")},
                        slow = {ui.reference("AA", "Other", "Slow motion")},
                        fakeLag = {ui.reference("AA", "Fake lag", "Limit")},
                        legMovement = ui.reference("AA", "Other", "Leg movement"),
                        indicators = {ui.reference("VISUALS", "Other ESP", "Feature indicators")},
                        ping = {ui.reference("MISC", "Miscellaneous", "Ping spike")},
                    }
                    -- @region REFERENCES end
        
                    -- @region VARIABLES start
                    local vars = {
                        localPlayer = 0,
                        hitgroup_names = { 'Generic', 'Head', 'Chest', 'Stomach', 'Left arm', 'Right arm', 'Left leg', 'Right leg', 'Neck', '?', 'Gear' },
                        aaStates = {"Global", "Standing", "Moving", "Slowwalking", "Crouching", "Air", "Air-Crouching", "Legit-AA"},
                        pStates = {"G", "S", "M", "SW", "C", "A", "AC", "LA"},
                        sToInt = {["Global"] = 1, ["Standing"] = 2, ["Moving"] = 3, ["Slowwalking"] = 4, ["Crouching"] = 5, ["Air"] = 6, ["Air-Crouching"] = 7,["Legit-AA"] = 8},
                        intToS = {[1] = "Global", [2] = "Stand", [3] = "Move", [4] = "Slowwalk", [5] = "Crouch", [6] = "Air", [7] = "Air+C", [8] = "Legit"},
                        currentTab = 1,
                        activeState = 1,
                        pState = 1,
                        should_disable = false,
                        defensive_until = 0,
                        defensive_prev_sim = 0,
                        fs = false,
                        choke1 = 0,
                        choke2 = 0,
                        choke3 = 0,
                        choke4 = 0,
                        switch = false,
                    }
        
                    local kill = {
                        "smell the heel of the fucking son of a shabolda",
                        "You suck worse than Megion chicks",
                        "omg ładny mały pisunchik",
                        "You're not a fucking legend",
                        "WŁAŚCIWOŚĆ LEGENDICK son of a fucking whore",
                        "let my little pussy explore the depths of your mother's mine",
                        "kiss the pussy, kurwa, żadna legenda",
                        "your pussy is as small as iqshe4ka",
                        "next time you'll win a legend",
                        "Czy jesteś legendą? Możesz sprawdzić, czy jesteś legendą - taktowany#5537 wirtualny#0085",
                        "YOU ARE THE SAME DANCER AS NOLEGENDICKI FLOWERS",
                        "Your mother is as fat as idle nolegend (140)",
                        "I came on your bald head, it’s like Father Shamelisik’s,",
                        "your mother made me delicious sandwiches like gachi nolegend's",
                        "you are a very good heel licker, teach the clokedik legendicka",
                        "The fucking whore died just like Fipp and Maut's grandmother",
                        "son of a whore, you have the same computers as vanino nolegend",
                        "your mom is licking the ice cream, oh fuck, that's my pussy",
                        "your mother has a pussy as tight as her eyes d4ssh legend",
                        "You're the same fucking dog as l4fn nolegend",
                        "Of course you play like crap, not like virtual legendick",
                        "I bombed your motherfucker like they bomb a walper nolegend",
                        "you will never be a legend with such a small pise4ka",
                        "while you're sucking dick we're chilling on legendickov island",
                        "The fucking whore died just like Fipp and Maut's grandmother",
                        "do you want to buy config by legendick? FUCK YOU SON OF A FUCKING WHORE",
                        "EHHH HOW FUCKING SUCKED YOUR MOTHER MY PISUN4IK",
                        "e1",
                    }
        
                    local js = panorama.open()
                    local MyPersonaAPI, LobbyAPI, PartyListAPI, SteamOverlayAPI = js.MyPersonaAPI, js.LobbyAPI, js.PartyListAPI, js.SteamOverlayAPI
                    -- @region VARIABLES end
        
                    -- @region FUNCS start
                    local func = {
                        fclamp = function(x, min, max)
                            return math.max(min, math.min(x, max));
                        end,
                        frgba = function(hex)
                            hex = hex:gsub("#", "");
                        
                            local r = tonumber(hex:sub(1, 2), 16);
                            local g = tonumber(hex:sub(3, 4), 16);
                            local b = tonumber(hex:sub(5, 6), 16);
                            local a = tonumber(hex:sub(7, 8), 16) or 255;
                        
                            return r, g, b, a;
                        end,
                        render_text = function(x, y, ...)
                            local x_Offset = 0
                            
                            local args = {...}
                        
                            for i, line in pairs(args) do
                                local r, g, b, a, text = unpack(line)
                                local size = vector(renderer.measure_text("-d", text))
                                renderer.text(x + x_Offset, y, r, g, b, a, "-d", 0, text)
                                x_Offset = x_Offset + size.x
                            end
                        end,
                        easeInOut = function(t)
                            return (t > 0.5) and 4*((t-1)^3)+1 or 4*t^3;
                        end,
                        rec = function(x, y, w, h, radius, color)
                            radius = math.min(x/2, y/2, radius)
                            local r, g, b, a = unpack(color)
                            renderer.rectangle(x, y + radius, w, h - radius*2, r, g, b, a)
                            renderer.rectangle(x + radius, y, w - radius*2, radius, r, g, b, a)
                            renderer.rectangle(x + radius, y + h - radius, w - radius*2, radius, r, g, b, a)
                            renderer.circle(x + radius, y + radius, r, g, b, a, radius, 180, 0.25)
                            renderer.circle(x - radius + w, y + radius, r, g, b, a, radius, 90, 0.25)
                            renderer.circle(x - radius + w, y - radius + h, r, g, b, a, radius, 0, 0.25)
                            renderer.circle(x + radius, y - radius + h, r, g, b, a, radius, -90, 0.25)
                        end,
                        rec_outline = function(x, y, w, h, radius, thickness, color)
                            radius = math.min(w/2, h/2, radius)
                            local r, g, b, a = unpack(color)
                            if radius == 1 then
                                renderer.rectangle(x, y, w, thickness, r, g, b, a)
                                renderer.rectangle(x, y + h - thickness, w , thickness, r, g, b, a)
                            else
                                renderer.rectangle(x + radius, y, w - radius*2, thickness, r, g, b, a)
                                renderer.rectangle(x + radius, y + h - thickness, w - radius*2, thickness, r, g, b, a)
                                renderer.rectangle(x, y + radius, thickness, h - radius*2, r, g, b, a)
                                renderer.rectangle(x + w - thickness, y + radius, thickness, h - radius*2, r, g, b, a)
                                renderer.circle_outline(x + radius, y + radius, r, g, b, a, radius, 180, 0.25, thickness)
                                renderer.circle_outline(x + radius, y + h - radius, r, g, b, a, radius, 90, 0.25, thickness)
                                renderer.circle_outline(x + w - radius, y + radius, r, g, b, a, radius, -90, 0.25, thickness)
                                renderer.circle_outline(x + w - radius, y + h - radius, r, g, b, a, radius, 0, 0.25, thickness)
                            end
                        end,
                        clamp = function(x, min, max)
                            return x < min and min or x > max and max or x
                        end,
                        includes = function(tbl, value)
                            for i = 1, #tbl do
                                if tbl[i] == value then
                                    return true
                                end
                            end
                            return false
                        end,
                        setAATab = function(ref)
                            ui.set_visible(refs.enabled, ref)
                            ui.set_visible(refs.pitch[1], ref)
                            ui.set_visible(refs.pitch[2], ref)
                            ui.set_visible(refs.roll, ref)
                            ui.set_visible(refs.yawBase, ref)
                            ui.set_visible(refs.yaw[1], ref)
                            ui.set_visible(refs.yaw[2], ref)
                            ui.set_visible(refs.yawJitter[1], ref)
                            ui.set_visible(refs.yawJitter[2], ref)
                            ui.set_visible(refs.bodyYaw[1], ref)
                            ui.set_visible(refs.bodyYaw[2], ref)
                            ui.set_visible(refs.freeStand[1], ref)
                            ui.set_visible(refs.freeStand[2], ref)
                            ui.set_visible(refs.fsBodyYaw, ref)
                            ui.set_visible(refs.edgeYaw, ref)
                        end,
                        findDist = function (x1, y1, z1, x2, y2, z2)
                            return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
                        end,
                        resetAATab = function()
                            ui.set(refs.enabled, false)
                            ui.set(refs.pitch[1], "Off")
                            ui.set(refs.pitch[2], 0)
                            ui.set(refs.roll, 0)
                            ui.set(refs.yawBase, "local view")
                            ui.set(refs.yaw[1], "Off")
                            ui.set(refs.yaw[2], 0)
                            ui.set(refs.yawJitter[1], "Off")
                            ui.set(refs.yawJitter[2], 0)
                            ui.set(refs.bodyYaw[1], "Off")
                            ui.set(refs.bodyYaw[2], 0)
                            ui.set(refs.freeStand[1], false)
                            ui.set(refs.freeStand[2], "On hotkey")
                            ui.set(refs.fsBodyYaw, false)
                            ui.set(refs.edgeYaw, false)
                        end,
                        type_from_string = function(input)
                            if type(input) ~= "string" then return input end
        
                            local value = input:lower()
        
                            if value == "true" then
                                return true
                            elseif value == "false" then
                                return false
                            elseif tonumber(value) ~= nil then
                                return tonumber(value)
                            else
                                return tostring(input)
                            end
                        end,
                        lerp = function(start, vend, time)
                            return start + (vend - start) * time
                        end,
                        vec_angles = function(angle_x, angle_y)
                            local sy = math.sin(math.rad(angle_y))
                            local cy = math.cos(math.rad(angle_y))
                            local sp = math.sin(math.rad(angle_x))
                            local cp = math.cos(math.rad(angle_x))
                            return cp * cy, cp * sy, -sp
                        end,
                        hex = function(arg)
                            local result = "\a"
                            for key, value in next, arg do
                                local output = ""
                                while value > 0 do
                                    local index = math.fmod(value, 16) + 1
                                    value = math.floor(value / 16)
                                    output = string.sub("0123456789ABCDEF", index, index) .. output 
                                end
                                if #output == 0 then 
                                    output = "00" 
                                elseif #output == 1 then 
                                    output = "0" .. output 
                                end 
                                result = result .. output
                            end 
                            return result .. "FF"
                        end,
                        split = function( inputstr, sep)
                            if sep == nil then
                                    sep = "%s"
                            end
                            local t={}
                            for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                                    table.insert(t, str)
                            end
                            return t
                        end,
                        RGBAtoHEX = function(redArg, greenArg, blueArg, alphaArg)
                            return string.format('%.2x%.2x%.2x%.2x', redArg, greenArg, blueArg, alphaArg)
                        end,
                        create_color_array = function(r, g, b, string)
                            local colors = {}
                            for i = 0, #string do
                                local color = {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime() / 4 + i * 5 / 30))}
                                table.insert(colors, color)
                            end
                            return colors
                        end,
                        textArray = function(string)
                            local result = {}
                            for i=1, #string do
                                result[i] = string.sub(string, i, i)
                            end
                            return result
                        end,
                        gradient_text = function(r1, g1, b1, a1, r2, g2, b2, a2, text)
                            local output = ''
                        
                            local len = #text-1
                        
                            local rinc = (r2 - r1) / len
                            local ginc = (g2 - g1) / len
                            local binc = (b2 - b1) / len
                            local ainc = (a2 - a1) / len
                        
                            for i=1, len+1 do
                                output = output .. ('\a%02x%02x%02x%02x%s'):format(r1, g1, b1, a1, text:sub(i, i))
                        
                                r1 = r1 + rinc
                                g1 = g1 + ginc
                                b1 = b1 + binc
                                a1 = a1 + ainc
                            end
                        
                            return output
                        end,    
                        time_to_ticks = function(t)
                            return math.floor(0.5 + (t / globals.tickinterval()))
                        end,
                        headVisible = function(enemy)
                            local local_player = entity.get_local_player()
                            if local_player == nil then return end
                            local ex, ey, ez = entity.hitbox_position(enemy, 1)
                        
                            local hx, hy, hz = entity.hitbox_position(local_player, 1)
                            local head_fraction, head_entindex_hit = client.trace_line(enemy, ex, ey, ez, hx, hy, hz)
                            if head_entindex_hit == local_player or head_fraction == 1 then return true else return false end
                        end,
                        defensive = {
                            cmd = 0,
                            check = 0,
                            defensive = 0,
                        },
                        aa_clamp = function(x) if x == nil then return 0 end x = (x % 360 + 360) % 360 return x > 180 and x - 360 or x end,
                    }
        
                    client.set_event_callback("run_command", function(e)
                        func.defensive.cmd = e.command_number
                    end)
                    client.set_event_callback("predict_command", function(e)
                        if e.command_number == func.defensive.cmd then
                            local tickbase = entity.get_prop(entity.get_local_player(), "m_nTickBase")
                            func.defensive.defensive = math.abs(tickbase - func.defensive.check)
                            func.defensive.check = math.max(tickbase, func.defensive.check or 0)
                            func.defensive.cmd = 0
                        end
                    end)
                    client.set_event_callback("level_init", function() func.defensive.check, func.defensive.defensive = 0, 0 end)
        
                    local clantag_anim = function(text, indices)
                        local text_anim = "               " .. text ..                       "" 
                        local tickinterval = globals.tickinterval()
                        local tickcount = globals.tickcount() + func.time_to_ticks(client.latency())
                        local i = tickcount / func.time_to_ticks(0.3)
                        i = math.floor(i % #indices)
                        i = indices[i+1]+1
                        return string.sub(text_anim, i, i+15)
                    end
        
                    local trashtalk = function(e)
        
                        local victim_userid, attacker_userid = e.userid, e.attacker
                        if victim_userid == nil or attacker_userid == nil then
                            return
                        end
        
                        local victim_entindex   = client.userid_to_entindex(victim_userid)
                        local attacker_entindex = client.userid_to_entindex(attacker_userid)
                        if attacker_entindex == entity.get_local_player() and entity.is_enemy(victim_entindex) then
                            local phrase = kill[math.random(1, #kill)]
                            local say = 'say ' .. phrase
                            client.exec(say)
                        end
                    end
        
                    local color_text = function( string, r, g, b, a)
                        local accent = "\a" .. func.RGBAtoHEX(r, g, b, a)
                        local white = "\a" .. func.RGBAtoHEX(255, 255, 255, a)
        
                        local str = ""
                        for i, s in ipairs(func.split(string, "$")) do
                            str = str .. (i % 2 ==( string:sub(1, 1) == "$" and 0 or 1) and white or accent) .. s
                        end
        
                        return str
                    end
        
                    local animate_text = function(time, string, r, g, b, a)
                        local t_out, t_out_iter = { }, 1
        
                        local l = string:len( ) - 1
        
                        local r_add = (255 - r)
                        local g_add = (255 - g)
                        local b_add = (255 - b)
                        local a_add = (165 - a)
        
                        for i = 1, #string do
                            local iter = (i - 1)/(#string - 1) + time
                            t_out[t_out_iter] = "\a" .. func.RGBAtoHEX( r + r_add * math.abs(math.cos( iter )), g + g_add * math.abs(math.cos( iter )), b + b_add * math.abs(math.cos( iter )), a + a_add * math.abs(math.cos( iter )) )
        
                            t_out[t_out_iter + 1] = string:sub( i, i )
        
                            t_out_iter = t_out_iter + 2
                        end
        
                        return t_out
                    end
        
                    local glow_module = function(x, y, w, h, width, rounding, accent, accent_inner)
                        local thickness = 1
                        local Offset = 1
                        local r, g, b, a = unpack(accent)
                        if accent_inner then
                            func.rec(x, y, w, h + 1, rounding, accent_inner)
                        end
                        for k = 0, width do
                            if a * (k/width)^(1) > 5 then
                                local accent = {r, g, b, a * (k/width)^(2)}
                                func.rec_outline(x + (k - width - Offset)*thickness, y + (k - width - Offset) * thickness, w - (k - width - Offset)*thickness*2, h + 1 - (k - width - Offset)*thickness*2, rounding + thickness * (width - k + Offset), thickness, accent)
                            end
                        end
                    end
        
                    local colorful_text = {
                        lerp = function(self, from, to, duration)
                            if type(from) == 'table' and type(to) == 'table' then
                                return { 
                                    self:lerp(from[1], to[1], duration), 
                                    self:lerp(from[2], to[2], duration), 
                                    self:lerp(from[3], to[3], duration) 
                                };
                            end
                        
                            return from + (to - from) * duration;
                        end,
                        console = function(self, ...)
                            for i, v in ipairs({ ... }) do
                                if type(v[1]) == 'table' and type(v[2]) == 'table' and type(v[3]) == 'string' then
                                    for k = 1, #v[3] do
                                        local l = self:lerp(v[1], v[2], k / #v[3]);
                                        client.color_log(l[1], l[2], l[3], v[3]:sub(k, k) .. '\0');
                                    end
                                elseif type(v[1]) == 'table' and type(v[2]) == 'string' then
                                    client.color_log(v[1][1], v[1][2], v[1][3], v[2] .. '\0');
                                end
                            end
                        end,
                        text = function(self, ...)
                            local menu = false;
                            local alpha = 255
                            local f = '';
                            
                            for i, v in ipairs({ ... }) do
                                if type(v) == 'boolean' then
                                    menu = v;
                                elseif type(v) == 'number' then
                                    alpha = v;
                                elseif type(v) == 'string' then
                                    f = f .. v;
                                elseif type(v) == 'table' then
                                    if type(v[1]) == 'table' and type(v[2]) == 'string' then
                                        f = f .. ('\a%02x%02x%02x%02x'):format(v[1][1], v[1][2], v[1][3], alpha) .. v[2];
                                    elseif type(v[1]) == 'table' and type(v[2]) == 'table' and type(v[3]) == 'string' then
                                        for k = 1, #v[3] do
                                            local g = self:lerp(v[1], v[2], k / #v[3])
                                            f = f .. ('\a%02x%02x%02x%02x'):format(g[1], g[2], g[3], alpha) .. v[3]:sub(k, k)
                                        end
                                    end
                                end
                            end
                        
                            return ('%s\a%s%02x'):format(f, (menu) and 'cdcdcd' or 'ffffff', alpha);
                        end,
                        log = function(self, ...)
                            for i, v in ipairs({ ... }) do
                                if type(v) == 'table' then
                                    if type(v[1]) == 'table' then
                                        if type(v[2]) == 'string' then
                                            self:console({ v[1], v[1], v[2] })
                                            if (v[3]) then
                                                self:console({ { 255, 255, 255 }, '\n' })
                                            end
                                        elseif type(v[2]) == 'table' then
                                            self:console({ v[1], v[2], v[3] })
                                            if v[4] then
                                                self:console({ { 255, 255, 255 }, '\n' })
                                            end
                                        end
                                    elseif type(v[1]) == 'string' then
                                        self:console({ { 205, 205, 205 }, v[1] });
                                        if v[2] then
                                            self:console({ { 255, 255, 255 }, '\n' })
                                        end
                                    end
                                end
                            end
                        end
                    }
                    -- @region FUNCS end
        
                    -- @region UI_LAYOUT start
                    local tab, container = "AA", "Anti-aimbot angles"
                    local masterSwitch = ui.new_checkbox(tab, container, func.hex({lua_color.r, lua_color.g, lua_color.b}) .. '› ' .. lua_name)
                    local tabPicker = ui.new_combobox(tab, container, "\nTab", "Home", "Anti-aim", "Builder", "Visuals", "Misc", "Config")
        
                    local menu = {
                        homeTab = {
                            ui.new_label(tab, container, func.hex({lua_color.r, lua_color.g, lua_color.b}) .. "     >\\ gengar - Best script </"),
                            ui.new_label(tab, container, "                 coded by"),
                            ui.new_label(tab, container, func.hex({lua_color.r, lua_color.g, lua_color.b}) .. "              sk33ter & nil"),
                        },
                        aaTab = {
                            fixHideshots = ui.new_checkbox(tab, container, "Adjust fakelag limit"),
                            dtDischarge = ui.new_checkbox(tab, container, "Discharge Exploit"),
                            safeKnife = ui.new_checkbox(tab, container, "Safe Knife"),
                            BombEfix = ui.new_checkbox(tab, container, "Fix E Bombsite"),
                            freestandHotkey = ui.new_hotkey(tab, container, "Freestand"),
                            freestandDisablers = ui.new_multiselect(tab, container, "› Disablers", {"Air", "Slow Walk", "Crouch", "Manual"}),
                            edgeYawHotkey = ui.new_hotkey(tab, container, "Edge Yaw"),
                            avoidBackstab = ui.new_slider(tab, container, "Avoid Backstab", 0, 300, 0, true, "u", 1, {[0] = "Off"}),
                            staticManuals = ui.new_checkbox(tab, container, "Static on manuals"),
                            manualTab = {
                                manualLeft = ui.new_hotkey(tab, container, "Manual " .. func.hex({200,200,200}) .. "left"),
                                manualRight = ui.new_hotkey(tab, container, "Manual " .. func.hex({200,200,200}) .. "right"),
                                manualReset = ui.new_hotkey(tab, container, "Manual " .. func.hex({200,200,200}) .. "reset"),
                                manualForward = ui.new_hotkey(tab, container, "Manual " .. func.hex({200,200,200}) .. "forward"),
                            },
                        },
                        builderTab = {
                            LogicComboBox = ui.new_combobox(tab, container, "logica secret", "1", "2"),
                            PresetComboBox = ui.new_combobox(tab, container, "Presets", "Disabled", "gengar.tech"),
                            buttonPresets = ui.new_button(tab, container, "Go to Presets", function() end),
                            buttonBuilder = ui.new_button(tab, container, "Go to Builder", function() end),
                            state = ui.new_combobox(tab, container, "Anti-aim state", vars.aaStates)
                        },
                        visualsTab = {
                            indicators = ui.new_combobox(tab, container, "Indicators", "Disabled", "Soft"),
                            indicatorsClr = ui.new_color_picker(tab, container, "Main Color", lua_color.r, lua_color.g, lua_color.b, 255),
                            indicatorsStyle = ui.new_multiselect(tab, container, "\n Elements", "Name", "State", "Doubletap", "Hideshots", "Freestand", "Safepoint", "Body aim", "Fakeduck"),
                            arrows = ui.new_checkbox(tab, container, "Arrows"),
                            arrowClr = ui.new_color_picker(tab, container, "Arrow Color", lua_color.r, lua_color.g, lua_color.b, 255),
                            arrowIndicatorStyle = ui.new_combobox(tab, container, "\n arrows style", "-", "Teamskeet", "Standart"),
                            minDmgIndicator = ui.new_checkbox(tab, container, "Minimum Damage Indicator"),
                            logs = ui.new_checkbox(tab, container, "Hit/Miss Logs"),
                            logsinfo = ui.new_multiselect(tab, container, "Output", "Console", "Screen"),
                            logsClr = ui.new_color_picker(tab, container, "Logs Color", lua_color.r, lua_color.g, lua_color.b, 255),
                            logOffset = ui.new_slider(tab, container, "Offset", 0, 500, 100, true, "px", 1)
                        },
                        miscTab = {
                            devPrint = ui.new_checkbox(tab, container, "Upper left logs"),
                            clanTag = ui.new_checkbox(tab, container, "Clantag"),
                            trashTalk = ui.new_checkbox(tab, container, "Trashtalk"),
                            fastLadderEnabled = ui.new_checkbox(tab, container, "Fast ladder"),
                            animationsEnabled = ui.new_checkbox(tab, container, "Anim breakers"),
                            animations = ui.new_multiselect(tab, container, "\n animation breakers", "Static legs", "In air", "On land", "Leg fucker", "Allah legs", "Haram legs", "Blend legs"),
                            resolver = ui.new_checkbox(tab, container, func.hex({lua_color.r, lua_color.g, lua_color.b}) .. '› ' .. "gengar resolver [experimental]"),
                        },
                        configTab = {
                            list = ui.new_listbox(tab, container, "Configs", ""),
                            name = ui.new_textbox(tab, container, "Config name", ""),
                            load = ui.new_button(tab, container, "Load", function() end),
                            save = ui.new_button(tab, container, "Save", function() end),
                            delete = ui.new_button(tab, container, "Delete", function() end),
                            import = ui.new_button(tab, container, "Import", function() end),
                            export = ui.new_button(tab, container, "Export", function() end)
                        },
                        configTab2 = {
                            WarningConfig = ui.new_checkbox(tab, container, "* There's nothing because AA preset is active"),
                            WarningConfig2 = ui.new_checkbox(tab, container, "* Disable preset to activate Config AA builder")
                        }
                    }
        
                    local aaBuilder = {}
                    local aaContainer = {}
                    for i=1, #vars.aaStates do
                        aaContainer[i] = func.hex({200,200,200}) .. "(" .. func.hex({222,55,55}) .. "" .. vars.pStates[i] .. "" .. func.hex({200,200,200}) .. ")" .. func.hex({155,155,155}) .. " "
                        aaBuilder[i] = {
                            enableState = ui.new_checkbox(tab, container, "Enable " .. func.hex({lua_color.r, lua_color.g, lua_color.b}) .. vars.aaStates[i] .. func.hex({200,200,200}) .. " state"),
                            pitch = ui.new_combobox(tab, container, "Pitch\n" .. aaContainer[i], "Off", "Default", "Up", "Down", "Minimal", "Random", "Custom"),
                            pitchSlider = ui.new_slider(tab, container, "\nPitch add" .. aaContainer[i], -89, 89, 0, true, "°", 1),
                            yawBase = ui.new_combobox(tab, container, "Yaw base\n" .. aaContainer[i], "Local view", "At targets"),
                            yaw = ui.new_combobox(tab, container, "Yaw\n" .. aaContainer[i], "Off", "180", "Spin", "180 Z"),
                            yawCondition = ui.new_combobox(tab, container, "Yaw condition\n" .. aaContainer[i], "Static", "L & R", "Slow", "Hold"),
                            yawStatic = ui.new_slider(tab, container, "\nyaw limit" .. aaContainer[i], -180, 180, 0, true, "°", 1),
                            yawLeft = ui.new_slider(tab, container, "Left\nyaw" .. aaContainer[i], -180, 180, 0, true, "°", 1),
                            yawRight = ui.new_slider(tab, container, "Right\nyaw" .. aaContainer[i], -180, 180, 0, true, "°", 1),
                            yawSpeed = ui.new_slider(tab, container, "Speed\nyaw" .. aaContainer[i], 1, 14, 6, 0),
                            yawJitter = ui.new_combobox(tab, container, "Yaw jitter\n" .. aaContainer[i], "Off", "Offset", "Center", "3-Way", "Random"),
                            yawJitterCondition = ui.new_combobox(tab, container, "Yaw jitter condition\n" .. aaContainer[i], "Static", "L & R"),
                            yawJitterStatic = ui.new_slider(tab, container, "\nyaw jitter limit" .. aaContainer[i], -180, 180, 0, true, "°", 1),
                            yawJitterLeft = ui.new_slider(tab, container, "Left\nyaw jitter" .. aaContainer[i], -180, 180, 0, true, "°", 1),
                            yawJitterRight = ui.new_slider(tab, container, "Right\nyaw jitter" .. aaContainer[i], -180, 180, 0, true, "°", 1),
                            yawJitterDisablers = ui.new_multiselect(tab, container, "Jitter disablers\n" .. aaContainer[i], "Head safety", "Height advantage"),
                            bodyYaw = ui.new_combobox(tab, container, "Body yaw\n" .. aaContainer[i], "Off", "Opposite", "Jitter", "Static"),
                            bodyYawSlider = ui.new_slider(tab, container, "\nbody yaw limit" .. aaContainer[i], -180, 180, 0, true, "°", 1),
                            defensiveOpt = ui.new_multiselect(tab, container, "Defensive options\n" .. aaContainer[i], "Elusive mode", "Always on"),
                            defensiveYaw = ui.new_combobox(tab, container, "Defensive yaw\n" .. aaContainer[i], "-", "Random", "Jitter", "Custom"),
                            defensiveYawSlider = ui.new_slider(tab, container, "\nDefensiveYawSlider" .. aaContainer[i], -180, 180, 0, true, "", 1),
                            defensivePitch = ui.new_combobox(tab, container, "Defensive pitch\n" .. aaContainer[i], "-", "Custom"),
                            defensivePitchSlider = ui.new_slider(tab, container, "\nDefensivePitchSlider" .. aaContainer[i], -89, 89, 0, true, "°", 1),
                        }
                    end
        
                    local function getConfig(name)
                        local database = database.read(lua.database.configs) or {}
        
                        for i, v in pairs(database) do
                            if v.name == name then
                                return {
                                    config = v.config,
                                    index = i
                                }
                            end
                        end
        
                        for i, v in pairs(presets) do
                            if v.name == name then
                                return {
                                    config = v.config,
                                    index = i
                                }
                            end
                        end
        
                        return false
                    end
                    local function saveConfig(name)
                        local db = database.read(lua.database.configs) or {}
                        local config = {}
        
                        if name:match("[^%w]") ~= nil then
                            return
                        end
        
                        for key, value in pairs(vars.pStates) do
                            config[value] = {}
                            for k, v in pairs(aaBuilder[key]) do
                                config[value][k] = ui.get(v)
                            end
                        end
        
                        local cfg = getConfig(name)
        
                        if not cfg then
                            table.insert(db, { name = name, config = config })
                        else
                            db[cfg.index].config = config
                        end
        
                        database.write(lua.database.configs, db)
                    end
                    local function deleteConfig(name)
                        local db = database.read(lua.database.configs) or {}
        
                        for i, v in pairs(db) do
                            if v.name == name then
                                table.remove(db, i)
                                break
                            end
                        end
        
                        for i, v in pairs(presets) do
                            if v.name == name then
                                return false
                            end
                        end
        
                        database.write(lua.database.configs, db)
                    end
                    local function getConfigList()
                        local database = database.read(lua.database.configs) or {}
                        local config = {}
        
                        for i, v in pairs(presets) do
                            table.insert(config, v.name)
                        end
        
                        for i, v in pairs(database) do
                            table.insert(config, v.name)
                        end
        
                        return config
                    end
                    local function typeFromString(input)
                        if type(input) ~= "string" then return input end
        
                        local value = input:lower()
        
                        if value == "true" then
                            return true
                        elseif value == "false" then
                            return false
                        elseif tonumber(value) ~= nil then
                            return tonumber(value)
                        else
                            return tostring(input)
                        end
                    end
                    local inspect = try_require('gamesense/inspect')
                    local function loadSettings(e)
                        for key, value in pairs(vars.pStates) do
                            for k, v in pairs(aaBuilder[key]) do
                                if (e[value][k] ~= nil) then
                                    ui.set(v, e[value][k])
                                end
                            end 
                        end
                    end
                    local alph = "base64"
                    local function importSettings()
                        local frombuffer = clipboard.get()
                        local decode = base64.decode(frombuffer, alph)
                        local toTable = json.parse(decode)
                        loadSettings(toTable.config)
                    end
                    local function importPreset()
                        local frombuffer = "eyJpbmRleCI6NywiY29uZmlnIjp7IkxBIjp7InBpdGNoIjoiT2ZmIiwicGl0Y2hTbGlkZXIiOjAsImJvZHlZYXdTbGlkZXIiOjAsInlhd0ppdHRlckxlZnQiOjAsInlhd0ppdHRlclJpZ2h0IjowLCJib2R5WWF3IjoiT2ZmIiwiZGVmZW5zaXZlUGl0Y2giOiItIiwiZGVmZW5zaXZlUGl0Y2hTbGlkZXIiOjAsImVuYWJsZVN0YXRlIjpmYWxzZSwiZGVmZW5zaXZlWWF3IjoiLSIsInlhd1JpZ2h0IjowLCJ5YXdKaXR0ZXJEaXNhYmxlcnMiOnt9LCJ5YXdTdGF0aWMiOjAsInlhdyI6Ik9mZiIsInlhd0NvbmRpdGlvbiI6IlN0YXRpYyIsInlhd0ppdHRlckNvbmRpdGlvbiI6IlN0YXRpYyIsInlhd0ppdHRlciI6Ik9mZiIsInlhd1NwZWVkIjo2LCJ5YXdKaXR0ZXJTdGF0aWMiOjAsImRlZmVuc2l2ZU9wdCI6e30sInlhd0xlZnQiOjAsImRlZmVuc2l2ZVlhd1NsaWRlciI6MCwieWF3QmFzZSI6IkxvY2FsIHZpZXcifSwiU1ciOnsicGl0Y2giOiJPZmYiLCJwaXRjaFNsaWRlciI6MCwiYm9keVlhd1NsaWRlciI6MCwieWF3Sml0dGVyTGVmdCI6MCwieWF3Sml0dGVyUmlnaHQiOjAsImJvZHlZYXciOiJPZmYiLCJkZWZlbnNpdmVQaXRjaCI6Ii0iLCJkZWZlbnNpdmVQaXRjaFNsaWRlciI6MCwiZW5hYmxlU3RhdGUiOmZhbHNlLCJkZWZlbnNpdmVZYXciOiItIiwieWF3UmlnaHQiOjAsInlhd0ppdHRlckRpc2FibGVycyI6e30sInlhd1N0YXRpYyI6MCwieWF3IjoiT2ZmIiwieWF3Q29uZGl0aW9uIjoiU3RhdGljIiwieWF3Sml0dGVyQ29uZGl0aW9uIjoiU3RhdGljIiwieWF3Sml0dGVyIjoiT2ZmIiwieWF3U3BlZWQiOjYsInlhd0ppdHRlclN0YXRpYyI6MCwiZGVmZW5zaXZlT3B0Ijp7fSwieWF3TGVmdCI6MCwiZGVmZW5zaXZlWWF3U2xpZGVyIjowLCJ5YXdCYXNlIjoiTG9jYWwgdmlldyJ9LCJTIjp7InBpdGNoIjoiRGVmYXVsdCIsInBpdGNoU2xpZGVyIjowLCJib2R5WWF3U2xpZGVyIjotMSwieWF3Sml0dGVyTGVmdCI6MCwieWF3Sml0dGVyUmlnaHQiOjAsImJvZHlZYXciOiJKaXR0ZXIiLCJkZWZlbnNpdmVQaXRjaCI6Ii0iLCJkZWZlbnNpdmVQaXRjaFNsaWRlciI6MCwiZW5hYmxlU3RhdGUiOnRydWUsImRlZmVuc2l2ZVlhdyI6Ii0iLCJ5YXdSaWdodCI6NDIsInlhd0ppdHRlckRpc2FibGVycyI6e30sInlhd1N0YXRpYyI6MCwieWF3IjoiMTgwIiwieWF3Q29uZGl0aW9uIjoiTCAmIFIiLCJ5YXdKaXR0ZXJDb25kaXRpb24iOiJTdGF0aWMiLCJ5YXdKaXR0ZXIiOiJPZmYiLCJ5YXdTcGVlZCI6NiwieWF3Sml0dGVyU3RhdGljIjowLCJkZWZlbnNpdmVPcHQiOnt9LCJ5YXdMZWZ0IjotMjMsImRlZmVuc2l2ZVlhd1NsaWRlciI6MCwieWF3QmFzZSI6IkF0IHRhcmdldHMifSwiQUMiOnsicGl0Y2giOiJEZWZhdWx0IiwicGl0Y2hTbGlkZXIiOjAsImJvZHlZYXdTbGlkZXIiOi0xLCJ5YXdKaXR0ZXJMZWZ0IjowLCJ5YXdKaXR0ZXJSaWdodCI6MCwiYm9keVlhdyI6IkppdHRlciIsImRlZmVuc2l2ZVBpdGNoIjoiLSIsImRlZmVuc2l2ZVBpdGNoU2xpZGVyIjotNDUsImVuYWJsZVN0YXRlIjp0cnVlLCJkZWZlbnNpdmVZYXciOiItIiwieWF3UmlnaHQiOjM4LCJ5YXdKaXR0ZXJEaXNhYmxlcnMiOnt9LCJ5YXdTdGF0aWMiOjAsInlhdyI6IjE4MCIsInlhd0NvbmRpdGlvbiI6IkwgJiBSIiwieWF3Sml0dGVyQ29uZGl0aW9uIjoiU3RhdGljIiwieWF3Sml0dGVyIjoiT2ZmIiwieWF3U3BlZWQiOjYsInlhd0ppdHRlclN0YXRpYyI6MCwiZGVmZW5zaXZlT3B0IjpbIkFsd2F5cyBvbiJdLCJ5YXdMZWZ0IjotMTYsImRlZmVuc2l2ZVlhd1NsaWRlciI6MCwieWF3QmFzZSI6IkF0IHRhcmdldHMifSwiQSI6eyJwaXRjaCI6IkRlZmF1bHQiLCJwaXRjaFNsaWRlciI6MCwiYm9keVlhd1NsaWRlciI6LTEsInlhd0ppdHRlckxlZnQiOjAsInlhd0ppdHRlclJpZ2h0IjowLCJib2R5WWF3IjoiSml0dGVyIiwiZGVmZW5zaXZlUGl0Y2giOiItIiwiZGVmZW5zaXZlUGl0Y2hTbGlkZXIiOjg5LCJlbmFibGVTdGF0ZSI6dHJ1ZSwiZGVmZW5zaXZlWWF3IjoiLSIsInlhd1JpZ2h0IjozOCwieWF3Sml0dGVyRGlzYWJsZXJzIjp7fSwieWF3U3RhdGljIjowLCJ5YXciOiIxODAiLCJ5YXdDb25kaXRpb24iOiJMICYgUiIsInlhd0ppdHRlckNvbmRpdGlvbiI6IlN0YXRpYyIsInlhd0ppdHRlciI6Ik9mZiIsInlhd1NwZWVkIjo2LCJ5YXdKaXR0ZXJTdGF0aWMiOjAsImRlZmVuc2l2ZU9wdCI6WyJBbHdheXMgb24iXSwieWF3TGVmdCI6LTMzLCJkZWZlbnNpdmVZYXdTbGlkZXIiOjAsInlhd0Jhc2UiOiJBdCB0YXJnZXRzIn0sIk0iOnsicGl0Y2giOiJEZWZhdWx0IiwicGl0Y2hTbGlkZXIiOjAsImJvZHlZYXdTbGlkZXIiOi0xLCJ5YXdKaXR0ZXJMZWZ0IjowLCJ5YXdKaXR0ZXJSaWdodCI6MCwiYm9keVlhdyI6IkppdHRlciIsImRlZmVuc2l2ZVBpdGNoIjoiLSIsImRlZmVuc2l2ZVBpdGNoU2xpZGVyIjowLCJlbmFibGVTdGF0ZSI6dHJ1ZSwiZGVmZW5zaXZlWWF3IjoiLSIsInlhd1JpZ2h0IjozNywieWF3Sml0dGVyRGlzYWJsZXJzIjp7fSwieWF3U3RhdGljIjowLCJ5YXciOiIxODAiLCJ5YXdDb25kaXRpb24iOiJMICYgUiIsInlhd0ppdHRlckNvbmRpdGlvbiI6IlN0YXRpYyIsInlhd0ppdHRlciI6Ik9mZiIsInlhd1NwZWVkIjozLCJ5YXdKaXR0ZXJTdGF0aWMiOjAsImRlZmVuc2l2ZU9wdCI6e30sInlhd0xlZnQiOi0yOSwiZGVmZW5zaXZlWWF3U2xpZGVyIjowLCJ5YXdCYXNlIjoiQXQgdGFyZ2V0cyJ9LCJDIjp7InBpdGNoIjoiRGVmYXVsdCIsInBpdGNoU2xpZGVyIjowLCJib2R5WWF3U2xpZGVyIjotMSwieWF3Sml0dGVyTGVmdCI6MCwieWF3Sml0dGVyUmlnaHQiOjAsImJvZHlZYXciOiJKaXR0ZXIiLCJkZWZlbnNpdmVQaXRjaCI6Ii0iLCJkZWZlbnNpdmVQaXRjaFNsaWRlciI6LTQ1LCJlbmFibGVTdGF0ZSI6dHJ1ZSwiZGVmZW5zaXZlWWF3IjoiLSIsInlhd1JpZ2h0IjoyMywieWF3Sml0dGVyRGlzYWJsZXJzIjp7fSwieWF3U3RhdGljIjoyOCwieWF3IjoiMTgwIiwieWF3Q29uZGl0aW9uIjoiU2xvdyIsInlhd0ppdHRlckNvbmRpdGlvbiI6IlN0YXRpYyIsInlhd0ppdHRlciI6Ik9mZiIsInlhd1NwZWVkIjozLCJ5YXdKaXR0ZXJTdGF0aWMiOjAsImRlZmVuc2l2ZU9wdCI6WyJBbHdheXMgb24iXSwieWF3TGVmdCI6LTE5LCJkZWZlbnNpdmVZYXdTbGlkZXIiOjAsInlhd0Jhc2UiOiJBdCB0YXJnZXRzIn0sIkciOnsicGl0Y2giOiJEZWZhdWx0IiwicGl0Y2hTbGlkZXIiOjAsImJvZHlZYXdTbGlkZXIiOi0xLCJ5YXdKaXR0ZXJMZWZ0IjowLCJ5YXdKaXR0ZXJSaWdodCI6MCwiYm9keVlhdyI6IkppdHRlciIsImRlZmVuc2l2ZVBpdGNoIjoiLSIsImRlZmVuc2l2ZVBpdGNoU2xpZGVyIjowLCJlbmFibGVTdGF0ZSI6dHJ1ZSwiZGVmZW5zaXZlWWF3IjoiLSIsInlhd1JpZ2h0IjozOSwieWF3Sml0dGVyRGlzYWJsZXJzIjp7fSwieWF3U3RhdGljIjowLCJ5YXciOiIxODAiLCJ5YXdDb25kaXRpb24iOiJTbG93IiwieWF3Sml0dGVyQ29uZGl0aW9uIjoiU3RhdGljIiwieWF3Sml0dGVyIjoiT2ZmIiwieWF3U3BlZWQiOjUsInlhd0ppdHRlclN0YXRpYyI6MCwiZGVmZW5zaXZlT3B0Ijp7fSwieWF3TGVmdCI6LTI4LCJkZWZlbnNpdmVZYXdTbGlkZXIiOjAsInlhd0Jhc2UiOiJBdCB0YXJnZXRzIn19fQ=="
                        local decode = base64.decode(frombuffer, alph)
                        local toTable = json.parse(decode)
                        loadSettings(toTable.config)
                    end
                    local function importPresetClear()
                        local frombuffer = "eyJpbmRleCI6OCwiY29uZmlnIjp7IkxBIjp7InBpdGNoIjoiT2ZmIiwicGl0Y2hTbGlkZXIiOjAsImJvZHlZYXdTbGlkZXIiOjAsInlhd0ppdHRlckxlZnQiOjAsInlhd0ppdHRlclJpZ2h0IjowLCJib2R5WWF3IjoiT2ZmIiwiZGVmZW5zaXZlUGl0Y2giOiItIiwiZGVmZW5zaXZlUGl0Y2hTbGlkZXIiOjAsImVuYWJsZVN0YXRlIjpmYWxzZSwiZGVmZW5zaXZlWWF3IjoiLSIsInlhd1JpZ2h0IjowLCJ5YXdKaXR0ZXJEaXNhYmxlcnMiOnt9LCJ5YXdTdGF0aWMiOjAsInlhdyI6Ik9mZiIsInlhd0NvbmRpdGlvbiI6IlN0YXRpYyIsInlhd0ppdHRlckNvbmRpdGlvbiI6IlN0YXRpYyIsInlhd0ppdHRlciI6Ik9mZiIsInlhd1NwZWVkIjo2LCJ5YXdKaXR0ZXJTdGF0aWMiOjAsImRlZmVuc2l2ZU9wdCI6e30sInlhd0xlZnQiOjAsImRlZmVuc2l2ZVlhd1NsaWRlciI6MCwieWF3QmFzZSI6IkxvY2FsIHZpZXcifSwiU1ciOnsicGl0Y2giOiJPZmYiLCJwaXRjaFNsaWRlciI6MCwiYm9keVlhd1NsaWRlciI6MCwieWF3Sml0dGVyTGVmdCI6MCwieWF3Sml0dGVyUmlnaHQiOjAsImJvZHlZYXciOiJPZmYiLCJkZWZlbnNpdmVQaXRjaCI6Ii0iLCJkZWZlbnNpdmVQaXRjaFNsaWRlciI6MCwiZW5hYmxlU3RhdGUiOmZhbHNlLCJkZWZlbnNpdmVZYXciOiItIiwieWF3UmlnaHQiOjAsInlhd0ppdHRlckRpc2FibGVycyI6e30sInlhd1N0YXRpYyI6MCwieWF3IjoiT2ZmIiwieWF3Q29uZGl0aW9uIjoiU3RhdGljIiwieWF3Sml0dGVyQ29uZGl0aW9uIjoiU3RhdGljIiwieWF3Sml0dGVyIjoiT2ZmIiwieWF3U3BlZWQiOjYsInlhd0ppdHRlclN0YXRpYyI6MCwiZGVmZW5zaXZlT3B0Ijp7fSwieWF3TGVmdCI6MCwiZGVmZW5zaXZlWWF3U2xpZGVyIjowLCJ5YXdCYXNlIjoiTG9jYWwgdmlldyJ9LCJTIjp7InBpdGNoIjoiT2ZmIiwicGl0Y2hTbGlkZXIiOjAsImJvZHlZYXdTbGlkZXIiOjAsInlhd0ppdHRlckxlZnQiOjAsInlhd0ppdHRlclJpZ2h0IjowLCJib2R5WWF3IjoiT2ZmIiwiZGVmZW5zaXZlUGl0Y2giOiItIiwiZGVmZW5zaXZlUGl0Y2hTbGlkZXIiOjAsImVuYWJsZVN0YXRlIjpmYWxzZSwiZGVmZW5zaXZlWWF3IjoiLSIsInlhd1JpZ2h0IjowLCJ5YXdKaXR0ZXJEaXNhYmxlcnMiOnt9LCJ5YXdTdGF0aWMiOjAsInlhdyI6Ik9mZiIsInlhd0NvbmRpdGlvbiI6IlN0YXRpYyIsInlhd0ppdHRlckNvbmRpdGlvbiI6IlN0YXRpYyIsInlhd0ppdHRlciI6Ik9mZiIsInlhd1NwZWVkIjo2LCJ5YXdKaXR0ZXJTdGF0aWMiOjAsImRlZmVuc2l2ZU9wdCI6e30sInlhd0xlZnQiOjAsImRlZmVuc2l2ZVlhd1NsaWRlciI6MCwieWF3QmFzZSI6IkxvY2FsIHZpZXcifSwiQUMiOnsicGl0Y2giOiJPZmYiLCJwaXRjaFNsaWRlciI6MCwiYm9keVlhd1NsaWRlciI6MCwieWF3Sml0dGVyTGVmdCI6MCwieWF3Sml0dGVyUmlnaHQiOjAsImJvZHlZYXciOiJPZmYiLCJkZWZlbnNpdmVQaXRjaCI6Ii0iLCJkZWZlbnNpdmVQaXRjaFNsaWRlciI6MCwiZW5hYmxlU3RhdGUiOmZhbHNlLCJkZWZlbnNpdmVZYXciOiItIiwieWF3UmlnaHQiOjAsInlhd0ppdHRlckRpc2FibGVycyI6e30sInlhd1N0YXRpYyI6MCwieWF3IjoiT2ZmIiwieWF3Q29uZGl0aW9uIjoiU3RhdGljIiwieWF3Sml0dGVyQ29uZGl0aW9uIjoiU3RhdGljIiwieWF3Sml0dGVyIjoiT2ZmIiwieWF3U3BlZWQiOjYsInlhd0ppdHRlclN0YXRpYyI6MCwiZGVmZW5zaXZlT3B0Ijp7fSwieWF3TGVmdCI6MCwiZGVmZW5zaXZlWWF3U2xpZGVyIjowLCJ5YXdCYXNlIjoiTG9jYWwgdmlldyJ9LCJBIjp7InBpdGNoIjoiT2ZmIiwicGl0Y2hTbGlkZXIiOjAsImJvZHlZYXdTbGlkZXIiOjAsInlhd0ppdHRlckxlZnQiOjAsInlhd0ppdHRlclJpZ2h0IjowLCJib2R5WWF3IjoiT2ZmIiwiZGVmZW5zaXZlUGl0Y2giOiItIiwiZGVmZW5zaXZlUGl0Y2hTbGlkZXIiOjAsImVuYWJsZVN0YXRlIjpmYWxzZSwiZGVmZW5zaXZlWWF3IjoiLSIsInlhd1JpZ2h0IjowLCJ5YXdKaXR0ZXJEaXNhYmxlcnMiOnt9LCJ5YXdTdGF0aWMiOjAsInlhdyI6Ik9mZiIsInlhd0NvbmRpdGlvbiI6IlN0YXRpYyIsInlhd0ppdHRlckNvbmRpdGlvbiI6IlN0YXRpYyIsInlhd0ppdHRlciI6Ik9mZiIsInlhd1NwZWVkIjo2LCJ5YXdKaXR0ZXJTdGF0aWMiOjAsImRlZmVuc2l2ZU9wdCI6e30sInlhd0xlZnQiOjAsImRlZmVuc2l2ZVlhd1NsaWRlciI6MCwieWF3QmFzZSI6IkxvY2FsIHZpZXcifSwiTSI6eyJwaXRjaCI6Ik9mZiIsInBpdGNoU2xpZGVyIjowLCJib2R5WWF3U2xpZGVyIjowLCJ5YXdKaXR0ZXJMZWZ0IjowLCJ5YXdKaXR0ZXJSaWdodCI6MCwiYm9keVlhdyI6Ik9mZiIsImRlZmVuc2l2ZVBpdGNoIjoiLSIsImRlZmVuc2l2ZVBpdGNoU2xpZGVyIjowLCJlbmFibGVTdGF0ZSI6ZmFsc2UsImRlZmVuc2l2ZVlhdyI6Ii0iLCJ5YXdSaWdodCI6MCwieWF3Sml0dGVyRGlzYWJsZXJzIjp7fSwieWF3U3RhdGljIjowLCJ5YXciOiJPZmYiLCJ5YXdDb25kaXRpb24iOiJTdGF0aWMiLCJ5YXdKaXR0ZXJDb25kaXRpb24iOiJTdGF0aWMiLCJ5YXdKaXR0ZXIiOiJPZmYiLCJ5YXdTcGVlZCI6NiwieWF3Sml0dGVyU3RhdGljIjowLCJkZWZlbnNpdmVPcHQiOnt9LCJ5YXdMZWZ0IjowLCJkZWZlbnNpdmVZYXdTbGlkZXIiOjAsInlhd0Jhc2UiOiJMb2NhbCB2aWV3In0sIkMiOnsicGl0Y2giOiJPZmYiLCJwaXRjaFNsaWRlciI6MCwiYm9keVlhd1NsaWRlciI6MCwieWF3Sml0dGVyTGVmdCI6MCwieWF3Sml0dGVyUmlnaHQiOjAsImJvZHlZYXciOiJPZmYiLCJkZWZlbnNpdmVQaXRjaCI6Ii0iLCJkZWZlbnNpdmVQaXRjaFNsaWRlciI6MCwiZW5hYmxlU3RhdGUiOmZhbHNlLCJkZWZlbnNpdmVZYXciOiItIiwieWF3UmlnaHQiOjAsInlhd0ppdHRlckRpc2FibGVycyI6e30sInlhd1N0YXRpYyI6MCwieWF3IjoiT2ZmIiwieWF3Q29uZGl0aW9uIjoiU3RhdGljIiwieWF3Sml0dGVyQ29uZGl0aW9uIjoiU3RhdGljIiwieWF3Sml0dGVyIjoiT2ZmIiwieWF3U3BlZWQiOjYsInlhd0ppdHRlclN0YXRpYyI6MCwiZGVmZW5zaXZlT3B0Ijp7fSwieWF3TGVmdCI6MCwiZGVmZW5zaXZlWWF3U2xpZGVyIjowLCJ5YXdCYXNlIjoiTG9jYWwgdmlldyJ9LCJHIjp7InBpdGNoIjoiT2ZmIiwicGl0Y2hTbGlkZXIiOjAsImJvZHlZYXdTbGlkZXIiOjAsInlhd0ppdHRlckxlZnQiOjAsInlhd0ppdHRlclJpZ2h0IjowLCJib2R5WWF3IjoiT2ZmIiwiZGVmZW5zaXZlUGl0Y2giOiItIiwiZGVmZW5zaXZlUGl0Y2hTbGlkZXIiOjAsImVuYWJsZVN0YXRlIjp0cnVlLCJkZWZlbnNpdmVZYXciOiItIiwieWF3UmlnaHQiOjAsInlhd0ppdHRlckRpc2FibGVycyI6e30sInlhd1N0YXRpYyI6MCwieWF3IjoiT2ZmIiwieWF3Q29uZGl0aW9uIjoiU3RhdGljIiwieWF3Sml0dGVyQ29uZGl0aW9uIjoiU3RhdGljIiwieWF3Sml0dGVyIjoiT2ZmIiwieWF3U3BlZWQiOjYsInlhd0ppdHRlclN0YXRpYyI6MCwiZGVmZW5zaXZlT3B0Ijp7fSwieWF3TGVmdCI6MCwiZGVmZW5zaXZlWWF3U2xpZGVyIjowLCJ5YXdCYXNlIjoiTG9jYWwgdmlldyJ9fX0="
                        local decode = base64.decode(frombuffer, alph)
                        local toTable = json.parse(decode)
                        loadSettings(toTable.config)
                    end
                    local function exportSettings(name)
                        local config = getConfig(name)
                        local toString = json.stringify(config)
                        local toExport = base64.encode(toString, alph)
                        clipboard.set(toExport)
                    end
                    local function loadConfig(name)
                        local config = getConfig(name)
                        loadSettings(config.config)
                    end
        
                    local function initDatabase()
                        if database.read(lua.database.configs) == nil then
                            database.write(lua.database.configs, {})
                        end
        
                        local link = "https://pastebin.com/raw/afg2YkEv"
        
                        http.get(link, function(success, response)
                            if not success then
                                print("Failed to get presets")
                                return
                            end
                        
                            local data = json.parse(response.body)
                        
                            for i, preset in pairs(data.presets) do
                                table.insert(presets, { name = "*"..preset.name, config = preset.config})
                                ui.set(menu.configTab.name, "*"..preset.name)
                            end
                            ui.update(menu.configTab.list, getConfigList())
                        end)
                    end
                    initDatabase()
                    -- @region UI_LAYOUT end
        
                    -- @region NOTIFICATION_ANIM start
                    local anim_time = 0.5
                    local max_notifs = 6
                    local data = {}
                    local notifications = {
        
                        new = function(string, r, g, b)
                            table.insert(data, {
                                time = globals.curtime(),
                                string = string,
                                color = {r, g, b, 255},
                                fraction = 0
                            })
                            local time = 5
                            for i = #data, 1, -1 do
                                local notif = data[i]
                                if #data - i + 1 > max_notifs and notif.time + time - globals.curtime() > 0 then
                                    notif.time = globals.curtime() - time
                                end
                            end
                        end,
        
                        render = function()
                            local x, y = client.screen_size()
                            local to_remove = {}
                            local Offset = 0
                            for i = 1, #data do
                                local notif = data[i]
        
                                local data = {rounding = 4, size = 3, glow = 2, time = 2}
        
                                if notif.time + data.time - globals.curtime() > 0 then
                                    notif.fraction = func.clamp(notif.fraction + globals.frametime() / anim_time, 0, 1)
                                else
                                    notif.fraction = func.clamp(notif.fraction - globals.frametime() / anim_time, 0, 1)
                                end
        
                                if notif.fraction <= 0 and notif.time + data.time - globals.curtime() <= 0 then
                                    table.insert(to_remove, i)
                                end
                                local fraction = func.easeInOut(notif.fraction)
        
                                local r, g, b, a = unpack(notif.color)
                                local string = color_text(notif.string, r, g, b, a * fraction)
        
                                local strw, strh = renderer.measure_text("", string)
                                local strw2 = renderer.measure_text("b", "")
        
                                local paddingx, paddingy = 7, data.size
                                local offsetY = ui.get(menu.visualsTab.logOffset)
        
                                Offset = Offset + (strh + paddingy*2 + 	math.sqrt(data.glow/10)*10 + 5) * fraction
                                glow_module(x/2 - (strw + strw2)/2 - paddingx, y - offsetY - strh/2 - paddingy - Offset, strw + strw2 + paddingx*2, strh + paddingy*2, data.glow, data.rounding, {r, g, b, 45 * fraction}, {25,25,25,140 * fraction})
                                renderer.text(x/2 + strw2/2, y - offsetY - Offset, 255, 255, 255, 255 * fraction, "c", 0, string)
                            end
        
                            for i = #to_remove, 1, -1 do
                                table.remove(data, to_remove[i])
                            end
                        end,
        
                        clear = function()
                            data = {}
                        end
                    }
        
                    local function onHit(e)
                        local group = vars.hitgroup_names[e.hitgroup + 1] or '?'
                        local r, g, b, a = ui.get(menu.visualsTab.logsClr)
                        notifications.new(string.format("Hit %s's $%s$ for $%d$ damage ($%d$ health remaining)", entity.get_player_name(e.target), group:lower(), e.damage, entity.get_prop(e.target, 'm_iHealth')), r, g, b) 
                    end
        
                    local function onMiss(e)
                        local group = vars.hitgroup_names[e.hitgroup + 1] or '?'
                        local ping = math.min(999, client.real_latency() * 1000)
                        local ping_col = (ping >= 100) and { 255, 0, 0 } or { 150, 200, 60 }
                        local hc = math.floor(e.hit_chance + 0.5);
                        local hc_col = (hc < ui.get(refs.hitChance)) and { 255, 0, 0 } or { 150, 200, 60 };
                        e.reason = e.reason == "?" and "resolver" or e.reason
                        local console = func.includes(ui.get(menu.visualsTab.logsinfo), "Console")
                        local onscreen = func.includes(ui.get(menu.visualsTab.logsinfo), "Screen")
        
                        if onscreen then
                            notifications.new(string.format("Missed %s's $%s$ due to $%s$", entity.get_player_name(e.target), group:lower(), e.reason), 255, 120, 120)
                        end
                        
                        if console then
                            print(string.format("Missed %s's %s due to %s (hitchance: %s)", entity.get_player_name(e.target), group:lower(), e.reason, math.floor(e.hit_chance + 0.5)))
                        end
                    end
                    -- @region NOTIFICATION_ANIM end
        
                    -- @region AA_CALLBACKS start
                    local aa = {
                        ignore = false,
                        manualAA= 0,
                        input = 0,
                    }
                    client.set_event_callback("player_connect_full", function() 
                        aa.ignore = false
                        aa.manualAA= 0
                        aa.input = globals.curtime()
                    end)
        
                    local clantag = {
                        steam = steamworks.ISteamFriends,
                        prev_ct = "",
                        orig_ct = "",
                        enb = false,
                    }
        
                    local function get_original_clantag()
                        local clan_id = cvar.cl_clanid.get_int()
                        if clan_id == 0 then return "\0" end
        
                        local clan_count = clantag.steam.GetClanCount()
                        for i = 0, clan_count do 
                            local group_id = clantag.steam.GetClanByIndex(i)
                            if group_id == clan_id then
                                return clantag.steam.GetClanTag(group_id)
                            end
                        end
                    end
        
                    local current_tick = func.time_to_ticks(globals.realtime())
                    client.set_event_callback("setup_command", function(cmd)
                        vars.localPlayer = entity.get_local_player()
        
                        if not vars.localPlayer or not entity.is_alive(vars.localPlayer) or not ui.get(masterSwitch) then return end
                        local flags = entity.get_prop(vars.localPlayer, "m_fFlags")
                        local onground = bit.band(flags, 1) ~= 0 and cmd.in_jump == 0
                        local valve = entity.get_prop(entity.get_game_rules(), "m_bIsValveDS")
                        local origin = vector(entity.get_prop(vars.localPlayer, "m_vecOrigin"))
                        local velocity = vector(entity.get_prop(vars.localPlayer, "m_vecVelocity"))
                        local camera = vector(client.camera_angles())
                        local eye = vector(client.eye_position())
                        local speed = math.sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y) + (velocity.z * velocity.z))
                        local weapon = entity.get_player_weapon()
                        local pStill = math.sqrt(velocity.x ^ 2 + velocity.y ^ 2) < 5
                        local bodyYaw = entity.get_prop(vars.localPlayer, "m_flPoseParameter", 11) * 120 - 60
        
                        local weapon = entity.get_player_weapon(vars.localPlayer)
        
                        local isSlow = ui.get(refs.slow[1]) and ui.get(refs.slow[2])
                        local isOs = ui.get(refs.os[1]) and ui.get(refs.os[2])
                        local isFd = ui.get(refs.fakeDuck)
                        local isDt = ui.get(refs.dt[1]) and ui.get(refs.dt[2])
                        local isLegitAA = ui.get(aaBuilder[8].enableState) and client.key_state(0x45)
                        local isDefensive = (func.defensive.defensive > 1 and func.defensive.defensive < 14)
                        local safeKnife = ui.get(menu.aaTab.safeKnife) and entity.get_classname(weapon) == "CKnife"
        
                        -- search for states
                        vars.pState = 1
                        if pStill then vars.pState = 2 end
                        if not pStill then vars.pState = 3 end
                        if isSlow then vars.pState = 4 end
                        if entity.get_prop(vars.localPlayer, "m_flDuckAmount") > 0.1 then vars.pState = 5 end
                        if not onground then vars.pState = 6 end
                        if not onground and entity.get_prop(vars.localPlayer, "m_flDuckAmount") > 0.1 then vars.pState = 7 end
        
                        if ui.get(aaBuilder[vars.pState].enableState) == false and vars.pState ~= 1 then
                            vars.pState = 1
                        end
        
                        if isLegitAA and not vars.should_disable then
                            vars.pState = 8
                        end
        
                        local nextAttack = entity.get_prop(vars.localPlayer, "m_flNextAttack")
                        local nextPrimaryAttack = entity.get_prop(entity.get_player_weapon(vars.localPlayer), "m_flNextPrimaryAttack")
                        local dtActive = false
                        local isFl = ui.get(ui.reference("AA", "Fake lag", "Enabled"))
                        if nextPrimaryAttack ~= nil then
                            dtActive = not (math.max(nextPrimaryAttack, nextAttack) > globals.curtime())
                        end
        
                        local side_yaw = 2
                        if cmd.chokedcommands == 0 then
                            vars.choke1 = vars.choke1 + 1
                            vars.choke2 = vars.choke2 + 1
                            vars.choke3 = vars.choke3 + 1
                            vars.choke4 = vars.choke4 + 1
                        end
                        if vars.choke1 >= 5 then
                            vars.choke1 = 0
                        end
                        if vars.choke2 >= 8 then
                            vars.choke2 = 0
                        end
                        if vars.choke3 >= 8 then
                            vars.choke3 = 5
                        end
        
                        if globals.tickcount() % ui.get(aaBuilder[vars.pState].yawSpeed) == 1 then
                            vars.switch = not vars.switch
                        end
        
                        local tickcount = globals.tickcount()
        
                        local side = bodyYaw > 0 and 1 or -1
        
                            -- manual aa
                            local isStatic = ui.get(menu.aaTab.staticManuals)
        
                            ui.set(menu.aaTab.manualTab.manualLeft, "On hotkey")
                            ui.set(menu.aaTab.manualTab.manualRight, "On hotkey")
                            ui.set(menu.aaTab.manualTab.manualReset, "On hotkey")
                            ui.set(menu.aaTab.manualTab.manualForward, "On hotkey")
        
                            if aa.input + 0.182 < globals.curtime() then
                                if aa.manualAA == 0 then
                                    if ui.get(menu.aaTab.manualTab.manualLeft) then
                                        aa.manualAA = 1
                                        aa.input = globals.curtime()    
                                        ui.set(refs.pitch[1], ui.get(aaBuilder[vars.pState].pitch))
                                        ui.set(refs.pitch[2], ui.get(aaBuilder[vars.pState].pitchSlider))
                                    elseif ui.get(menu.aaTab.manualTab.manualRight) then
                                        aa.manualAA = 2
                                        aa.input = globals.curtime()
                                        ui.set(refs.pitch[1], ui.get(aaBuilder[vars.pState].pitch))
                                        ui.set(refs.pitch[2], ui.get(aaBuilder[vars.pState].pitchSlider))
                                    elseif ui.get(menu.aaTab.manualTab.manualForward) then
                                        aa.manualAA = 3
                                        aa.input = globals.curtime()
                                        ui.set(refs.pitch[1], ui.get(aaBuilder[vars.pState].pitch))
                                        ui.set(refs.pitch[2], ui.get(aaBuilder[vars.pState].pitchSlider))  
                                    elseif ui.get(menu.aaTab.manualTab.manualReset) then
                                        aa.manualAA = 0
                                        aa.input = globals.curtime()
                                        ui.set(refs.pitch[1], ui.get(aaBuilder[vars.pState].pitch))
                                        ui.set(refs.pitch[2], ui.get(aaBuilder[vars.pState].pitchSlider))  
                                    end
                                elseif aa.manualAA == 1 then
                                    if ui.get(menu.aaTab.manualTab.manualRight) then
                                        aa.manualAA = 2
                                        aa.input = globals.curtime()
                                        ui.set(refs.pitch[1], ui.get(aaBuilder[vars.pState].pitch))
                                        ui.set(refs.pitch[2], ui.get(aaBuilder[vars.pState].pitchSlider))  
                                    elseif ui.get(menu.aaTab.manualTab.manualForward) then
                                        aa.manualAA = 3
                                        aa.input = globals.curtime()
                                        ui.set(refs.pitch[1], ui.get(aaBuilder[vars.pState].pitch))
                                        ui.set(refs.pitch[2], ui.get(aaBuilder[vars.pState].pitchSlider))  
                                    elseif ui.get(menu.aaTab.manualTab.manualLeft) then
                                        aa.manualAA = 0
                                        aa.input = globals.curtime()
                                        ui.set(refs.pitch[1], ui.get(aaBuilder[vars.pState].pitch))
                                        ui.set(refs.pitch[2], ui.get(aaBuilder[vars.pState].pitchSlider))  
                                    elseif ui.get(menu.aaTab.manualTab.manualReset) then
                                        aa.manualAA = 0
                                        aa.input = globals.curtime()    
                                        ui.set(refs.pitch[1], ui.get(aaBuilder[vars.pState].pitch))
                                        ui.set(refs.pitch[2], ui.get(aaBuilder[vars.pState].pitchSlider))  
                                    end
                                elseif aa.manualAA == 2 then
                                    if ui.get(menu.aaTab.manualTab.manualLeft) then
                                        aa.manualAA = 1
                                        aa.input = globals.curtime()
                                        ui.set(refs.pitch[1], ui.get(aaBuilder[vars.pState].pitch))
                                        ui.set(refs.pitch[2], ui.get(aaBuilder[vars.pState].pitchSlider))  
                                    elseif ui.get(menu.aaTab.manualTab.manualForward) then
                                        aa.manualAA = 3
                                        aa.input = globals.curtime()
                                        ui.set(refs.pitch[1], ui.get(aaBuilder[vars.pState].pitch))
                                        ui.set(refs.pitch[2], ui.get(aaBuilder[vars.pState].pitchSlider))  
                                    elseif ui.get(menu.aaTab.manualTab.manualRight) then
                                        aa.manualAA = 0
                                        aa.input = globals.curtime()
                                        ui.set(refs.pitch[1], ui.get(aaBuilder[vars.pState].pitch))
                                        ui.set(refs.pitch[2], ui.get(aaBuilder[vars.pState].pitchSlider))  
                                    elseif ui.get(menu.aaTab.manualTab.manualReset) then
                                        aa.manualAA = 0
                                        aa.input = globals.curtime()    
                                        ui.set(refs.pitch[1], ui.get(aaBuilder[vars.pState].pitch))
                                        ui.set(refs.pitch[2], ui.get(aaBuilder[vars.pState].pitchSlider))  
                                    end
                                elseif aa.manualAA == 3 then
                                    if ui.get(menu.aaTab.manualTab.manualForward) then
                                        aa.manualAA = 0
                                        aa.input = globals.curtime()
                                        ui.set(refs.pitch[1], ui.get(aaBuilder[vars.pState].pitch))
                                        ui.set(refs.pitch[2], ui.get(aaBuilder[vars.pState].pitchSlider))  
                                    elseif ui.get(menu.aaTab.manualTab.manualLeft) then
                                        aa.manualAA = 1
                                        aa.input = globals.curtime()
                                        ui.set(refs.pitch[1], ui.get(aaBuilder[vars.pState].pitch))
                                        ui.set(refs.pitch[2], ui.get(aaBuilder[vars.pState].pitchSlider))  
                                    elseif ui.get(menu.aaTab.manualTab.manualRight) then
                                        aa.manualAA = 2
                                        aa.input = globals.curtime()
                                        ui.set(refs.pitch[1], ui.get(aaBuilder[vars.pState].pitch))
                                        ui.set(refs.pitch[2], ui.get(aaBuilder[vars.pState].pitchSlider))  
                                    elseif ui.get(menu.aaTab.manualTab.manualReset) then
                                        aa.manualAA = 0
                                        aa.input = globals.curtime()    
                                        ui.set(refs.pitch[1], ui.get(aaBuilder[vars.pState].pitch))
                                        ui.set(refs.pitch[2], ui.get(aaBuilder[vars.pState].pitchSlider))  
                                    end
                                end
        
                                if aa.manualAA == 1 or aa.manualAA == 2 or aa.manualAA == 3 then
                                    aa.ignore = true
        
                                    if isStatic then
                                        ui.set(refs.yawJitter[1], "Off")
                                        ui.set(refs.yawJitter[2], 0)
                                        ui.set(refs.bodyYaw[1], "Static")
                                        ui.set(refs.bodyYaw[2], 180)
        
                                        if aa.manualAA == 1 then
                                            ui.set(refs.yawBase, "local view")
                                            ui.set(refs.yaw[1], "180")
                                            ui.set(refs.yaw[2], -90)
                                        elseif aa.manualAA == 2 then
                                            ui.set(refs.yawBase, "local view")
                                            ui.set(refs.yaw[1], "180")
                                            ui.set(refs.yaw[2], 90)
                                        elseif aa.manualAA == 3 then
                                            ui.set(refs.yawBase, "local view")
                                            ui.set(refs.yaw[1], "180")
                                            ui.set(refs.yaw[2], 180)
                                        end
                                    elseif not isStatic and ui.get(aaBuilder[vars.pState].enableState) then
                                        if ui.get(aaBuilder[vars.pState].yawJitter) == "3-Way" then
                                            ui.set(refs.yawJitter[1], "Center")
                                            ui.set(refs.yawJitter[2], (side == 1 and ui.get(aaBuilder[vars.pState].yawJitterLeft)*math.random(-1, 1)  or ui.get(aaBuilder[vars.pState].yawJitterRight)*math.random(-1, 1) ))
                                        elseif ui.get(aaBuilder[vars.pState].yawJitter) == "L & R" then
                                            ui.set(refs.yawJitter[1], "Center")
                                            ui.set(refs.yawJitter[2], (side == 1 and ui.get(aaBuilder[vars.pState].yawJitterLeft) or ui.get(aaBuilder[vars.pState].yawJitterRight)))
                                        else
                                            ui.set(refs.yawJitter[1], ui.get(aaBuilder[vars.pState].yawJitter))
                                            ui.set(refs.yawJitter[2], ui.get(aaBuilder[vars.pState].yawJitterStatic))
                                        end
        
                                        if ui.get(aaBuilder[vars.pState].yawCondition) == "L & R" then
                                            ui.set(refs.bodyYaw[1], "Jitter")
                                            ui.set(refs.bodyYaw[2], -1)
                                        else
                                            ui.set(refs.bodyYaw[1], "Static")
                                            ui.set(refs.bodyYaw[2], -180)
                                        end
        
                                        if aa.manualAA == 1 then
                                            ui.set(refs.yawBase, "local view")
                                            ui.set(refs.yaw[1], "180")
                                            ui.set(refs.yaw[2], -90)
                                        elseif aa.manualAA == 2 then
                                            ui.set(refs.yawBase, "local view")
                                            ui.set(refs.yaw[1], "180")     
                                            ui.set(refs.yaw[2], 90)
                                        elseif aa.manualAA == 3 then
                                            ui.set(refs.yawBase, "local view")
                                            ui.set(refs.yaw[1], "180")
                                            ui.set(refs.yaw[2], 180)
                                        end
                                    end
                                else
                                    aa.ignore = false
                                end
                            elseif aa.input > globals.curtime() then
                            --    aa.ignore = false
                            --    aa.manualAA = 0
                                aa.input = globals.curtime()
                            end
        
                        -- check height advantage and head safety
                        local heightAdvantage = false
                        local safetyAlert = false
                        local enemies = entity.get_players(true)
                        for i=1, #enemies do
                            if entity.is_dormant(enemies[i]) then heightAlert = false sidewaysAlert = false return end
                            local playerX, playerY, playerZ  = entity.get_prop(enemies[i], "m_vecOrigin")
                            local playerFlags = entity.get_prop(enemies[i], "m_fFlags")
                            local playerOnGround = bit.band(playerFlags, 1) ~= 0
                            local lengthDistance = math.sqrt((playerX - origin.x)^2 + (playerY - origin.y)^2 + (playerZ - origin.z)^2)
                            if ((playerZ + 100 < origin.z) and lengthDistance <= 300) then
                                heightAdvantage = true
                            else
                                heightAdvantage = false
                            end
        
                            if ((bodyYaw >= 40 or bodyYaw <= -40) and func.headVisible(enemies[i])) then
                                safetyAlert = true
                            else
                                safetyAlert = false
                            end
                        end
        
                        if ui.get(aaBuilder[vars.pState].enableState) then
        
                            if func.includes(ui.get(aaBuilder[vars.pState].defensiveOpt), "Always on") then
                                cmd.force_defensive = true
                            end
        
                            if cmd.chokedcommands > 1 then
                                cmd.allow_send_packet = false
                            else
                                cmd.allow_send_packet = true
                            end
        
                            if func.includes(ui.get(aaBuilder[vars.pState].defensiveOpt), "Elusive mode") then
                                ui.set(refs.dt[3], "Defensive")
        
                                if tickcount % 3 == 1 then
                                    ui.set(refs.dt[3], "Offensive")
                                end
                                cmd.force_defensive = tickcount % 3 ~= 1
                            end
                            
        
                            if aa.ignore then return end
        
                            if ui.get(aaBuilder[vars.pState].defensivePitch) == "Custom" and isDefensive then
                                ui.set(refs.pitch[1], "Custom")
                                ui.set(refs.pitch[2], ui.get(aaBuilder[vars.pState].defensivePitchSlider))
                            else
                                ui.set(refs.pitch[1], ui.get(aaBuilder[vars.pState].pitch))
                                ui.set(refs.pitch[2], ui.get(aaBuilder[vars.pState].pitchSlider))
                            end                
        
                            ui.set(refs.yawBase, ui.get(aaBuilder[vars.pState].yawBase))
        
                            ui.set(refs.yaw[1], ui.get(aaBuilder[vars.pState].yaw))
        
                            if ui.get(aaBuilder[vars.pState].defensiveYaw) == "Random" and isDefensive then
                                local randomyaw = client.random_int(61, 180)
                                ui.set(refs.yaw[2], func.aa_clamp((tickcount % 6 < 3 and randomyaw or -randomyaw)))
                            elseif ui.get(aaBuilder[vars.pState].defensiveYaw) == "Jitter" and isDefensive then
                                ui.set(refs.yaw[2], tickcount % 3 == 0 and client.random_int(90, -90) or tickcount % 3 == 1 and 180 or tickcount % 3 == 2 and client.random_int(-90, 90) or 0)
                            elseif ui.get(aaBuilder[vars.pState].defensiveYaw) == "Custom" and isDefensive then
                    --            ui.set(refs.yaw[2], "Custom")
                                ui.set(refs.yaw[2], ui.get(aaBuilder[vars.pState].defensiveYawSlider))
                            elseif ui.get(aaBuilder[vars.pState].yawCondition) == "L & R" then
        
                                ui.set(refs.yaw[2],(side == 1 and ui.get(aaBuilder[vars.pState].yawLeft) or ui.get(aaBuilder[vars.pState].yawRight)))
        
                            elseif ui.get(aaBuilder[vars.pState].yawCondition) == "Hold" then
        
                                if vars.choke2 == 0 then
                                    ui.set(refs.yaw[2], ui.get(aaBuilder[vars.pState].yawRight))
                                elseif vars.choke2 == 1 then
                                    ui.set(refs.yaw[2], ui.get(aaBuilder[vars.pState].yawLeft))
                                elseif vars.choke2 == 2 then
                                    ui.set(refs.yaw[2], ui.get(aaBuilder[vars.pState].yawLeft))
                                elseif vars.choke2 == 3 then
                                    ui.set(refs.yaw[2], ui.get(aaBuilder[vars.pState].yawLeft))
                                elseif vars.choke2 == 4 then
                                    ui.set(refs.yaw[2], ui.get(aaBuilder[vars.pState].yawRight))
                                elseif vars.choke2 == 5 then
                                    ui.set(refs.yaw[2], ui.get(aaBuilder[vars.pState].yawLeft))
                                elseif vars.choke2 == 6 then
                                    ui.set(refs.yaw[2], ui.get(aaBuilder[vars.pState].yawRight))
                                elseif vars.choke2 == 7 then
                                    ui.set(refs.yaw[2], ui.get(aaBuilder[vars.pState].yawRight))
                                end
        
                            elseif ui.get(aaBuilder[vars.pState].yawCondition) == "Slow" then
                                ui.set(refs.yaw[2], vars.switch and ui.get(aaBuilder[vars.pState].yawLeft) or ui.get(aaBuilder[vars.pState].yawRight))
                                side_yaw = 0
                            else
                                ui.set(refs.yaw[2], ui.get(aaBuilder[vars.pState].yawStatic))
                                side_yaw = 2
                            end
        
                            local switch = false
                            if ((func.includes(ui.get(aaBuilder[vars.pState].yawJitterDisablers), "Height advantage" ) and heightAdvantage) or (func.includes(ui.get(aaBuilder[vars.pState].yawJitterDisablers), "Head safety") and safetyAlert)) then
                                ui.set(refs.yawJitter[1], "Off") 
                            elseif ui.get(aaBuilder[vars.pState].yawJitter) == "3-Way" then
                                ui.set(refs.yawJitter[1], "Center")
                            else
                                ui.set(refs.yawJitter[1], ui.get(aaBuilder[vars.pState].yawJitter))
                            end
                            if ui.get(aaBuilder[vars.pState].yawJitterCondition) == "L & R" then
                                if ui.get(aaBuilder[vars.pState].yawJitter) == "3-Way" then
                                    ui.set(refs.yawJitter[2], (side == 1 and ui.get(aaBuilder[vars.pState].yawJitterLeft)*math.random(-1, 1)  or ui.get(aaBuilder[vars.pState].yawJitterRight)*math.random(-1, 1) ))
                                elseif ui.get(aaBuilder[vars.pState].yawJitter) == "Slow Jitter" then
                                    ui.set(refs.yaw[2], switch and ui.get(aaBuilder[vars.pState].yawJitterRight) or ui.get(aaBuilder[vars.pState].yawJitterLeft))
                                else
                                    ui.set(refs.yawJitter[2], (side == 1 and ui.get(aaBuilder[vars.pState].yawJitterLeft) or ui.get(aaBuilder[vars.pState].yawJitterRight)))
                                end
                                
                            else
                                if  ui.get(aaBuilder[vars.pState].yawJitter) == "3-Way" then
                                    ui.set(refs.yawJitter[2], ui.get(aaBuilder[vars.pState].yawJitterStatic)*math.random(-1, 1) )
                                elseif ui.get(aaBuilder[vars.pState].yawJitter) == "Slow Jitter" then
                                    ui.set(refs.yaw[2], switch and ui.get(aaBuilder[vars.pState].yawJitterStatic) or -ui.get(aaBuilder[vars.pState].yawJitterStatic))
                                else
                                    ui.set(refs.yawJitter[2], ui.get(aaBuilder[vars.pState].yawJitterStatic) )
                                end
                            end
        
                            if ui.get(aaBuilder[vars.pState].yawCondition) == "Slow" then
                                ui.set(refs.bodyYaw[1], "Static")
                                ui.set(refs.bodyYaw[2], 0)
                            elseif ui.get(aaBuilder[vars.pState].yawCondition) == "Hold" then
                                ui.set(refs.bodyYaw[1], "Static")
                                ui.set(refs.bodyYaw[2], 0)
                            else
                                ui.set(refs.bodyYaw[1], ui.get(aaBuilder[vars.pState].bodyYaw))
                                ui.set(refs.bodyYaw[2], ui.get(aaBuilder[vars.pState].bodyYawSlider))
                            end
        
                            if reversed and ui.get(aaBuilder[vars.pState].antiBruteSet) then
                                ui.set(refs.yaw[2], angle)
                            end
        
                            ui.set(refs.fsBodyYaw, false)
                        elseif not ui.get(aaBuilder[vars.pState].enableState) then
                            ui.set(refs.pitch[1], "Off")
                            ui.set(refs.yawBase, "Local view")
                            ui.set(refs.yaw[1], "Off")
                            ui.set(refs.yaw[2], 0)
                            ui.set(refs.yawJitter[1], "Off")
                            ui.set(refs.yawJitter[2], 0)
                            ui.set(refs.bodyYaw[1], "Off")
                            ui.set(refs.bodyYaw[2], 0)
                            ui.set(refs.fsBodyYaw, false)
                            ui.set(refs.edgeYaw, false)
                            ui.set(refs.roll, 0)
                        end
        
                        --safe safe
                        if ui.get(menu.aaTab.safeKnife) then
                            if entity.get_classname(entity.get_player_weapon(entity.get_local_player())) == "CKnife" and vars.pState == 7 then
                                ui.set(refs.pitch[1], "Default")
                                ui.set(refs.yawBase, "At targets")
                                ui.set(refs.yaw[1], "180")
                                ui.set(refs.yaw[2], 0)
                                ui.set(refs.yawJitter[1], "Off")
                                ui.set(refs.yawJitter[2], 0)
                                ui.set(refs.bodyYaw[1], "Static")
                                ui.set(refs.bodyYaw[2], 0)
                                ui.set(refs.fsBodyYaw, false)
                                ui.set(refs.edgeYaw, false)
                                ui.set(refs.roll, 0)
                            end
                        end
        
                        -- fix hideshots
                        if ui.get(menu.aaTab.fixHideshots) then
                            if isOs and not isDt and not isFd then
                                if not hsSaved then
                                    hsValue = ui.get(refs.fakeLag[1])
                                    hsSaved = true
                                end
                                ui.set(refs.fakeLag[1], 1)
                            elseif hsSaved then
                                ui.set(refs.fakeLag[1], hsValue)
                                hsSaved = false
                            end
                        end
        
                        distance_knife = {}
                        distance_knife.anti_knife_dist = function (x1, y1, z1, x2, y2, z2)
                            return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
                        end
        
        
                        -- Avoid backstab
                        if ui.get(menu.aaTab.avoidBackstab) ~= 0 then
                            local players = entity.get_players(true)
                            local lx, ly, lz = entity.get_prop(entity.get_local_player(), "m_vecOrigin")
                            if players == nil then return end
                            for i=1, #players do
                                local x, y, z = entity.get_prop(players[i], "m_vecOrigin")
                                local distance = distance_knife.anti_knife_dist(lx, ly, lz, x, y, z)
                                local weapon = entity.get_player_weapon(players[i])
                                if entity.get_classname(weapon) == "CKnife" and distance <= ui.get(menu.aaTab.avoidBackstab) then
                                    ui.set(refs.yaw[2], 180)
                                    ui.set(refs.yawBase, "At targets")
                                end
                            end
                        end
                        
                        -- dt discharge
                        if ui.get(menu.aaTab.dtDischarge) then
                            if dtEnabled == nil then
                                dtEnabled = true
                            end
                            local enemies = entity.get_players(true)
                            local vis = false
                            local health = entity.get_prop(vars.localPlayer, "m_iHealth")
                            for i=1, #enemies do
                                local entindex = enemies[i]
                                local body_x,body_y,body_z = entity.hitbox_position(entindex, 1)
                                if client.visible(body_x, body_y, body_z + 20) then
                                    vis = true
                                end
                            end	
        
                            if vis then
                                ui.set(refs.dt[1],false)
                                client.delay_call(0.01, function() 
                                    ui.set(refs.dt[1],true)
                                end)
                            end
                        else
                            if dtEnabled == true then
                                ui.set(refs.dt[1], dtEnabled)
                                dtEnabled = false
                            end
                        end
                        
                        -- fast ladder
                        if ui.get(menu.miscTab.fastLadderEnabled) then
                            local pitch, yaw = client.camera_angles()
                            if entity.get_prop(vars.localPlayer, "m_MoveType") == 9 then
                                cmd.yaw = math.floor(cmd.yaw+0.5)
                                cmd.roll = 0
                        
                                    if cmd.forwardmove > 0 then
                                        if pitch < 45 then
                                            cmd.pitch = 89
                                            cmd.in_moveright = 1
                                            cmd.in_moveleft = 0
                                            cmd.in_forward = 0
                                            cmd.in_back = 1
                                            if cmd.sidemove == 0 then
                                                cmd.yaw = cmd.yaw + 90
                                            end
                                            if cmd.sidemove < 0 then
                                                cmd.yaw = cmd.yaw + 150
                                            end
                                            if cmd.sidemove > 0 then
                                                cmd.yaw = cmd.yaw + 30
                                            end
                                        end 
                                    end
        
                                    if cmd.forwardmove < 0 then
                                        cmd.pitch = 89
                                        cmd.in_moveleft = 1
                                        cmd.in_moveright = 0
                                        cmd.in_forward = 1
                                        cmd.in_back = 0
                                        if cmd.sidemove == 0 then
                                            cmd.yaw = cmd.yaw + 90
                                        end
                                        if cmd.sidemove > 0 then
                                            cmd.yaw = cmd.yaw + 150
                                        end
                                        if cmd.sidemove < 0 then
                                            cmd.yaw = cmd.yaw + 30
                                        end
                                    end
                            end
                        end
        
                        -- edgeyaw
                        ui.set(refs.edgeYaw, ui.get(menu.aaTab.edgeYawHotkey))
                    end)
        
                    client.set_event_callback("setup_command", function(e)
                        if not vars.localPlayer or not entity.is_alive(vars.localPlayer) or not ui.get(masterSwitch) then return end
                        local flags = entity.get_prop(vars.localPlayer, "m_fFlags")
                        local onground = bit.band(flags, 1) ~= 0 and e.in_jump == 0
                        local isSlow = ui.get(refs.slow[1]) and ui.get(refs.slow[2])
        
                        local air = func.includes(ui.get(menu.aaTab.freestandDisablers), "Air") and not onground
                        local duck = func.includes(ui.get(menu.aaTab.freestandDisablers), "Duck") and entity.get_prop(vars.localPlayer, "m_flDuckAmount") > 0.1
                        local slow = func.includes(ui.get(menu.aaTab.freestandDisablers), "Slowmo") and isSlow
                        local manul = func.includes(ui.get(menu.aaTab.freestandDisablers), "Manual") and (aa.manualAA == 2 or aa.manualAA == 1) and aa.ignore
                        local fs_disabler = air or duck or slow or manul
        
                        if ui.get(menu.aaTab.freestandHotkey) and not fs_disabler then
                            vars.fs = true
                            ui.set(refs.freeStand[2], "Always on")
                            ui.set(refs.freeStand[1], true)
                        else
                            vars.fs = false
                            ui.set(refs.freeStand[1], false)
                            ui.set(refs.freeStand[2], "On hotkey")
                        end    
                    end)
        
                    client.set_event_callback("setup_command", function(cmd)
                        local using = true
                        local defusing = false
                        vars.should_disable = false
        
                        if entity.get_classname(entity.get_player_weapon(vars.localPlayer)) == "CC4" then
                            vars.should_disable = true
                            return
                        end
        
                        local planted_bomb = entity.get_all("CPlantedC4")[1]
                        local classnames = {"CWorld","CCSPlayer","CFuncBrush","CPropDoorRotating","CHostage"}
        
                        if planted_bomb ~= nil then
                            local bomb_distance = vector(entity.get_origin(vars.localPlayer)):dist(vector(entity.get_origin(planted_bomb)))
                            
                            if bomb_distance <= 64 and entity.get_prop(vars.localPlayer, "m_iTeamNum") == 3 then
                                vars.should_disable = true
                                defusing = true
                            end
                        end
        
                        local pitch, yaw = client.camera_angles()
                        local direct_vec = vector(func.vec_angles(pitch, yaw))
        
                        local eye_pos = vector(client.eye_position())
                        local fraction, ent = client.trace_line(vars.localPlayer, eye_pos.x, eye_pos.y, eye_pos.z, eye_pos.x + (direct_vec.x * 8192), eye_pos.y + (direct_vec.y * 8192), eye_pos.z + (direct_vec.z * 8192))
        
                        local using = true
        
                        if ent ~= nil and ent ~= -1 then
                            for i=0, #classnames do
                                if entity.get_classname(ent) == classnames[i] then
                                    using = false
                                end
                            end
                        end
        
                        if not vars.should_disable and client.key_state(0x45) and not using and not defusing and ui.get(aaBuilder[8].enableState) then
                            cmd.in_use = 0
                        end
        
                    --    local key = ui.get(menu.aaTab.BombEfix)
                    end)
                    local function clantag_set()
                        local lua_name = "gengar.lua"
                        if ui.get(menu.miscTab.clanTag) then
                            if ui.get(ui.reference("Misc", "Miscellaneous", "Clan tag spammer")) then return end
        
                            local clan_tag = clantag_anim(lua_name, {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 11, 11, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25})
        
                            if entity.get_prop(entity.get_game_rules(), "m_gamePhase") == 5 then
                                clan_tag = clantag_anim('gengar.lua', {13})
                                client.set_clan_tag(clan_tag)
                            elseif entity.get_prop(entity.get_game_rules(), "m_timeUntilNextPhaseStarts") ~= 0 then
                                clan_tag = clantag_anim('gengar.lua', {13})
                                client.set_clan_tag(clan_tag)
                            elseif clan_tag ~= clantag.prev_ct  then
                                client.set_clan_tag(clan_tag)
                            end
        
                            clantag.prev_ct = clan_tag
                            clantag.enb = true
                        elseif clantag.enb == true then
                            client.set_clan_tag(get_original_clantag())
                            clantag.enb = false
                        end
                    end
        
                    clantag.paint = function()
                        if entity.get_local_player() ~= nil then
                            if globals.tickcount() % 2 == 0 then
                                clantag_set()
                            end
                        end
                    end
        
                    clantag.run_command = function(e)
                        if entity.get_local_player() ~= nil then 
                            if e.chokedcommands == 0 then
                                clantag_set()
                            end
                        end
                    end
        
                    clantag.player_connect_full = function(e)
                        if client.userid_to_entindex(e.userid) == entity.get_local_player() then 
                            clantag.orig_ct = get_original_clantag()
                        end
                    end
        
                    clantag.shutdown = function()
                        client.set_clan_tag(get_original_clantag())
                    end
        
                    client.set_event_callback("paint", clantag.paint)
                    client.set_event_callback("run_command", clantag.run_command)
                    client.set_event_callback("player_connect_full", clantag.player_connect_full)
                    client.set_event_callback("shutdown", clantag.shutdown)
        
                    ui.set_callback(menu.miscTab.trashTalk, function() 
                        local callback = ui.get(menu.miscTab.trashTalk) and client.set_event_callback or client.unset_event_callback
                        callback('player_death', trashtalk)
                    end)
        
                    ui.set_callback(menu.visualsTab.logs, function() 
                        local callback = ui.get(menu.visualsTab.logs) and client.set_event_callback or client.unset_event_callback
                        callback("aim_miss", onMiss)
                        callback("aim_hit", onHit)
                    end)
        
                    client.set_event_callback("player_death", function(e)
                        local v, a = e.userid, e.attacker
                        local lp_death = client.userid_to_entindex(v)
                        if lp_death ~= entity.get_local_player() then return end
                        client.delay_call(1, notifications.clear)
                    end)
        
                    client.set_event_callback("player_connect_full", function(e)
                        if client.userid_to_entindex(e.userid) == entity.get_local_player() then 
                            notifications.clear()
                        end
                    end)
        
                    local legsTypes = {[1] = "Off", [2] = "Always slide", [3] = "Never slide"}
                    local ground_ticks = 0
                    client.set_event_callback("setup_command", function(e)
                        local is_on_ground = e.in_jump == 0
                        if func.includes(ui.get(menu.miscTab.animations), "Leg fucker") then
                            if func.includes(ui.get(menu.miscTab.animations), "Leg fucker") then
                                ui.set(refs.legMovement, e.command_number % 3 == 0 and "Off" or "Always slide")
                            end
                        end
                    end)
        
                    client.set_event_callback("pre_render", function()
                        local lp = entity.get_local_player()
                        if not lp then return end
                        if ui.get(menu.miscTab.animationsEnabled) == false then return end
                        local flags = entity.get_prop(lp, "m_fFlags")
                        ground_ticks = bit.band(flags, 1) == 0 and 0 or (ground_ticks < 5 and ground_ticks + 1 or ground_ticks)
        
                        if func.includes(ui.get(menu.miscTab.animations), "Static legs") then
                            entity.set_prop(lp, "m_flPoseParameter", 1, 0) 
                        end
        
                        if func.includes(ui.get(menu.miscTab.animations), "In air") and bit.band(flags, 1) == 0 then
                            entity.set_prop(lp, "m_flPoseParameter", 1, 6) 
                        end
        
                        if func.includes(ui.get(menu.miscTab.animations), "Leg fucker") then
                            entity.set_prop(lp, "m_flPoseParameter", 1, globals.tickcount() % 4 > 1 and 5 / 10 or 1)
                        end
        
                        if func.includes(ui.get(menu.miscTab.animations), "On land") then
                            ground_ticks = bit.band(flags, 1) == 1 and ground_ticks + 1 or 0
        
                            if ground_ticks > 20 and ground_ticks < 150 then
                                entity.set_prop(lp, "m_flPoseParameter", 0.5, 12)
                            end
                        end
        
                        if func.includes(ui.get(menu.miscTab.animations), "Allah legs") then
                            entity.set_prop(lp, "m_flPoseParameter", 1, 7)
                            ui.set(refs.legMovement, "Never slide")
                        end
        
                        if func.includes(ui.get(menu.miscTab.animations), "Haram legs") then
                            local lp = ent.get_local_player()
                            local m_fFlags = lp:get_prop("m_fFlags")
                            local is_onground = bit.band(m_fFlags, 1) ~= 0 
                            
                            if not is_onground then 
                                local my_animlayer = lp:get_anim_overlay(6)
                                my_animlayer.weight = 1 
                                entity.set_prop(lp, "m_flPoseParameter", 1, 6) 
                            end
                        end
        
                        if func.includes(ui.get(menu.miscTab.animations), "Blend legs") then
                            entity.set_prop(lp, "m_flPoseParameter", 0, 8)
                            entity.set_prop(lp, "m_flPoseParameter", 0, 9)
                            entity.set_prop(lp, "m_flPoseParameter", 0, 10)
                        end
                    end)
                    -- @region AA_CALLBACKS end
        
                    -- @region INDICATORS start
                    local alpha = 0
                    local scopedFraction = 0
        
                    local mainIndClr = {r = 0, g = 0, b = 0, a = 0}
                    local dtClr = {r = 0, g = 0, b = 0, a = 0}
                    local chargeClr = {r = 0, g = 0, b = 0, a = 0}
                    local chargeInd = {w = 0, x = 0, y = 25}
                    local psClr = {r = 0, g = 0, b = 0, a = 0}
                    local dtInd = {w = 0, x = 0, y = 25}
                    local qpInd = {w = 0, x = 0, y = 25, a = 0}
                    local fdInd = {w = 0, x = 0, y = 25, a = 0}
                    local spInd = {w = 0, x = 0, y = 25, a = 0}
                    local baInd = {w = 0, x = 0, y = 25, a = 0}
                    local fsInd = {w = 0, x = 0, y = 25, a = 0}
                    local osInd = {w = 0, x = 0, y = 25, a = 0}
                    local psInd = {w = 0, x = 0, y = 25}
                    local wAlpha = 0
                    local value = 0
                    local once1 = false
                    local once2 = false
                    local dt_a = 0
                    local dt_y = 45
                    local dt_x = 0
                    local dt_w = 0
                    local os_a = 0
                    local os_y = 45
                    local os_x = 0
                    local os_w = 0
                    local fs_a = 0
                    local fs_y = 45
                    local fs_x = 0
                    local fs_w = 0
                    local n_x = 0
                    local n2_x = 0
                    local n3_x = 0
                    local n4_x = 0
                    local testx = 0
                    local aaa = 0
                    local lele = 0
                    local hitler = {}
                    hitler.lerp = function(start, vend, time)
                        return start + (vend - start) * time
                    end
        
                    function rgba_to_hex(b,c,d,e)
                        return string.format('%02x%02x%02x%02x',b,c,d,e)
                    end
        
                    local gradient_text = function(text, speed, r,g,b,a)
                            local final_text = ''
                            local curtime = globals.curtime()
                            local center = math.floor(#text / 2) + 1  -- calculate the center of the text
                            for i=1, #text do
                                -- calculate the distance from the center character
                                local distance = math.abs(i - center)
                                -- calculate the alpha based on the distance and the speed and time
                                a = 255 - math.abs(255 * math.sin(speed * curtime / 4 - distance * 4 / 20))
                                local col = rgba_to_hex(r,g,b,a)
                                final_text = final_text .. '\a' .. col .. text:sub(i, i)
                            end
                            return final_text
                        end
        
                    local X, Y = client.screen_size() -- Deklaracja i inicjalizacja zmiennych X i Y
                    local float = math.sin(globals.realtime() * 2.3) * 15
        
                    client.set_event_callback("paint", function()
                        renderer.text(X/2, Y/2 + 500 + float, 255,150,150,255, "cb", 0, gradient_text("gengar technologies", 5, 190, 190,255,255))
        
                        local local_player = entity.get_local_player()
                        if local_player == nil or entity.is_alive(local_player) == false then return end
                        local sizeX, sizeY = client.screen_size()
                        local weapon = entity.get_player_weapon(local_player)
                        local bodyYaw = entity.get_prop(local_player, "m_flPoseParameter", 11) * 120 - 60
                        local side = bodyYaw > 0 and 1 or -1
                        local state = vars.intToS[vars.pState]:upper()
                        local mainClr = {}
                        mainClr.r, mainClr.g, mainClr.b, mainClr.a = ui.get(menu.visualsTab.indicatorsClr)
                        local arrowClr = {}
                        arrowClr.r, arrowClr.g, arrowClr.b, arrowClr.a = ui.get(menu.visualsTab.arrowClr)
                        local fake = math.floor(antiaim_funcs.get_desync(1))
        
                        local indicators = 0
        
                        -- draw arrows
                        if ui.get(menu.visualsTab.arrows) then
                            if ui.get(menu.visualsTab.arrowIndicatorStyle) == "Standard" then
                                alpha = (aa.manualAA == 2 or aa.manualAA == 1) and func.lerp(alpha, 255, globals.frametime() * 20) or func.lerp(alpha, 0, globals.frametime() * 20)
                                renderer.text(sizeX / 2 + 45, sizeY / 2 - 2.5, aa.manualAA == 2 and arrowClr.r or 200, aa.manualAA == 2 and arrowClr.g or 200, aa.manualAA == 2 and arrowClr.b or 200, alpha, "c+", 0, '>')
                                renderer.text(sizeX / 2 - 45, sizeY / 2 - 2.5, aa.manualAA == 1 and arrowClr.r or 200, aa.manualAA == 1 and arrowClr.g or 200, aa.manualAA == 1 and arrowClr.b or 200, alpha, "c+", 0, '<')
                            end
                        
                            if ui.get(menu.visualsTab.arrowIndicatorStyle) == "Teamskeet" then
                                renderer.triangle(sizeX / 2 + 55, sizeY / 2 + 2, sizeX / 2 + 42, sizeY / 2 - 7, sizeX / 2 + 42, sizeY / 2 + 11, 
                                aa.manualAA == 2 and arrowClr.r or 25, 
                                aa.manualAA == 2 and arrowClr.g or 25, 
                                aa.manualAA == 2 and arrowClr.b or 25, 
                                aa.manualAA == 2 and arrowClr.a or 160)
                        
                                renderer.triangle(sizeX / 2 - 55, sizeY / 2 + 2, sizeX / 2 - 42, sizeY / 2 - 7, sizeX / 2 - 42, sizeY / 2 + 11, 
                                aa.manualAA == 1 and arrowClr.r or 25, 
                                aa.manualAA == 1 and arrowClr.g or 25, 
                                aa.manualAA == 1 and arrowClr.b or 25, 
                                aa.manualAA == 1 and arrowClr.a or 160)
                            
                                renderer.rectangle(sizeX / 2 + 38, sizeY / 2 - 7, 2, 18, 
                                bodyYaw < -10 and arrowClr.r or 25,
                                bodyYaw < -10 and arrowClr.g or 25,
                                bodyYaw < -10 and arrowClr.b or 25,
                                bodyYaw < -10 and arrowClr.a or 160)
                                renderer.rectangle(sizeX / 2 - 40, sizeY / 2 - 7, 2, 18,			
                                bodyYaw > 10 and arrowClr.r or 25,
                                bodyYaw > 10 and arrowClr.g or 25,
                                bodyYaw > 10 and arrowClr.b or 25,
                                bodyYaw > 10 and arrowClr.a or 160)
                            end
                        end
        
                        -- move on scope
                        local scopeLevel = entity.get_prop(weapon, 'm_zoomLevel')
                        local scoped = entity.get_prop(local_player, 'm_bIsScoped') == 1
                        local resumeZoom = entity.get_prop(local_player, 'm_bResumeZoom') == 1
                        local isValid = weapon ~= nil and scopeLevel ~= nil
                        local act = isValid and scopeLevel > 0 and scoped and not resumeZoom
                        local time = globals.frametime() * 30
        
                        if act then
                            if scopedFraction < 1 then
                                scopedFraction = func.lerp(scopedFraction, 1 + 0.1, time)
                            else
                                scopedFraction = 1
                            end
                        else
                            scopedFraction = func.lerp(scopedFraction, 0, time)
                        end
        
                        -- draw indicators
                        if ui.get(menu.visualsTab.indicators) == "Soft" then
                            local dpi = ui.get(ui.reference("MISC", "Settings", "DPI scale")):gsub('%%', '') - 100
                            local globalFlag = "cd"
                            local globalMoveY = globalFlag == "cd-" and 5 + dpi/10 or 9 + dpi/10
                            local indX, indY = renderer.measure_text(globalFlag, "DT")
                            local yDefault = func.includes(ui.get(menu.visualsTab.indicatorsStyle), "State") and 18 or 9
                            local indCount = 0
                            indY = globalFlag == "cd-" and indY - 3 or indY - 2
                        
                            local isCharged = antiaim_funcs.get_double_tap()
                            local isFs = ui.get(menu.aaTab.freestandHotkey)
                            local isBa = ui.get(refs.forceBaim)
                            local isSp = ui.get(refs.safePoint)
                            local isQp = ui.get(refs.quickPeek[2])
                            local isSlow = ui.get(refs.slow[1]) and ui.get(refs.slow[2])
                            local isOs = ui.get(refs.os[1]) and ui.get(refs.os[2])
                            local isFd = ui.get(refs.fakeDuck)
                            local isDt = ui.get(refs.dt[1]) and ui.get(refs.dt[2])
                        
                            local state = vars.intToS[vars.pState]:upper()
                        
                            if func.includes(ui.get(menu.visualsTab.indicatorsStyle), "Name") then
                                indicators = indicators + 1
                                local namex, namey = renderer.measure_text(globalFlag, globalFlag == "cd-" and lua_name:upper() or lua_name:lower())
                                local logo = animate_text(globals.curtime(), globalFlag == "cd-" and lua_name:upper() or lua_name:lower(), mainClr.r, mainClr.g, mainClr.b, 255)
                        
                                renderer.text(sizeX/2 + ((namex + 2)/2) * scopedFraction, sizeY/2 + 20 - dpi/10, 255, 255, 255, 255, globalFlag, nil, unpack(logo))
                            end 
                        
                            if func.includes(ui.get(menu.visualsTab.indicatorsStyle), "State") then
                                indicators = indicators + 1
                                local namex, namey = renderer.measure_text(globalFlag, globalFlag == "cd-" and lua_name:upper() or lua_name:lower())
                                local stateX, stateY = renderer.measure_text(globalFlag, state:lower())
                                local string = state:lower()
                                renderer.text(sizeX/2 + (stateX + 2)/2 * scopedFraction, sizeY/2 + 20 + namey/1.2, 255, 255, 255, 255, globalFlag, 0, string)
                            end
                        
                            if func.includes(ui.get(menu.visualsTab.indicatorsStyle), "Doubletap") then
                                indicators = indicators + 1
                                if isDt then 
                                    dtClr.a = func.lerp(dtClr.a, 255, time)
                                    if dtInd.y < yDefault + indY * indCount then
                                        dtInd.y = func.lerp(dtInd.y, yDefault + indY * indCount + 1, time)
                                    else
                                        dtInd.y = yDefault + indY * indCount
                                    end
                                    chargeInd.w = 0.1
                                    if not isCharged and func.defensive.defensive > 1 then
                                        dtClr.r = func.lerp(dtClr.r, 144, time)
                                        dtClr.g = func.lerp(dtClr.g, 238, time)
                                        dtClr.b = func.lerp(dtClr.b, 144, time)
                                    elseif not isCharged then
                                        dtClr.r = func.lerp(dtClr.r, 222, time)
                                        dtClr.g = func.lerp(dtClr.g, 55, time)
                                        dtClr.b = func.lerp(dtClr.b, 55, time)
                                    else
                                        dtClr.r = func.lerp(dtClr.r, 144, time)
                                        dtClr.g = func.lerp(dtClr.g, 238, time)
                                        dtClr.b = func.lerp(dtClr.b, 144, time)
                                    end
                                    indCount = indCount + 1
                                elseif not isDt then 
                                    dtClr.a = func.lerp(dtClr.a, 0, time)
                                    dtInd.y = func.lerp(dtInd.y, yDefault - 5, time)
                                end
                        
                                renderer.text(sizeX / 2 + ((renderer.measure_text(globalFlag, globalFlag == "cd-" and "DT" or "dt") + 2)/2) * scopedFraction , sizeY / 2 + dtInd.y + 13 + globalMoveY, dtClr.r, dtClr.g, dtClr.b, dtClr.a, globalFlag, dtInd.w, globalFlag == "cd-" and "DT" or "dt")
                            end
                        
                            if func.includes(ui.get(menu.visualsTab.indicatorsStyle), "Hideshots") then
                                indicators = indicators + 1
                                if isOs then 
                                    osInd.a = func.lerp(osInd.a, 255, time)
                                    if osInd.y < yDefault + indY * indCount then
                                        osInd.y = func.lerp(osInd.y, yDefault + indY * indCount + 1, time)
                                    else
                                        osInd.y = yDefault + indY * indCount
                                    end
                            
                                    indCount = indCount + 1
                                elseif not isOs then
                                    osInd.a = func.lerp(osInd.a, 0, time)
                                    osInd.y = func.lerp(osInd.y, yDefault - 5, time)
                                end
                                renderer.text(sizeX / 2 + ((renderer.measure_text(globalFlag, globalFlag == "cd-" and "HS" or "hs") + 2)/2) * scopedFraction, sizeY / 2 + osInd.y + 13 + globalMoveY, 255, 255, 255, osInd.a, globalFlag, osInd.w, globalFlag == "cd-" and "HS" or "hs")
                            end
                        
                            if func.includes(ui.get(menu.visualsTab.indicatorsStyle), "Freestand") then
                                indicators = indicators + 1
                                if isFs then 
                                    fsInd.a = func.lerp(fsInd.a, 255, time)
                                    if fsInd.y < yDefault + indY * indCount then
                                        fsInd.y = func.lerp(fsInd.y, yDefault + indY * indCount + 1, time)
                                    else
                                        fsInd.y = yDefault + indY * indCount
                                    end
                                    indCount = indCount + 1
                                elseif not isFs then 
                                    fsInd.a = func.lerp(fsInd.a, 0, time)
                                    fsInd.y = func.lerp(fsInd.y, yDefault - 5, time)
                                end
                                local fs_col = vars.fs and {255,255,255} or {222,55,55}
                                renderer.text(sizeX / 2 + fsInd.x + ((renderer.measure_text(globalFlag, globalFlag == "cd-" and "FS" or "fs") + 2)/2) * scopedFraction, sizeY / 2 + fsInd.y + 13 + globalMoveY, fs_col[1], fs_col[2], fs_col[3], fsInd.a, globalFlag, fsInd.w, globalFlag == "cd-" and "FS" or "fs")
                            end
                        
                            if func.includes(ui.get(menu.visualsTab.indicatorsStyle), "Safepoint") then
                                indicators = indicators + 1
                                if isSp then 
                                    spInd.a = func.lerp(spInd.a, 255, time)
                                    if spInd.y < yDefault + indY * indCount then
                                        spInd.y = func.lerp(spInd.y, yDefault + indY * indCount + 1, time)
                                    else
                                        spInd.y = yDefault + indY * indCount
                                    end
                                    indCount = indCount + 1
                                elseif not isSp then 
                                    spInd.a = func.lerp(spInd.a, 0, time)
                                    spInd.y = func.lerp(spInd.y, yDefault - 5, time)
                                end
                                renderer.text(sizeX / 2 + ((renderer.measure_text(globalFlag, globalFlag == "cd-" and "SP" or "sp") + 2)/2) * scopedFraction, sizeY / 2 + spInd.y + 13 + globalMoveY, 255, 255, 255, spInd.a, globalFlag, 0, globalFlag == "cd-" and "SP" or "sp")
                            end
                        
                            if func.includes(ui.get(menu.visualsTab.indicatorsStyle), "Body aim") then
                                indicators = indicators + 1
                                if isBa then
                                    baInd.a = func.lerp(baInd.a, 255, time)
                                    if baInd.y < yDefault + indY * indCount then
                                        baInd.y = func.lerp(baInd.y, yDefault + indY * indCount + 1, time)
                                    else
                                        baInd.y = yDefault + indY * indCount
                                    end
                                    indCount = indCount + 1
                                elseif not isBa then 
                                    baInd.a = func.lerp(baInd.a, 0, time)
                                    baInd.y = func.lerp(baInd.y, yDefault - 5, time)
                                end
                                renderer.text(sizeX / 2 + ((renderer.measure_text(globalFlag, globalFlag == "cd-" and "BA" or "ba") + 2)/2) * scopedFraction, sizeY / 2 + baInd.y + 13 + globalMoveY, 255, 255, 255, baInd.a, globalFlag, 0, globalFlag == "cd-" and "BA" or "ba")
                            end
                        
                            if func.includes(ui.get(menu.visualsTab.indicatorsStyle), "Fakeduck") then
                                indicators = indicators + 1
                                if isFd then
                                    fdInd.a = func.lerp(fdInd.a, 255, time)
                                    if fdInd.y < yDefault + indY * indCount then
                                        fdInd.y = func.lerp(fdInd.y, yDefault + indY * indCount + 1, time)
                                    else
                                        fdInd.y = yDefault + indY * indCount
                                    end
                                    indCount = indCount + 1
                                elseif not isFd then 
                                    fdInd.a = func.lerp(fdInd.a, 0, time)
                                    fdInd.y = func.lerp(fdInd.y, yDefault - 5, time)
                                end
                                renderer.text(sizeX / 2 + ((renderer.measure_text(globalFlag, globalFlag == "cd-" and "FD" or "fd") + 2)/2) * scopedFraction, sizeY / 2 + fdInd.y + 13 + globalMoveY, 255, 255, 255, fdInd.a, globalFlag, 0, globalFlag == "cd-" and "FD" or "fd")
                            end
                        end
                        -- indicator d4ssh
                        
        
                        -- draw dmg indicator
                        if ui.get(menu.visualsTab.minDmgIndicator) and entity.get_classname(weapon) ~= "CKnife" and ui.get(refs.dmgOverride[1]) and ui.get(refs.dmgOverride[2]) then
                            local dmg = ui.get(refs.dmgOverride[3])
                            renderer.text(sizeX / 2 + 2, sizeY / 2 - 14, 255, 255, 255, 255, "d", 0, dmg)
                        end
        
                        -- draw watermark
                        if indicators == 0 then
                            local watermarkX, watermarkY = renderer.measure_text("cd-", "")
                            local lua_watermarkname = ''
                            local logo = animate_text(globals.curtime(), globalFlag == "cd-" and lua_watermarkname:upper() or lua_watermarkname:upper(), mainClr.r, mainClr.g, mainClr.b, 255)
                            renderer.text(sizeX/2-watermarkX/2+24, sizeY/1.025,  mainClr.r, mainClr.g, mainClr.b, 255, "c", 0, unpack(logo))
                        end
        
                        -- draw logs
                        local call_back = ui.get(menu.visualsTab.logs) and client.set_event_callback or client.unset_event_callback
        
                        notifications.render()
                    end)
                    -- @region INDICATORS end
        
                    --Console
                    local u8, device, localize, surface, notify = {}, {}, {}, {}, {}
        
                    do 
                        function u8:len(s)
                            return #s:gsub("[\128-\191]", "");
                        end
        
                        local string_mod; do
                            local float = 0;
                            local to_alpha = 1 / 255;
        
                            local function fn(rgb, alpha)
                                return string.format("%s%02x", rgb, float * tonumber(alpha, 16));
                            end
        
                            function string_mod(s, alpha)
                                float = alpha * to_alpha;
                                return s:gsub("(\a%x%x%x%x%x%x)(%x%x)", fn);
                            end
                        end
        
                        function device:on_update()
                            local new_rect = vector(client.screen_size());
        
                            if new_rect ~= self.rect then
                                self.rect = new_rect;
                            end
                        end
        
                        function device:draw_text(x, y, r, g, b, a, flags, max_width, ...)
                            local text = table.concat {...};
                            text = string.mod(text, a);
        
                            renderer.text(x, y, r, g, b, a, flags, max_width, text);
                        end
        
                        local native_ConvertAnsiToUnicode = vtable_bind("localize.dll", "Localize_001", 15, "int(__thiscall*)(void* thisptr, const char *ansi, wchar_t *unicode, int buffer_size)")
                        local native_ConvertUnicodeToAnsi = vtable_bind("localize.dll", "Localize_001", 16, "int(__thiscall*)(void* thisptr, wchar_t *unicode, char *ansi, int buffer_size)")
        
                        function localize:ansi_to_unicode(ansi, unicode, buffer_size)
                            return native_ConvertAnsiToUnicode(ansi, unicode, buffer_size);
                        end
        
                        function localize:unicode_to_ansi(ansi, unicode, buffer_size)
                            return native_ConvertUnicodeToAnsi(ansi, unicode, buffer_size);
                        end
        
                        local native_SetTextFont = vtable_bind("vguimatsurface.dll", "VGUI_Surface031", 23, "void*(__thiscall*)(void *thisptr, dword font_id)");
                        local native_SetTextColor = vtable_bind("vguimatsurface.dll", "VGUI_Surface031", 25, "void*(__thiscall*)(void *thisptr, int r, int g, int b, int a)");
                        local native_SetTextPos = vtable_bind("vguimatsurface.dll", "VGUI_Surface031", 26, "void*(__thiscall*)(void *thisptr, int x, int y)");
                        local native_DrawPrintText = vtable_bind("vguimatsurface.dll", "VGUI_Surface031", 28, "void*(__thiscall*)(void *thisptr, const wchar_t *text, int maxlen, int draw_type)");
        
                        local native_GetTextSize = vtable_bind("vguimatsurface.dll", "VGUI_Surface031", 79, "void(__thiscall*)(void *thisptr, size_t font, const wchar_t *text, int &wide, int &tall)");
        
                        local native_GetFontName = vtable_bind("vguimatsurface.dll", "VGUI_Surface031", 134, "const char*(__thiscall*)(void *thisptr, size_t font)");
        
                        local buffer = ffi.new("wchar_t[65535]");
                        local wide, tall = ffi.new("int[1]"), ffi.new("int[1]");
        
                        local to_alpha = 1 / 255;
        
                        function surface:get_font_name(font_id)
                            return ffi.string(native_GetFontName(font_id));
                        end
        
                        function surface:text(font, x, y, r, g, b, a, ...)
                            local text = table.concat {...};
                            localize:ansi_to_unicode(text, buffer, 65535);
        
                            native_GetTextSize(font, buffer, wide, tall);
        
                            native_SetTextFont(font);
                            native_SetTextPos(x, y);
                            native_SetTextColor(r, g, b, a);
        
                            native_DrawPrintText(buffer, u8:len(text), 0);
        
                            return wide[0], tall[0];
                        end
        
                        function surface:color_text(font, x, y, r, g, b, a, ...)
                            local text = table.concat {...};
                            local i, j = text:find "\a";
        
                            if i ~= nil then
                                x = x + self:text(font, x, y, r, g, b, a, text:sub(1, i - 1))
        
                                while i ~= nil do
                                    local new_r, new_g, new_b, new_a = r, g, b, a;
        
                                    if text:sub(i, j + 7) == "\adefault" then
                                        text = text:sub(1 + j + 7);
                                    else
                                        local hex = text:sub(i + 1, j + 8);
                                        text = text:sub(1 + j + 8);
        
                                        new_r, new_g, new_b, new_a = func.frgba(hex);
                                        new_a = new_a * (a * to_alpha);
                                    end
        
                                    i, j = text:find "\a";
        
                                    local new_text = text;
        
                                    if i ~= nil then
                                        new_text = text:sub(1, i - 1);
                                    end
        
                                    x = x + self:text(font, x, y, new_r, new_g, new_b, new_a, new_text);
                                end
        
                                return;
                            end
        
                            self:text(font, x, y, r, g, b, a, text);
                        end
        
                        local native_ConsoleIsVisible = vtable_bind("engine.dll", "VEngineClient014", 11, "bool(__thiscall*)(void*)");
                        local native_ColorPrint = vtable_bind("vstdlib.dll", "VEngineCvar007", 25, "void(__cdecl*)(void*, const color_t&, const char*, ...)");
        
                        local queue = {};
                        local current;
        
                        local times = 6;
                        local duration = 8;
        
                        local buffer = ffi.new("color_t");
                        local to_alpha = 1 / 255;
        
                        local function color_print(r, g, b, a, ...)
                            buffer.r, buffer.g, buffer.b, buffer.a = r, g, b, a;
                            native_ColorPrint(buffer, ...);
                        end
        
                        function notify:color_log(r, g, b, a, ...)
                            local text = table.concat {...};
                            local i, j = text:find "\a";
        
                            if i ~= nil then
                                color_print(r, g, b, a, text:sub(1, i - 1));
        
                                while i ~= nil do
                                    local new_r, new_g, new_b, new_a = r, g, b, a;
        
                                    if text:sub(i, j + 7) == "\adefault" then
                                        text = text:sub(1 + j + 7);
                                    else
                                        local hex = text:sub(i + 1, j + 8);
                                        text = text:sub(1 + j + 8);
        
                                        new_r, new_g, new_b, new_a = rgba(hex);
                                        new_a = new_a * a * to_alpha;
                                    end
        
                                    i, j = text:find "\a";
        
                                    local new_text = text;
        
                                    if i ~= nil then
                                        new_text = text:sub(1, i - 1);
                                    end
        
                                    color_print(new_r, new_g, new_b, new_a, new_text);
                                end
        
                                color_print(0, 0, 0, 0, "\n");
                                return;
                            end
        
                            color_print(r, g, b, a, text .. "\n");
                        end
        
                        function notify:add_to_queue(r, g, b, a, ...)
                            local text = table.concat {...};
        
                            local this =
                            {
                                text = text,
                                colour = {r, g, b, a},
                                colored = true,
                                liferemaining = duration
                            };
        
                            queue[#queue + 1] = this;
        
                            while #queue > times do
                                table.remove(queue, 1);
                            end
        
                            return this;
                        end
        
                        function notify:should_draw()
                            local is_visible = false;
                            local host_frametime = globals.frametime();
        
                            if not native_ConsoleIsVisible() then
                                for i = #queue, 1, -1 do
                                    local v = queue[i];
                                    v.liferemaining = v.liferemaining - host_frametime;
        
                                    if v.liferemaining <= 0 then
                                        table.remove(queue, i);
                                        goto continue;
                                    end
        
                                    is_visible = true;
                                    ::continue::
                                end
                            end
        
                            return is_visible;
                        end
        
                        function notify:on_paint_ui()
                            local x, y = 8, 5;
                            local flags = "d";
        
                            for i = 1, #queue do
                                local v = queue[i];
        
                                local colour = v.colour;
                                local r, g, b, a = colour[1], colour[2], colour[3], colour[4];
        
                                local text = v.text:gsub("\n", "");
                                local measure = vector(renderer.measure_text(flags, text));
        
                                local tall = measure.y + 1;
        
                                if v.liferemaining < .5 then
                                    local f = func.fclamp(v.liferemaining, 0, .5) / .5;
                                    a = a * f;
        
                                    if i == 1 and f < .2 then
                                        y = y - tall * (1 - f / .2);
                                    end
                                end
        
                                if v.colored then
                                    surface:color_text(63, x, y, r, g, b, a, text);
                                else
                                    surface:text(63, x, y, r, g, b, a, text);
                                end
        
                                y = y + tall;
                            end
                        end
        
                        function notify:on_output(e)
                            local text = string.format("\a%02x%02x%02x%02x%s", e.r, e.g, e.b, e.a, e.text);
                            local i = text:find "\0";
        
                            if i ~= nil then
                                text = text:sub(1, i - 1);
                            end
        
                            if current ~= nil then
                                current.text = current.text .. text;
        
                                if i == nil then
                                    current = nil;
                                end
        
                                return current;
                            end
        
                            local this = self:add_to_queue(e.r, e.g, e.b, e.a, text);
                            this.colored = text:find "\a" ~= nil;
        
                            if i ~= nil then
                                current = this;
                            end
        
                            return this;
                        end
        
                        function notify:on_console_input(e)
                            if e:find("clear") == 1 then
                                for i = 1, #queue do
                                    queue[i] = nil;
                                end
                            end
                        end
                    end
        
                    device:on_update()
        
                    client.set_event_callback("paint_ui", function()
                        if not ui.get(menu.miscTab.devPrint) then return end
                        device:on_update()
                        notify:should_draw()
                        notify:on_paint_ui()
                    end)
        
                    client.set_event_callback("output", function(e)
                        notify:on_output(e)
                    end)
        
                    client.set_event_callback("console_input", function(e)
                        if not ui.get(menu.miscTab.devPrint) then return end
                        notify:on_console_input(e)
                    end)
        
                    ui.set_callback(menu.miscTab.devPrint, function() 
                        local callback = ui.get(menu.miscTab.devPrint) and client.set_event_callback or client.unset_event_callback
                        callback("output", function(e) notify:on_output(e) end)
                    end)
        
                    -- @region UI_CALLBACKS start
                    ui.update(menu.configTab.list,getConfigList())
                    if database.read(lua.database.configs) == nil then
                        database.write(lua.database.configs, {})
                    end
                    ui.set(menu.configTab.name, #database.read(lua.database.configs) == 0 and "" or database.read(lua.database.configs)[ui.get(menu.configTab.list)+1].name)
                    ui.set_callback(menu.configTab.list, function(value)
                        local protected = function()
                            if value == nil then return end
                            local name = ""
                        
                            local configs = getConfigList()
                            if configs == nil then return end
                        
                            name = configs[ui.get(value)+1] or ""
                        
                            ui.set(menu.configTab.name, name)
                        end
        
                        if pcall(protected) then
        
                        end
                    end)
        
                    ui.set_callback(menu.configTab.load, function()
                        local r, g, b = ui.get(menu.visualsTab.logsClr)
                        local name = ui.get(menu.configTab.name)
                        if name == "" then return end
        
                        local protected = function()
                            loadConfig(name)
                        end
        
                        if pcall(protected) then
                            name = name:gsub('*', '')
                            notifications.new(string.format('Successfully loaded "$%s$"', name), r, g, b)
                        else
                            notifications.new(string.format('Failed to load "$%s$"', name), 255, 120, 120)
                        end
                    end)
        
                    ui.set_callback(menu.configTab.save, function()
                        local r, g, b = ui.get(menu.visualsTab.logsClr)
        
                        local name = ui.get(menu.configTab.name)
                        if name == "" then return end
        
                        for i, v in pairs(presets) do
                            if v.name == name:gsub('*', '') then
                                notifications.new(string.format('You can`t save built-in preset "$%s$"', name:gsub('*', '')), 255, 120, 120)
                                return
                            end
                        end
        
                        if name:match("[^%w]") ~= nil then
                            notifications.new(string.format('Failed to save "$%s$" due to invalid characters', name), 255, 120, 120)
                            return
                        end
        
                        local protected = function()
                            saveConfig(name)
                            ui.update(menu.configTab.list, getConfigList())
                        end
                        if pcall(protected) then
                            notifications.new(string.format('Successfully saved "$%s$"', name), r, g, b)
                        else
                            notifications.new(string.format('Failed to save "$%s$"', name), 255, 120, 120)
                        end
                    end)
        
                    ui.set_callback(menu.configTab.delete, function()
                        local name = ui.get(menu.configTab.name)
                        if name == "" then return end
                        local r, g, b = ui.get(menu.visualsTab.logsClr)
                        if deleteConfig(name) == false then
                            notifications.new(string.format('Failed to delete "$%s$"', name), 255, 120, 120)
                            ui.update(menu.configTab.list, getConfigList())
                            return
                        end
        
                        for i, v in pairs(presets) do
                            if v.name == name:gsub('*', '') then
                                notifications.new(string.format('You can`t delete built-in preset "$%s$"', name:gsub('*', '')), 255, 120, 120)
                                return
                            end
                        end
        
                        local protected = function()
                            deleteConfig(name)
                        end
        
                        if pcall(protected) then
                            ui.update(menu.configTab.list, getConfigList())
                            ui.set(menu.configTab.list, #presets + #database.read(lua.database.configs) - #database.read(lua.database.configs))
                            ui.set(menu.configTab.name, #database.read(lua.database.configs) == 0 and "" or getConfigList()[#presets + #database.read(lua.database.configs) - #database.read(lua.database.configs)+1])
                            notifications.new(string.format('Successfully deleted "$%s$"', name), r, g, b)
                        end
                    end)
        
                    ui.set_callback(menu.configTab.import, function()
                        local r, g, b = ui.get(menu.visualsTab.logsClr)
        
                        local protected = function()
                            importSettings()
                        end
        
                        if pcall(protected) then
                            notifications.new(string.format('Successfully imported settings', name), r, g, b)
                        else
                            notifications.new(string.format('Failed to import settings', name), 255, 120, 120)
                        end
                    end)
        
                    ui.set_callback(menu.configTab.export, function()
                        local name = ui.get(menu.configTab.name)
                        if name == "" then return end
        
                        local protected = function()
                            exportSettings(name)
                        end
                        local r, g, b = ui.get(menu.visualsTab.logsClr)
        
                        if pcall(protected) then
                            notifications.new(string.format('Successfully exported settings', name), r, g, b)
                        else
                            notifications.new(string.format('Failed to export settings', name), 255, 120, 120)
                        end
                    end)
        
                    local logica1337 = "2"
        
                    ui.set_callback(menu.builderTab.PresetComboBox, function()
                        if ui.get(menu.builderTab.PresetComboBox) == "[beta] scalevillain" then
                            local r, g, b = ui.get(menu.visualsTab.logsClr)
        
                            local protected = function()
                                importPreset()
                            end
        
                            if pcall(protected) then
                                notifications.new(string.format('Successfully enabled [beta] scalevillain', name), r, g, b)
                            else
                                notifications.new(string.format('Error with presets scalevillain, bugreport this please', name), 255, 120, 120)
                            end
                        end
                    end)
        
                    ui.set_callback(menu.builderTab.buttonPresets, function()
                        local r, g, b = ui.get(menu.visualsTab.logsClr)
        
                        local protected = function()
                            ui.set(menu.builderTab.LogicComboBox, "2")
                        end
        
                        if pcall(protected) then
                            notifications.new(string.format('Successfully opened presets combobox', name), r, g, b)
                        else
                            notifications.new(string.format('Failed to open presets combobox', name), 255, 120, 120)
                        end
                    end)
        
                    ui.set_callback(menu.builderTab.buttonBuilder, function()
                        local r, g, b = ui.get(menu.visualsTab.logsClr)
        
                        local protected = function()
                            ui.set(menu.builderTab.LogicComboBox, "1")
                            ui.set(menu.builderTab.PresetComboBox, "Disabled")
                            importPresetClear()
                        end
        
                        if pcall(protected) then
                            notifications.new(string.format('Successfully opened builder combobox', name), r, g, b)
                        else
                            notifications.new(string.format('Failed to open builder combobox', name), 255, 120, 120)
                        end
                    end)
        
                    -- @region UI_CALLBACKS end
        
                    -- @region UI_RENDER start
                    client.set_event_callback("paint_ui", function()
                        vars.activeState = vars.sToInt[ui.get(menu.builderTab.state)]
                        local isEnabled = ui.get(masterSwitch)
                        ui.set_visible(tabPicker, isEnabled)
                        local isHomeTab = ui.get(tabPicker) == "Home" 
                        local isAATab = ui.get(tabPicker) == "Anti-aim" 
                        local isBuilderTab = ui.get(tabPicker) == "Builder" 
                        local isVisualsTab = ui.get(tabPicker) == "Visuals" 
                        local isMiscTab = ui.get(tabPicker) == "Misc" 
                        local isCFGTab = ui.get(tabPicker) == "Config"
                        local ispresetdisabled = ui.get(menu.builderTab.PresetComboBox) == "Disabled"
                        local isLogicBuilder = ui.get(menu.builderTab.LogicComboBox) == "1"
                        local isLogicPresets = ui.get(menu.builderTab.LogicComboBox) == "2"
        
                        ui.set(aaBuilder[1].enableState, true)
                        for i = 1, #vars.aaStates do
                            local stateEnabled = ui.get(aaBuilder[i].enableState)
                            ui.set_visible(aaBuilder[i].enableState, vars.activeState == i and isBuilderTab and isEnabled and ispresetdisabled and isLogicBuilder)
                            ui.set_visible(aaBuilder[i].pitch, vars.activeState == i and isBuilderTab and stateEnabled and isEnabled and ispresetdisabled and isLogicBuilder)
                            ui.set_visible(aaBuilder[i].pitchSlider , vars.activeState == i and isBuilderTab and stateEnabled and ui.get(aaBuilder[i].pitch) == "Custom" and isEnabled and ispresetdisabled and isLogicBuilder)
                            ui.set_visible(aaBuilder[i].yawBase, vars.activeState == i and isBuilderTab and stateEnabled and isEnabled and ispresetdisabled and isLogicBuilder)
                            ui.set_visible(aaBuilder[i].yaw, vars.activeState == i and isBuilderTab and stateEnabled and isEnabled and ispresetdisabled and isLogicBuilder)
                            ui.set_visible(aaBuilder[i].yawCondition, vars.activeState == i and ui.get(aaBuilder[i].yaw) ~= "Off" and isBuilderTab and stateEnabled and isEnabled and ispresetdisabled and isLogicBuilder)
                            ui.set_visible(aaBuilder[i].yawStatic, vars.activeState == i and ui.get(aaBuilder[i].yaw) ~= "Off" and ui.get(aaBuilder[i].yawCondition) == "Static" and isBuilderTab and stateEnabled and isEnabled and ispresetdisabled and isLogicBuilder)
                            ui.set_visible(aaBuilder[i].yawLeft, vars.activeState == i and ui.get(aaBuilder[i].yaw) ~= "Off" and ui.get(aaBuilder[i].yawCondition) ~= "Static" and isBuilderTab and stateEnabled and isEnabled and ispresetdisabled and isLogicBuilder)
                            ui.set_visible(aaBuilder[i].yawRight, vars.activeState == i and ui.get(aaBuilder[i].yaw) ~= "Off" and ui.get(aaBuilder[i].yawCondition) ~= "Static" and isBuilderTab and stateEnabled and isEnabled and ispresetdisabled and isLogicBuilder)
                            ui.set_visible(aaBuilder[i].yawSpeed, vars.activeState == i and ui.get(aaBuilder[i].yaw) ~= "Off" and ui.get(aaBuilder[i].yawCondition) == "Slow" and isBuilderTab and stateEnabled and isEnabled and ispresetdisabled and isLogicBuilder)
                            ui.set_visible(aaBuilder[i].yawJitter, vars.activeState == i and ui.get(aaBuilder[i].yaw) ~= "Off" and isBuilderTab and stateEnabled and isEnabled and ispresetdisabled and isLogicBuilder)
                            ui.set_visible(aaBuilder[i].yawJitterCondition, vars.activeState == i and ui.get(aaBuilder[i].yawJitter) ~= "Off" and isBuilderTab and stateEnabled and isEnabled and ispresetdisabled and isLogicBuilder)
                            ui.set_visible(aaBuilder[i].yawJitterStatic, vars.activeState == i and ui.get(aaBuilder[i].yawJitter) ~= "Off" and ui.get(aaBuilder[i].yawJitterCondition) == "Static" and isBuilderTab and stateEnabled and isEnabled and ispresetdisabled and isLogicBuilder)
                            ui.set_visible(aaBuilder[i].yawJitterLeft, vars.activeState == i and ui.get(aaBuilder[i].yawJitter) ~= "Off" and ui.get(aaBuilder[i].yawJitterCondition) == "L & R" and isBuilderTab and stateEnabled and isEnabled and ispresetdisabled and isLogicBuilder)
                            ui.set_visible(aaBuilder[i].yawJitterRight, vars.activeState == i and ui.get(aaBuilder[i].yawJitter) ~= "Off" and ui.get(aaBuilder[i].yawJitterCondition) == "L & R" and isBuilderTab and stateEnabled and isEnabled and ispresetdisabled and isLogicBuilder)
                            ui.set_visible(aaBuilder[i].yawJitterDisablers, vars.activeState == i and ui.get(aaBuilder[i].yawJitter) ~= "Off" and isBuilderTab and stateEnabled and isEnabled and ispresetdisabled and isLogicBuilder)
                            ui.set_visible(aaBuilder[i].bodyYaw, vars.activeState == i and isBuilderTab and stateEnabled and isEnabled and ispresetdisabled and isLogicBuilder)
                            ui.set_visible(aaBuilder[i].bodyYawSlider, vars.activeState == i and ui.get(aaBuilder[i].bodyYaw) ~= "Off" and isBuilderTab and stateEnabled and isEnabled and ispresetdisabled and isLogicBuilder)
                            ui.set_visible(aaBuilder[i].defensiveOpt, vars.activeState == i and isBuilderTab and stateEnabled and isEnabled and ispresetdisabled and isLogicBuilder)
                            ui.set_visible(aaBuilder[i].defensiveYaw, vars.activeState == i and isBuilderTab and stateEnabled and isEnabled and ispresetdisabled and isLogicBuilder)
                            ui.set_visible(aaBuilder[i].defensiveYawSlider, vars.activeState == i and isBuilderTab and stateEnabled and isEnabled and ui.get(aaBuilder[i].defensiveYaw) == "Custom" and ispresetdisabled and isLogicBuilder)
                            ui.set_visible(aaBuilder[i].defensivePitch, vars.activeState == i and isBuilderTab and stateEnabled and isEnabled and ispresetdisabled and isLogicBuilder)
                            ui.set_visible(aaBuilder[i].defensivePitchSlider, vars.activeState == i and isBuilderTab and stateEnabled and isEnabled and ui.get(aaBuilder[i].defensivePitch) == "Custom" and ispresetdisabled and isLogicBuilder)
                        end
        
                        for i, feature in pairs(menu.aaTab) do
                            if type(feature) ~= "table" then
                                ui.set_visible(feature, isAATab and isEnabled)
                            end
                        end 
        
                        for i, feature in pairs(menu.aaTab.manualTab) do
                            if type(feature) ~= "table" then
                                ui.set_visible(feature, isAATab and isEnabled)
                            end
                        end 
        
                        -- builderTab
                        ui.set_visible(menu.builderTab.state, ui.get(menu.builderTab.PresetComboBox) == "Disabled" and isBuilderTab and isEnabled and isLogicBuilder)
                        ui.set_visible(menu.builderTab.buttonBuilder, isBuilderTab and isEnabled and isLogicPresets)
                        ui.set_visible(menu.builderTab.buttonPresets, isBuilderTab and isEnabled and isLogicBuilder)
                        ui.set_visible(menu.builderTab.PresetComboBox, isBuilderTab and isEnabled and isLogicPresets)
                        ui.set_visible(menu.builderTab.LogicComboBox, isBuilderTab and isEnabled and logica1337 == "1")
        
                        for i, feature in pairs(menu.visualsTab) do
                            if type(feature) ~= "table" then
                                ui.set_visible(feature, isVisualsTab and isEnabled)
                            end
                        end 
                        ui.set_visible(menu.visualsTab.logsinfo, ui.get(menu.visualsTab.logs) and isVisualsTab and isEnabled)
                        ui.set_visible(menu.visualsTab.logOffset, ui.get(menu.visualsTab.logs) and isVisualsTab and isEnabled)
                        ui.set_visible(menu.visualsTab.logsClr, ui.get(menu.visualsTab.logs) and isVisualsTab and isEnabled)
                        ui.set_visible(menu.visualsTab.indicatorsStyle, ui.get(menu.visualsTab.indicators) == "Soft" and isVisualsTab and isEnabled)
                        ui.set_visible(menu.visualsTab.indicatorsClr, ui.get(menu.visualsTab.indicators) == "Soft" and isVisualsTab and isEnabled)
                        ui.set_visible(menu.visualsTab.arrowIndicatorStyle, ui.get(menu.visualsTab.arrows) and isVisualsTab and isEnabled)
                        ui.set_visible(menu.visualsTab.arrowClr, ui.get(menu.visualsTab.arrows) and isVisualsTab and isEnabled)
                        ui.set_visible(menu.configTab.export, isLogicBuilder and isCFGTab and isEnabled)
                        ui.set_visible(menu.configTab2.WarningConfig, isLogicPresets and isCFGTab and isEnabled)
                        ui.set_visible(menu.configTab2.WarningConfig2, isLogicPresets and isCFGTab and isEnabled)
                        
                        for i, feature in pairs(menu.miscTab) do
                            if type(feature) ~= "table" then
                                ui.set_visible(feature, isMiscTab and isEnabled)
                            end
                        end
        
        
                        ui.set_visible(menu.miscTab.animations, ui.get(menu.miscTab.animationsEnabled) and isMiscTab and isEnabled)
        
                        for i, feature in pairs(menu.homeTab) do
                            if type(feature) ~= "table" then
                                ui.set_visible(feature, isHomeTab and isEnabled)
                            end
                        end
        
                        for i, feature in pairs(menu.configTab) do
                            ui.set_visible(feature, isLogicBuilder and isCFGTab and isEnabled)
                        end
        
                        if not isEnabled and not saved then
                            func.resetAATab()
                            ui.set(refs.fsBodyYaw, isEnabled)
                            ui.set(refs.enabled, isEnabled)
                            saved = true
                        elseif isEnabled and saved then
                            ui.set(refs.fsBodyYaw, not isEnabled)
                            ui.set(refs.enabled, isEnabled)
                            saved = false
                        end
                        func.setAATab(not isEnabled)
        
                    end)
                    -- @region UI_RENDER end
        
                    client.set_event_callback("shutdown", function()
                        if hsValue ~= nil then
                            ui.set(refs.fakeLag[1], hsValue)
                        end
                        if clanTag ~= nil then
                            client.set_clan_tag("")
                        end
                        if dtSaved ~= nil then
                            ui.set(refs.dt[3], "Defensive")
                        end
                        func.setAATab(true)
                        cvar.cl_interp_ratio:set_int(1)
                        cvar.cl_interp:set_int(0.15)
                        cvar.cl_updaterate:set_int(64)
                    end)
        
                    ffi.cdef[[
                        struct c_animstate {
                            char pad[ 3 ];
                            char m_bForceWeaponUpdate; //0x4
                            char pad1[ 91 ];
                            void* m_pBaseEntity; //0x60
                            void* m_pActiveWeapon; //0x64
                            void* m_pLastActiveWeapon; //0x68
                            float m_flLastClientSideAnimationUpdateTime; //0x6C
                            int m_iLastClientSideAnimationUpdateFramecount; //0x70
                            float m_flAnimUpdateDelta; //0x74
                            float m_flEyeYaw; //0x78
                            float m_flPitch; //0x7C
                            float m_flGoalFeetYaw; //0x80
                            float m_flCurrentFeetYaw; //0x84
                            float m_flCurrentTorsoYaw; //0x88
                            float m_flUnknownVelocityLean; //0x8C
                            float m_flLeanAmount; //0x90
                            char pad2[ 4 ];
                            float m_flFeetCycle; //0x98
                            float m_flFeetYawRate; //0x9C
                            char pad3[ 4 ];
                            float m_fDuckAmount; //0xA4
                            float m_fLandingDuckAdditiveSomething; //0xA8
                            char pad4[ 4 ];
                            float m_vOriginX; //0xB0
                            float m_vOriginY; //0xB4
                            float m_vOriginZ; //0xB8
                            float m_vLastOriginX; //0xBC
                            float m_vLastOriginY; //0xC0
                            float m_vLastOriginZ; //0xC4
                            float m_vVelocityX; //0xC8
                            float m_vVelocityY; //0xCC
                            char pad5[ 4 ];
                            float m_flUnknownFloat1; //0xD4
                            char pad6[ 8 ];
                            float m_flUnknownFloat2; //0xE0
                            float m_flUnknownFloat3; //0xE4
                            float m_flUnknown; //0xE8
                            float m_flSpeed2D; //0xEC
                            float m_flUpVelocity; //0xF0
                            float m_flSpeedNormalized; //0xF4
                            float m_flFeetSpeedForwardsOrSideWays; //0xF8
                            float m_flFeetSpeedUnknownForwardOrSideways; //0xFC
                            float m_flTimeSinceStartedMoving; //0x100
                            float m_flTimeSinceStoppedMoving; //0x104
                            bool m_bOnGround; //0x108
                            bool m_bInHitGroundAnimation; //0x109
                            float m_flTimeSinceInAir; //0x10A
                            float m_flLastOriginZ; //0x10E
                            float m_flHeadHeightOrOffsetFromHittingGroundAnimation; //0x112
                            float m_flStopToFullRunningFraction; //0x116
                            char pad7[ 4 ]; //0x11A
                            float m_flMagicFraction; //0x11E
                            char pad8[ 60 ]; //0x122
                            float m_flWorldForce; //0x15E
                            char pad9[ 462 ]; //0x162
                            float m_flMaxYaw; //0x334
        
                            float velocity_subtract_x; //0x0330 
                            float velocity_subtract_y; //0x0334 
                            float velocity_subtract_z; //0x0338 
                        };
        
                        typedef void*(__thiscall* get_client_entity_t)(void*, int);
        
                        typedef struct
                        {
                            float   m_anim_time;		
                            float   m_fade_out_time;	
                            int     m_flags;			
                            int     m_activity;			
                            int     m_priority;			
                            int     m_order;			
                            int     m_sequence;			
                            float   m_prev_cycle;		
                            float   m_weight;			
                            float   m_weight_delta_rate;
                            float   m_playback_rate;	
                            float   m_cycle;			
                            void* m_owner;			
                            int     m_bits;				
                        } C_AnimationLayer;
        
                        typedef uintptr_t (__thiscall* GetClientEntityHandle_4242425_t)(void*, uintptr_t);
                    ]]
        
                    ffi.cdef[[
                        typedef struct MaterialAdapterInfo_tt
                        {
                            char m_pDriverName[512];
                            unsigned int m_VendorID;
                            unsigned int m_DeviceID;
                            unsigned int m_SubSysID;
                            unsigned int m_Revision;
                            int m_nDXSupportLevel;			// This is the *preferred* dx support level
                            int m_nMinDXSupportLevel;
                            int m_nMaxDXSupportLevel;
                            unsigned int m_nDriverVersionHigh;
                            unsigned int m_nDriverVersionLow;
                        };
        
                        typedef int(__thiscall* get_current_adapter_fn)(void*);
                        typedef void(__thiscall* get_adapter_info_fn)(void*, int adapter, struct MaterialAdapterInfo_t& info);
                    ]]
        
                    math.clamp = function(v, min, max)
                        if min > max then min, max = max, min end
                        if v > max then return max end
                        if v < min then return v end
                        return v
                    end
        
                    math.vec_length2d = function(vec)
                        root = 0.0
                        sqst = vec.x * vec.x + vec.y * vec.y
                        root = math.sqrt(sqst)
                        return root
                    end
        
                    math.angle_diff = function(dest, src)
                        local delta = 0.0
        
                        delta = math.fmod(dest - src, 360.0)
        
                        if dest > src then
                            if delta >= 180 then delta = delta - 360 end
                        else
                            if delta <= -180 then delta = delta + 360 end
                        end
        
                        return delta
                    end
        
                    math.angle_normalize = function(angle)
                        local ang = 0.0
                        ang = math.fmod(angle, 360.0)
        
                        if ang < 0.0 then ang = ang + 360 end
        
                        return ang
                    end
        
                    math.anglemod = function(a)
                        local num = (360 / 65536) * bit.band(math.floor(a * (65536 / 360.0), 65535))
                        return num
                    end
        
                    math.approach_angle = function(target, value, speed)
                        target = math.anglemod(target)
                        value = math.anglemod(value)
        
                        local delta = target - value
        
                        if speed < 0 then speed = -speed end
        
                        if delta < -180 then
                            delta = delta + 360
                        elseif delta > 180 then
                            delta = delta - 360
                        end
        
                        if delta > speed then
                            value = value + speed
                        elseif delta < -speed then
                            value = value - speed
                        else
                            value = target
                        end
        
                        return value
                    end
        
                    local entity_list_ptr = ffi.cast("void***", client.create_interface("client.dll", "VClientEntityList003"))
                    local get_client_entity_fn = ffi.cast("GetClientEntityHandle_4242425_t", entity_list_ptr[0][3])
                    local get_client_entity_by_handle_fn = ffi.cast("GetClientEntityHandle_4242425_t", entity_list_ptr[0][4])
                    local voidptr = ffi.typeof("void***")
                    local rawientitylist = client.create_interface("client_panorama.dll", "VClientEntityList003") or error("VClientEntityList003 wasnt found", 2)
                    local ientitylist = ffi.cast(voidptr, rawientitylist) or error("rawientitylist is nil", 2)
                    local get_client_entity = ffi.cast("get_client_entity_t", ientitylist[0][3]) or error("get_client_entity is nil", 2)
        
                    entity.get_vector_prop = function(idx, prop, array)
                        local v1, v2, v3 = entity.get_prop(idx, prop, array)
                        return {
                            x = v1, y = v2, z = v3
                        }
                    end
        
                    entity.get_address = function(idx)
                        return get_client_entity_fn(entity_list_ptr, idx)
                    end
        
                    entity.get_animstate = function(idx)
                        local addr = entity.get_address(idx)
                        if not addr then return end
                        return ffi.cast("struct c_animstate**", addr + 0x9960)[0]
                    end
        
                    entity.get_animlayer = function(idx)
                        local addr = entity.get_address(idx)
                        if not addr then return end
                        return ffi.cast("C_AnimationLayer**", ffi.cast('uintptr_t', addr) + 0x9960)[0]
                    end
        
                    local resolver = {}
                    resolver.m_flMaxDelta = function(idx)
                        local animstate = entity.get_animstate(idx)
        
                        local speedfactor = math.clamp(animstate.m_flFeetSpeedForwardsOrSideWays, 0, 1)
                        local avg_speedfactor = (animstate.m_flStopToFullRunningFraction * -0.3 - 0.2) * speedfactor + 1
        
                        local duck_amount = animstate.m_fDuckAmount
        
                        if duck_amount > 0 then
                            local max_velocity = math.clamp(animstate.m_flFeetSpeedForwardsOrSideWays, 0, 1)
                            local duck_speed = duck_amount * max_velocity
        
                            avg_speedfactor = avg_speedfactor + (duck_speed * (0.5 - avg_speedfactor))
                        end
        
                        return avg_speedfactor
                    end
        
                    resolver.layers = {}
                    resolver.update_layers = function(idx)
                        local layers = entity.get_animlayer(idx)
                        if not layers then return end
                    
                        if not resolver.layers[idx] then
                            resolver.layers[idx] = {}
                        end
                    
                        for i = 1, 12 do
                            local layer = layers[i]
                            if layer then
                                if not resolver.layers[idx][i] then
                                    resolver.layers[idx][i] = {}
                                end
                    
                                resolver.layers[idx][i].m_playback_rate = layer.m_playback_rate or resolver.layers[idx][i].m_playback_rate
                                resolver.layers[idx][i].m_sequence = layer.m_sequence or resolver.layers[idx][i].m_sequence
                            end
                        end
                    end
                    
        
                    resolver.m_bIsBreakingLby = function(idx)
                        if not resolver.layers[idx] then return end
                        for i = 1, 12 do
                            if not resolver.layers[idx][i] then goto continue end
                            if not resolver.layers[idx][i].m_sequence then goto continue end
        
                            if resolver.layers[idx][i].m_sequence == 979 then return true end
        
                            ::continue::
                        end
                        return false
                    end
        
                    resolver.safepoints = {}
                    resolver.rotation = {
                        CENTER = 1,
                        LEFT = 2,
                        RIGHT = 3
                    }
                    resolver.update_safepoints = function(idx, side, desync)
                        if not resolver.safepoints[idx] then
                            resolver.safepoints[idx] = {}
                        end
        
                        if not resolver.safepoints[idx][3] then
                            for i = 1, 3 do
                                resolver.safepoints[idx][i] = {}
                                resolver.safepoints[idx][i].m_playback_rate = nil
                                resolver.safepoints[idx][i].m_flDesync = nil
                            end
                        end
        
                        if side < 0 then
                            if not resolver.safepoints[idx][3].m_flDesync then
                                resolver.safepoints[idx][3].m_flDesync = -desync
                            end
        
                            if math.abs(resolver.safepoints[idx][3].m_flDesync) <= desync then
                                resolver.safepoints[idx][3].m_flDesync = -desync
                                resolver.safepoints[idx][3].m_playback_rate = resolver.layers[idx][6].m_playback_rate
                            end
        
                            if not resolver.safepoints[idx][3].m_playback_rate then
                                resolver.safepoints[idx][3].m_playback_rate = resolver.layers[idx][6].m_playback_rate
                            end
                        elseif side > 0 then
                            if not resolver.safepoints[idx][2].m_flDesync then
                                resolver.safepoints[idx][2].m_flDesync = desync
                            end
        
                            if resolver.safepoints[idx][2].m_flDesync >= desync then
                                resolver.safepoints[idx][2].m_flDesync = desync
                                resolver.safepoints[idx][2].m_playback_rate = resolver.layers[idx][6].m_playback_rate
                            end
        
                            if not resolver.safepoints[idx][2].m_playback_rate then
                                resolver.safepoints[idx][2].m_playback_rate = resolver.layers[idx][6].m_playback_rate
                            end 
                        else
                            local m_flDesync = side * desync
                            if not resolver.safepoints[idx][1].m_flDesync then
                                resolver.safepoints[idx][1].m_flDesync = m_flDesync
                            end
                        
                            if math.abs(resolver.safepoints[idx][1].m_flDesync) >= desync then
                                resolver.safepoints[idx][1].m_flDesync = m_flDesync
                                resolver.safepoints[idx][1].m_playback_rate = resolver.layers[idx][6].m_playback_rate
                            end
                        
                            if not resolver.safepoints[idx][1].m_playback_rate then
                                resolver.safepoints[idx][1].m_playback_rate = resolver.layers[idx][6].m_playback_rate
                            end 
                        end
        
                        if resolver.safepoints[idx][2].m_playback_rate and resolver.safepoints[idx][3].m_playback_rate then
                            local m_flDesync = side * desync
                            if m_flDesync >= resolver.safepoints[idx][3].m_flDesync then
                                if m_flDesync <= resolver.safepoints[idx][2].m_flDesync then
                                    if not resolver.safepoints[idx][1].m_flDesync then
                                        resolver.safepoints[idx][1].m_flDesync = m_flDesync
                                    end
                                
                                    if math.abs(resolver.safepoints[idx][1].m_flDesync) >= desync then
                                        resolver.safepoints[idx][1].m_flDesync = m_flDesync
                                        resolver.safepoints[idx][1].m_playback_rate = resolver.layers[idx][6].m_playback_rate
                                    end
                                
                                    if not resolver.safepoints[idx][1].m_playback_rate then
                                        resolver.safepoints[idx][1].m_playback_rate = resolver.layers[idx][6].m_playback_rate
                                    end 
                                end
                            end
                        end
                    end
        
                    resolver.walk_to_run_transition = function(m_flWalkToRunTransition, m_bWalkToRunTransitionState,
                        m_flLastUpdateIncrement, m_flVelocityLengthXY)
                        ANIM_TRANSITION_WALK_TO_RUN = false
                        ANIM_TRANSITION_RUN_TO_WALK = true
                        CSGO_ANIM_WALK_TO_RUN_TRANSITION_SPEED = 2.0
                        CS_PLAYER_SPEED_RUN = 260.0
                        CS_PLAYER_SPEED_DUCK_MODIFIER = 0.34
                        CS_PLAYER_SPEED_WALK_MODIFIER = 0.52
        
                        if m_flWalkToRunTransition > 0 and m_flWalkToRunTransition < 1 then
                            if m_bWalkToRunTransitionState == ANIM_TRANSITION_WALK_TO_RUN then
                                m_flWalkToRunTransition = m_flWalkToRunTransition + m_flLastUpdateIncrement * CSGO_ANIM_WALK_TO_RUN_TRANSITION_SPEED
                            else
                                m_flWalkToRunTransition = m_flWalkToRunTransition - m_flLastUpdateIncrement * CSGO_ANIM_WALK_TO_RUN_TRANSITION_SPEED
                            end
        
                            m_flWalkToRunTransition = math.clamp(m_flWalkToRunTransition, 0, 1)
                        end
        
                        if m_flVelocityLengthXY >
                            (CS_PLAYER_SPEED_RUN * CS_PLAYER_SPEED_WALK_MODIFIER) and m_bWalkToRunTransitionState == ANIM_TRANSITION_RUN_TO_WALK then
                            m_bWalkToRunTransitionState = ANIM_TRANSITION_WALK_TO_RUN
                            m_flWalkToRunTransition = math.max(0.01, m_flWalkToRunTransition)
                        elseif m_flVelocityLengthXY < (CS_PLAYER_SPEED_RUN * CS_PLAYER_SPEED_WALK_MODIFIER) and m_bWalkToRunTransitionState == ANIM_TRANSITION_WALK_TO_RUN then
                            m_bWalkToRunTransitionState = ANIM_TRANSITION_RUN_TO_WALK
                            m_flWalkToRunTransition = math.min(0.99, m_flWalkToRunTransition)
                        end
        
                        return m_flWalkToRunTransition, m_bWalkToRunTransitionState
                    end
        
                    resolver.calculate_predicted_foot_yaw = function(m_flFootYawLast, m_flEyeYaw, m_flLowerBodyYawTarget, m_flWalkToRunTransition, m_vecVelocity, m_flMinBodyYaw, m_flMaxBodyYaw)
                        local m_flVelocityLengthXY = math.min(math.vec_length2d( m_vecVelocity ), 260.0)
        
                        local m_flFootYaw = math.clamp(m_flFootYawLast, -360, 360)
                        local flEyeFootDelta = math.angle_diff(m_flEyeYaw, m_flFootYaw)
        
                        if flEyeFootDelta > m_flMaxBodyYaw then
                            m_flFootYaw = m_flEyeYaw - math.abs(m_flMaxBodyYaw)
                        elseif flEyeFootDelta < m_flMinBodyYaw then
                            m_flFootYaw = m_flEyeYaw + math.abs(m_flMinBodyYaw)
                        end
        
                        m_flFootYaw = math.angle_normalize(m_flFootYaw)
        
                        local m_flLastUpdateIncrement = globals.tickinterval()
        
                        if m_flVelocityLengthXY > 0.1 or m_vecVelocity.z > 100 then
                            m_flFootYaw = math.approach_angle(m_flEyeYaw, m_flFootYaw, m_flLastUpdateIncrement * (30.0 + 20.0 * m_flWalkToRunTransition))
                        else
                            m_flFootYaw = math.approach_angle(m_flLowerBodyYawTarget, m_flFootYaw, m_flLastUpdateIncrement * 100)
                        end
        
                        return m_flFootYaw
                    end
        
                    resolver.previous = {}
                    resolver.resolve = function(idx)
                        -- type of idx = unsigned int, can t go under 1
                        if not idx or idx <= 0 then return end
        
                        -- Checking For Valid Index.
                        -- Required for !crash
                        local m_bIsValidIdx = entity.get_address(idx)
                        if not m_bIsValidIdx then return end
        
                        local animstate = entity.get_animstate(idx)
                        if not animstate then return end
                        resolver.update_layers(idx) -- Update Entity Animation Layers
        
                        if not resolver.previous[idx] then
                            resolver.previous[idx] = {}
                        end
        
                        local m_vecVelocity = entity.get_vector_prop(idx, 'm_vecVelocity')
                        local m_flVelocityLengthXY = math.vec_length2d(m_vecVelocity) -- We don t need to check for jump
        
                        local m_flMaxDesyncDelta = resolver.m_flMaxDelta(idx) -- return float
                        local m_flDesync = m_flMaxDesyncDelta * 58 -- 57 (Max Desync Value)
        
                        local m_flEyeYaw = animstate.m_flEyeYaw -- Current Entity Eye Yaw
                        local m_flGoalFeetYaw = animstate.m_flGoalFeetYaw -- Current Feet Yaw
                        local m_flLowerBodyYawTarget = entity.get_prop(idx, 'm_flLowerBodyYawTarget') -- Current Lower Body Yaw
        
                        local m_flAngleDiff = math.angle_diff(m_flEyeYaw, m_flGoalFeetYaw)
        
                        local side = 0 -- It can be centered? Oh yeah bots and legit players
                        if m_flAngleDiff < 0 then
                            side = 1
                        elseif m_flAngleDiff > 0 then
                            side = -1
                        end
        
                        local m_flAbsAngleDiff = math.abs(m_flAngleDiff) -- Current Angle Diffrence, Only positive value
                        local m_flAbsPreviousDiff = math.abs(resolver.previous[idx].m_flAbsAngleDiff or m_flAbsAngleDiff) -- Previous Angle Diffrence
        
                        local m_bShouldTryResolve = true -- Yes, we wanna resolve
        
                        if m_flAbsAngleDiff > 0 or m_flAbsPreviousDiff > 0 then
                            if m_flAbsAngleDiff < m_flAbsPreviousDiff then
                                m_bShouldTryResolve = false
        
                                if m_flVelocityLengthXY > (resolver.previous[idx].m_flVelocityLengthXY or 0) then
                                    m_bShouldTryResolve = true
                                end
                            end
        
                            if resolver.m_bIsBreakingLby(idx) then m_bShouldTryResolve = true end
        
                            if m_bShouldTryResolve then
                                local m_flCurrentAngle = math.max(m_flAbsAngleDiff, m_flAbsPreviousDiff)
                                if m_flAbsAngleDiff <= 10.0 and m_flAbsPreviousDiff <= 10.0 then
                                    m_flDesync = m_flCurrentAngle
                                elseif m_flAbsAngleDiff <= 35.0 and m_flAbsPreviousDiff <= 35.0 then
                                    m_flDesync = math.max(29.0, m_flCurrentAngle)
                                else
                                    m_flDesync = math.clamp(m_flCurrentAngle, 29.0, 58)
                                end
                            end
                        end
        
                        m_flDesync = math.clamp(m_flDesync, 0, (m_flMaxDesyncDelta * 58))
        
                        resolver.update_safepoints(idx, side, m_flDesync) -- I wanna kill myself
        
                        if m_flVelocityLengthXY > 5 and side ~= 0 then
                            if resolver.safepoints[1] and resolver.safepoints[2] and resolver.safepoints[3] then
                                if resolver.safepoints[1].m_playback_rate and resolver.safepoints[2].m_playback_rate and resolver.safepoints[3].m_playback_rate then
                                    local server_playback = resolver.layers[idx][6].m_playback_rate
                                    local center_playback = resolver.safepoints[1].m_playback_rate
                                    local left_playback = resolver.safepoints[2].m_playback_rate
                                    local right_playback = resolver.safepoints[3].m_playback_rate
        
                                    local m_layer_delta1 = math.abs(server_playback - center_playback)
                                    local m_layer_delta2 = math.abs(server_playback - left_playback)
                                    local m_layer_delta3 = math.abs(server_playback - right_playback)
        
                                    if m_layer_delta1 < m_layer_delta2 or m_layer_delta3 <= m_layer_delta2 then
                                        if m_layer_delta1 >= m_layer_delta3 or m_layer_delta2 > m_layer_delta3 then
                                            side = 1
                                        end
                                    else
                                        side = -1
                                    end
                                end
                            end
                        end
        
                        -- @BackupPrevious
                        resolver.previous[idx].m_flAbsAngleDiff = m_flAbsAngleDiff
                        resolver.previous[idx].m_flVelocityLengthXY = m_flVelocityLengthXY
        
                        resolver.previous[idx].m_flDesync = m_flDesync * side
        
                        resolver.previous[idx].m_flGoalFeetYaw = animstate.m_flGoalFeetYaw
                        -- #EndBackupPrevious
        
                        -- @Debug
        
                        --print(tostring(entity.get_player_name(idx) .. ' : ' .. resolver.previous[idx].m_flDesync))
                        
                        -- #EndDebug
        
                        resolver.previous[idx].m_flWalkToRunTransition, resolver.previous[idx].m_bWalkToRunTransitionState = resolver.walk_to_run_transition(
                            resolver.previous[idx].m_flWalkToRunTransition or 0,
                            resolver.previous[idx].m_bWalkToRunTransitionState or false,
                            globals.tickinterval(), m_flVelocityLengthXY
                        ) -- We need this only for m_flWalkToRunTransition
        
                        resolver.previous[idx].m_flPredictedFootYaw = resolver.calculate_predicted_foot_yaw(
                            m_flGoalFeetYaw, m_flEyeYaw + resolver.previous[idx].m_flDesync, m_flLowerBodyYawTarget,
                            resolver.previous[idx].m_flWalkToRunTransition, m_vecVelocity, -58, 58
                        ) -- Calculate new foot yaw
        
                        --animstate.m_flGoalFeetYaw = resolver.previous[idx].m_flPredictedFootYaw -- Set New Resolved Foot Yaw
                        dbgangle = math.floor(resolver.previous[idx].m_flDesync)
                        dbgside = side
                        plist.set(idx, 'Force body yaw', true)
                        plist.set(idx, 'Force body yaw value', math.floor(resolver.previous[idx].m_flPredictedFootYaw))
                    end
        
                    resolver.call = function()
                        local lp = entity.get_local_player()
                        if not lp or lp <= 0 then return end
                        local lp_health = entity.get_prop(lp, 'm_iHealth')
                        if lp_health < 1 then return end
        
                        local players = entity.get_players(true)
                        if ui.get(menu.miscTab.resolver) then
                        for idx in pairs(players) do
                            if idx == lp then goto continue end
                            local m_iHealth = entity.get_prop(idx, 'm_iHealth')
                            if not m_iHealth then goto continue end
                            if m_iHealth < 1 then goto continue end
        
                            resolver.resolve(idx)
        
                            ::continue::
                        end
                        end
                    end
        
                    client.set_event_callback('net_update_start', function()
                        resolver.call()
                    end)
        
                    client.set_event_callback("setup_command", function(cmd)
                        if ui.get(menu.miscTab.resolver) then
                            cvar.cl_interp_ratio:set_int(0)
                            cvar.cl_interp:set_int(0)
                            cvar.cl_updaterate:set_int(62)
                        end
                    end)
        
                
