local function get_ziplink()
    local regex = '(https?)://github.com/.+/.+'
    if UPSTREAM_REPO == "zel" then
        return "aHR0cHM6Ly9naXRodWIuY29tL1ppbHphbGxsL1pUaG9uL2FyY2hpdmUvbGl0ZS56aXA=":base64_decode()
    elseif UPSTREAM_REPO:match(regex) then
        if UPSTREAM_REPO_BRANCH then
            return UPSTREAM_REPO .. "/archive/" .. UPSTREAM_REPO_BRANCH .. ".zip"
        else
            return UPSTREAM_REPO .. "/archive/lite.zip"
        end
    else
        return "aHR0cHM6Ly9naXRodWIuY29tL1ppbHphbGxsL1pUaG9uL2FyY2hpdmUvbGl0ZS56aXA=":base64_decode()
    end
end

local function get_repolink()
    local regex = '(https?)://github.com/.+/.+'
    local rlink
    if UPSTREAM_REPO == "zel" then
        rlink = "aHR0cHM6Ly9naXRodWIuY29tL1ppbHphbGxsL1pUaG9uLmdpdA==":base64_decode()
    elseif UPSTREAM_REPO:match(regex) then
        rlink = UPSTREAM_REPO
    else
        rlink = "aHR0cHM6Ly9naXRodWIuY29tL1ppbHphbGxsL1pUaG9uLmdpdA==":base64_decode()
    end
    return rlink
end

local function run_python_code(code)
    local command = "python3" .. pVer:gsub("%.", "") .. " -c '" .. code .. "'"
    os.execute(command)
end

local function run_catpack_git()
    run_python_code([[
        from git import Repo
        import sys
        OFFICIAL_UPSTREAM_REPO = "https://github.com/Zilzalll/ZThon"
        ACTIVE_BRANCH_NAME = "lite"
        repo = Repo.init()
        origin = repo.create_remote("temponame", OFFICIAL_UPSTREAM_REPO)
        origin.fetch()
        repo.create_head(ACTIVE_BRANCH_NAME, origin.refs[ACTIVE_BRANCH_NAME])
        repo.heads[ACTIVE_BRANCH_NAME].checkout(True)
    ]])
end

local function run_cat_git()
    local repolink = get_repolink()
    run_python_code([[
        from git import Repo
        import sys
        OFFICIAL_UPSTREAM_REPO="]] .. repolink .. [["
        ACTIVE_BRANCH_NAME = "'$UPSTREAM_REPO_BRANCH'" or "lite"
        repo = Repo.init()
        origin = repo.create_remote("temponame", OFFICIAL_UPSTREAM_REPO)
        origin.fetch()
        repo.create_head(ACTIVE_BRANCH_NAME, origin.refs[ACTIVE_BRANCH_NAME])
        repo.heads[ACTIVE_BRANCH_NAME].checkout(True)
    ]])
end

local function set_bot()
    local zippath = "lite.zip"
    print("⌭ جاري تنزيل اكواد السورس ⌭")
    os.execute("wget -q " .. get_ziplink() .. " -O \"" .. zippath .. "\"")
    print("⌭ تفريغ البيانات ⌭")
    local catpath = io.popen("unzip -qq " .. zippath .. " | grep -v '/.'"):read("*a")
    print("⌭ تـم التفريـغ ⌭")
    print("⌭ يتم التنظيف ⌭")
    os.execute("rm -rf \"" .. zippath .. "\"")
    os.execute("sleep 5")
    run_catpack_git()
    os.execute("cd " .. catpath)
    run_cat_git()
    run_python_code("from setup.updater import update_requirements; update_requirements('../requirements.txt', 'requirements.txt')")
    os.execute("chmod -R 755 bin")
    print("⌭ جـاري بـدء تنصيـب زدثـــون ⌭")
    print("\n\n")
    run_python_code("import zira; zira.main()")
end

set_bot()
