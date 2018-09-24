# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog HEX_Decoder.v

#load simulation using mux as the top level simulation module
vsim HEX_Decoder

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

# first test case
#set input values using the force command, signal names need to be in {} brackets
force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 0
force {SW[0]} 0
#run simulation for a few ns
run 10ns

# first test case
#set input values using the force command, signal names need to be in {} brackets
force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 0
force {SW[0]} 1
#run simulation for a few ns
run 10ns

# first test case
#set input values using the force command, signal names need to be in {} brackets
force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 1
force {SW[0]} 0
#run simulation for a few ns
run 10ns

# first test case
#set input values using the force command, signal names need to be in {} brackets
force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 1
force {SW[0]} 1
#run simulation for a few ns
run 10ns

# first test case
#set input values using the force command, signal names need to be in {} brackets
force {SW[3]} 0
force {SW[2]} 1
force {SW[1]} 0
force {SW[0]} 0
#run simulation for a few ns
run 10ns

# first test case
#set input values using the force command, signal names need to be in {} brackets
force {SW[3]} 0
force {SW[2]} 1
force {SW[1]} 0
force {SW[0]} 1
#run simulation for a few ns
run 10ns

# first test case
#set input values using the force command, signal names need to be in {} brackets
force {SW[3]} 0
force {SW[2]} 1
force {SW[1]} 1
force {SW[0]} 0
#run simulation for a few ns
run 10ns

# first test case
#set input values using the force command, signal names need to be in {} brackets
force {SW[3]} 0
force {SW[2]} 1
force {SW[1]} 1
force {SW[0]} 1
#run simulation for a few ns
run 10ns

# first test case
#set input values using the force command, signal names need to be in {} brackets
force {SW[3]} 1
force {SW[2]} 0
force {SW[1]} 0
force {SW[0]} 0
#run simulation for a few ns
run 10ns

# first test case
#set input values using the force command, signal names need to be in {} brackets
force {SW[3]} 1
force {SW[2]} 0
force {SW[1]} 0
force {SW[0]} 1
#run simulation for a few ns
run 10ns

# first test case
#set input values using the force command, signal names need to be in {} brackets
force {SW[3]} 1
force {SW[2]} 0
force {SW[1]} 1
force {SW[0]} 0
#run simulation for a few ns
run 10ns

# first test case
#set input values using the force command, signal names need to be in {} brackets
force {SW[3]} 1
force {SW[2]} 0
force {SW[1]} 1
force {SW[0]} 1
#run simulation for a few ns
run 10ns

# first test case
#set input values using the force command, signal names need to be in {} brackets
force {SW[3]} 1
force {SW[2]} 1
force {SW[1]} 0
force {SW[0]} 0
#run simulation for a few ns
run 10ns

# first test case
#set input values using the force command, signal names need to be in {} brackets
force {SW[3]} 1
force {SW[2]} 1
force {SW[1]} 0
force {SW[0]} 1
#run simulation for a few ns
run 10ns

# first test case
#set input values using the force command, signal names need to be in {} brackets
force {SW[3]} 1
force {SW[2]} 1
force {SW[1]} 1
force {SW[0]} 0
#run simulation for a few ns
run 10ns

# first test case
#set input values using the force command, signal names need to be in {} brackets
force {SW[3]} 1
force {SW[2]} 1
force {SW[1]} 1
force {SW[0]} 1
#run simulation for a few ns
run 10ns