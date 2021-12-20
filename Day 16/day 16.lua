local open = io.open

-- http://lua-users.org/wiki/FunctionalLibrary
local function foldr(func, val, tbl)
    for i, v in pairs(tbl) do
        val = func(val, v)
    end
    return val
end

local function read_file(path)
    local file = open(path, "rb") -- r read mode and b binary mode
    if not file then
        return nil
    end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end

local function getBitAt(bitPosition)
    local charPos = math.floor(bitPosition / 4)
    local bitPosInsideChar = bitPosition % 4
    local nibble = tonumber(FileContent:sub(charPos, charPos + 1), 16)
    local mask = 1 << (3 - bitPosInsideChar)
    return (mask & nibble) > 0;
end

local function readNumber(numBits)
    local result = 0
    for i = 0, numBits - 1 do
        if (getBitAt(BitPosition + i)) then
            result = result | (1 << (numBits - i - 1))
        end
    end
    BitPosition = BitPosition + numBits
    return result
end

local function readLiteralPackage()
    local packageSize = 0
    local value = 0;
    repeat
        local numberFragment = readNumber(5)
        packageSize = packageSize + 5
        
        local numberBody = numberFragment & 15
        value = (value << 4) | numberBody
    until numberFragment & 16 == 0
    return packageSize, value
end

local function readOperatorPackage(packetTypeId)
    local subPackageValues = {}
    local packageSize = 0

    local lengthType = readNumber(1)
    packageSize = packageSize + 1

    local numSubPackages

    if (lengthType == 0) then
        local lengthSubPackages = readNumber(15)
        packageSize = packageSize + 15

        -- by length
        local readSubpackageSize = 0
        local i = 0
        while readSubpackageSize < lengthSubPackages do
            local subPackageSize, subpackageValue = ReadPackage()
            readSubpackageSize = readSubpackageSize + subPackageSize
            packageSize = packageSize + subPackageSize

            subPackageValues[i] = subpackageValue
            i = i + 1
        end
        numSubPackages = i
    else
        numSubPackages = readNumber(11)
        packageSize = packageSize + 11

        -- by nums package
        for i = 1, numSubPackages do
            local subPackageSize, subpackageValue = ReadPackage()
            packageSize = packageSize + subPackageSize
            subPackageValues[i - 1] = subpackageValue
        end
    end

    -- accumulating the results
    if (packetTypeId == 0) then
        return packageSize, foldr(function(a, b)
            return a + b
        end, 0, subPackageValues)
    elseif (packetTypeId == 1) then
        if (numSubPackages == 1) then
            return packageSize, subPackageValues[0]
        else
            return packageSize, foldr(function(a, b)
                return a * b
            end, 1, subPackageValues)
        end
    elseif (packetTypeId == 2) then
        return packageSize, foldr(function(a, b)
            return math.min(a, b)
        end, subPackageValues[0], subPackageValues)
    elseif (packetTypeId == 3) then
        return packageSize, foldr(function(a, b)
            return math.max(a, b)
        end, subPackageValues[0], subPackageValues)
    elseif (packetTypeId == 5) then
        if (subPackageValues[0] > subPackageValues[1]) then
            return packageSize, 1
        else
            return packageSize, 0
        end
    elseif (packetTypeId == 6) then
        if (subPackageValues[0] < subPackageValues[1]) then
            return packageSize, 1
        else
            return packageSize, 0
        end
    elseif (packetTypeId == 7) then
        if (subPackageValues[0] == subPackageValues[1]) then
            return packageSize, 1
        else
            return packageSize, 0
        end
    end
end

function ReadPackage()
    local packageSize = 0

    local version = readNumber(3)
    packageSize = packageSize + 3

    AccumulatedVersions = AccumulatedVersions + version

    local packetTypeId = readNumber(3)
    packageSize = packageSize + 3

    if (packetTypeId == 4) then
        local subpackageSize, subpackageValue = readLiteralPackage()
        packageSize = packageSize + subpackageSize
        return packageSize, subpackageValue
    else
        local subpackageSize, subpackageValue = readOperatorPackage(packetTypeId)
        packageSize = packageSize + subpackageSize
        return packageSize, subpackageValue
    end
end

FileContent = read_file("./input.txt");

AccumulatedVersions = 0
BitPosition = 0

local packageSize, val = ReadPackage()
print("accumulated version (part 1) is " .. AccumulatedVersions)
print("overall value (part 2) is " .. val)
