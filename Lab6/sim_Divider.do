# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog Divider.v HEX_Decoder.v

#load simulation using mux as the top level simulation module
vsim Divider

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}
add wave {Divider/dp/*}
add wave {Divider/ctrl/*}

#Initialize

force {KEY[0]} 0
force {CLOCK_50} 0

run 5ns

# Start Clock

force {CLOCK_50} 1 0ns , 0 {5ns} -r 10ns
run 5ns

#Test Cases

force {KEY[0]} 1
force {KEY[1]} 0
# 6 divided by 2
force {SW[7:0]} 01100010

run 10ns

force {KEY[1]} 1

run 300ns

force {KEY[0]} 1
force {KEY[1]} 0
# 7 divided by 3
force {SW[7:0]} 01110011

run 10ns

force {KEY[1]} 1

run 370ns