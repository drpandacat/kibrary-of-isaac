--[[
    Kerkel's Standard Isaac Library
    not to be confused with
    Thicco's Standard Isaac Library

    Version 1.0.2

    Collection of libraries, utility functions, enums, and other declarations I find useful to use across mods

    GitHub repository: https://github.com/drpandacat/kibrary-of-isaac

    Special thanks to:
    Catinsurance
    Sanio64
    Thicco Catto
]]

---@class ksil.Preferences
---@field JumpLib boolean?
---@field CustomStatusLib boolean?
---@field HiddenItemManager boolean?

---@param name string
---@param path string
---@param preferences ksil.Preferences?
return {SuperRegisterMod = function (self, name, path, preferences)
    local mod = RegisterMod(name, 1)

    local AddCallback = mod.AddCallback
    local AddPriorityCallback = mod.AddPriorityCallback

    ---@param id ModCallbacks | JumpCallback | CustomStatusCallback | SaveManager.Utility.CustomCallback | string
    ---@param fn function
    ---@param param any
    function mod:AddCallback(id, fn, param)
        AddCallback(mod, id, fn, param)
    end

    ---@param id ModCallbacks | JumpCallback | CustomStatusCallback | SaveManager.Utility.CustomCallback | string
    ---@param priority CallbackPriority | integer
    ---@param fn function
    ---@param param any
    function mod:AddPriorityCallback(id, priority, fn, param)
        AddPriorityCallback(mod, id, priority, fn, param)
    end

    ---@module "IsaacSaveManager.src.save_manager"
    mod.SaveManager = include(path .. ".IsaacSaveManager.src.save_manager")
    mod.SaveManager.Init(mod)

    if not preferences or preferences.HiddenItemManager ~= false then
        ---@module "HiddenItemManager.hidden_item_manager"
        mod.HiddenItemManager = require(path .. ".HiddenItemManager.hidden_item_manager")
        mod.HiddenItemManager:Init(mod)

        mod:AddCallback(mod.SaveManager.Utility.CustomCallback.POST_DATA_SAVE, function ()
            mod.SaveManager.GetRunSave().HiddenItemManager = mod.HiddenItemManager:GetSaveData()
        end)

        mod:AddCallback(mod.SaveManager.Utility.CustomCallback.POST_DATA_LOAD, function ()
            mod.HiddenItemManager:LoadData(mod.SaveManager.GetRunSave().HiddenItemManager or {})
        end)
    end

    if not preferences or preferences.JumpLib ~= false then
        include(path .. ".JumpLib.jumplib").Init()
    end

    if REPENTOGON and (not preferences or preferences.CustomStatusLib ~= false) then
        include(path .. ".CustomStatusLib.customstatuslib").Init()
    end

    __TEMP_DATA = __TEMP_DATA or {} -- TODO: replace

    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function ()
        __TEMP_DATA = {}
    end)

    ---@param entity Entity
    mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function (_, entity)
        if not __TEMP_DATA[mod.Name] then return end
        __TEMP_DATA[mod.Name][GetPtrHash(entity)] = nil
    end)

    mod.TEAR_COPYING_FAMILIARS = (JumpLib and JumpLib.Internal.TEAR_COPYING_FAMILIARS) or {
        [FamiliarVariant.INCUBUS] = true,
        [FamiliarVariant.TWISTED_BABY] = true,
        [FamiliarVariant.UMBILICAL_BABY] = true,
        [FamiliarVariant.BLOOD_BABY] = true,
    }

    ---@enum DataPersistenceMode
    mod.DataPersistenceMode = {
        ROOM = 1,
        RUN = 2,
        FLOOR = 3,
        ROOM_FLOOR = 4
    }

    mod.Vector = {
        ZERO = Vector(0, 0),
        ONE = Vector(1, 1),
    }

    mod.Color = {
        DEFAULT = Color(1, 1, 1, 1)
    }

    ---@param type EntityType | integer
    ---@param variant integer | integer
    ---@param position Vector
    ---@param velocity? Vector
    ---@param subtype? integer
    ---@param spawner? Entity
    ---@param seed? integer
    ---@return EntityNPC
    function mod:SpawnNPC(type, variant, position, velocity, spawner, subtype, seed)
        ---@diagnostic disable-next-line: return-type-mismatch
        return Game():Spawn(type, variant, position, velocity or mod.Vector.ZERO, spawner or nil, subtype or 0, seed or math.max(Random(), 1)):ToNPC()
    end

    ---@param variant EffectVariant | integer
    ---@param position Vector
    ---@param velocity? Vector
    ---@param subtype? integer
    ---@param spawner? Entity
    ---@param seed? integer
    ---@return EntityEffect
    function mod:SpawnEffect(variant, position, velocity, spawner, subtype, seed)
        ---@diagnostic disable-next-line: return-type-mismatch
        return Game():Spawn(EntityType.ENTITY_EFFECT, variant, position, velocity or mod.Vector.ZERO, spawner or nil, subtype or 0, seed or math.max(Random(), 1)):ToEffect()
    end

    ---@param variant TearVariant | integer
    ---@param position Vector
    ---@param velocity? Vector
    ---@param subtype? integer
    ---@param spawner? Entity
    ---@param seed? integer
    ---@return EntityTear
    function mod:SpawnTear(variant, position, velocity, spawner, subtype, seed)
        ---@diagnostic disable-next-line: return-type-mismatch
        return Game():Spawn(EntityType.ENTITY_TEAR, variant, position, velocity or mod.Vector.ZERO, spawner or nil, subtype or 0, seed or math.max(Random(), 1)):ToTear()
    end

    ---@param variant ProjectileVariant | integer
    ---@param position Vector
    ---@param velocity? Vector
    ---@param subtype? integer
    ---@param spawner? Entity
    ---@param seed? integer
    ---@return EntityProjectile
    function mod:SpawnProjectile(variant, position, velocity, spawner, subtype, seed)
        ---@diagnostic disable-next-line: return-type-mismatch
        return Game():Spawn(EntityType.ENTITY_PROJECTILE, variant, position, velocity or mod.Vector.ZERO, spawner or nil, subtype or 0, seed or math.max(Random(), 1)):ToProjectile()
    end

    ---@param variant PickupVariant | integer
    ---@param position Vector
    ---@param velocity? Vector
    ---@param subtype? integer
    ---@param spawner? Entity
    ---@param seed? integer
    ---@return EntityPickup
    function mod:SpawnPickup(variant, position, velocity, spawner, subtype, seed)
        ---@diagnostic disable-next-line: return-type-mismatch
        return Game():Spawn(EntityType.ENTITY_PICKUP, variant, position, velocity or mod.Vector.ZERO, spawner or nil, subtype or 0, seed or math.max(Random(), 1)):ToPickup()
    end

    ---@param variant FamiliarVariant | integer
    ---@param position Vector
    ---@param velocity? Vector
    ---@param subtype? integer
    ---@param spawner? Entity
    ---@param seed? integer
    ---@return EntityFamiliar
    function mod:SpawnFamiliar(variant, position, velocity, spawner, subtype, seed)
        ---@diagnostic disable-next-line: return-type-mismatch
        return Game():Spawn(EntityType.ENTITY_FAMILIAR, variant, position, velocity or mod.Vector.ZERO, spawner or nil, subtype or 0, seed or math.max(Random(), 1)):ToFamiliar()
    end

    ---@param variant BombVariant | integer
    ---@param position Vector
    ---@param velocity? Vector
    ---@param subtype? integer
    ---@param spawner? Entity
    ---@param seed? integer
    ---@return EntityBomb
    function mod:SpawnBomb(variant, position, velocity, spawner, subtype, seed)
        ---@diagnostic disable-next-line: return-type-mismatch
        return Game():Spawn(EntityType.ENTITY_BOMB, variant, position, velocity or mod.Vector.ZERO, spawner or nil, subtype or 0, seed or math.max(Random(), 1)):ToBomb()
    end

    ---@param entity Entity
    ---@param identifier string
    ---@param persistenceMode? DataPersistenceMode
    ---@return table
    function mod:GetData(entity, identifier, persistenceMode)
        if not persistenceMode then
            local hash = GetPtrHash(entity)
            __TEMP_DATA[self.Name] = __TEMP_DATA[self.Name] or {}
            __TEMP_DATA[self.Name][hash] = __TEMP_DATA[self.Name][hash] or {}
            __TEMP_DATA[self.Name][hash][identifier] = __TEMP_DATA[self.Name][hash][identifier] or {}

            return __TEMP_DATA[self.Name][hash][identifier]
        else
            local data

            if persistenceMode == mod.DataPersistenceMode.ROOM then
                data = mod.SaveManager.GetRoomSave(entity)
            elseif persistenceMode == mod.DataPersistenceMode.FLOOR then
                data = mod.SaveManager.GetFloorSave(entity)
            elseif persistenceMode == mod.DataPersistenceMode.ROOM_FLOOR then
                data = mod.SaveManager.GetRoomFloorSave(entity)
            else
                data = mod.SaveManager.GetRunSave(entity)
            end

            data[self.Name] = data[self.Name] or {}
            data[self.Name][identifier] = data[self.Name][identifier] or {}

            return data[self.Name][identifier]
        end
    end

    ---@param player EntityPlayer
    function mod:ApplyBleed(player)
        mod:GetData(player, "Bleeding").Bleeding = true
    end

    ---@param player EntityPlayer
    mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function (_, player)
        local data = mod:GetData(player, "Bleeding") if not data.Bleeding then return end

        if player:GetHearts() <= 1 then
            data.Bleeding = false
            return
        end

        if not player:HasEntityFlags(EntityFlag.FLAG_BLEED_OUT) then
            player:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
        end
    end)

    ---@param flags integer
    ---@param flag integer
    ---@return boolean
    function mod:HasFlags(flags, flag)
        return flags & flag ~= 0
    end

    if REPENTOGON then
        ---@param player EntityPlayer
        ---@param amt integer
        ---@diagnostic disable-next-line: undefined-doc-name
        ---@param type AddHealthType
        ---@diagnostic disable-next-line: undefined-field
        mod:AddCallback(ModCallbacks.MC_POST_PLAYER_ADD_HEARTS, function (_, player, amt, type)
            if amt <= 0 then return end

            local data = mod:GetData(player, "Bleeding") if not data.Bleeding then return end

            ---@diagnostic disable-next-line: undefined-global, param-type-mismatch
            if mod:HasFlags(type, AddHealthType.RED | AddHealthType.ROTTEN) then
                data.Bleeding = false
            end
        end)
    else
        ---@param player EntityPlayer
        mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
            local data = mod:GetData(player, "Bleeding") if not data.Bleeding then return end
            local hearts = player:GetHearts()
            data.PrevHearts = data.PrevHearts or hearts

            if hearts > data.PrevHearts then
                data.Bleeding = false
            end

            data.PrevHearts = hearts
        end)
    end

    ---@param list Entity[]
    ---@param pos Vector
    ---@param condition? fun(entity: Entity): boolean
    ---@param source? Entity
    ---@return Entity[]
    function mod:EntitiesByDistance(list, pos, condition, source)
        local _list = {}
        local sourceHash = source and GetPtrHash(source)

        for _, v in pairs(list) do
            if (not source or GetPtrHash(v) ~= sourceHash) and (not condition or condition(v)) then
                table.insert(_list, v)
            end
        end

        table.sort(_list, function (a, b)
            return a.Position:Distance(pos) < b.Position:Distance(pos)
        end)

        return _list
    end

    ---@param pos Vector
    ---@param source? Entity
    ---@param maxDistance? number
    ---@return Entity?
    function mod:GetNearestEnemy(pos, source, maxDistance)
        ---@param entity Entity
        local entity = mod:EntitiesByDistance(Isaac.GetRoomEntities(), pos, function (entity)
            return entity:IsActiveEnemy(false)
        end, source)[1]

        if entity and (not maxDistance or entity.Position:Distance(pos) < maxDistance) then
            return entity
        end
    end

    local SCALES <const> = {0, 0.2, 0.45, 0.7, 0.9, 1, 1.3, 1.55, 1.8, 2, 2.2, 2.5, 2.8}

    ---@param scale number
    ---@return string
    function mod:GetTearAnimation(scale)
        local size = 1

        for i = 1, #SCALES do
            if scale > SCALES[i] then
                size = i - 1
            end

            size = math.max(1, size)
        end

        return "RegularTear" .. size
    end

    local DIRECTION_TO_OFFSET <const> = {
        [Direction.UP] = Vector(0, 40),
        [Direction.RIGHT] = Vector(-40, 0),
        [Direction.DOWN] = Vector(0, -40),
        [Direction.LEFT] = Vector(40, 0),
    }

    ---@param position Vector
    ---@return boolean
    function mod:IsPositionAccessible(position)
        for slot = DoorSlot.LEFT0, DoorSlot.NUM_DOOR_SLOTS - 1 do
            local door = Game():GetRoom():GetDoor(slot) if door then
                local entity = mod:SpawnNPC(EntityType.ENTITY_SHOPKEEPER, 0, door.Position + DIRECTION_TO_OFFSET[door.Direction])
                local pathFinder = entity.Pathfinder

                entity.Visible = false
                entity:Remove()

                if pathFinder:HasPathToPos(position, true) then
                    return true
                end
            end
        end
        return false
    end

    ---@enum TempStatType
    mod.TempStatType = {
        INCREASE = 1,
        DECREASE = 2,
    }

    ---@class ksil.TempStatConfig
    ---@field Stat CacheFlag
    ---@field Duration integer
    ---@field Amount number
    ---@field Persistent? boolean
    ---@field Frequency? integer
    ---@field Identifier string

    ---@param player EntityPlayer
    ---@param config ksil.TempStatConfig
    function mod:AddTempStat(player, config)
        ---@type ksil.TempStatEntry[]
        local save = mod:GetData(player, "TempStats", mod.DataPersistenceMode.RUN)
        local insert = {
            Persistent = config.Persistent,
            Type = config.Amount < 0 and mod.TempStatType.INCREASE or mod.TempStatType.DECREASE,
            Frequency = config.Frequency or 10,
            Amount = config.Amount,
            ChangeAmount = config.Amount / config.Duration * (config.Frequency or 10),
            Stat = config.Stat,
            ApplyFrame = Game():GetFrameCount(),
            Identifier = config.Identifier
        }

        for i, v in ipairs(save) do
            if v.Identifier == config.Identifier then
                insert.Amount = v.Amount + insert.Amount
                save[i] = insert
                player:AddCacheFlags(config.Stat)
                player:EvaluateItems()
                return
            end
        end

        table.insert(save, insert)

        player:AddCacheFlags(config.Stat)
        player:EvaluateItems()
    end

    ---@class ksil.TempStatEntry
    ---@field Persistent boolean
    ---@field Type TempStatType
    ---@field Frequency integer
    ---@field Amount number
    ---@field ChangeAmount number
    ---@field Stat CacheFlag
    ---@field ApplyFrame integer
    ---@field Identifier string

    ---@param player EntityPlayer
    mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
        ---@type ksil.TempStatEntry[]
        local data = mod:GetData(player, "TempStats", mod.DataPersistenceMode.RUN)

        if #data > 0 then
            for i, v in ipairs(data) do
                if not v.Persistent and player.FrameCount == 0 then
                    table.remove(data, i)
                else
                    if (Game():GetFrameCount() - v.ApplyFrame) % v.Frequency == 0 then
                        if v.Type == mod.TempStatType.DECREASE then
                            v.Amount = v.Amount - v.ChangeAmount
                            if v.Amount <= 0 then
                                table.remove(data, i)
                            end
                        else
                            v.Amount = v.Amount + v.ChangeAmount
                            if v.Amount >= 0 then
                                table.remove(data, i)
                            end
                        end
                        player:AddCacheFlags(v.Stat)
                    end
                end
            end
            player:EvaluateItems()
        end
    end)

    ---@param player EntityPlayer
    ---@param flag CacheFlag
    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player, flag)
        ---@type ksil.TempStatEntry[]
        local data = mod:GetData(player, "TempStats", mod.DataPersistenceMode.RUN)

        if #data > 0 then
            for _, v in ipairs(data) do
                if v.Stat == CacheFlag.CACHE_DAMAGE then
                    player.Damage = player.Damage + v.Amount
                elseif v.Stat == CacheFlag.CACHE_FIREDELAY then
                    player.MaxFireDelay = mod:ToMaxFireDelay(mod:ToTearsPerSecond(player.MaxFireDelay) + v.Amount)
                elseif v.Stat == CacheFlag.CACHE_SHOTSPEED then
                    player.ShotSpeed = player.ShotSpeed + v.Amount
                elseif v.Stat == CacheFlag.CACHE_RANGE then
                    player.TearRange = player.TearRange + v.Amount * 40
                elseif v.Stat == CacheFlag.CACHE_SPEED then
                    player.MoveSpeed = player.MoveSpeed + v.Amount
                elseif v.Stat == CacheFlag.CACHE_LUCK then
                    player.Luck = player.Luck + v.Amount
                end
            end
        end
    end)

    ---@class ksil.SchedulerEntry
    ---@field Frame integer
    ---@field Fn function
    ---@field Delay integer
    ---@field Temp boolean

    ---@type ksil.SchedulerEntry[]
    local schedulerEntries = {}

    ---@param fn function
    ---@param delay integer
    ---@param temp boolean | nil
    function mod:Schedule(fn, delay, temp)
        table.insert(schedulerEntries, {
            Frame = Game():GetFrameCount(),
            Fn = fn,
            Delay = delay,
            Temp = temp
        })
    end

    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function ()
        schedulerEntries = {}
    end)

    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
        for i, v in pairs(schedulerEntries) do
            if v.Temp then
                table.remove(schedulerEntries, i)
            end
        end
    end)

    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function ()
        local frameCount = Game():GetFrameCount()

        for i, v in pairs(schedulerEntries) do
            if v.Frame + v.Delay <= frameCount then
                v.Fn()
                table.remove(schedulerEntries, i)
            end
        end
    end)

    function mod:Lerp(a, b, t)
        return a + (b - a) * t
    end

    function mod:ShortAngleDis(from, to)
        local maxAngle = 360
        local disAngle = (to - from) % maxAngle

        return (2 * disAngle) % maxAngle - disAngle
    end

    function mod:LerpAngle(from, to, fraction)
        return from + mod:ShortAngleDis(from, to) * fraction
    end

    ---@param maxFireDelay number
    ---@return number
    function mod:ToTearsPerSecond(maxFireDelay)
        return 30 / (maxFireDelay + 1)
    end

    ---@param tearsPerSecond number
    ---@return number
    function mod:ToMaxFireDelay(tearsPerSecond)
        return 30 / tearsPerSecond - 1
    end

    ---@param vector Vector
    function mod:CardinalClamp(vector)
        return Vector.FromAngle(((vector:GetAngleDegrees() + 45) // 90) * 90)
    end

    ---@param angleDegrees number
    ---@return Direction
    function mod:AngleToDirection(angleDegrees)
        local positiveDegrees = angleDegrees

        while positiveDegrees < 0 do
            positiveDegrees = positiveDegrees + 360
        end

        local normalizedDegrees = positiveDegrees % 360

        if normalizedDegrees < 45 then
            return Direction.RIGHT
        end

        if normalizedDegrees < 135 then
            return Direction.DOWN
        end

        if normalizedDegrees < 225 then
            return Direction.LEFT
        end

        if normalizedDegrees < 315 then
            return Direction.UP
        end

        return Direction.RIGHT
    end

    ---@param vector Vector
    ---@return Direction
    function mod:VectorToDirection(vector)
        return mod:AngleToDirection(vector:GetAngleDegrees())
    end

    local DIRECTION_TO_VECTOR <const> = {
        [Direction.DOWN] = Vector(0, 1),
        [Direction.LEFT] = Vector(-1, 0),
        [Direction.UP] = Vector(0, -1),
        [Direction.RIGHT] = Vector(1, 0),
        [Direction.NO_DIRECTION] = Vector(0, 0)
    }

    ---@param direction Direction
    ---@return Vector
    function mod:DirectionToVector(direction)
        return DIRECTION_TO_VECTOR[direction]
    end

    local DIRECTION_TO_ANGLE <const> = {
        [Direction.LEFT] = 180,
        [Direction.UP] = -90,
        [Direction.RIGHT] = 0,
        [Direction.DOWN] = 90,
        [Direction.NO_DIRECTION] = 0
    }

    ---@param direction Direction
    ---@return number
    function mod:DirectionToAngle(direction)
        return DIRECTION_TO_ANGLE[direction]
    end

    ---@param player EntityPlayer
    ---@param disableClamp? boolean
    function mod:GetAimVect(player, disableClamp)
        local returnVect
        if player.ControllerIndex == 0 then
            if Input.IsMouseBtnPressed(MouseButton.LEFT) then
                returnVect = (Input.GetMousePosition(true) - player.Position):Normalized()
            end
        end

        returnVect = returnVect or player:GetShootingInput()

        if not disableClamp then
            if returnVect:Length() > 0.001 then
                if not player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) and not player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) then
                    returnVect = mod:CardinalClamp(returnVect)
                end
            end
        end

        return returnVect
    end

    ---@param player EntityPlayer
    function mod:IsShooting(player)
        return mod:GetAimVect(player):Length() > 0.001
    end

    ---@param player EntityPlayer
    function mod:GetAimDir(player)
        if mod:IsShooting(player) then
            return mod:VectorToDirection(mod:GetAimVect(player))
        else
            return Direction.NO_DIRECTION
        end
    end

    ---@enum PlayerSearchType
    mod.PlayerSearchType = {
        PLAYER_ONLY = 1,
        FAMILIAR_TEARCOPYING = 2,
        ALL = 3
    }

    ---@param entity Entity
    ---@param searchType PlayerSearchType
    ---@return EntityPlayer?
    function mod:GetPlayerFromEntity(entity, searchType)
        local player = (entity.SpawnerEntity and entity.SpawnerEntity:ToPlayer()) or (entity.Parent and entity.Parent:ToPlayer())

        if player then
            return player
        end

        if searchType == mod.PlayerSearchType.PLAYER_ONLY then return end

        local spawners = {}

        local spawner = entity.SpawnerEntity if spawner then table.insert(spawners, spawner) end
        local parent = entity.Parent if parent then table.insert(spawners, parent) end

        for _, v in ipairs(spawners) do ---@cast v Entity
            player = v:ToPlayer()

            if player then
                return player
            end

            local familiar = v:ToFamiliar()

            if familiar then
                if searchType ~= mod.PlayerSearchType.FAMILIAR_TEARCOPYING or mod.TEAR_COPYING_FAMILIARS[familiar.Variant] then
                    return familiar.Player
                end
            end
        end

        return entity:ToPlayer()
    end

    ---@param player EntityPlayer
    function mod:PlayerDamageCooldown(player)
        player:SetMinDamageCooldown((player:GetTrinketMultiplier(TrinketType.TRINKET_BLIND_RAGE) + 1) * 30)
    end

    ---@param tbl table
    ---@param value any
    function mod:IsIn(tbl, value)
        for _, v in pairs(tbl) do
            if v == value then
                return true
            end
        end
        return false
    end

    ---@param rng RNG
    ---@param min number
    ---@param max number
    ---@return number
    function mod:RandomFloatRange(rng, min, max)
        return min + rng:RandomFloat() * (max - min)
    end

    ---@param player EntityPlayer
    ---@param enable boolean
    ---@param identifier string
    function mod:SetBloodTears(player, enable, identifier)
        local data = mod:GetData(player, "BloodTears")
        data[identifier] = data[identifier] or {}
        data[identifier] = enable
    end

    ---@param player EntityPlayer
    ---@return boolean
    function mod:HasBloodTears(player)
        for _, v in pairs(mod:GetData(player, "BloodTears")) do
            if v then
                return true
            end
        end
        return false
    end

    local TEAR_TO_BLOOD <const> = {
        [TearVariant.BLUE] = TearVariant.BLOOD,
        [TearVariant.CUPID_BLUE] = TearVariant.CUPID_BLOOD,
        [TearVariant.PUPULA] = TearVariant.PUPULA_BLOOD,
        [TearVariant.GODS_FLESH] = TearVariant.GODS_FLESH_BLOOD,
        [TearVariant.NAIL] = TearVariant.NAIL_BLOOD,
        [TearVariant.GLAUCOMA] = TearVariant.GLAUCOMA_BLOOD,
        [TearVariant.EYE] = TearVariant.EYE_BLOOD,
        [TearVariant.KEY] = TearVariant.KEY_BLOOD,
    }

    ---@param tear EntityTear
    mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function (_, tear)
        local player = mod:GetPlayerFromEntity(tear, mod.PlayerSearchType.FAMILIAR_TEARCOPYING) if not player or not mod:HasBloodTears(player) then return end
        if TEAR_TO_BLOOD[tear.Variant] then
            tear:ChangeVariant(TEAR_TO_BLOOD[tear.Variant])
        end
    end)

    return mod
end}