module UART_TX (
    input wire clk,        // System clock
    input wire reset,      // Reset signal
    input wire tx_start,   // Start transmission signal
    input wire [7:0] data_in, // 8-bit data to transmit
    input wire baud_rate_clk, // Baud rate clock
    output reg tx_serial,  // Serial output
    output reg tx_done     // Transmission complete flag
);

reg [3:0] bit_index;       // Tracks the current bit
reg [9:0] shift_reg;       // Shift register for data + start/stop bits
reg tx_busy;               // Busy flag

always @(posedge clk or posedge reset) begin
    if (reset) begin
        tx_serial <= 1'b1;  // Idle state (high)
        tx_done <= 1'b0;
        tx_busy <= 1'b0;
        bit_index <= 0;
    end else if (tx_start && !tx_busy) begin
        shift_reg <= {1'b1, data_in, 1'b0}; // Start bit + data + stop bit
        tx_busy <= 1'b1;
        bit_index <= 0;
        tx_done <= 1'b0;
    end else if (tx_busy) begin
        if (baud_rate_clk) begin
            tx_serial <= shift_reg[0];
            shift_reg <= shift_reg >> 1;
            bit_index <= bit_index + 1;
            if (bit_index == 9) begin
                tx_busy <= 1'b0;
                tx_done <= 1'b1;
            end
        end
    end
end
endmodule
