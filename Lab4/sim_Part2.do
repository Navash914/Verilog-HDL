# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog Part2.v HEX_Decoder.v fourBitAdder.v

#load simulation using mux as the top level simulation module
vsim Part2Top

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}



#Initialize

force {SW[3:0]} 1010
force {SW[9]} 0
force {KEY[3:0]} 0100

run 5ns

# Start Clock

force {KEY[0]} 1 0ns , 0 {5ns} -r 10ns
run 5ns

#Test Case

force {SW[3:0]} 1010
force {SW[9]} 1
force {KEY[3:1]} 000

run 10ns

#Test Case

force {KEY[3:1]} 001

run 10ns

#Test Case

force {KEY[3:1]} 010

run 10ns

#Test Case

force {KEY[3:1]} 011

run 10ns

#Test Case

force {KEY[3:1]} 100

run 10ns

#Test Case

force {KEY[3:1]} 101

run 10ns

#Test Case

force {KEY[3:1]} 111

run 10ns

#Test Case

force {KEY[3:1]} 010
force {SW[9]} 0

run 10ns