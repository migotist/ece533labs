module pwm_generator #(parameter RESOLUTION = 12) (
	input wire hf_clock
,	input wire [RESOLUTION-1:0] highD
,	input wire [RESOLUTION-1:0] lowD
,	input wire [RESOLUTION-1:0] frequency_select

,	output wire HPWM
,	output wire LPWM
);

// WIRES
wire [RESOLUTION-1:0] highside_count;
wire [RESOLUTION-1:0] lowside_count;

// Frequency Select Calculations
wire [RESOLUTION-1] fs;
assign fs = {RESOLUTION{1'b1}} - frequency_select;

// Duty Cycle Saturation Checking
wire [RESOLUTION-1:0] sat_highD = (highD > fs) ? fs : highD;
wire [RESOLUTION-1:0] sat_lowD  = (lowD > fs)  ? fs : lowD;

// PWM Sawtooth Implementation
negative_counter #( .WIDTH(RESOLUTION) ) HIGH_PWM (
	.clk(hf_clock),
	.reset(fs == highside_count),
	.enable(1'b1),
	.count(highside_count)
);

negative_counter #( .WIDTH(RESOLUTION) ) LOW_PWM (
	.clk(hf_clock),
	.reset(fs == lowside_count),
	.enable(1'b1),
	.count(lowside_count)
);

// PWM Generation Based on Sawtooth
assign HPWM = sat_highD > highside_count;
assign LPWM = sat_lowD  < lowside_count;


endmodule
