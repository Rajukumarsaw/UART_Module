module Baud_Rate_Gen #(
    parameter CLOCK_RATE = 50000000,  // Default: 50 MHz system clock
    parameter BAUD_RATE = 9600        // Default: 9600 bps
)(
    input wire clk,              // System clock input
    input wire reset,            // Reset signal
    output reg baud_rate_clk     // Baud rate clock output
);

    localparam DIVIDER = CLOCK_RATE / (2 * BAUD_RATE) - 1;
    reg [$clog2(DIVIDER)-1:0] counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            baud_rate_clk <= 0;
        end else begin
            if (counter == DIVIDER) begin
                counter <= 0;
                baud_rate_clk <= ~baud_rate_clk;
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule