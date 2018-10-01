# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog mux.v

#load simulation using mux as the top level simulation module
vsim mux7to1

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

#Test Case:

force {MuxSelect[2]} 0
force {MuxSelect[1]} 0
force {MuxSelect[0]} 0

force {Input[6]} 1
force {Input[5]} 1
force {Input[4]} 1
force {Input[3]} 1
force {Input[2]} 1
force {Input[1]} 1
force {Input[0]} 0

run 5ns

#Test Case:

force {MuxSelect[2]} 0
force {MuxSelect[1]} 0
force {MuxSelect[0]} 0

force {Input[6]} 0
force {Input[5]} 0
force {Input[4]} 0
force {Input[3]} 0
force {Input[2]} 0
force {Input[1]} 0
force {Input[0]} 1

run 5ns

#Test Case:

force {MuxSelect[2]} 0
force {MuxSelect[1]} 0
force {MuxSelect[0]} 1

force {Input[6]} 1
force {Input[5]} 1
force {Input[4]} 1
force {Input[3]} 1
force {Input[2]} 1
force {Input[1]} 0
force {Input[0]} 1

run 5ns

#Test Case:

force {MuxSelect[2]} 0
force {MuxSelect[1]} 0
force {MuxSelect[0]} 1

force {Input[6]} 0
force {Input[5]} 0
force {Input[4]} 0
force {Input[3]} 0
force {Input[2]} 0
force {Input[1]} 1
force {Input[0]} 0

run 5ns

#Test Case:

force {MuxSelect[2]} 0
force {MuxSelect[1]} 1
force {MuxSelect[0]} 0

force {Input[6]} 1
force {Input[5]} 1
force {Input[4]} 1
force {Input[3]} 1
force {Input[2]} 0
force {Input[1]} 1
force {Input[0]} 1

run 5ns

#Test Case:

force {MuxSelect[2]} 0
force {MuxSelect[1]} 1
force {MuxSelect[0]} 0

force {Input[6]} 0
force {Input[5]} 0
force {Input[4]} 0
force {Input[3]} 0
force {Input[2]} 1
force {Input[1]} 0
force {Input[0]} 0

run 5ns

#Test Case:

force {MuxSelect[2]} 0
force {MuxSelect[1]} 1
force {MuxSelect[0]} 1

force {Input[6]} 1
force {Input[5]} 1
force {Input[4]} 1
force {Input[3]} 0
force {Input[2]} 1
force {Input[1]} 1
force {Input[0]} 1

run 5ns

#Test Case:

force {MuxSelect[2]} 0
force {MuxSelect[1]} 1
force {MuxSelect[0]} 1

force {Input[6]} 0
force {Input[5]} 0
force {Input[4]} 0
force {Input[3]} 1
force {Input[2]} 0
force {Input[1]} 0
force {Input[0]} 0

run 5ns

#Test Case:

force {MuxSelect[2]} 1
force {MuxSelect[1]} 0
force {MuxSelect[0]} 0

force {Input[6]} 1
force {Input[5]} 1
force {Input[4]} 0
force {Input[3]} 1
force {Input[2]} 1
force {Input[1]} 1
force {Input[0]} 1

run 5ns

#Test Case:

force {MuxSelect[2]} 1
force {MuxSelect[1]} 0
force {MuxSelect[0]} 0

force {Input[6]} 0
force {Input[5]} 0
force {Input[4]} 1
force {Input[3]} 0
force {Input[2]} 0
force {Input[1]} 0
force {Input[0]} 0

run 5ns

#Test Case:

force {MuxSelect[2]} 1
force {MuxSelect[1]} 0
force {MuxSelect[0]} 1

force {Input[6]} 1
force {Input[5]} 0
force {Input[4]} 1
force {Input[3]} 1
force {Input[2]} 1
force {Input[1]} 1
force {Input[0]} 1

run 5ns

#Test Case:

force {MuxSelect[2]} 1
force {MuxSelect[1]} 0
force {MuxSelect[0]} 1

force {Input[6]} 0
force {Input[5]} 1
force {Input[4]} 0
force {Input[3]} 0
force {Input[2]} 0
force {Input[1]} 0
force {Input[0]} 0

run 5ns

#Test Case:

force {MuxSelect[2]} 1
force {MuxSelect[1]} 1
force {MuxSelect[0]} 0

force {Input[6]} 0
force {Input[5]} 1
force {Input[4]} 1
force {Input[3]} 1
force {Input[2]} 1
force {Input[1]} 1
force {Input[0]} 1

run 5ns

#Test Case:

force {MuxSelect[2]} 1
force {MuxSelect[1]} 1
force {MuxSelect[0]} 0

force {Input[6]} 1
force {Input[5]} 0
force {Input[4]} 0
force {Input[3]} 0
force {Input[2]} 0
force {Input[1]} 0
force {Input[0]} 0

run 5ns