# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog MorseCodeEncoder.v AutoCounter.v Counter.v HEX_Decoder.v

#load simulation using mux as the top level simulation module
vsim MorseEncoderTOP

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}



#Initialize

#force {ClockFrequency} 26'b00000000000000000000110010
force {ClockFrequency} 26'b00000000000000000000000101

force {CLOCK_50} 1 0ns, 0 {1ns} -r 2ns
force {SW[2:0]} 000

force {clr} 0
force {KEY[0]} 1;

run 10ns

force {clr} 1
force {KEY[1:0]} 10;

run 10ns

force {KEY[1]} 0;

run 20ns

force {SW[2:0]} 001
force {KEY[1]} 1

run 10ns

force {KEY[1]} 0

run 20ns

force {SW[2:0]} 010
force {KEY[1]} 1

run 10ns

force {KEY[1]} 0

run 30ns

force {SW[2:0]} 110
force {KEY[1]} 1

run 10ns

force {KEY[1]} 0

run 60ns

force {SW[2:0]} 111
force {KEY[1]} 1

run 10ns

force {KEY[1]} 0

run 60ns