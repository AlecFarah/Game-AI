
pipe_out = nil -- for sending data(output e.g. screen pixels, reward) back to client
pipe_in = nil -- for getting data(input e.g. controller status change) from client
flag_reset = false -- indicates whether a reset is happening

SEP = string.format('%c', 0xFF) -- as separator in communication protocol
IN_SEP = '|' -- seperator is a bar
COMMAND_TABLE = {
  A = "A",
  B = "B",
  U = "up",
  L = "left",
  D = "down",
  R = "right"
}

-- n functions start with nes_ prefix
-- called before each episode
function nes_reset()
  flag_reset = true
  print("Reset")
  -- load state so we don't have to instruct to skip title screen
  state = savestate.object(10)
  savestate.load(state)
  joypad.set(1,{start=true})


end


-- called once when emulator starts
function nes_init()
    --emu.speedmode("maximum")
emu.speedmode("normal")

  pipe_prefix = 'nesgym-pipe'
  -- from emulator to client
  pipe_out, _, _ = io.open(pipe_prefix .. "-in", "w")
  -- from client to emulator
  pipe_in, _, _ = io.open(pipe_prefix .. "-out", "r")
  print("Ready")
--  write_to_pipe("ready" .. SEP .. emu.framecount())
end

-- update_screen - get current screen pixels and store them (256 x 224)
-- Palette is a number from 0 to 127 that represents an RGB color (conversion table in python file)
function nes_update_screen()
    write_to_pipe(memory.readbyte(0x0000)..","..memory.readbyte(0x0001)..","..memory.readbyte(0x0004)..","..memory.readbyte(0x0006)..","..memory.readbyte(0x0005)..","..memory.readbyte(0x0007)..","..memory.readbyte(0x002C)..","..memory.readbyte(0x002D)..","..memory.readbyte(0x0044)..","..memory.readbyte(0x0045))
end


function nes_process_command()
  if not pipe_in then
    return false
  end

  local line = pipe_in:read()
  if line ~= nil then
    handle_command(line)
    print(line)
    return true
  end

  return false
end

function nes_ask_for_command()
  write_to_pipe("wait_for_command" .. SEP .. emu.framecount())
end

--- private functions
-- handle one command
function handle_command(line)
  local body = split(line, IN_SEP)
  local command = body[1]
  if command == 'reset' then
    nes_reset()
    nes_update_screen()

  elseif command == 'joypad' then
    -- joypad command
    local buttons = body[2]
    local joypad_command = {}
    for i = 1, #buttons do
      local btn = buttons:sub(i,i)
      local button = COMMAND_TABLE[buttons:sub(i,i)]
      joypad_command[button] = true
      gui.text(5,25, button)
    end
    joypad.set(1, joypad_command)
    nes_update_screen()
  end
  emu.frameadvance()
end

-- write_to_pipe - Write data to pipe
function write_to_pipe(data)
  if data and pipe_out then
    pipe_out:write(data)
    pipe_out:flush()
  end
end

function write_to_pipe_partial(data)
  if data and pipe_out then
    pipe_out:write(data)
  end
end

function write_to_pipe_end()
  if pipe_out then
    pipe_out:write(SEP .. "\n")
    pipe_out:flush()
  end
end

-- split - Splits a string with a specific delimiter
function split(self, delimiter)
    local results = {}
    local start = 1
    local split_start, split_end  = string.find(self, delimiter, start)
    while split_start do
        table.insert(results, string.sub(self, start, split_start - 1))
        start = split_end + 1
        split_start, split_end = string.find(self, delimiter, start)
    end
    table.insert(results, string.sub(self, start))
    return results
end

emu.softreset()
nes_reset()
nes_init()
while true do
    nes_process_command()


end




