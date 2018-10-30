# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog sequence_detector.v

#load simulation using mux as the top level simulation module
vsim sequence_detector

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

#Initialize

force {SW[0]} 0
force {KEY[0]} 1

run 5ns

# Start Clock

force {KEY[0]} 0 0ns , 1 {5ns} -r 10ns
run 5ns
force {SW[0]} 1

#Test Cases

force {SW[1]} 1

run 50ns

force {SW[1]} 0

run 10ns

force {SW[1]} 1

run 10ns

force {SW[1]} 0

run 10ns

force {SW[1]} 1

run 10ns

force {SW[1]} 1

run 10ns

force {SW[1]} 0

run 10ns

force {SW[1]} 1

run 50ns

force {SW[0]} 0

run 20ns