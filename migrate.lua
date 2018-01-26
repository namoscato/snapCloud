-- Migration utility
-- =================
--
-- This utility helps migrate records from the old cloud into the new one.
-- Not meant to be used from Lapis but as a command-line utility.
--
-- written by Bernat Romagosa
--
-- Copyright (C) 2017 by Bernat Romagosa
--
-- This file is part of Snap Cloud.
--
-- Snap Cloud is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Affero General Public License as
-- published by the Free Software Foundation, either version 3 of
-- the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Affero General Public License for more details.
--
-- You should have received a copy of the GNU Affero General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

local pgmoon = require('pgmoon')
local url = os.getenv('DATABASE_URL')
local table = arg[1] or nil
local filename = arg[2] or nil
local file = io.open(filename, 'r')
local usage = 'Usage:\n\nlua migrate.lua [user/projects] [file.xml]\n'
local raw_data

local db = pgmoon.new({
  host = url:match("([^:]*)"), -- only up to ":"
  port = url:match("^.*%:(.*)"), -- after ":"
  database = os.getenv('DATABASE_NAME'),
  user = os.getenv('DATABASE_USERNAME'),
  password = os.getenv('DATABASE_PASSWORD')
})

assert(db:connect())

if not (arg[1] and arg[2]) then
    print(usage)
end

if file then
    raw_data = file:read("*all")
    file:close()
else
    print('Could not read ' .. filename)  
    print(usage)
    os.exit()
end

function migrate_user()
    local fields = {}
    local i = 1
    raw_data:gsub("([^".. "\1" .."]*)" .. "\1", function (field)
        fields[i] = field
        i = i + 1
    end)

    print('migrating user ' .. fields[2])

    print(db:query("insert into users (created, username, salt, password, email, isadmin) values (" ..
        "'" .. fields[8] .. "', " ..
        "'" .. fields[2] .. "', " ..
        "'" .. fields[5] .. "', " ..
        "'" .. fields[4] .. "', " ..
        "'" .. fields[3] .. "', " ..
        "false);"))
end

function migrate_projects()
    print('migrating projects')
end

_G['migrate_' .. table]()
