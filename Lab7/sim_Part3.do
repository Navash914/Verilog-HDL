# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files

vlog move_fill.v

#load simulation using mux as the top level simulation module
vsim ControlPath2

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

#Initialize

force {Clock} 0
force {C_In} 100
force {ClockFrequency} 26'd30
force {Frequency} 26'd15

run 1ns

# Start Clock

force {Clock} 1 0ns , 0 {1ns} -r 2ns

#Test Cases

run 1000ns