module UART_RX (
    input wire clk,        // System clock
    input wire reset,      // Reset signal
    input wire rx_serial,  // Serial input
    input wire baud_rate_clk, // Baud rate clock
    output reg [7:0] data_out, // 8-bit data output
    output reg rx_done     // Reception complete flag
);

reg [3:0] bit_index;       // Tracks the current bit
reg [9:0] shift_reg;       // Shift register for data + start/stop bits
reg rx_busy;               // Busy flag

always @(posedge clk or posedge reset) begin
    if (reset) begin
        bit_index <= 0;
        rx_done <= 1'b0;
        rx_busy <= 1'b0;
    end else if (!rx_busy && !rx_serial) begin
        rx_busy <= 1'b1;   // Start bit detected
        bit_index <= 0;
        rx_done <= 1'b0;
    end else if (rx_busy && baud_rate_clk) begin
        shift_reg <= {rx_serial, shift_reg[9:1]};
        bit_index <= bit_index + 1;
        if (bit_index == 9) begin
            rx_busy <= 1'b0;
            data_out <= shift_reg[8:1]; // Extract data bits
            rx_done <= 1'b1;
        end
    end
end
endmodule
