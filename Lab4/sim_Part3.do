# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog Part3.v

#load simulation using mux as the top level simulation module
vsim Part3Top

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

force {KEY[0]} 0 0ns , 1 {15ns} -r 30ns

#Initialize

force {SW[7:0]} 10100110
force {SW[9]} 1
force {KEY[3:0]} 0000

run 5ns

# Start Clock

force {KEY[0]} 1 0ns , 0 {5ns} -r 10ns
run 5ns

#Test Case No Rotation

force {SW[9]} 0
force {KEY[3:1]} 000

run 10ns

#Test Case Left Rotation no LSRight

force {KEY[3:1]} 001

run 10ns

#Test Case Right Rotation no LSRight

force {KEY[3:1]} 011

run 20ns

#Test Case Right Rotation with LSRight

force {KEY[3:1]} 111

run 10ns

#Test Case Reset

force {SW[9]} 1
force {KEY[3:1]} 001

run 10ns

#Test Case Left Rotation with LSRight

force {SW[9]} 0
force {KEY[3:1]} 101

run 10ns

#Test Case differet Reset

force {SW[9]} 1
force {SW[7:0]} 10101001
force {KEY[3:1]} 000

run 10ns

#Test Case Left Rotation without ParallelLoad

force {SW[9]} 0
force {KEY[3:1]} 010

run 10ns