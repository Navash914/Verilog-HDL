# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog Counter.v HEX_Decoder.v

#load simulation using mux as the top level simulation module
vsim Counter

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}



#Initialize

force {Clear_b} 0
force {Enable} 0
force {Clock} 0

run 5ns

# Start Clock

force {Clock} 1 0ns , 0 {5ns} -r 10ns
run 5ns

#Test Case

force {Clear_b} 1
force {Enable} 1

run 100ns