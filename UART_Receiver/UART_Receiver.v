module UART_TX #(
    parameter DATA_WIDTH = 8,
    parameter STOP_BITS = 1
)(
    input wire clk,
    input wire reset,
    input wire tx_start,
    input wire [DATA_WIDTH-1:0] data_in,
    input wire baud_rate_clk,
    output reg tx_serial,
    output reg tx_done
);

reg [3:0] bit_index;
reg [DATA_WIDTH+STOP_BITS:0] shift_reg;
reg tx_busy;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        tx_serial <= 1'b1;
        tx_done <= 1'b0;
        tx_busy <= 1'b0;
        bit_index <= 0;
    end else if (tx_start && !tx_busy) begin
        shift_reg <= {{{STOP_BITS{1'b1}}, data_in, 1'b0}}; // Start bit + data + stop bit(s)
        tx_busy <= 1'b1;
        bit_index <= 0;
        tx_done <= 1'b0;
    end else if (tx_busy && baud_rate_clk) begin
        tx_serial <= shift_reg[0];
        shift_reg <= shift_reg >> 1;
        bit_index <= bit_index + 1;
        if (bit_index == DATA_WIDTH + STOP_BITS) begin
            tx_busy <= 1'b0;
            tx_done <= 1'b1;
        end
    end
end

endmodule
