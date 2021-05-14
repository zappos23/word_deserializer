module deserializer #(
    // The width of the buffer pointers (addresses)
    parameter int POINTER_WIDTH = 8,
    // The width of the data in the buffer
    parameter int DATA_WIDTH = 8    
) (
    input logic sender_clock,
    input logic data_in_enable,
    input logic [DATA_WIDTH-1:0] data_in,
    output logic [POINTER_WIDTH-1:0] data_in_used,

    input logic receiver_clock,
    output logic [DATA_WIDTH-1:0] data_out [3:0],   // deserializer into 4 x 8bits of outputs from input 8bits

    output logic data_out_ready         // this will be high when the entire 4bytes of data ready
);

logic [DATA_WIDTH-1:0] fifo_data_out;
//logic [POINTER_WIDTH-1:0] data_in_used;     // This indicates number of available row can be read
logic data_out_acknowledge = 1'b0;     // to tell the fifo data has been read and move the read pointer to the next row

fifo #(.DATA_WIDTH(DATA_WIDTH), .POINTER_WIDTH(POINTER_WIDTH), .SENDER_DELAY_CHAIN_LENGTH(1)) deserializer_fifo(
    .sender_clock(sender_clock),
    .data_in_enable(data_in_enable),
    .data_in_used(data_in_used),
    .data_in(data_in),
    .receiver_clock(receiver_clock),
    .data_out_used(),
    .data_out_acknowledge(data_out_acknowledge),
    .data_out(fifo_data_out)
);

// unpack the 8bits from fifo into word size

logic [1:0] data_index = 2'd0;
logic [3:0] counter = 3'd0;

always @(posedge receiver_clock) begin
    if (data_in_used == 8'd5 || (counter > 3'd0 && counter <= 3'd2))
        data_out_acknowledge <= 1'b1;
    else
        data_out_acknowledge <= 1'b0;

    if (data_out_acknowledge == 1'b1)
        counter <= counter + 3'd1;          // 1 cycle after data_out_acknowledge is 1
    else
        counter <= 3'd0;

    if (counter >= 3'd1) begin
        data_out[data_index] <= fifo_data_out;
        data_index <= data_index + 2'd1;    
    end

end

always @(posedge receiver_clock) begin
    data_out_ready <= counter == 3'd4 ? 1'b1 : 1'b0;
end

endmodule
