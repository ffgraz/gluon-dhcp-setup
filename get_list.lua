#!/usr/bin/env lua

local open = io.open

local function read_file(path)
    local file = open(path, "rb") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end

local board2gluon = {}

function device(gluon, board)
  board2gluon[board:gsub("[^a-z0-9]", "")] = gluon
  board2gluon[gluon:gsub("[^a-z0-9]", "")] = gluon
end

function packages() end

function config() end

function include() end

function defaults() end

env = {}

local listTargets = io.popen("cd .. && make list-targets")

for line in listTargets:lines() do
  if line then
    local fileContent = read_file("../targets/" .. line);
    local fnc = loadstring (fileContent);
    local site = fnc();
  end
end

for k, v in pairs(board2gluon) do
  print(k .. "=" .. v)
end
