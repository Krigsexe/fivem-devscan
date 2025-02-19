local resourcePath = "resources/"
local logFile = "logs.txt"

-- Fonction pour écrire les logs dans le fichier logs.txt
local function logToFile(message)
    local file = io.open(logFile, "a")
    if file then
        file:write(os.date("[%Y-%m-%d %H:%M:%S] ") .. message .. "\n")
        file:close()
    end)
end

local function log(message, level)
    local formattedMessage = string.format("[%s] %s", level, message)
    print(formattedMessage)
    logToFile(formattedMessage)
end

local function file_exists(path)
    local file = io.open(path, "r")
    if file then 
        file:close() 
        return true 
    else 
        return false 
    end
end

local function read_manifest(resourceName)
    local manifestPath = GetResourcePath(resourceName) .. "/fxmanifest.lua"
    local legacyManifestPath = GetResourcePath(resourceName) .. "/_resource.lua"

    local manifest = {dependencies = {}, files = {}, scripts = {}, resourceName = resourceName}
    
    if file_exists(manifestPath) or file_exists(legacyManifestPath) then
        local targetFile = file_exists(manifestPath) and manifestPath or legacyManifestPath
        for line in io.lines(targetFile) do
            local dependency = line:match('dependency%s+"([^"]+)"')
            if dependency then table.insert(manifest.dependencies, dependency) end
            local file = line:match('files%s+"([^"]+)"')
            if file then table.insert(manifest.files, file) end
            local scriptType, scriptPath = line:match('(server_script|client_script|shared_script)%s+"([^"]+)"')
            if scriptType and scriptPath then
                table.insert(manifest.scripts, {type = scriptType, path = scriptPath})
            end
        end
    else
        log(resourceName .. " ne contient pas de fxmanifest.lua ou _resource.lua", "ERROR")
        return nil
    end
    return manifest
end

local function is_obfuscated(filePath)
    for line in io.lines(filePath) do
        if line:match("loadstring%(") or line:match("%-%-%[%[.*%]%]%-%-") then
            return true
        end
    end
    return false
end

local function save_to_database(resource, manifest)
    for _, script in ipairs(manifest.scripts) do
        local scriptPath = GetResourcePath(resource) .. "/" .. script.path
        MySQL.insert("INSERT INTO resources (resource_name, script_type, script_path) VALUES (?, ?, ?)", {
            resource, script.type, scriptPath
        })
    end
    for _, dependency in ipairs(manifest.dependencies) do
        MySQL.insert("INSERT INTO resource_dependencies (resource_name, dependency) VALUES (?, ?)", {
            resource, dependency
        })
    end
end

local function check_dependencies()
    local resources = {}
    local numResources = GetNumResources()
    
    for i = 0, numResources - 1 do
        local resource = GetResourceByFindIndex(i)
        if resource then
            local manifest = read_manifest(resource)
            if manifest then
                resources[resource] = manifest
                save_to_database(resource, manifest)
            else
                resources[resource] = {dependencies = {}, files = {}, scripts = {}, resourceName = resource}
            end
        else
            log("Impossible de récupérer la ressource à l'index " .. i, "ERROR")
        end
    end
    
    for resource, manifest in pairs(resources) do
        for _, dependency in ipairs(manifest.dependencies) do
            if not resources[dependency] then
                log(resource .. " dépend de " .. dependency .. " mais il est introuvable !", "WARNING")
            else
                log("Dépendance trouvée : " .. resource .. " <--> " .. dependency, "SUCCESS")
            end
        end
        
        for _, script in ipairs(manifest.scripts) do
            local scriptPath = GetResourcePath(resource) .. "/" .. script.path
            if file_exists(scriptPath) then
                if is_obfuscated(scriptPath) then
                    log("Script obfusqué détecté : " .. scriptPath .. " (Non exécuté)", "WARNING")
                else
                    log("Exécution du script : " .. scriptPath, "INFO")
                end
            else
                log("Fichier introuvable : " .. scriptPath, "ERROR")
            end
        end
        
        log(resource .. " contient " .. #manifest.files .. " fichiers et " .. #manifest.scripts .. " scripts.", "INFO")
    end
end

CreateThread(function()
    Wait(35000)  -- Attente pour assurer le chargement de toutes les ressources
    log("\n--- Début de la vérification des ressources et dépendances ---\n", "INFO")
    check_dependencies()
    log("\n--- Vérification terminée ---\n", "INFO")
end

local function purge_old_resources()
    local retention_days = 7 -- Suppression des ressources non détectées depuis 7 jours
    local query = "DELETE FROM resources WHERE updated_at < NOW() - INTERVAL ? DAY"
    
    MySQL.Async.execute(query, {retention_days}, function(affectedRows)
        if affectedRows > 0 then
            log("🔥 Purge automatique : " .. affectedRows .. " ressources supprimées (non détectées depuis " .. retention_days .. " jours)", "WARNING")
        else
            log("✅ Purge automatique : Aucune ressource à supprimer.", "INFO")
        end
    end)
end

-- Exécution de la purge toutes les 24 heures
CreateThread(function()
    while true do
        Wait(24 * 60 * 60 * 1000) -- 24 heures en millisecondes
        log("🔄 Lancement de la purge automatique des ressources obsolètes...", "INFO")
        purge_old_resources()
    end
end)
