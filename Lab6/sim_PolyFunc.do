# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog poly_function.v HEX_Decoder.v

#load simulation using mux as the top level simulation module
vsim fpga_top

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}
add wave {/fpga_top/u0/*}
add wave {/fpga_top/u0/D0/*}

#Initialize

force {KEY[0]} 0
force {CLOCK_50} 0

run 5ns

# Start Clock

force {CLOCK_50} 1 0ns , 0 {1ns} -r 2ns
run 5ns

#Test Cases

# A = 4, B = 2, C = 1, X = 3

force {KEY[0]} 1
force {KEY[1]} 1
# A <= 4
force {SW[7:0]} 00000100

run 5ns

force {KEY[1]} 0
run 5ns
force {KEY[1]} 1
run 5ns

# B <= 2
force {SW[7:0]} 00000010

run 5ns

force {KEY[1]} 0
run 5ns
force {KEY[1]} 1
run 5ns

# C <= 1
force {SW[7:0]} 00000001

run 5ns

force {KEY[1]} 0
run 5ns
force {KEY[1]} 1
run 5ns

# X <= 3
force {SW[7:0]} 00000011

run 5ns

force {KEY[1]} 0
run 5ns
force {KEY[1]} 1
run 15ns


# A = 0, B = 0, C = 0, X = 0

force {KEY[0]} 1
force {KEY[1]} 1
# A <= 4
force {SW[7:0]} 00000000

run 5ns

force {KEY[1]} 0
run 5ns
force {KEY[1]} 1
run 5ns

# B <= 2
force {SW[7:0]} 00000000

run 5ns

force {KEY[1]} 0
run 5ns
force {KEY[1]} 1
run 5ns

# C <= 1
force {SW[7:0]} 00000000

run 5ns

force {KEY[1]} 0
run 5ns
force {KEY[1]} 1
run 5ns

# X <= 3
force {SW[7:0]} 00000000

run 5ns

force {KEY[1]} 0
run 5ns
force {KEY[1]} 1
run 15ns


# A = 127, B = 0, C = 127, X = 1

force {KEY[0]} 1
force {KEY[1]} 1
# A <= 4
force {SW[7:0]} 01111111

run 5ns

force {KEY[1]} 0
run 5ns
force {KEY[1]} 1
run 5ns

# B <= 2
force {SW[7:0]} 00000000

run 5ns

force {KEY[1]} 0
run 5ns
force {KEY[1]} 1
run 5ns

# C <= 1
force {SW[7:0]} 01111111

run 5ns

force {KEY[1]} 0
run 5ns
force {KEY[1]} 1
run 5ns

# X <= 3
force {SW[7:0]} 00000001

run 5ns

force {KEY[1]} 0
run 5ns
force {KEY[1]} 1
run 15ns


# A = 0, B = 0, C = 250, X = 64

force {KEY[0]} 1
force {KEY[1]} 1
# A <= 4
force {SW[7:0]} 00000000

run 5ns

force {KEY[1]} 0
run 5ns
force {KEY[1]} 1
run 5ns

# B <= 2
force {SW[7:0]} 00000000

run 5ns

force {KEY[1]} 0
run 5ns
force {KEY[1]} 1
run 5ns

# C <= 1
force {SW[7:0]} 11111010

run 5ns

force {KEY[1]} 0
run 5ns
force {KEY[1]} 1
run 5ns

# X <= 3
force {SW[7:0]} 01000000

run 5ns

force {KEY[1]} 0
run 5ns
force {KEY[1]} 1
run 15ns


# A = 10, B = 2, C = 16, X = 5

force {KEY[0]} 1
force {KEY[1]} 1
# A <= 4
force {SW[7:0]} 00001010

run 5ns

force {KEY[1]} 0
run 5ns
force {KEY[1]} 1
run 5ns

# B <= 2
force {SW[7:0]} 00000010

run 5ns

force {KEY[1]} 0
run 5ns
force {KEY[1]} 1
run 5ns

# C <= 1
force {SW[7:0]} 00010000

run 5ns

force {KEY[1]} 0
run 5ns
force {KEY[1]} 1
run 5ns

# X <= 3
force {SW[7:0]} 00000101

run 5ns

force {KEY[1]} 0
run 5ns
force {KEY[1]} 1
run 80ns  