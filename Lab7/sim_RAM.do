# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files

vlog RAM.v HEX_Decoder.v ram32x4.v

#load simulation using mux as the top level simulation module
vsim -L altera_mf_ver RAM_TOP

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}
add wave {RAM_TOP/ram/clock}
add wave {RAM_TOP/ram/address}
add wave {RAM_TOP/ram/data}
add wave {RAM_TOP/ram/wren}
add wave {RAM_TOP/ram/q}

#Initialize

force {KEY[0]} 1

run 5ns

# Start Clock

force {KEY[0]} 0 0ns , 1 {5ns} -r 10ns
run 5ns

#Test Cases

force {SW[9]} 1
force {SW[8:4]} 10101
force {SW[3:0]} 1011

run 10ns

force {SW[8:4]} 10111
force {SW[3:0]} 1100

run 10ns

force {SW[9]} 0
force {SW[8:4]} 10101

run 10ns

force {SW[8:4]} 10111

run 10ns

force {SW[8:4]} 11000

run 10ns