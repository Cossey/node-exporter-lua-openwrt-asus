local function scandir(directory)
    local i, t = 0, {}
    local pfile = assert(io.popen(("find '%s' -maxdepth 1"):format(directory), 'r'))
    local list = pfile:read('*a')
    pfile:close()
    for filename in list:gmatch("[^\r\n]+") do
        i = i + 1
        t[i] = filename
    end
    return t
end

local function remove_unsafe(text)
    return text:gsub("[^%w_:]", "_")
end

local chip_counter = {}
local function process_chip(chip)
    chip = remove_unsafe(chip)
    if chip_counter[chip] == nil then
        chip_counter[chip] = 0
    else
        chip_counter[chip] = chip_counter[chip] + 1
    end
    return chip .. "_" .. chip_counter[chip]
end

local function scrape()
    chip_counter = {}
    local folders = scandir("/sys/class/hwmon/")

    for _, folder in ipairs(folders) do
        local hwfolder = folder:match(".*/hwmon[0-9]+")
        if hwfolder ~= nill then
            local hw_files = scandir(hwfolder .. "/")
            local chip = process_chip(get_contents(hwfolder .. "/device/modalias"):match("[^\n]+"))
            local chip_name = get_contents(hwfolder .. "/name"):match("[^\n]+")
            for _, hw_file in ipairs(hw_files) do
                local temp_sensor = hw_file:match(".*/(temp[0-9]+)_input")
                if temp_sensor ~= nill then
                    local temp_sensor_label = ""
                    local temp_sensor_label_file = hw_file:match(".*/" .. temp_sensor .. "_label")
                    if temp_sensor_label_file ~= nill then
                        temp_sensor_label = get_contents(temp_sensor_label_file):match("[^\n]+")
                    end

                    local temp_sensor_iface = ""
                    local net_label_path = hwfolder .. "/device/net/"
                    local net_label_folders = scandir(net_label_path)
                    local net_iface_builder = ""
                    for _, net_label_folder in ipairs(net_label_folders) do
                        if net_label_folder ~= net_label_path then
                            local net_label_folder_leaf = net_label_folder:match(".*/(.+)")
                            net_iface_builder = net_iface_builder .. net_label_folder_leaf .. ","
                        end
                    end
                    if net_iface_builder ~= "" then
                        temp_sensor_iface = net_iface_builder:sub(1, -2)
                    end

                    local value = get_contents(hw_file)
                    local value = value / 1000

                    metric("node_hwmon_chip_names", "gauge", { chip = chip, chip_name = chip_name }, 1)
                    metric("node_hwmon_temp_celsius", "gauge", { chip = chip, sensor = temp_sensor }, value)

                    if temp_sensor_label ~= "" then
                        metric("node_hwmon_temp_sensor_label", "gauge", { chip = chip, sensor = temp_sensor, label = temp_sensor_label }, 1)
                    end

                    if temp_sensor_iface ~= "" then
                        metric("node_hwmon_temp_sensor_iface", "gauge", { chip = chip, sensor = temp_sensor, iface = temp_sensor_iface }, 1)
                    end

                end
            end
        end
    end
end

return {
    scrape = scrape
}
