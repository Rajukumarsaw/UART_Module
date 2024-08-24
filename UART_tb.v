module UART_TB;

reg clk;
reg reset;
reg tx_start;
reg [7:0] data_in;
wire tx_serial;
wire tx_done;
wire rx_done;
wire [7:0] data_out;
wire baud_rate_clk;
wire framing_error;

// Instantiate the Baud Rate Generator
Baud_Rate_Gen #(
    .CLOCK_RATE(50000000),  // 50 MHz system clock
    .BAUD_RATE(9600)        // 9600 bps
) baud_gen (
    .clk(clk),
    .reset(reset),
    .baud_rate_clk(baud_rate_clk)
);

// Instantiate the UART Transmitter
UART_TX #(
    .DATA_WIDTH(8),
    .STOP_BITS(1)
) tx (
    .clk(clk),
    .reset(reset),
    .tx_start(tx_start),
    .data_in(data_in),
    .baud_rate_clk(baud_rate_clk),
    .tx_serial(tx_serial),
    .tx_done(tx_done)
);

// Instantiate the UART Receiver
UART_RX #(
    .DATA_WIDTH(8),
    .STOP_BITS(1)
) rx (
    .clk(clk),
    .reset(reset),
    .rx_serial(tx_serial),
    .baud_rate_clk(baud_rate_clk),
    .data_out(data_out),
    .rx_done(rx_done),
    .framing_error(framing_error)
);

initial begin
    // Initialize signals
    clk = 0;
    reset = 1;
    tx_start = 0;
    data_in = 8'h00;
    
    #20 reset = 0;
    
    // Test case 1: Normal transmission
    #40 data_in = 8'hA5;
    tx_start = 1;
    #10 tx_start = 0;
    wait(rx_done);
    #100;
    if (data_out == 8'hA5 && !framing_error)
        $display("Test 1 Passed: Received Data = %h", data_out);
    else
        $display("Test 1 Failed: Received Data = %h, Framing Error = %b", data_out, framing_error);

    // Test case 2: Different data pattern
    #100 data_in = 8'h5A;
    tx_start = 1;
    #10 tx_start = 0;
    wait(rx_done);
    #100;
    if (data_out == 8'h5A && !framing_error)
        $display("Test 2 Passed: Received Data = %h", data_out);
    else
        $display("Test 2 Failed: Received Data = %h, Framing Error = %b", data_out, framing_error);

    $stop;
end

// Clock generation
always #5 clk = ~clk;

endmodule
