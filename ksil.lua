--[[
    Kerkel's Standard Isaac Library
    not to be confused with
    Thicco's Standard Isaac Library

    Version 1.0.1

    Collection of libraries, utility functions, enums, and other declarations I find useful to use across mods

    GitHub repository: https://github.com/drpandacat/kibrary-of-isaac

    Special thanks to:
    Catinsurance
    Sanio64
    Thicco Catto
    Linedime
]]

---@class ksil.Preferences
---@field JumpLib boolean?
---@field CustomStatusLib boolean?
---@field HiddenItemManager boolean?

---@class ksil.TempStatConfig
---@field Stat CacheFlag
---@field Duration integer
---@field Amount number
---@field Persistent? boolean
---@field Frequency? integer
---@field Identifier string

---@class ksil.TempStatEntry
---@field Persistent boolean
---@field Type ksil.TempStatType
---@field Frequency integer
---@field Amount number
---@field ChangeAmount number
---@field Stat CacheFlag
---@field ApplyFrame integer
---@field Identifier string

---@class ksil.SchedulerEntry
---@field Frame integer
---@field Fn function
---@field Delay integer
---@field Type ksil.FunctionScheduleType

---@param name string
---@param path string
---@param preferences ksil.Preferences?
return {SuperRegisterMod = function (self, name, path, preferences)

    --#region Init

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

    --#endregion

    --#region Declarations

    ---@type {[FamiliarVariant]: true}
    mod.TEAR_COPYING_FAMILIARS = (JumpLib and JumpLib.Internal.TEAR_COPYING_FAMILIARS) or {
        [FamiliarVariant.INCUBUS] = true,
        [FamiliarVariant.TWISTED_BABY] = true,
        [FamiliarVariant.UMBILICAL_BABY] = true,
        [FamiliarVariant.BLOOD_BABY] = true,
    }

    mod.TEAR_COPYING_FAMILIARS[FamiliarVariant.SPRINKLER] = true

    ---@type {[EffectVariant]: true}
    mod.CREEP = {
        [EffectVariant.CREEP_RED] = true,
        [EffectVariant.CREEP_GREEN] = true,
        [EffectVariant.CREEP_YELLOW] = true,
        [EffectVariant.CREEP_WHITE] = true,
        [EffectVariant.CREEP_BLACK] = true,
        [EffectVariant.PLAYER_CREEP_LEMON_MISHAP] = true,
        [EffectVariant.PLAYER_CREEP_HOLYWATER] = true,
        [EffectVariant.PLAYER_CREEP_WHITE] = true,
        [EffectVariant.PLAYER_CREEP_BLACK] = true,
        [EffectVariant.PLAYER_CREEP_RED] = true,
        [EffectVariant.PLAYER_CREEP_GREEN] = true,
        [EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL] = true,
        [EffectVariant.CREEP_BROWN] = true,
        [EffectVariant.PLAYER_CREEP_LEMON_PARTY] = true,
        [EffectVariant.PLAYER_CREEP_PUDDLE_MILK] = true,
        [EffectVariant.CREEP_SLIPPERY_BROWN] = true,
        [EffectVariant.CREEP_SLIPPERY_BROWN_GROWING] = true,
        [EffectVariant.CREEP_STATIC] = true,
        [EffectVariant.CREEP_LIQUID_POOP] = true,
    }

    ---@type {[EffectVariant]: true}
    mod.ELLIPSE_CREEP = {
        [EffectVariant.PLAYER_CREEP_HOLYWATER] = true,
        [EffectVariant.PLAYER_CREEP_LEMON_MISHAP] = true,
        [EffectVariant.PLAYER_CREEP_LEMON_PARTY] = true,
        [EffectVariant.PLAYER_CREEP_PUDDLE_MILK] = true,
    }

    ---@type {[string]: Vector}
    mod.Vector = {
        ZERO = Vector(0, 0),
        ONE = Vector(1, 1),
    }

    ---@type {[string]: Color}
    mod.Color = {
        DEFAULT = Color(1, 1, 1, 1)
    }

    ---@enum ksil.DataPersistenceMode
    mod.DataPersistenceMode = {
        ROOM = 1,
        RUN = 2,
        FLOOR = 3,
        ROOM_FLOOR = 4
    }

    ---@enum ksil.TempStatType
    mod.TempStatType = {
        INCREASE = 1,
        DECREASE = 2,
    }

    ---@enum ksil.PlayerSearchType
    mod.PlayerSearchType = {
        PLAYER_ONLY = 1,
        FAMILIAR_TEARCOPYING = 2,
        ALL = 3
    }

    ---@enum ksil.FunctionScheduleType
    mod.FunctionScheduleType = {
        PERSISTENT = 1,
        LEAVE_ROOM_CANCEL = 2,
        POST_LEAVE_ROOM_EXECUTE = 3,
        ---Treated as `POST_LEAVE_ROOM_EXECUTE` if REPENTOGON is not active
        PRE_LEAVE_ROOM_EXECUTE = 4,
    }

    ---@enum ksil.BloodBabySubType
    mod.BloodBabySubType = {
        RED = 0,
        SOUL = 1,
        BLACK = 2,
        ETERNAL = 3,
        GOLD = 4,
        BONE = 5,
        ROTTEN = 6,
        TRINKET = 7,
    }

    ---@type {[FamiliarVariant]: true}
    mod.HIVE_MIND_FAMILIARS = {
        [FamiliarVariant.FOREVER_ALONE] = true,
        [FamiliarVariant.DISTANT_ADMIRATION] = true,
        [FamiliarVariant.FLY_ORBITAL] = true,
        [FamiliarVariant.BLUE_FLY] = true,
        [FamiliarVariant.BBF] = true,
        [FamiliarVariant.BEST_BUD] = true,
        [FamiliarVariant.BIG_FAN] = true,
        [FamiliarVariant.SISSY_LONGLEGS] = true,
        [FamiliarVariant.BLUE_SPIDER] = true,
        -- [FamiliarVariant.BLUEBABYS_ONLY_FRIEND] = true,
        [FamiliarVariant.SWORN_PROTECTOR] = true,
        [FamiliarVariant.FRIEND_ZONE] = true,
        [FamiliarVariant.LOST_FLY] = true,
        [FamiliarVariant.SPIDER_MOD] = true,
        [FamiliarVariant.OBSESSED_FAN] = true,
        [FamiliarVariant.PAPA_FLY] = true,
        [FamiliarVariant.SPIDER_BABY] = true,
        [FamiliarVariant.BROWN_NUGGET_POOTER] = true,
        [FamiliarVariant.ANGRY_FLY] = true,
        [FamiliarVariant.INTRUDER] = true,
        [FamiliarVariant.PSY_FLY] = true,
        [FamiliarVariant.BOT_FLY] = true,
        [FamiliarVariant.BABY_PLUM] = true,
        [FamiliarVariant.FRUITY_PLUM] = true,
        [FamiliarVariant.SWARM_FLY_ORBITAL] = true,
        [FamiliarVariant.ABYSS_LOCUST] = true,
    }

    --#endregion

    --#region Math

    function mod:Lerp(a, b, t)
        return a + (b - a) * t
    end

    ---@param from number
    ---@param to number
    ---@return number
    function mod:ShortAngleDis(from, to)
        local disAngle = (to - from) % 360
        return 2 * disAngle % 360 - disAngle
    end

    ---@param from number
    ---@param to number
    ---@param fraction number
    ---@return number
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

    local ANGLE_TO_DIRECTION = {
        Direction.RIGHT,
        Direction.DOWN,
        Direction.LEFT,
        Direction.UP
    }

    ---@param angle number
    ---@return Direction
    function mod:AngleToDirection(angle)
        local normalizedDegrees = angle % 360

        return ANGLE_TO_DIRECTION[math.floor((normalizedDegrees + 45) / 90) % 4]
    end

    ---@param vector Vector
    ---@return Direction
    function mod:VectorToDirection(vector)
        return mod:AngleToDirection(vector:GetAngleDegrees())
    end

    local DIRECTION_TO_VECTOR = {
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

    local DIRECTION_TO_ANGLE = {
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

    function mod:Clamp(value, min, max)
        return math.max(min, math.min(max, value))
    end

    ---@param flags integer
    ---@param flag integer
    ---@return boolean
    function mod:HasFlags(flags, flag)
        return flags & flag ~= 0
    end

    --#endregion

    --#region Tables

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

    ---@param tbl table
    ---@param deeperCopy? boolean
    ---@return table
    function mod:DeepCopy(tbl, deeperCopy)
        local copy = {}

        for k, v in pairs(tbl) do
            copy[k] = deeperCopy and type(v) == "table" and mod:DeepCopy(v, true) or v
        end

        return copy
    end

    --#endregion

    --#region Vectors

    local DIRECTION_TO_OFFSET = {
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
                local npc = mod:SpawnNPC(EntityType.ENTITY_SHOPKEEPER, 0, door.Position + DIRECTION_TO_OFFSET[door.Direction])
                local pathFinder = npc.Pathfinder

                npc.Visible = false
                npc:Remove()

                if pathFinder:HasPathToPos(position, true) then
                    return true
                end
            end
        end

        return false
    end

    --#endregion

    --#region Entity data

    __TEMP_DATA = __TEMP_DATA or {} -- TODO: replace

    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function ()
        __TEMP_DATA = {}
    end)

    ---@param entity Entity
    mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function (_, entity)
        if not __TEMP_DATA[mod.Name] then return end
        __TEMP_DATA[mod.Name][GetPtrHash(entity)] = nil
    end)

    ---@param entity Entity
    ---@param identifier string
    ---@param persistenceMode? ksil.DataPersistenceMode
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

    --#endregion

    --#region Entity spawning

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

    ---@param variant integer
    ---@param position Vector
    ---@param velocity? Vector
    ---@param subtype? integer
    ---@param spawner? Entity
    ---@param seed? integer
    ---@return EntityKnife
    function mod:SpawnKnife(variant, position, velocity, spawner, subtype, seed)
        ---@diagnostic disable-next-line: return-type-mismatch
        return Game():Spawn(EntityType.ENTITY_KNIFE, variant, position, velocity or mod.Vector.ZERO, spawner or nil, subtype or 0, seed or math.max(Random(), 1)):ToKnife()
    end

    ---@param variant LaserVariant | integer
    ---@param position Vector
    ---@param velocity? Vector
    ---@param subtype? integer
    ---@param spawner? Entity
    ---@param seed? integer
    ---@return EntityLaser
    function mod:SpawnLaser(variant, position, velocity, spawner, subtype, seed)
        ---@diagnostic disable-next-line: return-type-mismatch
        return Game():Spawn(EntityType.ENTITY_LASER, variant, position, velocity or mod.Vector.ZERO, spawner or nil, subtype or 0, seed or math.max(Random(), 1)):ToLaser()
    end

    ---@param variant integer
    ---@param position Vector
    ---@param velocity? Vector
    ---@param subtype? integer
    ---@param spawner? Entity
    ---@param seed? integer
    ---@return Entity | EntitySlot
    function mod:SpawnSlot(variant, position, velocity, spawner, subtype, seed)
        ---@diagnostic disable-next-line: return-type-mismatch
        local entity = Game():Spawn(EntityType.ENTITY_SLOT, variant, position, velocity or mod.Vector.ZERO, spawner or nil, subtype or 0, seed or math.max(Random(), 1))

        if REPENTOGON then
            ---@diagnostic disable-next-line: return-type-mismatch
            return entity:ToSlot()
        end

        return entity
    end

    --#endregion

    --#region Bleeding

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

    --#endregion

    --#region Entity filtering

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

        ---@param a Entity
        ---@param b Entity
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

    --#endregion

    --#region Tears

    local SCALES = {0, 0.2, 0.45, 0.7, 0.9, 1, 1.3, 1.55, 1.8, 2, 2.2, 2.5, 2.8}

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

    --#endregion

    --#region Temporary stats

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

    --#endregion

    --#region Scheduler

    ---@type ksil.SchedulerEntry[]
    local schedulerEntries = {}

    ---@param fn function
    ---@param delay integer
    ---@param type ksil.FunctionScheduleType
    function mod:Schedule(fn, delay, type)
        table.insert(schedulerEntries, {
            Frame = Game():GetFrameCount(),
            Fn = fn,
            Delay = delay,
            Type = type
        })
    end

    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function ()
        schedulerEntries = {}
    end)

    if REPENTOGON then
        mod:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, function ()
            for _, v in pairs(schedulerEntries) do
                if v.Type == mod.FunctionScheduleType.PRE_LEAVE_ROOM_EXECUTE then
                    v.Fn()
                end
            end
        end)
    end

    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
        for i, v in pairs(schedulerEntries) do
            if v.Type ~= mod.FunctionScheduleType.PERSISTENT then
                if v.Type == mod.FunctionScheduleType.POST_LEAVE_ROOM_EXECUTE or (not REPENTOGON and (v.Type == mod.FunctionScheduleType.PRE_LEAVE_ROOM_EXECUTE)) then
                    v.Fn()
                end
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

    --#endregion

    --#region RNG

    ---@param rng RNG
    ---@param min number
    ---@param max number
    ---@return number
    function mod:RandomFloatRange(rng, min, max)
        return min + rng:RandomFloat() * (max - min)
    end

    --#endregion

    --#region Aiming

    ---@param player EntityPlayer
    ---@param disableClamp? boolean
    ---@return Vector
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
    ---@return boolean
    function mod:IsShooting(player)
        return mod:GetAimVect(player):Length() > 0.001
    end

    ---@param player EntityPlayer
    ---@return Direction
    function mod:GetAimDir(player)
        if mod:IsShooting(player) then
            return mod:VectorToDirection(mod:GetAimVect(player))
        else
            return Direction.NO_DIRECTION
        end
    end

    ---@param player EntityPlayer
    ---@return Direction
    function mod:GetLastAimDir(player)
        return mod:GetData(player, "Aiming").LastDirection or Direction.NO_DIRECTION
    end

    ---@param player EntityPlayer
    ---@param disableClamp? boolean
    ---@return Vector
    function mod:GetLastAimVect(player, disableClamp)
        local vect = mod:GetData(player, "Aiming").LastVector
        return (not vect and mod.Vector.Zero) or (not disableClamp and mod:CardinalClamp(vect)) or vect
    end

    ---@param player EntityPlayer
    mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function (_, player)
        if not mod:IsShooting(player) then return end

        local data = mod:GetData(player, "Aiming")

        data.LastDirection = mod:GetAimDir(player)
        data.LastVector = mod:GetAimVect(player, true)
    end)

    --#endregion

    --#region Players

    ---@param entity Entity
    ---@param searchType ksil.PlayerSearchType
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
        player:SetMinDamageCooldown((player:GetTrinketMultiplier(TrinketType.TRINKET_BLIND_RAGE) + 1) * 60)
    end

    ---@param player EntityPlayer
    ---@param enable boolean
    ---@param identifier string
    function mod:SetBloodTears(player, enable, identifier)
        mod:GetData(player, "BloodTears")[identifier] = enable
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

    local TEAR_TO_BLOOD = {
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

    --#endregion

    --#region Familiars

    ---@param familiar Entity?
    ---@return number
    function mod:GetFamiliarDamageMult(familiar)
        familiar = familiar and familiar:ToFamiliar() if not familiar then
            return 1
        end

        local mult
        local playerType = familiar.Player:GetPlayerType()

        if playerType == PlayerType.PLAYER_LILITH or playerType == PlayerType.PLAYER_LILITH_B then
            if familiar.Variant == FamiliarVariant.TWISTED_BABY then
                mult = 0.5
            end
        else
            if familiar.Variant == FamiliarVariant.INCUBUS or familiar.Variant == FamiliarVariant.UMBILICAL_BABY then
                mult = 0.75
            elseif familiar.Variant == FamiliarVariant.TWISTED_BABY then
                mult = 0.375
            end
        end

        if not mult then
            if familiar.Variant == FamiliarVariant.BLOOD_BABY then
                if familiar.SubType == mod.BloodBabySubType.BLACK then
                    mult = 0.4375
                elseif familiar.SubType == mod.BloodBabySubType.ETERNAL then
                    mult = 0.525
                else
                    mult = 0.35
                end
            end
        end

        if not mult then
            mult = 1
        end

        if REPENTOGON then
            ---@diagnostic disable-next-line: undefined-field
            mult = mult * familiar:GetMultiplier()
        else
            local extraMult = (mod.HIVE_MIND_FAMILIARS[familiar.Variant] and familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND)) or familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)

            if extraMult then
                return mult * 2
            end

            return mult
        end

        return mult
    end

    --#endregion

    --#region Creep

    ---@param pos Vector
    ---@return Entity?
    local function GetNearestCreep(pos)
        ---@param entity Entity
        return mod:EntitiesByDistance(Isaac.FindByType(EntityType.ENTITY_EFFECT), pos, function (entity)
            return mod.CREEP[entity.Variant]
        end)[1]
    end

    ---@param entity Entity
    ---@param creep? Entity
    ---@param slack? integer
    ---@return boolean
    local function IsInEllipseCreep(entity, creep, slack)
        creep = creep or GetNearestCreep(entity.Position) if not creep then return false end
        local size = creep.Size * (slack or 1)
        local dif = entity.Position - creep.Position

        return (dif.X / (size * creep.SpriteScale.X)) ^ 2 + (dif.Y / (size * creep.SpriteScale.Y / 1.5)) ^ 2 <= 1
    end

    ---@param entity Entity
    ---@param creep? Entity
    ---@param slack? integer
    ---@return boolean
    function mod:IsInCreep(entity, creep, slack)
        creep = creep or GetNearestCreep(entity.Position) if not creep then return false end

        if creep:ToEffect().Timeout < 1 then
            return false
        end

        if mod.ELLIPSE_CREEP[creep.Variant] then

            return IsInEllipseCreep(entity, creep, slack)
        end

        return entity.Position:Distance(creep.Position) <= (creep.Size * (slack or 1))
    end

    --#endregion

    return mod
end}
