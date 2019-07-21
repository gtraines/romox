--[[
    CollectionService

    * Manages groups (collections) of instances with tags
    * Tags = sets of strings applied to objects that replicate __ from the server to the client and in Team Create __
        ** At the moment, tags are NOT VISIBLE IN ROBLOX STUDIO except with the use of a tag-editing plugin
    * Serialized when places are saved

    * Primary use of CollectionService is to add flags and/or behaviors to Roblox objects

    - If you find yourself adding the same script to many different objects, perhaps a script
      that uses CollectionService would be better

      Examples: 
      - Have any brick tagged 'KillBrick' kill the player
      - Players w/ VIP game pass could have their Humanoid tagged w/ "VIP" and be allowed through VIP-only doors
      - Use a LocalScript to listen for the "Frozen" tag applied to player's Humanoid obj and create client-side
        visual effects
]]