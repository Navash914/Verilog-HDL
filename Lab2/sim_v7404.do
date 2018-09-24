# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog mux.v

#load simulation using v7404 as the top level simulation module
vsim v7404

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

# test case
force {pin1} 0
force {pin3} 0
force {pin5} 0
force {pin9} 0
force {pin11} 0
force {pin13} 0
#run simulation for a few ns
run 10ns

# test case
force {pin1} 1
force {pin3} 0
force {pin5} 1
force {pin9} 0
force {pin11} 1
force {pin13} 0
#run simulation for a few ns
run 10ns

# test case
force {pin1} 0
force {pin3} 1
force {pin5} 0
force {pin9} 1
force {pin11} 0
force {pin13} 1
#run simulation for a few ns
run 10ns

# test case
force {pin1} 1
force {pin3} 1
force {pin5} 1
force {pin9} 1
force {pin11} 1
force {pin13} 1
#run simulation for a few ns
run 10ns
