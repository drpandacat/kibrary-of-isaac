my kibrary is very cool!

it has tons of useful features
- full VSC autocompletion support
- defines mod:AddCallback and similar functions for VSC autocompletion
- entity data functions that return a table with options for persistence mod and default value
- various enums and dictionaries
- math functions for tears per second caluclations, lerping, angle lerping, + more
- vector + direction functions for various conversions and vector cardinal clamping
- table utility functions (any value is, any key is, deep copy with deeper copy argument, filter)
- entity spawning functions with default values for certain arguments, has seed argument, return their specific EntityX object
- get player from entity function with search types including player-only, player+tear-copying familiars, all
- player shooting input functions (GetAimVect, IsShooting, GetAimDir) optionally automatically clamped unless you have marked/analog stick
- IsPositionAccessible
- GetFamiliarDamageMult (accounts for lillith+tainted, blood clot subtypes, all tear-copying familiars)
- filter entities by distance, get nearest entity with source, max distance, and filter arguments
- various creep utility functions, useful for checking if an entity is in creep
- tear animation function
- random float range
- GetFilteredCollectible and GetFilteredTrinket with a filter argument that gives you the items config. get your quality 4 items easily now!
- GetFilteredCard with CardFilterFlags
- + more!
built in optional libraries that i made:
- throwable item library (the best one youll ever see!!)
  - full support for active items and cards
  - blank card + clear rune behavior
  - 6 throwable item flags to modify default behavior
  - Optional lift, throw, and hide functions
  - HoldCondition field
- blood tear utility
  - set or disable blood tears with specific tags to avoid overriding other blood tear effects
- temp stat library
  - support for any fading stat increase/decrease
  - control over duration, amount, persistence, update frequency
  - identifiers to have stat boosts from the same source blend together
- function scheduler
  - its cooler than any other one! it has a FunctionScheduleType argument that controls if its persistent, is cancelled on a new room, is executed on a new room, or executed before a new room (rgon only)
- floating text library
  - display text on the screen but its really cool trust me
  - control over wigglespeed, wigglesize, text, position, font, color, floatspeed, fadespeed, fadewait, scale, option for updating while game is paused
- bleed utility
  - control player bleed status effect
- last aim utility
- custom extra anim lib
also includes these ones:
- https://github.com/catinsurance/IsaacSaveManager (not optional!)
- https://github.com/ConnorForan/HiddenItemManager
- https://github.com/drpandacat/JumpLib
- https://github.com/drpandacat/CustomStatusLib
