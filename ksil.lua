--[[
    Kerkel's Standard Isaac Library
    Not to be confused with
    Thicco's Standard Isaac Library

    Version 2.0.1

    Collection of libraries, utility functions, enums, and other declarations I find useful to have across mods

    GitHub repository: https://github.com/drpandacat/kibrary-of-isaac

    Special thanks to:
    Catinsurance - Save mananger
    Sanio64 - Save manager
    Thicco Catto - TSIL
    Linedime - Ellipse creep utility
    ConnorForan - Hidden item manager
]]

local VERSION = 1.001

---@class ksil.ModConfig
---@field JumpLib? boolean
---@field HiddenItemManager? boolean
---@field CustomStatusLib? boolean
---@field ThrowableItemLib? boolean
---@field BloodTearUtility? boolean
---@field TempStatLib? boolean
---@field Scheduler? boolean
---@field FloatingTextLib? boolean
---@field BleedUtility? boolean
---@field LastAimUtility? boolean

---@class ksil.CallbackEntry
---@field ID ModCallbacks | string
---@field FN function
---@field FILTER any

---@param self any
---@param name any
---@param path any
---@param ksilConfig ksil.ModConfig
-- -@return ksil.Mod
return {SuperRegisterMod = function (self, name, path, ksilConfig)
    local meta = RegisterMod("KSIL", 1)

    meta.VERSION = VERSION

    local foundKsil

    if ksil then
        for k, v in pairs(ksil.Config) do
            if v then
                ksilConfig[k] = true
            end
        end

        if ksil.VERSION > meta.VERSION then
            foundKsil = true
            meta = ksil
        else
            ksil:ClearCallbacks()
        end
    end

    ---@param _path string
    local function _include(_path)
        return include(path .. "." .. _path)
    end

    ---@param ref any
    ---@param identifier string
    ---@param persistenceMode? ksil.DataPersistenceMode @default: `ksil.DataPersistenceMode.TEMP`
    ---@param default? table
    ---@return table
    local function GetData(ref, entity, identifier, persistenceMode, default)
        local data

        if not persistenceMode or persistenceMode == ksil.DataPersistenceMode.TEMP then
            data = entity:GetData()
        else
            if persistenceMode == ksil.DataPersistenceMode.ROOM then
                data = ref.SaveManager.GetRoomSave(entity)
            elseif persistenceMode == ksil.DataPersistenceMode.FLOOR then
                data = ref.SaveManager.GetFloorSave(entity)
            elseif persistenceMode == ksil.DataPersistenceMode.ROOM_FLOOR then
                data = ref.SaveManager.GetRoomFloorSave(entity)
            else
                data = ref.SaveManager.GetRunSave(entity)
            end
        end

        data.____KSIL = data.____KSIL or {}
        data.____KSIL[ref.Name] = data.____KSIL[ref.Name] or {}
        data.____KSIL[ref.Name][identifier] = data.____KSIL[ref.Name][identifier] or default or {}

        return data.____KSIL[ref.Name][identifier]
    end

    if not foundKsil then
        _G.ksil = meta

        ksil.Config = ksilConfig

        local MetaAddCallback = ksil.AddCallback

        ---@param id ModCallbacks | string
        ---@param fn function
        ---@param filter any
        function meta:AddCallback(id, fn, filter)
            table.insert(ksil.CallbackEntries, {ID = id, FN = fn, FILTER = filter})
            MetaAddCallback(ksil, id, fn, filter)
        end

        function ksil:ClearCallbacks()
            for _, v in ipairs(ksil.CallbackEntries) do
                ksil:RemoveCallback(v.ID, v.FN)
            end
        end

        ---@module "savemanager"
        ksil.SaveManager = _include("savemanager")
        ksil.SaveManager.Init(ksil)

        ---@enum ksil.DataPersistenceMode
        ksil.DataPersistenceMode = {
            TEMP = 1,
            ROOM = 2,
            RUN = 3,
            FLOOR = 4,
            ROOM_FLOOR = 5,
        }

        ksil.Color = {
            DEFAULT = Color(1, 1, 1, 1),
        }

        ---@param entity Entity
        ---@param identifier string
        ---@param persistenceMode? ksil.DataPersistenceMode @default: `ksil.DataPersistenceMode.TEMP`
        ---@param default? table
        ---@return table
        function ksil:GetData(entity, identifier, persistenceMode, default)
            return GetData(ksil, entity, identifier, persistenceMode, default)
        end

        ---@enum ksil.PlayerSearchType
        ksil.PlayerSearchType = {
            PLAYER_ONLY = 1,
            FAMILIAR_TEARCOPYING = 2,
            ALL = 3
        }

        if ksilConfig.BloodTearUtility then
            ksil.TEAR_TO_BLOOD = {
                [TearVariant.BLUE] = TearVariant.BLOOD,
                [TearVariant.CUPID_BLUE] = TearVariant.CUPID_BLOOD,
                [TearVariant.PUPULA] = TearVariant.PUPULA_BLOOD,
                [TearVariant.GODS_FLESH] = TearVariant.GODS_FLESH_BLOOD,
                [TearVariant.NAIL] = TearVariant.NAIL_BLOOD,
                [TearVariant.GLAUCOMA] = TearVariant.GLAUCOMA_BLOOD,
                [TearVariant.EYE] = TearVariant.EYE_BLOOD,
                [TearVariant.KEY] = TearVariant.KEY_BLOOD,
            }
        end

        ksil.TEAR_COPYING_FAMILIARS = {
            [FamiliarVariant.INCUBUS] = true,
            [FamiliarVariant.TWISTED_BABY] = true,
            [FamiliarVariant.UMBILICAL_BABY] = true,
            [FamiliarVariant.BLOOD_BABY] = true,
            [FamiliarVariant.SPRINKLER] = true,
            [FamiliarVariant.CAINS_OTHER_EYE] = true,
        }

        if ksilConfig.Scheduler then
            ---@type ksil.SchedulerEntry[]
            ksil.FunctionScheduleEntries = {}

            ---@enum ksil.FunctionScheduleType
            ksil.FunctionScheduleType = {
                PERSISTENT = 1,
                LEAVE_ROOM_CANCEL = 2,
                POST_LEAVE_ROOM_EXECUTE = 3,
                ---Treated as `POST_LEAVE_ROOM_EXECUTE` if REPENTOGON is disabled
                PRE_LEAVE_ROOM_EXECUTE = 4,
            }
        end

        ksil.ANGLE_TO_DIRECTION = {
            Direction.RIGHT,
            Direction.DOWN,
            Direction.LEFT,
            Direction.UP,
        }

        ksil.DIRECTION_TO_VECTOR = {
            [Direction.DOWN] = Vector(0, 1),
            [Direction.LEFT] = Vector(-1, 0),
            [Direction.UP] = Vector(0, -1),
            [Direction.RIGHT] = Vector(1, 0),
            [Direction.NO_DIRECTION] = Vector(0, 0),
        }

        ksil.DIRECTION_TO_ANGLE = {
            [Direction.LEFT] = 180,
            [Direction.UP] = -90,
            [Direction.RIGHT] = 0,
            [Direction.DOWN] = 90,
            [Direction.NO_DIRECTION] = 0
        }

        ksil.Vector = {
            ZERO = Vector(0, 0),
            ONE = Vector(1, 1),
        }

        ksil.CREEP = {
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

        ksil.ELLIPSE_CREEP = {
            [EffectVariant.PLAYER_CREEP_HOLYWATER] = true,
            [EffectVariant.PLAYER_CREEP_LEMON_MISHAP] = true,
            [EffectVariant.PLAYER_CREEP_LEMON_PARTY] = true,
            [EffectVariant.PLAYER_CREEP_PUDDLE_MILK] = true,
        }

        ---@enum ksil.BloodBabySubType
        ksil.BloodBabySubType = {
            RED = 0,
            SOUL = 1,
            BLACK = 2,
            ETERNAL = 3,
            GOLD = 4,
            BONE = 5,
            ROTTEN = 6,
            TRINKET = 7,
        }

        ksil.HIVE_MIND_FAMILIARS = {
            [FamiliarVariant.FOREVER_ALONE] = true,
            [FamiliarVariant.DISTANT_ADMIRATION] = true,
            [FamiliarVariant.FLY_ORBITAL] = true,
            [FamiliarVariant.BLUE_FLY] = true,
            [FamiliarVariant.BBF] = true,
            [FamiliarVariant.BEST_BUD] = true,
            [FamiliarVariant.BIG_FAN] = true,
            [FamiliarVariant.SISSY_LONGLEGS] = true,
            [FamiliarVariant.BLUE_SPIDER] = true,
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

        if ksilConfig.ThrowableItemLib then
            ---@class ksil.ThrowableItemConfig
            ---@field ID CollectibleType | Card
            ---@field Type ksil.ThrowableItemType
            ---@field LiftFn? fun(player: EntityPlayer)
            ---@field HideFn? fun(player: EntityPlayer)
            ---@field ThrowFn? fun(player: EntityPlayer, vect: Vector)
            ---@field Flags? ksil.ThrowableItemFlag | integer

            ---@enum ksil.ThrowableItemFlag
            ksil.ThrowableItemFlag = {
                NO_DISCHARGE = 1 << 0,
                DISCHARGE_HIDE = 1 << 1,
                USABLE_ANY_CHARGE = 1 << 2,
                DISABLE_HIDE = 1 << 3,
                PERSISTENT = 1 << 4,
            }

            ---@enum ksil.ThrowableItemType
            ksil.ThrowableItemType = {
                ACTIVE = 1,
                CARD = 2,
            }
        end

        if ksilConfig.FloatingTextLib then
            ---@type ksil.FloatingTextConfig[]
            ksil.FloatingTextEntries = {}
        end

        if ksilConfig.TempStatLib then
            ---@enum ksil.TempStatType
            ksil.TempStatType = {
                INCREASE = 1,
                DECREASE = 2,
            }
        end
    end

    ---@type ksil.CallbackEntry[]
    ksil.CallbackEntries = {}

    -- -@class ksil.Mod
    local mod = RegisterMod(name, 1)

    mod.KSIL_VERSION = VERSION

    local AddCallback = mod.AddCallback

    ---@param id ModCallbacks | string
    ---@param fn function
    ---@param filter any
    function mod:AddCallback(id, fn, filter)
        AddCallback(mod, id, fn, filter)
    end

    local AddPriorityCallback = mod.AddPriorityCallback

    ---@param id ModCallbacks | string
    ---@param priority CallbackPriority | integer
    ---@param fn function
    ---@param filter any
    function mod:AddPriorityCallback(id, priority, fn, filter)
        AddPriorityCallback(mod, id, priority, fn, filter)
    end

    local RemoveCallback = mod.RemoveCallback

    ---@param id ModCallbacks | string
    ---@param fn function
    function mod:RemoveCallback(id, fn)
        RemoveCallback(mod, id, fn)
    end

    mod.Name = name

    ---@module "savemanager"
    mod.SaveManager = _include("savemanager")
    mod.SaveManager.Init(mod)

    --#region Entity data

    ---@param entity Entity
    ---@param identifier string
    ---@param persistenceMode? ksil.DataPersistenceMode @default: `ksil.DataPersistenceMode.TEMP`
    ---@param default? table
    ---@return table
    function mod:GetData(entity, identifier, persistenceMode, default)
        return GetData(mod, entity, identifier, persistenceMode, default)
    end

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

    ---@param angle number
    ---@return Direction
    function mod:AngleToDirection(angle)
        return ksil.ANGLE_TO_DIRECTION[math.floor((angle % 360 + 45) / 90) % 4 + 1]
    end

    ---@param vector Vector
    ---@return Direction
    function mod:VectorToDirection(vector)
        if vector:Length() < 0.001 then
            return Direction.NO_DIRECTION
        end

        return mod:AngleToDirection(vector:GetAngleDegrees())
    end

    ---@param direction Direction
    ---@return Vector
    function mod:DirectionToVector(direction)
        return ksil.DIRECTION_TO_VECTOR[direction]
    end

    ---@param direction Direction
    ---@return number
    function mod:DirectionToAngle(direction)
        return ksil.DIRECTION_TO_ANGLE[direction]
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
    function mod:AnyValueIs(tbl, value)
        for _, v in pairs(tbl) do
            if v == value then
                return true
            end
        end
        return false
    end

    ---@param tbl table
    ---@param key any
    function mod:AnyKeyIs(tbl, key)
        for k in pairs(tbl) do
            if k == key then
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
        return Game():Spawn(type, variant, position, velocity or ksil.Vector.ZERO, spawner or nil, subtype or 0, seed or math.max(Random(), 1)):ToNPC()
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
        return Game():Spawn(EntityType.ENTITY_EFFECT, variant, position, velocity or ksil.Vector.ZERO, spawner or nil, subtype or 0, seed or math.max(Random(), 1)):ToEffect()
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
        return Game():Spawn(EntityType.ENTITY_TEAR, variant, position, velocity or ksil.Vector.ZERO, spawner or nil, subtype or 0, seed or math.max(Random(), 1)):ToTear()
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
        return Game():Spawn(EntityType.ENTITY_PROJECTILE, variant, position, velocity or ksil.Vector.ZERO, spawner or nil, subtype or 0, seed or math.max(Random(), 1)):ToProjectile()
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
        return Game():Spawn(EntityType.ENTITY_PICKUP, variant, position, velocity or ksil.Vector.ZERO, spawner or nil, subtype or 0, seed or math.max(Random(), 1)):ToPickup()
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
        return Game():Spawn(EntityType.ENTITY_FAMILIAR, variant, position, velocity or ksil.Vector.ZERO, spawner or nil, subtype or 0, seed or math.max(Random(), 1)):ToFamiliar()
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
        return Game():Spawn(EntityType.ENTITY_BOMB, variant, position, velocity or ksil.Vector.ZERO, spawner or nil, subtype or 0, seed or math.max(Random(), 1)):ToBomb()
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
        return Game():Spawn(EntityType.ENTITY_KNIFE, variant, position, velocity or ksil.Vector.ZERO, spawner or nil, subtype or 0, seed or math.max(Random(), 1)):ToKnife()
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
        return Game():Spawn(EntityType.ENTITY_LASER, variant, position, velocity or ksil.Vector.ZERO, spawner or nil, subtype or 0, seed or math.max(Random(), 1)):ToLaser()
    end

    ---@param variant integer
    ---@param position Vector
    ---@param velocity? Vector
    ---@param subtype? integer
    ---@param spawner? Entity
    ---@param seed? integer
    ---@diagnostic disable-next-line: undefined-doc-name
    ---@return Entity
    function mod:SpawnSlot(variant, position, velocity, spawner, subtype, seed)
        ---@diagnostic disable-next-line: return-type-mismatch
        return Game():Spawn(EntityType.ENTITY_SLOT, variant, position, velocity or ksil.Vector.ZERO, spawner or nil, subtype or 0, seed or math.max(Random(), 1))
    end

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

        if searchType == ksil.PlayerSearchType.PLAYER_ONLY then return end

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
                if searchType ~= ksil.PlayerSearchType.FAMILIAR_TEARCOPYING or ksil.TEAR_COPYING_FAMILIARS[familiar.Variant] then
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

    if ksilConfig.LastAimUtility then
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
            return ksil:GetData(player, "Aiming").LastDirection or Direction.NO_DIRECTION
        end

        ---@param player EntityPlayer
        ---@param disableClamp? boolean
        ---@return Vector
        function mod:GetLastAimVect(player, disableClamp)
            local vect = ksil:GetData(player, "Aiming").LastVector
            return (not vect and ksil.Vector.Zero) or (not disableClamp and mod:CardinalClamp(vect)) or vect
        end

        ---@param player EntityPlayer
        ksil:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function (_, player)
            if not mod:IsShooting(player) then return end

            local data = ksil:GetData(player, "Aiming")

            data.LastDirection = mod:GetAimDir(player)
            data.LastVector = mod:GetAimVect(player, true)
        end)
    end

    --#endregion

    --#region Vector

    local DIRECTION_TO_DOOR_OFFSET = {
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
                local npc = mod:SpawnNPC(EntityType.ENTITY_SHOPKEEPER, 0, door.Position + DIRECTION_TO_DOOR_OFFSET[door.Direction])
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
                if familiar.SubType == ksil.BloodBabySubType.BLACK then
                    mult = 0.4375
                elseif familiar.SubType == ksil.BloodBabySubType.ETERNAL then
                    mult = 0.525
                else
                    mult = 0.35
                end
            end
        end

        mult = mult or 1

        if REPENTOGON then
            ---@diagnostic disable-next-line: undefined-field
            mult = mult * familiar:GetMultiplier()
        else
            local extraMult = (ksil.HIVE_MIND_FAMILIARS[familiar.Variant] and familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND))
            or familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)

            if extraMult then
                return mult * 2
            end
        end

        return mult
    end

    --#endregion

    --#region Entity filtering

    ---@param list Entity[]
    ---@param filter fun(entity: Entity): boolean | nil
    ---@return Entity[]
    function mod:GetFilteredEntities(list, filter)
        local _list = {}

        for _, v in pairs(list) do
            if filter(v) then
                table.insert(_list, v)
            end
        end

        return _list
    end

    ---@param list Entity[]
    ---@param pos Vector
    ---@param filter? fun(entity: Entity): (boolean?)
    ---@param source? Entity
    ---@return Entity[]
    function mod:EntitiesByDistance(list, pos, filter, source)
        local _list = {}

        list = filter and mod:GetFilteredEntities(list, filter) or list

        if source then
            local hash = GetPtrHash(source)

            for _, v in pairs(list) do
                if hash ~= GetPtrHash(v) then
                    table.insert(_list, v)
                end
            end
        else
            _list = list
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
    ---@param filter? fun(entity: Entity): boolean | nil
    ---@return Entity?
    function mod:GetNearestEntity(pos, source, maxDistance, filter)
        local entity = mod:EntitiesByDistance(Isaac.GetRoomEntities(), pos, filter, source)[1]

        if entity and (not maxDistance or entity.Position:Distance(pos) < maxDistance) then
            return entity
        end
    end

    ---@param pos Vector
    ---@param source? Entity
    ---@param maxDistance? number
    ---@return Entity?
    function mod:GetNearestEnemy(pos, source, maxDistance)
        ---@param entity Entity
        return mod:GetNearestEntity(pos, source, maxDistance, function (entity)
            return entity:IsActiveEnemy(false)
        end)
    end

    --#endregion

    --#region Creep

    ---@param pos Vector
    ---@return Entity?
    local function GetNearestCreep(pos)
        ---@param entity Entity
        return mod:GetNearestEntity(pos, nil, nil, function (entity)
            return ksil.CREEP[entity.Variant]
        end)
    end

    ---@param entity Entity
    ---@param creep? Entity
    ---@param slack? integer
    ---@return boolean
    function mod:IsInEllipseCreep(entity, creep, slack)
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

        if ksil.ELLIPSE_CREEP[creep.Variant] then
            return mod:IsInEllipseCreep(entity, creep, slack)
        end

        return entity.Position:Distance(creep.Position) <= (creep.Size * (slack or 1))
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

    --#region RNG

    ---@param min number
    ---@param max number
    ---@param rng? RNG
    ---@return number
    function mod:RandomFloatRange(min, max, rng)
        if not rng then
            rng = RNG()
            rng:SetSeed(math.max(Random(), 1), 35)
        end

        return min + rng:RandomFloat() * (max - min)
    end

    --#endregion

    --#region Item filtering

    ---@param filter fun(config: ItemConfigItem): boolean | nil
    ---@param pool? ItemPoolType
    ---@param maxTries? integer Increase when using a strict filter
    ---@param seed? integer
    ---@return CollectibleType
    function mod:GetFilteredCollectible(filter, pool, maxTries, seed)
        local rng = RNG()

        rng:SetSeed(seed or Game():GetSeeds():GetStartSeed(), 35)

        pool = pool or math.max(ItemPoolType.POOL_TREASURE, Game():GetItemPool():GetPoolForRoom(Game():GetRoom():GetType(), rng:Next()))
        maxTries = maxTries or 200

        local collectible = CollectibleType.COLLECTIBLE_BREAKFAST
        local tries = 0

        for i = 1, maxTries do
            collectible = Game():GetItemPool():GetCollectible(pool, false, rng:Next())
            tries = tries + 1

            if filter(Isaac.GetItemConfig():GetCollectible(collectible)) or tries >= maxTries then
                break
            end
        end

        Game():GetItemPool():RemoveCollectible(collectible)

        return collectible
    end

    ---@param filter fun(config: ItemConfigItem): boolean | nil
    ---@param maxTries? integer Increase when using a strict filter
    ---@param seed? integer
    ---@return TrinketType
    function mod:GetFilteredTrinket(filter, maxTries, seed)
        local rng = RNG()

        rng:SetSeed(seed or Game():GetSeeds():GetStartSeed(), 35)

        maxTries = maxTries or 100

        local trinket = TrinketType.TRINKET_WIGGLE_WORM
        local tries = 0

        for i = 1, maxTries do
            trinket = Game():GetItemPool():GetTrinket()
            tries = tries + 1

            if filter(Isaac.GetItemConfig():GetTrinket(trinket)) or tries >= maxTries then
                break
            end
        end

        Game():GetItemPool():RemoveTrinket(trinket)

        return trinket
    end

    --#endregion

    if ksilConfig.BleedUtility then
        ---@param player EntityPlayer
        function mod:ApplyBleed(player)
            if player:HasCollectible(CollectibleType.COLLECTIBLE_EVIL_CHARM) then return end
            ksil:GetData(player, "Bleeding", ksil.DataPersistenceMode.RUN).Bleeding = true
        end

        ---@param player EntityPlayer
        function mod:ClearBleed(player)
            ksil:GetData(player, "Bleeding", ksil.DataPersistenceMode.RUN).Bleeding = false
            player:ClearEntityFlags(EntityFlag.FLAG_BLEED_OUT)
        end

        ---@param player EntityPlayer
        function mod:HasBleed(player)
            return ksil:GetData(player, "Bleeding", ksil.DataPersistenceMode.RUN).Bleeding or player:HasEntityFlags(EntityFlag.FLAG_BLEED_OUT)
        end

        ---@param player EntityPlayer
        ksil:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function (_, player)
            if not mod:HasBleed(player) then return end

            if player:GetHearts() <= 1 or player:HasCollectible(CollectibleType.COLLECTIBLE_EVIL_CHARM) then
                mod:ClearBleed(player)
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
            ksil:AddCallback(ModCallbacks.MC_POST_PLAYER_ADD_HEARTS, function (_, player, amt, type)
                if amt <= 0 then return end

                if not mod:HasBleed(player) then return end

                ---@diagnostic disable-next-line: undefined-global, param-type-mismatch
                if mod:HasFlags(type, AddHealthType.RED | AddHealthType.ROTTEN) then
                    mod:ClearBleed(player)
                end
            end)
        else
            ---@param player EntityPlayer
            ksil:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
                local data = ksil:GetData(player, "Bleeding", ksil.DataPersistenceMode.RUN) if not data.Bleeding then return end
                local hearts = player:GetHearts()

                data.PrevHearts = data.PrevHearts or hearts

                if hearts > data.PrevHearts then
                    mod:ClearBleed(player)
                end

                data.PrevHearts = hearts
            end)
        end
    end

    if ksilConfig.CustomStatusLib then
        ---@module "customstatuslib"
        local CustomStatusLib = _include("customstatuslib")
        CustomStatusLib.Init()
    end

    if ksilConfig.HiddenItemManager then
        ---@module "hiddenitemmanager"
        local HiddenItemManager = _include("customstatuslib")
        HiddenItemManager:Init(mod)
        mod.HiddenItemManager = HiddenItemManager
    end

    if ksilConfig.JumpLib then
        ---@module "jumplib"
        local JumpLib = _include("jumplib")
        JumpLib.Init()
    end

    if ksilConfig.BloodTearUtility then
        ---@param player EntityPlayer
        ---@param identifier? string
        ---@return boolean
        function mod:GetBloodTears(player, identifier)
            if identifier then
                return ksil:GetData(player, "BloodTears")[identifier]
            end
            return mod:AnyValueIs(ksil:GetData(player, "BloodTears"), true)
        end

        ---@param player EntityPlayer
        ---@param set boolean
        ---@param identifier string
        function mod:SetBloodTears(player, set, identifier)
            ksil:GetData(player, "BloodTears")[identifier] = set
        end

        ---@param tear EntityTear
        ksil:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function (_, tear)
            if not ksil.TEAR_TO_BLOOD[tear.Variant] then return end
            local player = mod:GetPlayerFromEntity(tear, ksil.PlayerSearchType.FAMILIAR_TEARCOPYING) if not player or not mod:GetBloodTears(player) then return end
            tear:ChangeVariant(ksil.TEAR_TO_BLOOD[tear.Variant])
        end)
    end

    if ksilConfig.Scheduler then
        ---@class ksil.SchedulerEntry
        ---@field Frame integer
        ---@field Fn function
        ---@field Delay integer
        ---@field Type ksil.FunctionScheduleType

        ---@param fn function
        ---@param delay integer
        ---@param type ksil.FunctionScheduleType
        function mod:Schedule(fn, delay, type)
            table.insert(ksil.FunctionScheduleEntries, {
                Frame = Game():GetFrameCount(),
                Fn = fn,
                Delay = delay,
                Type = type
            })
        end

        ksil:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function ()
            ksil.FunctionScheduleEntries = {}
        end)

        if REPENTOGON then
            ---@diagnostic disable-next-line: undefined-field
            ksil:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, function ()
                for _, v in pairs(ksil.FunctionScheduleEntries) do
                    if v.Type == ksil.FunctionScheduleType.PRE_LEAVE_ROOM_EXECUTE then
                        v.Fn()
                    end
                end
            end)
        end

        ksil:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
            for i, v in pairs(ksil.FunctionScheduleEntries) do
                if v.Type ~= ksil.FunctionScheduleType.PERSISTENT then
                    if v.Type == ksil.FunctionScheduleType.POST_LEAVE_ROOM_EXECUTE or (not REPENTOGON and (v.Type == ksil.FunctionScheduleType.PRE_LEAVE_ROOM_EXECUTE)) then
                        v.Fn()
                    end
                    table.remove(ksil.FunctionScheduleEntries, i)
                end
            end
        end)

        ksil:AddCallback(ModCallbacks.MC_POST_UPDATE, function ()
            local frameCount = Game():GetFrameCount()

            for i, v in pairs(ksil.FunctionScheduleEntries) do
                if v.Frame + v.Delay <= frameCount then
                    table.remove(ksil.FunctionScheduleEntries, i)
                    v.Fn()
                end
            end
        end)
    end

    if ksilConfig.TempStatLib then
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

        ---@param player EntityPlayer
        ---@param config ksil.TempStatConfig
        function mod:AddTempStat(player, config)
            ---@type ksil.TempStatEntry[]
            local data = ksil:GetData(player, "TempStats", ksil.DataPersistenceMode.RUN)

            local insert = {
                Persistent = config.Persistent,
                Type = config.Amount < 0 and ksil.TempStatType.INCREASE or ksil.TempStatType.DECREASE,
                Frequency = config.Frequency or 10,
                Amount = config.Amount,
                ChangeAmount = config.Amount / config.Duration * (config.Frequency or 10),
                Stat = config.Stat,
                ApplyFrame = Game():GetFrameCount(),
                Identifier = config.Identifier
            }

            for i, v in ipairs(data) do
                if v.Identifier == config.Identifier then
                    insert.Amount = v.Amount + insert.Amount
                    data[i] = insert
                    player:AddCacheFlags(config.Stat)
                    player:EvaluateItems()
                    return
                end
            end

            table.insert(data, insert)

            player:AddCacheFlags(config.Stat)
            player:EvaluateItems()
        end

        ---@param player EntityPlayer
        ksil:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
            ---@type ksil.TempStatEntry[]
            local data = ksil:GetData(player, "TempStats", ksil.DataPersistenceMode.RUN)

            if #data > 0 then
                for i, v in ipairs(data) do
                    if not v.Persistent and player.FrameCount == 0 then
                        table.remove(data, i)
                    else
                        if (Game():GetFrameCount() - v.ApplyFrame) % v.Frequency == 0 then
                            if v.Type == ksil.TempStatType.DECREASE then
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
        ksil:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player, flag)
            ---@type ksil.TempStatEntry[]
            local data = ksil:GetData(player, "TempStats", ksil.DataPersistenceMode.RUN)

            if #data > 0 then
                for _, v in ipairs(data) do
                    if v.Stat == CacheFlag.CACHE_DAMAGE and flag == CacheFlag.CACHE_DAMAGE then
                        player.Damage = player.Damage + v.Amount
                    elseif v.Stat == CacheFlag.CACHE_FIREDELAY and flag == CacheFlag.CACHE_FIREDELAY then
                        player.MaxFireDelay = mod:ToMaxFireDelay(mod:ToTearsPerSecond(player.MaxFireDelay) + v.Amount)
                    elseif v.Stat == CacheFlag.CACHE_SHOTSPEED and flag == CacheFlag.CACHE_SHOTSPEED then
                        player.ShotSpeed = player.ShotSpeed + v.Amount
                    elseif v.Stat == CacheFlag.CACHE_RANGE and flag == CacheFlag.CACHE_RANGE then
                        player.TearRange = player.TearRange + v.Amount * 40
                    elseif v.Stat == CacheFlag.CACHE_SPEED and flag == CacheFlag.CACHE_SPEED then
                        player.MoveSpeed = player.MoveSpeed + v.Amount
                    elseif v.Stat == CacheFlag.CACHE_LUCK and flag == CacheFlag.CACHE_LUCK then
                        player.Luck = player.Luck + v.Amount
                    end
                end
            end
        end)
    end

    if ksilConfig.ThrowableItemLib then
        ---@type ksil.ThrowableItemConfig[]
        local ThrowableItemConfigs = {}

        ---@param id CollectibleType | Card
        ---@param type ksil.ThrowableItemType
        ---@return string
        local function GetHeldConfigKey(id, type)
            return (type == ksil.ThrowableItemType.ACTIVE and "ACTIVE_" or "CARD_") .. id
        end

        ---@param player EntityPlayer
        ---@param id CollectibleType | Card
        ---@param type ksil.ThrowableItemType
        ---@param slot? ActiveSlot
        ---@param continue? boolean
        function mod:LiftItem(player, id, type, slot, continue)
            local config = ThrowableItemConfigs[GetHeldConfigKey(id, type)] if not config then return end
            local data = ksil:GetData(player, "ThrowableItem")

            data.HeldConfig = config
            data.ActiveSlot = slot

            if type == ksil.ThrowableItemType.ACTIVE then
                player:AnimateCollectible(data.HeldConfig.ID, "LiftItem", "PlayerPickup")
            else
                player:AnimateCard(data.HeldConfig.ID, "LiftItem")
            end

            if REPENTOGON then
                ---@diagnostic disable-next-line: undefined-field
                player:SetItemState(type == ksil.ThrowableItemType.ACTIVE and config.ID or 0)
            end

            if data.HeldConfig.LiftFn and not continue then
                data.HeldConfig.LiftFn(player)
            end
        end

        ---@param player EntityPlayer
        ---@return ksil.ThrowableItemConfig
        function mod:GetLiftedItem(player)
            return ksil:GetData(player, "ThrowableItem").HeldConfig
        end

        ---@param player EntityPlayer
        ---@return boolean
        function mod:IsItemLifted(player)
            return not not mod:GetLiftedItem(player)
        end

        ---@param player EntityPlayer
        ---@param throw? boolean
        function mod:HideItem(player, throw)
            if not mod:IsItemLifted(player) then return end

            local data = ksil:GetData(player, "ThrowableItem")
            local active = data.HeldConfig.Type == ksil.ThrowableItemType.ACTIVE

            if active then
                player:AnimateCollectible(data.HeldConfig.ID, "HideItem", "PlayerPickup")
            else
                player:AnimateCard(data.HeldConfig.ID, "HideItem")
            end

            local function CardBehavior()
                if data.Mimic then
                    player:DischargeActiveItem()
                else
                    player:SetCard(0, Card.CARD_NULL)
                end
            end

            if throw and not mod:HasFlags(data.HeldConfig.Flags, ksil.ThrowableItemFlag.NO_DISCHARGE) then
                if active and data.ActiveSlot then
                    player:DischargeActiveItem(data.ActiveSlot)
                else
                    CardBehavior()
                end
            elseif not throw then
                if data.HeldConfig.HideFn then
                    data.HeldConfig.HideFn(player)
                end

                if mod:HasFlags(data.HeldConfig.Flags, ksil.ThrowableItemFlag.DISCHARGE_HIDE) then
                    if active then
                        player:DischargeActiveItem(data.ActiveSlot)
                    else
                        CardBehavior()
                    end
                end
            end

            data.HeldConfig = nil
            data.ActiveSlot = nil
            data.Mimic = nil

            if REPENTOGON then
                ---@diagnostic disable-next-line: undefined-field
                player:SetItemState(CollectibleType.COLLECTIBLE_NULL)
            end
        end

        ---@param player EntityPlayer
        ---@return boolean
        function mod:ThrowableActiveSelected(player)
            return not not ThrowableItemConfigs[GetHeldConfigKey(player:GetActiveItem(ActiveSlot.SLOT_PRIMARY), ksil.ThrowableItemType.ACTIVE)]
        end

        ---@param player EntityPlayer
        ---@return boolean
        function mod:ThrowableCardSelected(player)
            return not not ThrowableItemConfigs[GetHeldConfigKey(player:GetCard(0), ksil.ThrowableItemType.CARD)]
        end

        ---@param player EntityPlayer
        ---@return boolean
        function mod:ThrowablePocketActiveSelected(player)
            if player:GetCard(0) ~= Card.CARD_NULL then return false end
            return not not ThrowableItemConfigs[GetHeldConfigKey(player:GetActiveItem(ActiveSlot.SLOT_POCKET), ksil.ThrowableItemType.ACTIVE)]
        end

        ---@param config ksil.ThrowableItemConfig
        function mod:RegisterThrowableItem(config)
            config.Flags = config.Flags or 0
            ThrowableItemConfigs[GetHeldConfigKey(config.ID, config.Type)] = config
        end

        ---@param entity Entity?
        ---@param action ButtonAction
        ksil:AddCallback(ModCallbacks.MC_INPUT_ACTION, function (_, entity, _, action)
            local player = entity and entity:ToPlayer() if not player then return end

            if action == ButtonAction.ACTION_ITEM then
                if mod:ThrowableActiveSelected(player) then
                    return false
                end

                if mod:ThrowableCardSelected(player) then
                    local card = player:GetCard(0)
                    local config = Isaac.GetItemConfig():GetCard(card)
                    local item = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)

                    if (config:IsRune() and item == CollectibleType.COLLECTIBLE_CLEAR_RUNE) or (config:IsCard() and item == CollectibleType.COLLECTIBLE_BLANK_CARD) then
                        return false
                    end
                end
            elseif action == ButtonAction.ACTION_PILLCARD then
                if mod:ThrowablePocketActiveSelected(player) or mod:ThrowableCardSelected(player) then
                    return false
                end
            elseif action == ButtonAction.ACTION_DROP and mod:IsItemLifted(player) then
                return false
            end
        end, InputHook.IS_ACTION_TRIGGERED)

        ---@param player EntityPlayer
        ksil:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
            local q = Input.IsActionTriggered(ButtonAction.ACTION_PILLCARD, player.ControllerIndex)
            local data = ksil:GetData(player, "ThrowableItem")

            local function HandleAction(slot)
                local item = player:GetActiveItem(slot)

                if mod:IsItemLifted(player) and data.ActiveSlot == slot then
                    data.ScheduleHide = true
                elseif player:GetActiveCharge(slot) >= Isaac.GetItemConfig():GetCollectible(item).MaxCharges
                or mod:HasFlags(ThrowableItemConfigs[GetHeldConfigKey(item, ksil.ThrowableItemType.ACTIVE)].Flags, ksil.ThrowableItemFlag.USABLE_ANY_CHARGE) then
                    mod:LiftItem(player, item, ksil.ThrowableItemType.ACTIVE, slot)
                end
            end

            if mod:ThrowableActiveSelected(player) and Input.IsActionTriggered(ButtonAction.ACTION_ITEM, player.ControllerIndex) then
                HandleAction(ActiveSlot.SLOT_PRIMARY)
            end

            if mod:ThrowablePocketActiveSelected(player) and q then
                HandleAction(ActiveSlot.SLOT_POCKET)
            end

            if mod:ThrowableCardSelected(player) then
                local card = player:GetCard(0)

                if q then
                    if mod:IsItemLifted(player) and data.HeldConfig.Type == ksil.ThrowableItemType.CARD then
                        data.ScheduleHide = true
                    else
                        mod:LiftItem(player, card, ksil.ThrowableItemType.CARD)
                    end
                end

                local item = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)

                if (player:GetActiveCharge() >= Isaac.GetItemConfig():GetCollectible(item).MaxCharges
                or mod:HasFlags(ThrowableItemConfigs[GetHeldConfigKey(card, ksil.ThrowableItemType.CARD)].Flags, ksil.ThrowableItemFlag.USABLE_ANY_CHARGE))
                and Input.IsActionTriggered(ButtonAction.ACTION_ITEM, player.ControllerIndex) then
                    local config = Isaac.GetItemConfig():GetCard(card)

                    if config:IsRune() and item == CollectibleType.COLLECTIBLE_CLEAR_RUNE or (config:IsCard() and item == CollectibleType.COLLECTIBLE_BLANK_CARD) then
                        if mod:IsItemLifted(player) and data.HeldConfig.Type == ksil.ThrowableItemType.CARD then
                            data.ScheduleHide = true
                        else
                            data.Mimic = item
                            data.ActiveSlot = ActiveSlot.SLOT_PRIMARY
                            mod:LiftItem(player, card, ksil.ThrowableItemType.CARD)
                        end
                    end
                end
            end
        end)

        ---@param player EntityPlayer
        ksil:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
            local data = ksil:GetData(player, "ThrowableItem")

            if data.ScheduleHide then
                if not mod:HasFlags(data.HeldConfig.Flags, ksil.ThrowableItemFlag.DISABLE_HIDE) then
                    mod:HideItem(player)
                end

                data.ScheduleHide = false
            end

            if mod:IsItemLifted(player) then
                if player:IsExtraAnimationFinished() then
                    if mod:HasFlags(data.HeldConfig.Flags, ksil.ThrowableItemFlag.PERSISTENT) then
                        mod:LiftItem(player, data.HeldConfig.ID, data.HeldConfig.Type, data.ActiveSlot, true)
                    else
                        data.HeldConfig = nil
                        data.ActiveSlot = nil
                        data.Mimic = nil
                    end
                elseif mod:IsShooting(player) then
                    if data.HeldConfig.ThrowFn then
                        data.HeldConfig.ThrowFn(player, mod:GetAimVect(player))
                    end

                    mod:HideItem(player, true)
                end
            end
        end)
    end

    if ksilConfig.FloatingTextLib then
        ---@class ksil.FloatingTextConfig
        ---@field WiggleSpeed? integer
        ---@field WiggleSize? integer
        ---@field Text string
        ---@field Position Vector
        ---@field Font? Font
        ---@field Color? KColor
        ---@field FloatSpeed? integer
        ---@field FadeSpeed? integer
        ---@field FadeWait? integer
        ---@field FrameCount? integer
        ---@field Scale? integer
        ---@field PauseOnPause? boolean

        ksil:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
            ksil.FloatingTextEntries = {}
        end)

        ---@param textConfig ksil.FloatingTextConfig
        function mod:CreateFloatingText(textConfig)
            if not textConfig.Font then
                local font = Font()
                font:Load("font/pftempestasevencondensed.fnt")
                textConfig.Font = font
            end

            textConfig.Color = textConfig.Color or KColor(1, 1, 1, 1)
            textConfig.FrameCount = textConfig.FrameCount or 0
            textConfig.Scale = textConfig.Scale or 1
            textConfig.WiggleSize = textConfig.WiggleSize or 0.5
            textConfig.WiggleSpeed = textConfig.WiggleSpeed or 0.1
            textConfig.FadeSpeed = textConfig.FadeSpeed or 0.025
            textConfig.FadeWait = textConfig.FadeWait or 60
            textConfig.FloatSpeed = textConfig.FloatSpeed or 1

            if textConfig.PauseOnPause == nil then
                textConfig.PauseOnPause = true
            end

            table.insert(ksil.FloatingTextEntries, textConfig)
        end

        ksil:AddCallback(ModCallbacks.MC_POST_RENDER, function ()
            for i, textConfig in pairs(ksil.FloatingTextEntries) do
                if textConfig.Color.Alpha <= 0 then
                    table.remove(ksil.FloatingTextEntries, i)
                else
                    if not (textConfig.PauseOnPause and Game():IsPaused()) then
                        textConfig.Position.X = textConfig.Position.X + math.sin(textConfig.FrameCount * textConfig.WiggleSpeed) * textConfig.WiggleSize
                        textConfig.Position.Y = textConfig.Position.Y - textConfig.FloatSpeed
                        textConfig.FrameCount = textConfig.FrameCount + 1

                        if textConfig.FrameCount > textConfig.FadeWait then
                            textConfig.Color.Alpha = textConfig.Color.Alpha - textConfig.FadeSpeed
                        end
                    end

                    textConfig.Font:DrawStringScaled(textConfig.Text, textConfig.Position.X, textConfig.Position.Y, textConfig.Scale, textConfig.Scale, textConfig.Color, 1, true)
                end
            end
        end)
    end

    return mod
end}
