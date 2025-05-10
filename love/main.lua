local love = require("love")

local screenWidth, screenHeight
local cellSize = 5
local gridWidth, gridHeight
local grid, nextGrid

function love.load()
    love.window.setMode(0, 0, { fullscreen = true })
    screenWidth, screenHeight = love.graphics.getDimensions()

    gridWidth = math.floor(screenWidth / cellSize)
    gridHeight = math.floor(screenHeight / cellSize)

    grid = {}
    nextGrid = {}
    for x = 0, gridWidth - 1 do
        grid[x] = {}
        nextGrid[x] = {}
        for y = 0, gridHeight - 1 do
            grid[x][y] = love.math.random(0, 1)
            nextGrid[x][y] = 0
        end
    end

    love.graphics.setBackgroundColor(0, 0, 0)
end

local function countNeighbors(x, y)
    local count = 0
    for dx = -1, 1 do
        for dy = -1, 1 do
            if not (dx == 0 and dy == 0) then
                local nx, ny = x + dx, y + dy
                if nx >= 0 and nx < gridWidth and ny >= 0 and ny < gridHeight then
                    count = count + grid[nx][ny]
                end
            end
        end
    end
    return count
end

local function updateGrid()
    for x = 0, gridWidth - 1 do
        for y = 0, gridHeight - 1 do
            local neighbors = countNeighbors(x, y)
            local alive = grid[x][y]

            if alive == 1 and (neighbors < 2 or neighbors > 3) then
                nextGrid[x][y] = 0
            elseif alive == 0 and neighbors == 3 then
                nextGrid[x][y] = 1
            else
                nextGrid[x][y] = alive
            end
        end
    end
    grid, nextGrid = nextGrid, grid
end

function love.update(dt)
    updateGrid()
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    for x = 0, gridWidth - 1 do
        for y = 0, gridHeight - 1 do
            if grid[x][y] == 1 then
                love.graphics.rectangle("fill", x * cellSize, y * cellSize, cellSize, cellSize)
            end
        end
    end
end
