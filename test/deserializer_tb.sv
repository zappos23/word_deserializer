module deserializer_tb();

timeunit 1ps;
timeprecision 1ps;

initial
	begin
		// Required to dump signals to EPWave
		$dumpfile("deserializer_tb.vcd");
		$dumpvars(0);

        #100us; $finish;
	end

logic sender_clock = 0;
always
begin
    //#3969ps; sender_clock = 1;
    #1ns; sender_clock = 1;
    //#3969ps; sender_clock = 0;
    #1ns; sender_clock = 0;
end

logic receiver_clock = 0;
always
begin
    //#3969ps; receiver_clock = 1;
    #1ns; receiver_clock = 1;
    //#3969ps; receiver_clock = 0;
    #1ns; receiver_clock = 0;
    // #20833333ps; receiver_clock = 1;
    // #20833333ps; receiver_clock = 0;
end


localparam int DATA_WIDTH = 8;
localparam int POINTER_WIDTH = 8; // 2**8 = 256

logic data_in_enable = 0;
always
begin
    #1001ns; data_in_enable =1;
    #1ns; data_in_enable =0;
end
logic [POINTER_WIDTH-1:0] data_in_used;
logic [DATA_WIDTH-1:0] data_in = DATA_WIDTH'(0);

logic data_out_ready;
logic [DATA_WIDTH-1:0] data_out [3:0];

deserializer #(.DATA_WIDTH(DATA_WIDTH), .POINTER_WIDTH(POINTER_WIDTH)) deserializer(
    .sender_clock(sender_clock),
    .data_in_enable(data_in_enable),
    .data_in_used(data_in_used),
    .data_in(data_in),

    .receiver_clock(receiver_clock),
    .data_out_ready(data_out_ready),
    .data_out(data_out)
);

//assign data_in_enable = data_in_used < 2**POINTER_WIDTH - 1;
//logic [DATA_WIDTH-1:0] data_in_last = 0;
//assign data_in = data_in_last + (data_in_enable ? 1'b1 : 1'b0);
always_ff @(posedge sender_clock)
    if (data_in_enable)
        data_in <= data_in + 1'b1;

logic [DATA_WIDTH-1:0] last_data_out0 = {8'd0};
logic [DATA_WIDTH-1:0] last_data_out1 = {8'd0};
logic [DATA_WIDTH-1:0] last_data_out2 = {8'd0};
logic [DATA_WIDTH-1:0] last_data_out3 = {8'd0};
logic [31:0] last_data_out;

assign last_data_out = {data_out[3], data_out[2], data_out[1], data_out[0]};

always_ff @(posedge receiver_clock)
begin
    if (data_out_ready)
    begin
        last_data_out0 <= data_out[0];
        last_data_out1 <= data_out[1];
        last_data_out2 <= data_out[2];
        last_data_out3 <= data_out[3];
        //assert (last_data_out[3] + 1'd1 == data_out[3]) else $fatal(1, "%d + 1 != %d", last_data_out[3], data_out[3]);
        //if (data_out[3] == 1)
        //    $finish;
    end
end

endmodule
