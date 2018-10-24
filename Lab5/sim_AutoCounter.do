# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog AutoCounter.v Counter.v HEX_Decoder.v

#load simulation using mux as the top level simulation module
vsim AutoCounterTOP

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}



#Initialize

#force {Clear_b} 0
#force {Enable} 0
#force {Clock} 0
force {ClockFrequency} 26'b00000000000000000000110010

force {CLOCK_50} 1 0ns, 0 {1ns} -r 2ns
force {SW[1:0]} 00

force {clr1} 0

run 10ns

force {clr1} 1
force {clr2} 0

run 10ns

force {clr2} 1

run 20ns

force {SW[1:0]} 01

run 100ns

force {SW[1:0]} 10

run 100ns

force {SW[1:0]} 11

run 200ns
