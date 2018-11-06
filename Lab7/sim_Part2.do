# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files

vlog fill.v

#load simulation using mux as the top level simulation module
vsim ControlPath

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

#Initialize

force {Reset_n} 0
force {Clear} 0
force {Clock} 0

force {LoadX} 0
force {Data_In} 1011011
force {C_In} 100
force {Plot} 0

run 5ns

# Start Clock

force {Clock} 1 0ns , 0 {5ns} -r 10ns
run 5ns

#Test Cases

force {Reset_n} 1
run 10ns

force {LoadX} 1

run 10ns

force {LoadX} 0

run 20ns

force {Data_In} 0100100

run 10ns

force {Plot} 1

run 10ns

force {Plot} 0

run 350ns