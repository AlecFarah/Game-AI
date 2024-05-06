import time
import subprocess

def initialize():
    open(r'nesgym-pipe-out', 'w').close()
    open(r'nesgym-pipe-in', 'w').close()
    global proc
    global file
    global filein
    args = [r'C:\Users\Alec\Downloads\fceux-2.6.6-win64\fceux64.exe', '-lua', "Luafiles.lua", "Game.nes"]
    proc = subprocess.Popen(' '.join(args))
    file = open(r'nesgym-pipe-out', 'w', buffering=1)
    filein = open(r'nesgym-pipe-in', 'rb', buffering=0)

initialize()

def envreset():
    global file
    global filein
    global framenum
    framenum = 0
    file.write("reset")

    file.flush()

    while True:
        pipe_content = filein.readline()
        if pipe_content !=  b"":
            pipe_data = pipe_content.decode('utf-8').split(',')
            state = [int(pipe_data[0]),int(pipe_data[1]),int(pipe_data[2]),int(pipe_data[3]),int(pipe_data[4]),int(pipe_data[5]),int(pipe_data[6]),int(pipe_data[7]),int(pipe_data[8]),int(pipe_data[9])]
            return state

def envstep(action):
    global file
    global filein
    global framenum
    global stock
    global percent

    framenum += 1
    actions = ['U', 'D', 'L', 'R',
        'UR', 'DR', 'URA', 'DRB',
        'A', 'B', 'RB', 'RA']

    file.write("joypad"+ '|' + actions[action])

    file.flush()

    while True:
        pipe_content = filein.readline()
        if pipe_content !=  b"":
            pipe_data = pipe_content.decode('utf-8').split(',')
            state = [int(pipe_data[0]),int(pipe_data[1]),int(pipe_data[2]),int(pipe_data[3]),int(pipe_data[4]),int(pipe_data[5]),int(pipe_data[6]),int(pipe_data[7]),int(pipe_data[8]),int(pipe_data[9])]
            break

    reward = .1
    if state[0] == 2:
        print("player 1 lost")
    if state[1] == 2:
        print("player 2 lost")
    if stock != state[9]:
        reward = 1
    if state[1] ==2:
        reward = 1
    stock = state[9]
    end = False
    if state[0] == 2  or state[1] == 2:
        end = True
    return state, reward, end, False

