file = open(r'nesgym-pipe-in', 'rb', buffering=0)
while True:
    pipe_content = file.readline()
    if pipe_content !=  b"":
        print(pipe_content.decode('utf-8'))
        pipe_data = pipe_content.decode('utf-8').split(',')
        print(pipe_data)
        state = [int(pipe_data[0]),int(pipe_data[1]),int(pipe_data[2]),int(pipe_data[3]),int(pipe_data[4]),int(pipe_data[5]),int(pipe_data[6]),int(pipe_data[7]),int(pipe_data[8]),int(pipe_data[9])]
        print(state)
        print(f" P1 state is {state[0]} and P1 x coordinate is {state[2]}, P1 y coordinate is {state[3]}, P1 percent is {state[6]}, P1 stock remaining is {state[8]}")
        print(f" P2 state is {state[1]} and P2 x coordinate is {state[4]}, P2 y coordinate is {state[5]}, P2 percent is {state[7]}, P2 stock remaining is {state[9]}")

#End section of reading emulator RAM to be readed by AI